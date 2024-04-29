--------------------------------------------------------
--  DDL for Package Body PER_PCL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PCL_BUS" as
/* $Header: pepclrhi.pkb 115.9 2002/12/09 15:33:43 pkakar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pcl_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_cagr_entitlement_line_id    number         default null;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_for_correct_type >-----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_dates_are_valid
  (p_cagr_entitlement_item_id IN per_cagr_entitlements.cagr_entitlement_item_id%TYPE
  ,p_value                    IN per_cagr_entitlement_lines_f.value%TYPE
  ,p_range_from               IN per_cagr_entitlement_lines_f.range_from%TYPE
  ,p_range_to                 IN per_cagr_entitlement_lines_f.range_to%TYPE
  ,p_effective_date           IN DATE) IS
  --
  l_proc            VARCHAR2(72) := g_package||'check_dates_are_valid';
  l_column_type     per_cagr_entitlement_items.column_type%TYPE;
  l_value_date      DATE;
  l_range_to_date   DATE;
  l_range_from_date DATE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_column_type := per_cagr_utility_pkg.get_column_type
                     (p_cagr_entitlement_item_id => p_cagr_entitlement_item_id
					 ,p_effective_date           => p_effective_date);
  --
  -- Only check the fields is for entitlement items
  -- that have been defined as a DATE type.
  --
  IF l_column_type = 'DATE' THEN
    --
	hr_utility.set_location(l_proc, 20);
	--
	-- Convert paramters to date format for comparison
	--
	l_value_date      := p_value;
	l_range_from_date := p_range_from;
	l_range_to_date   := p_range_to;
    --
    hr_utility.set_location(l_proc||' / '||l_value_Date,25);
    hr_utility.set_location(l_proc||' / '||l_range_from_Date,26);
    hr_utility.set_location(l_proc||' / '||l_range_to_Date,27);
    --
    -- Check to ensure that the value date is within
    -- the range_from and range_to dates.
    --
    IF l_value_date < l_range_from_date OR
       l_value_date > l_range_to_date THEN
      --
 	  hr_utility.set_message(800, 'HR_289331_DATE_NOT_IN_RANGE');
	  hr_utility.raise_error;
    --
    -- Ensure that the range_from date is
    -- not later than the range_to date.
    --
    ELSIF l_range_from_date > l_range_to_date THEN
      --
	  hr_utility.set_message(800, 'HR_289332_FROM_DT_AFTER_TO_DT');
	  hr_utility.raise_error;
    --
    -- Ensure that the range_to date is
    -- not before the range_from date
    --
    ELSIF l_range_to_date < l_range_from_date THEN
      --
	  hr_utility.set_message(800, 'HR_289333_TO_DT_BEFORE_FROM_DT');
	  hr_utility.raise_error;
	  --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 999);
  --
END chk_dates_are_valid;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_for_correct_type >-----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE check_for_correct_type
  (p_cagr_entitlement_item_id IN     NUMBER
  ,p_value                    IN OUT NOCOPY VARCHAR2
  ,p_business_group_id        IN     NUMBER
  ,p_effective_date           IN     DATE) IS
  --
  -- Delcare Local Variables
  --
  l_proc        VARCHAR2(72) := g_package||'check_for_correct_type';
  l_column_type per_cagr_entitlement_items.column_type%TYPE;
  l_column_size per_cagr_entitlement_items.column_size%TYPE;
  l_number      NUMBER;
  l_date        DATE;
  l_value       VARCHAR2(255);
  l_output      VARCHAR2(255);
  l_rgeflg      VARCHAR2(255);
  l_ccy_code    per_business_groups.currency_code%TYPE;
  size_error    EXCEPTION;
  --
  CURSOR csr_get_ccy_code IS
    SELECT currency_code
	  FROM per_business_groups
	 WHERE business_group_id = p_business_group_id;
  --
  CURSOR csr_get_item_size IS
    SELECT cap.column_size
	FROM   per_cagr_api_parameters cap,
	       per_cagr_entitlement_items cei
    WHERE  cap.cagr_api_param_id = cei.cagr_api_param_id
	AND    cei.cagr_entitlement_item_id = p_cagr_entitlement_item_id;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_column_type := per_cagr_utility_pkg.get_column_type
                     (p_cagr_entitlement_item_id => p_cagr_entitlement_item_id
					 ,p_effective_date           => p_effective_date);
  --
  IF l_column_type = 'NUM' THEN
    --
	hr_utility.set_location(l_proc, 20);
	--
    l_number := p_value;
    --
	hr_utility.set_location(l_proc, 30);
	--
	-- Check that the column size for the number
	-- fields is not greater than the size seeded
	-- for that api parameter
	--
	BEGIN
	  --
	  OPEN csr_get_item_size;
	  FETCH csr_get_item_size INTO l_column_size;
	  --
	  CLOSE csr_get_item_size;
	  --
      hr_utility.set_location(l_proc, 40);
	  --
  	  IF LENGTH(p_value) > l_column_size  THEN
	    --
		RAISE size_error;
	    --
	  END IF;
	  --
	  EXCEPTION
	    --
	    WHEN size_error THEN
	      RAISE;
	END;
    --
  ELSIF l_column_type = 'DATE' THEN
    --
	hr_utility.set_location(l_proc, 50);
	--
    l_date := p_value;
	--
  ELSIF l_column_type = 'VAR' THEN
    --
	hr_utility.set_location(l_proc, 60);
	--
    l_value := p_value;
	--
  ELSE
    --
	hr_utility.set_location(l_proc, 70);
	--
	l_value := p_value;
	--
	OPEN  csr_get_ccy_code;
	FETCH csr_get_ccy_code INTO l_ccy_code;
	CLOSE csr_get_ccy_code;
	--
	hr_utility.set_location(l_proc, 80);
	--
	hr_chkfmt.checkformat
      (value   => l_value
      ,format  => l_column_type
      ,output  => l_output
      ,minimum => NULL
      ,maximum => NULL
      ,nullok  => NULL
      ,rgeflg  => l_rgeflg
      ,curcode => l_ccy_code);
	--
	p_value := l_value;
	--
  END IF;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 999);
  --
EXCEPTION
  --
  WHEN size_error THEN
    --
	fnd_message.set_name('PER','HR_289588_VALUE_SIZE_TOO_LONG');
    fnd_message.raise_error;
	--
  WHEN OTHERS THEN
    --
    IF l_column_type = 'DATE' THEN
      --
      fnd_message.set_name('PER','HR_289328_ENT_ITEM_NOT_A_DATE');
      fnd_message.raise_error;
      --
    ELSIF l_column_type = 'NUM' THEN
      --
      fnd_message.set_name('PER','HR_289326_ENT_ITEM_NOT_A_NUM');
      fnd_message.raise_error;
      --
	ELSE
	  --
      fnd_message.set_name('PER','HR_289473_INVALID_VALUE');
      fnd_message.raise_error;
      --
    END IF;
    --
    RAISE;
    --
END check_for_correct_type;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_cagr_entitlement_line_id             in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_cagr_entitlement_lines_f pcl
     	 , per_cagr_entitlements pce
    	 , per_cagr_entitlement_items pci

     where pcl.cagr_entitlement_line_id    =  p_cagr_entitlement_line_id
	and   pcl.cagr_entitlement_id 	   =  pce.cagr_entitlement_id
	and   pce.cagr_entitlement_item_id =  pci.cagr_entitlement_item_id
	and   pbg.business_group_id	   =  pci.business_group_id   ;

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
    ,p_argument           => 'cagr_entitlement_line_id'
    ,p_argument_value     => p_cagr_entitlement_line_id
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
  (p_cagr_entitlement_line_id             in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --

  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , per_cagr_entitlement_lines_f pcl
     	 , per_cagr_entitlements pce
	 , per_cagr_entitlement_items pci

     where pcl.cagr_entitlement_line_id    =  p_cagr_entitlement_line_id
	and   pcl.cagr_entitlement_id 	   =  pce.cagr_entitlement_id
	and   pce.cagr_entitlement_item_id =  pci.cagr_entitlement_item_id
	and   pbg.business_group_id	   =  pci.business_group_id   ;


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
    ,p_argument           => 'cagr_entitlement_line_id'
    ,p_argument_value     => p_cagr_entitlement_line_id
    );
  --
  if ( nvl(per_pcl_bus.g_cagr_entitlement_line_id, hr_api.g_number)
       = p_cagr_entitlement_line_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_pcl_bus.g_legislation_code;
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
    per_pcl_bus.g_cagr_entitlement_line_id    := p_cagr_entitlement_line_id;
    per_pcl_bus.g_legislation_code  := l_legislation_code;
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
  (p_effective_date  in date
  ,p_rec             in per_pcl_shd.g_rec_type
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
  IF NOT per_pcl_shd.api_updating
      (p_cagr_entitlement_line_id         => p_rec.cagr_entitlement_line_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;


  IF nvl(p_rec.cagr_entitlement_id, hr_api.g_number) <>
     nvl(per_pcl_shd.g_old_rec.cagr_entitlement_id,hr_api.g_number) THEN
    --
    l_argument := 'cagr_entitlement_id';
    RAISE l_error;
    --
  END IF;

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
--  |---------------------------< chk_mandatory >-----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that on insert and update mandatory is not null and that
--    it is validated against hr_lookups.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_mandatory
--    p_effective_date
--    p_cagr_entitlement_line_id
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
PROCEDURE chk_mandatory
  ( p_mandatory                IN per_cagr_entitlement_lines_f.mandatory%TYPE
   ,p_cagr_entitlement_line_id IN per_cagr_entitlement_lines_f.cagr_entitlement_line_id%TYPE
   ,p_effective_date           IN DATE
   ,p_validation_start_date    IN DATE
   ,p_validation_end_date      IN DATE) IS

  --
  l_proc     VARCHAR2(72) := g_package || 'chk_mandatory';
  l_dummy    VARCHAR2(1);
  --

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory is not null
  --
  IF p_mandatory IS NULL THEN
    --
    hr_utility.set_message(800, 'HR_289281_MANDATORY_NULL');
    hr_utility.raise_error;
    --
  END IF;
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for mandatory has changed
  --
  IF ( (p_cagr_entitlement_line_id IS NULL) OR
       ((p_cagr_entitlement_line_id IS NOT NULL) AND
        (per_pcl_shd.g_old_rec.mandatory <> p_mandatory))) THEN
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- Check that the type exists in HR_LOOKUPS
    --
    IF hr_api.not_exists_in_dt_hr_lookups
      (p_effective_date        => p_effective_date
      ,p_lookup_type           => 'YES_NO'
      ,p_lookup_code           => p_mandatory
      ,p_validation_start_date => p_validation_start_date
      ,p_validation_end_date   => p_validation_end_date) THEN
      --
      hr_utility.set_location(l_proc, 30);
      --
      hr_utility.set_message(800, 'HR_289282_MANDATORY_INVALID');
      hr_utility.raise_error;
      --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving '||l_proc, 40);
  --
  --
END chk_mandatory;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_values >--------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that value stored in the value field is correct. This is
--    achieved by checking the following:
--
--    1).  If the entitlement item has been defined with a value set
--         then the value column will contain an ID. Therefore we must
--         check that this ID exists as the primary key to the table
--         defined in the value set.
--
--    2).  Enusre that the value in the value column matches the type
--         defined for the entitlement item. For example if the entitlement
--         item has been defined as a NUMBER then the value column
--         must be a number.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_value
--    p_range_from
--    p_range_to
--    p_cagr_entitlement_item_id
--    p_cagr_entitlement_line_id
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
PROCEDURE chk_value
  (p_value                    IN per_cagr_entitlement_lines_f.value%TYPE
  ,p_cagr_entitlement_line_id IN per_cagr_entitlement_lines_f.cagr_entitlement_line_id%TYPE
  ,p_cagr_entitlement_item_id IN per_cagr_entitlement_items.cagr_entitlement_item_id%TYPE
  ,p_cagr_entitlement_id      IN per_cagr_entitlements.cagr_entitlement_id%TYPE
  ,p_category_name            IN VARCHAR2
  ,p_effective_date           IN DATE) IS
  --
  -- Declare Local Variables
  --
  l_proc                     VARCHAR2(72) := g_package || 'chk_values';
  l_flex_value_set_id        per_cagr_entitlement_items.flex_value_set_id%TYPE;
  l_value_desc               VARCHAR2(2000);
  l_non_value_category       BOOLEAN;
  l_value                    per_cagr_entitlement_lines_f.value%TYPE;
  l_formatted_value          VARCHAR2(2000);
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory parameters has been set
  --
  hr_api.mandatory_arg_error
    (p_api_name	      => l_proc
    ,p_argument	      => 'CAGR_ENTITLEMENT_ITEM_ID'
    ,p_argument_value => p_cagr_entitlement_item_id);
  --
  -- Function to see if the value field is supported
  -- by the category name passed in.
  --
  l_non_value_category := per_pcl_shd.non_value_category
                            (p_category_name => p_category_name);
  --
  -- If the value field has been populated for a category
  -- that does not use the value field then raise an error.
  --
  IF p_value IS NOT NULL AND l_non_value_category THEN
    --
	hr_utility.set_message(800, 'HR_289346_VALUE_IS_NOT_NULL');
	hr_utility.raise_error;
  --
  -- Only validate if the value is populated and
  -- the category is not a category for which the value
  -- should not be populated (eg. Process).
  --
  ELSIF p_value IS NOT NULL AND NOT l_non_value_category THEN
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- Check value has been populated as it should
	-- now contain a value.
    --
    hr_api.mandatory_arg_error
      (p_api_name	      => l_proc
      ,p_argument	      => 'VALUE'
      ,p_argument_value => p_value);
    --
    -- Only proceed with validation if :
    -- a) Inserting or
    -- b) The value for value has changed
    --
    IF ( (p_cagr_entitlement_line_id  IS NULL) OR
         ((p_cagr_entitlement_line_id IS NOT NULL) AND
          (per_pcl_shd.g_old_rec.value <> p_value))) THEN
      --
	  hr_utility.set_location(l_proc,30);
      --
      -- Fetch the flex_value_set_id if one has
      -- been set for the entitlement item
      --
      l_flex_value_set_id := per_pcl_shd.retrieve_value_set_id
        (p_cagr_entitlement_item_id => p_cagr_entitlement_item_id);
	  --
      hr_utility.set_location(l_proc, 40);
      --
      -- If the entitlement item does not have
      -- a value set stored against it then
      -- just check that the value is of the
      -- correct type for the entitlement item
      --
      IF l_flex_value_set_id IS NULL THEN
        --
	    hr_utility.set_location(l_proc,50);
		--
		l_value := p_value;
	    --
	    -- Check that the value is of the correct
	    -- type for the entitlement item
	    --
        per_pcl_bus.check_for_correct_type
          (p_cagr_entitlement_item_id => p_cagr_entitlement_item_id
          ,p_value                    => l_value
		  ,p_business_group_id        => 0
		  ,p_effective_date           => p_effective_date);
      --
      -- The entitlement item has a value set stored against it,
      -- so ensure that the value field (which will contain an
      -- id) contents are valid for the value set.
      --
      ELSIF l_flex_value_set_id IS NOT NULL THEN
        --
	    hr_utility.set_location(l_proc,60);
	    --
	    -- Fetch the value description from the value set
	    -- for the value content (which will be a fk).
	    --
	    l_value_desc := per_cagr_utility_pkg.get_name_from_value_set
                          (p_cagr_entitlement_id => p_cagr_entitlement_id
                          ,p_value               => p_value);
        --
	    hr_utility.set_location(l_proc,70);
	    --
	    -- If the value_desc is null then this means that
	    -- the value field is invalid, so raise an error.
	    --
        IF l_value_desc IS NULL THEN
	      --
          hr_utility.set_message(800, 'HR_289283_VALUE_INVALID');
	      hr_utility.raise_error;
	      --
	    END IF;
	    --
      END IF;
	  --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving: '||l_proc,999);
  --
END chk_value;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_range_from >------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that value stored in the range_to field is correct. This is
--    achieved by checking the following:
--
--    1).  If the entitlement item has been defined with a value set
--         then the range_from column will contain an ID. Therefore we must
--         check that this ID exists as the primary key to the table
--         defined in the value set.
--
--    2).  Enusre that the value in the range_from column matches the type
--         defined for the entitlement item. For example if the entitlement
--         item has been defined as a NUMBER then the range_from column
--         must be a number.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_range_from
--    p_cagr_entitlement_item_id
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
PROCEDURE chk_range_from
  (p_range_from               IN per_cagr_entitlement_lines_f.range_from%TYPE
  ,p_cagr_entitlement_line_id IN per_cagr_entitlement_lines_f.cagr_entitlement_line_id%TYPE
  ,p_cagr_entitlement_item_id IN per_cagr_entitlement_items.cagr_entitlement_item_id%TYPE
  ,p_category_name            IN VARCHAR2
  ,p_effective_date           IN DATE) IS
  --
  -- Declare Local Variables
  --
  l_proc               VARCHAR2(72) := g_package || 'chk_range_from';
  l_flex_value_set_id  per_cagr_entitlement_items.flex_value_set_id%TYPE;
  l_range_from_desc    VARCHAR2(2000);
  l_range_from         per_cagr_entitlement_lines_f.range_to%TYPE;
  l_non_value_category BOOLEAN;
  l_formatted_value    VARCHAR2(2000);
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory parameters has been set
  --
  hr_api.mandatory_arg_error
    (p_api_name	      => l_proc
    ,p_argument	      => 'CAGR_ENTITLEMENT_ITEM_ID'
    ,p_argument_value => p_cagr_entitlement_item_id);
  --
  -- Function to see if the range_from field is supported
  -- by the category name passed in.
  --
  l_non_value_category := per_pcl_shd.non_value_category
                            (p_category_name => p_category_name);
  --
  -- If the range_from field has been populated for a category
  -- that does not use the range_from field then raise an error.
  --
  IF p_range_from IS NOT NULL AND l_non_value_category THEN
    --
	hr_utility.set_message(800, 'HR_289347_RANGE_FROM_POPULATED');
	hr_utility.raise_error;
  --
  -- Only validate if the range_from is populated and
  -- the category is not a category for which the range_from
  -- should not be populated (eg. Process).
  --
  ELSIF p_range_from IS NOT NULL AND NOT l_non_value_category THEN
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- Only proceed with validation if :
    -- a) Inserting or
    -- b) The value for range_from has changed
    --
    IF ( (p_cagr_entitlement_line_id IS NULL) OR
         ((p_cagr_entitlement_line_id IS NOT NULL) AND
          (per_pcl_shd.g_old_rec.range_from <> p_range_from)))THEN
      --
	  hr_utility.set_location(l_proc,30);
      --
      -- Fetch the flex_value_set_id if one has
      -- been set for the entitlement item
      --
      l_flex_value_set_id := per_pcl_shd.retrieve_value_set_id
        (p_cagr_entitlement_item_id => p_cagr_entitlement_item_id);
	  --
      hr_utility.set_location(l_proc, 40);
      --
      -- If the entitlement item does not have
      -- a value set stored against it then
      -- just check that the value is of the
      -- correct type for the entitlement item
      --
      IF l_flex_value_set_id IS NULL THEN
        --
	    hr_utility.set_location(l_proc,50);
		--
		l_range_from := p_range_from;
	    --
	    -- Check that the value is of the correct
	    -- type for the entitlement item
	    --
        per_pcl_bus.check_for_correct_type
          (p_cagr_entitlement_item_id => p_cagr_entitlement_item_id
          ,p_value                    => l_range_from
		  ,p_business_group_id        => 0
		  ,p_effective_date           => p_effective_date);
      --
      -- The entitlement item has a value set stored against it,
      -- so ensure that the value field (which will contain an
      -- id) contents are valid for the value set.
      --
      ELSIF l_flex_value_set_id IS NOT NULL THEN
        --
	    hr_utility.set_location(l_proc,60);
	    --
	    -- Fetch the value description from the value set
	    -- for the value content (which will be a fk).
	    --
	    l_range_from_desc := per_cagr_utility_pkg.get_name_from_value_set
                               (p_cagr_entitlement_id => p_cagr_entitlement_item_id
                               ,p_value               => p_range_from);
        --
	    hr_utility.set_location(l_proc,70);
	    --
	    -- If the value_desc is null then this means that
	    -- the value field is invalid, so raise an error.
	    --
        IF l_range_from_desc IS NULL THEN
	      --
          hr_utility.set_message(800, 'HR_289284_RANGE_FROM_INVALID');
	      hr_utility.raise_error;
	      --
	    END IF;
	    --
      END IF;
	  --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving: '||l_proc,999);
  --
END chk_range_from;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_range_to >-------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that value stored in the range_to field is correct. This is
--    achieved by checking the following:
--
--    1).  If the entitlement item has been defined with a value set
--         then the range_to column will contain an ID. Therefore we must
--         check that this ID exists as the primary key to the table
--         defined in the value set.
--
--    2).  Enusre that the value in the range_to column matches the type
--         defined for the entitlement item. For example if the entitlement
--         item has been defined as a NUMBER then the range_to column
--         must be a number.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_range_to
--    p_cagr_entitlement_item_id
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
PROCEDURE chk_range_to
  (p_range_to                 IN per_cagr_entitlement_lines_f.range_to%TYPE
  ,p_cagr_entitlement_line_id IN per_cagr_entitlement_lines_f.cagr_entitlement_line_id%TYPE
  ,p_cagr_entitlement_item_id IN per_cagr_entitlement_items.cagr_entitlement_item_id%TYPE
  ,p_category_name            IN VARCHAR2
  ,p_effective_date           IN DATE) IS
  --
  -- Declare Local Variables
  --
  l_proc               VARCHAR2(72) := g_package || 'chk_range_to';
  l_flex_value_set_id  per_cagr_entitlement_items.flex_value_set_id%TYPE;
  l_range_to_desc      VARCHAR2(2000);
  l_range_to           per_cagr_entitlement_lines_f.range_to%TYPE;
  l_non_value_category BOOLEAN;
  l_formatted_value    VARCHAR2(2000);
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory parameters has been set
  --
  hr_api.mandatory_arg_error
    (p_api_name	      => l_proc
    ,p_argument	      => 'CAGR_ENTITLEMENT_ITEM_ID'
    ,p_argument_value => p_cagr_entitlement_item_id);
 --
  -- Function to see if the range_to field is supported
  -- by the category name passed in.
  --
  l_non_value_category := per_pcl_shd.non_value_category
                            (p_category_name => p_category_name);
  --
  -- If the range_to field has been populated for a category
  -- that does not use the range_to field then raise an error.
  --
  IF p_range_to IS NOT NULL AND l_non_value_category THEN
    --
	hr_utility.set_message(800, 'HR_289348_RANGE_TO_POPULATED');
	hr_utility.raise_error;
    --
    -- Only validate if the range_to is populated and
    -- the category is not a category for which the range_to
    -- should not be populated (eg. Process).
    --
  ELSIF p_range_to IS NOT NULL AND NOT l_non_value_category THEN
    --
    hr_utility.set_location(l_proc, 20);
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- Only proceed with validation if :
    -- a) Inserting or
    -- b) The value for range_to has changed
    --
    IF ( (p_cagr_entitlement_line_id IS NULL) OR
         ((p_cagr_entitlement_line_id IS NOT NULL) AND
          (per_pcl_shd.g_old_rec.range_to <> p_range_to))) THEN
      --
	  hr_utility.set_location(l_proc,30);
      --
      -- Fetch the flex_value_set_id if one has
      -- been set for the entitlement item
      --
      l_flex_value_set_id := per_pcl_shd.retrieve_value_set_id
        (p_cagr_entitlement_item_id => p_cagr_entitlement_item_id);
	  --
      hr_utility.set_location(l_proc, 40);
      --
      -- If the entitlement item does not have
      -- a value set stored against it then
      -- just check that the value is of the
      -- correct type for the entitlement item
      --
      IF l_flex_value_set_id IS NULL THEN
        --
	    hr_utility.set_location(l_proc,50);
		--
		l_range_to := p_range_to;
	    --
	    -- Check that the value is of the correct
	    -- type for the entitlement item
	    --
        per_pcl_bus.check_for_correct_type
          (p_cagr_entitlement_item_id => p_cagr_entitlement_item_id
          ,p_value                    => l_range_to
		  ,p_business_group_id        => 0
		  ,p_effective_date           => p_effective_date);
        --
        -- The entitlement item has a value set stored against it,
        -- so ensure that the value field (which will contain an
        -- id) contents are valid for the value set.
        --
      ELSIF l_flex_value_set_id IS NOT NULL THEN
        --
	    hr_utility.set_location(l_proc,60);
	    --
	    -- Fetch the value description from the value set
	    -- for the value content (which will be a fk).
	    --
	    l_range_to_desc := per_cagr_utility_pkg.get_name_from_value_set
                             (p_cagr_entitlement_id => p_cagr_entitlement_item_id
                             ,p_value               => p_range_to);
        --
	    hr_utility.set_location(l_proc,70);
	    --
	    -- If the value_desc is null then this means that
	    -- the value field is invalid, so raise an error.
	    --
        IF l_range_to_desc IS NULL THEN
	      --
          hr_utility.set_message(800, 'HR_289285_RANGE_TO_INVALID');
	      hr_utility.raise_error;
	      --
	    END IF;
	    --
      END IF;
	  --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving: '||l_proc,999);
  --
END chk_range_to;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_grade_spine_id >------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that on insert and update  grade_spine_id,parent_spine_id,step_id
--      are not null WHEN category is pay scale.
--      grade_spine_id should be refrenced from per_grade_spines_f.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_grade_spine_id
--    p_effective_date
--    p_cagr_entitlement_line_id
--    p_cagr_entitlement_id
--    p_validation_start_date
--    p_validation_end_date
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
PROCEDURE chk_grade_spine_id
  ( p_grade_spine_id      IN per_cagr_entitlement_lines_f.grade_spine_id%TYPE
   ,p_cagr_entitlement_line_id IN per_cagr_entitlement_lines_f.cagr_entitlement_line_id%TYPE
   ,p_cagr_entitlement_id IN per_cagr_entitlement_lines_f.cagr_entitlement_id%TYPE
   ,p_effective_date    IN DATE
   ,p_validation_start_date IN DATE
   ,p_validation_end_date IN DATE) IS

CURSOR csr_chk_category IS
   SELECT  category_name
     FROM  per_cagr_entitlement_items pci
          ,per_cagr_entitlements      pce
    WHERE  pci.CAGR_ENTITLEMENT_ITEM_ID = pce.CAGR_ENTITLEMENT_ITEM_ID
      AND  pce.CAGR_ENTITLEMENT_ID      = p_CAGR_ENTITLEMENT_ID;


CURSOR csr_chk_grd_fk_start IS
    SELECT  'Y'
      FROM  per_grade_spines_f  pgs
     WHERE  pgs.grade_spine_id = p_grade_spine_id
       AND  p_validation_start_date between pgs.effective_start_date and pgs.effective_end_date ;


CURSOR csr_chk_grd_fk_end IS
    SELECT  'Y'
      FROM  per_grade_spines_f  pgs
     WHERE  pgs.grade_spine_id = p_grade_spine_id
       AND  p_validation_end_date between pgs.effective_start_date and pgs.effective_end_date ;


 --
  l_proc     VARCHAR2(72) := g_package || 'chk_grade_spine_id';
  l_cat      per_cagr_entitlement_items.category_name%TYPE;
  l_grd      VARCHAR2(1);
  --

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check category is pay scales

  OPEN  csr_chk_category;
  FETCH csr_chk_category INTO l_cat;

  hr_utility.set_location(l_proc,20);

  IF (l_cat = 'PYS') then

    -- Check if  parent_spine_id is not null

       hr_api.mandatory_arg_error
	    (p_api_name	=> l_proc
	    ,p_argument	=> 'grade_spine_id'
	    ,p_argument_value => p_grade_spine_id);

       hr_utility.set_location('Leaving:'||l_proc, 30);

    -- check while inserting or updating grade_spine_id

    IF ((p_cagr_entitlement_line_id IS NULL) OR
       ((p_cagr_entitlement_line_id IS NOT NULL) AND
        (per_pcl_shd.g_old_rec.grade_spine_id <> p_grade_spine_id))) THEN

      	hr_utility.set_location('Leaving:'||l_proc, 40);

    	OPEN  csr_chk_grd_fk_start;
	FETCH csr_chk_grd_fk_start INTO l_grd;

    	IF csr_chk_grd_fk_start%NOTFOUND THEN
           hr_utility.set_location(l_proc,50);
           CLOSE csr_chk_grd_fk_start;
    	   hr_utility.set_message(800, 'HR_289287_GRD_EFFECTIVE_DT_INV');
    	   hr_utility.raise_error;
    	END IF;

    	CLOSE csr_chk_grd_fk_start;
    	hr_utility.set_location(l_proc,60);

    	OPEN  csr_chk_grd_fk_end;
    	FETCH csr_chk_grd_fk_end INTO l_grd;

    	IF csr_chk_grd_fk_end%NOTFOUND THEN
            hr_utility.set_location(l_proc,70);
            CLOSE csr_chk_grd_fk_end;
    	    hr_utility.set_message(800, 'HR_289287_GRD_EFFECTIVE_DT_INV');
            hr_utility.raise_error;
    	END IF;

    	CLOSE csr_chk_grd_fk_end;
    	hr_utility.set_location(l_proc,80);

     END IF;




  END IF;


        CLOSE csr_chk_category;
        hr_utility.set_location(l_proc,100);
        --

END chk_grade_spine_id;



--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_parent_spine_id >------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate parent_spine_id is refrenced from per_parent_spines_f.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_parent_spine_id
--    p_cage_entitlement_line_id
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
PROCEDURE chk_parent_spine_id
  ( p_parent_spine_id           IN per_cagr_entitlement_lines_f.parent_spine_id%TYPE
   ,p_cagr_entitlement_line_id  IN
                              per_cagr_entitlement_lines_f.cagr_entitlement_line_id%TYPE
   ,p_cagr_entitlement_id       IN per_cagr_entitlement_lines_f.cagr_entitlement_id%TYPE ) IS
  --

  CURSOR csr_chk_category IS
    SELECT  category_name
      FROM  per_cagr_entitlement_items pci
           ,per_cagr_entitlements      pce
     WHERE  pci.CAGR_ENTITLEMENT_ITEM_ID = pce.CAGR_ENTITLEMENT_ITEM_ID
       AND  pce.CAGR_ENTITLEMENT_ID      = p_CAGR_ENTITLEMENT_ID;

  --
    CURSOR csr_chk_parent_spine_fk IS
    SELECT 'Y'
      FROM per_parent_spines  pps
     WHERE pps.parent_spine_id = p_parent_spine_id;
  --
  l_proc     VARCHAR2(72) := g_package || 'chk_parent_spine_id';
  l_dummy    VARCHAR2(1);
  l_cat      per_cagr_entitlement_items.category_name%TYPE;
  --
BEGIN
   --
   hr_utility.set_location('Entering:'||l_proc, 10);

   -- Check category is pay scales

   OPEN  csr_chk_category;
   FETCH csr_chk_category INTO l_cat;
   --
   hr_utility.set_location(l_proc,20);

   IF (l_cat = 'PYS') then

       -- Check if  parent_spine_id is not null

       hr_api.mandatory_arg_error
  	    (p_api_name	=> l_proc
  	    ,p_argument	=> 'parent_spine_id'
  	    ,p_argument_value => p_parent_spine_id);

       hr_utility.set_location('Leaving:'||l_proc, 30);

        --
        -- check while inserting or updating parent_spine_id
	--

       IF ((p_cagr_entitlement_line_id IS NULL) OR
          ((p_cagr_entitlement_line_id IS NOT NULL) AND
           (per_pcl_shd.g_old_rec.parent_spine_id <> p_parent_spine_id))) THEN


	     hr_utility.set_location(l_proc,40);
	     OPEN  csr_chk_parent_spine_fk;
             FETCH csr_chk_parent_spine_fk INTO l_dummy;
	     hr_utility.set_location(l_proc,50);

   	     IF csr_chk_parent_spine_fk%NOTFOUND THEN

                hr_utility.set_location(l_proc,60);
                CLOSE csr_chk_parent_spine_fk;
    	        hr_utility.set_message(800, 'HR_289286_PARENT_SPINE_INVALID');
    	        hr_utility.raise_error;

             END IF;

      	     CLOSE csr_chk_parent_spine_fk;
	     hr_utility.set_location(l_proc,70);

         END IF;

     END IF;
     --
     hr_utility.set_location('Leaving: '||l_proc,100);
     --
END chk_parent_spine_id;



--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_status >--------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that on insert status is not null and that
--    it is validated against hr_lookups.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_status
--    p_effective_date
--    p_cagr_entitlement_line_id
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
PROCEDURE chk_status
  (p_status                    IN per_cagr_entitlement_lines_f.status%TYPE
   ,p_cagr_entitlement_line_id IN per_cagr_entitlement_lines_f.cagr_entitlement_line_id%TYPE
   ,p_effective_date           IN DATE
   ,p_validation_start_date    IN DATE
   ,p_validation_end_date      IN DATE) IS

  --
  l_proc     VARCHAR2(72) := g_package || 'chk_status';
  --

BEGIN
   --
   hr_utility.set_location('Entering:'||l_proc, 10);

   IF p_status is not null THEN

      --
      -- Only proceed with validation if :
      -- a) Inserting or
      -- b) The value for status has changed
      --
      hr_utility.set_location(l_proc, 20);
      IF ((p_cagr_entitlement_line_id IS NULL) OR
         ((p_cagr_entitlement_line_id IS NOT NULL) AND
          (per_pcl_shd.g_old_rec.status <> p_status))) THEN

         hr_utility.set_location(l_proc, 30);
         --
         -- Check that the type exists in HR_LOOKUPS
         --

         IF hr_api.not_exists_in_dt_hr_lookups
           (p_effective_date        => p_effective_date
           ,p_lookup_type           => 'CAGR_STATUS'
           ,p_lookup_code           => p_status
           ,p_validation_start_date => p_validation_start_date
           ,p_validation_end_date   => p_validation_end_date) THEN

             hr_utility.set_location(l_proc, 40);
             hr_utility.set_message(800, 'HR_289267_STATUS_INVALID');
             hr_utility.raise_error;

         END IF;

       END IF;

    ELSE

       hr_utility.set_location('Leaving '||l_proc, 50);
       hr_utility.set_message(800, 'HR_289267_STATUS_INVALID');
       hr_utility.raise_error;

    END IF;


END chk_status;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_oipl_id >-------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that oipl_id is refrenced from ben_oipl_f.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_oipl_id
--    p_cagr_entitlement_line_id
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
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
PROCEDURE chk_oipl_id
  ( p_oipl_id                   IN per_cagr_entitlement_lines_f.oipl_id%TYPE
   ,p_cagr_entitlement_line_id  IN NUMBER
   ,p_effective_date            IN DATE
   ,p_validation_start_date     IN DATE
   ,p_validation_end_date       IN DATE) IS
  --
  -- Delcare Cursors
  --
  CURSOR csr_chk_oipl_fk_start IS
    SELECT  'Y'
      FROM  ben_oipl_f  bof
     WHERE  bof.oipl_id = p_oipl_id
       AND  p_validation_start_date
       BETWEEN bof.effective_start_date AND bof.effective_end_date ;
  --
  CURSOR csr_chk_oipl_fk_end IS
    SELECT  'Y'
      FROM  ben_oipl_f  bof
     WHERE  bof.oipl_id = p_oipl_id
       AND  p_validation_end_date
       BETWEEN bof.effective_start_date  AND  bof.effective_end_date;
  --
  -- Delcare Local Variables
  --
  l_proc     VARCHAR2(72) := g_package || 'chk_oipl_id';
  l_dummy    VARCHAR2(1);
  --

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- If the oipl_id has not been set to the default
  -- value (0) then continue with the validation
  --
  IF p_oipl_id <> 0 THEN
    --
    -- Only proceed with validation if :
    -- a) Inserting or
    -- b) The value for oipl_id has changed
    --
    IF ( (p_cagr_entitlement_line_id IS NULL) OR
         ((p_cagr_entitlement_line_id IS NOT NULL) AND
          (per_pcl_shd.g_old_rec.oipl_id <> p_oipl_id))) THEN

    	hr_utility.set_location('Leaving:'||l_proc, 20);
	OPEN  csr_chk_oipl_fk_start;
        FETCH csr_chk_oipl_fk_start INTO l_dummy;

        IF csr_chk_oipl_fk_start%NOTFOUND THEN

          hr_utility.set_location(l_proc,30);
	  CLOSE csr_chk_oipl_fk_start;
	  hr_utility.set_message(800, 'HR_289288_OIPL_ID_DT_INVALID');
          hr_utility.raise_error;

        END IF;

        CLOSE csr_chk_oipl_fk_start;
	hr_utility.set_location(l_proc,40);

	OPEN  csr_chk_oipl_fk_end;
   	FETCH csr_chk_oipl_fk_end INTO l_dummy;

        IF csr_chk_oipl_fk_end%NOTFOUND THEN

          hr_utility.set_location(l_proc,50);
	  CLOSE csr_chk_oipl_fk_end;
	  hr_utility.set_message(800, 'HR_289288_OIPL_ID_DT_INVALID');
          hr_utility.raise_error;

        END IF;

        CLOSE csr_chk_oipl_fk_end;
	hr_utility.set_location(l_proc,60);

     END IF;

  END IF;
  --
  hr_utility.set_location('Leaving: '||l_proc,100);
  --
END chk_oipl_id;

--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_eligy_prfl_id >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that the eligy_prfl_id exists in ben_eligy_prfl_f. This
--    procedure also ensures that the eligibility profile has only been
--    used once for the entitlement.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_eligy_prfl_id
--    p_cagr_entitlement_line_id
--    p_cagr_entilement_id
--    p_grade_spine_id
--    p_category_name
--    p_formula_criteria
--    p_business_group_id
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
PROCEDURE chk_eligy_prfl_id
   (p_eligy_prfl_id            IN per_cagr_entitlement_lines_f.eligy_prfl_id%TYPE
   ,p_grade_spine_id           IN NUMBER
   ,p_category_name            IN VARCHAR2
   ,p_cagr_entitlement_line_id IN NUMBER
   ,p_cagr_entitlement_id      IN per_cagr_entitlement_lines_f.cagr_entitlement_id%TYPE
   ,p_business_group_id        IN NUMBER
   ,p_formula_criteria         IN VARCHAR2
   ,p_effective_date           IN DATE) IS
  --
  -- Delcare Cursors
  --
  CURSOR csr_chk_id IS
    SELECT  bep.eligy_prfl_id
      FROM  ben_eligy_prfl_f bep
     WHERE  business_group_id = p_business_group_id
       AND  bep.eligy_prfl_id = p_eligy_prfl_id
       AND  p_effective_date BETWEEN bep.effective_start_date AND bep.effective_end_date
       AND  bep.bnft_cagr_prtn_cd IN ('GLOBAL','CAGR')
       --
       -- Fix for bug 2491566
       --
       --AND  NOT EXISTS (SELECT 'X'
       --           FROM   per_cagr_entitlement_lines_f pcl
       --           WHERE  pcl.eligy_prfl_id       = bep.eligy_prfl_id
       --           AND    pcl.cagr_entitlement_id = p_cagr_entitlement_id
       --           AND    p_effective_date BETWEEN pcl.effective_start_date AND
       --                                           pcl.effective_end_date)
     UNION
	   SELECT 0
	     FROM   DUAL;
  --
  -- Fix for bug 2491566
  --
	 --WHERE  NOT EXISTS (SELECT 'X'
  --                FROM   per_cagr_entitlement_lines_f pcl
  --                WHERE  pcl.eligy_prfl_id       = 0
  --                AND    pcl.cagr_entitlement_id = p_cagr_entitlement_id
  --                AND    p_effective_date BETWEEN pcl.effective_start_date AND
  --                                                pcl.effective_end_date);
  --
  CURSOR csr_chk_payscale IS
    SELECT  bep.eligy_prfl_id
      FROM  ben_eligy_prfl_f bep
     WHERE  business_group_id = p_business_group_id
	      AND  bep.eligy_prfl_id = p_eligy_prfl_id
       AND  p_effective_date BETWEEN bep.effective_start_date
                                 AND bep.effective_end_date
       --
       -- Fix for bug 2491566
       --
       --AND  NOT EXISTS (SELECT 'X'
       --                   FROM per_cagr_entitlement_lines_f pcl
       --                  WHERE pcl.eligy_prfl_id       = bep.eligy_prfl_id
				   --                    AND pcl.grade_spine_id      = p_grade_spine_id
       --                    AND pcl.cagr_entitlement_id = p_cagr_entitlement_id
       --                    AND p_effective_date BETWEEN pcl.effective_start_date
       --                                             AND pcl.effective_end_date)
     UNION
   	SELECT 0
	     FROM   DUAL;
  --
  -- Fix for bug 2491566
  --
	 --WHERE  NOT EXISTS (SELECT 'X'
  --                     FROM per_cagr_entitlement_lines_f pcl
  --                    WHERE pcl.eligy_prfl_id       = 0
		--		                    AND pcl.grade_spine_id      = p_grade_spine_id
  --                      AND pcl.cagr_entitlement_id = p_cagr_entitlement_id
  --                      AND p_effective_date BETWEEN pcl.effective_start_date
  --                                               AND pcl.effective_end_date);
  --
  -- Delcare Local Variables
  --
  l_proc          VARCHAR2(72) := g_package || 'chk_eligy_prfl_id';
  l_eligy_prfl_id per_cagr_entitlement_lines_f.oipl_id%TYPE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory parameters has been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument	      => 'ELIGY_PRFL_ID'
	,p_argument_value => p_eligy_prfl_id);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument	      => 'CATEGORY_NAME'
	,p_argument_value => p_category_name);
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for eligy_prfl_id has changed
  --
  IF ( (p_cagr_entitlement_line_id IS NULL) OR
       ((p_cagr_entitlement_line_id IS NOT NULL) AND
        ((per_pcl_shd.g_old_rec.eligy_prfl_id <> p_eligy_prfl_id) OR
		 (per_pcl_shd.g_old_rec.grade_spine_id <> p_grade_spine_id))
	   )
	  ) THEN
    --
	hr_utility.set_location(l_proc, 20);
	--
	-- If the entitlement has been defined with a formula
	-- for calculating elibility and cagr values then
	-- raise an error.
	--
	IF p_formula_criteria = 'F' THEN
	  --
      hr_utility.set_message(800, 'HR_289392_ELIG_FOR_FORMULA_ENT');
      hr_utility.raise_error;
	  --
	END IF;
	--
	-- If the category is Payscale then check to see
	-- if the eligibility profile and grade combination
	-- are unique for this entitlement
	--
	IF p_category_name = 'PYS' THEN
	  --
	  hr_utility.set_location(l_proc, 30);
	  --
	  OPEN csr_chk_payscale;
	  FETCH csr_chk_payscale INTO l_eligy_prfl_id;
	  --
	  IF csr_chk_payscale%NOTFOUND THEN
	    --
	    CLOSE csr_chk_payscale;
	    --
        hr_utility.set_message(800, 'HR_289344_ELIGY_PRFL_ID_INV');
        hr_utility.raise_error;
	    --
	  ELSE
	    --
	    CLOSE csr_chk_payscale;
	    --
	  END IF;
    --
	-- If the category is not Payscale then check to see
	-- if the eligibility profile is unique for this entitlement
	--
	ELSIF p_category_name <> 'PYS' THEN
	  --
	  hr_utility.set_location(l_proc, 40);
	  --
   	  -- Check that the elig_prfl_id exists and is unique
	  -- for the collective agreement entitlement.
	  --
	  OPEN csr_chk_id;
	  FETCH csr_chk_id INTO l_eligy_prfl_id;
	  --
	  IF csr_chk_id%NOTFOUND THEN
	    --
	    CLOSE csr_chk_id;
	    --
        hr_utility.set_message(800, 'HR_289344_ELIGY_PRFL_ID_INV');
        hr_utility.raise_error;
	    --
	  ELSE
	    --
	    CLOSE csr_chk_id;
	    --
	  END IF;
	  --
	END IF;
	--
  END IF;
  --
  hr_utility.set_location('Leaving: '||l_proc,999);
  --
END chk_eligy_prfl_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_step_id >-------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that step_id is refrenced from per_spinal_point_steps_f.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_step_id
--    p_cagr_entitlement_line_id
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
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
PROCEDURE chk_step_id
  ( p_step_id                  IN per_cagr_entitlement_lines_f.step_id%TYPE
   ,p_cagr_entitlement_line_id IN NUMBER
   ,p_cagr_entitlement_id      IN per_cagr_entitlement_lines_f.cagr_entitlement_id%TYPE
   ,p_effective_date           IN DATE
   ,p_validation_start_date     IN DATE
   ,p_validation_end_date       IN DATE) IS
  --
  --Declare Cursors
  --

  CURSOR csr_chk_category IS
      SELECT  category_name
        FROM  per_cagr_entitlement_items pci
             ,per_cagr_entitlements      pce
       WHERE  pci.CAGR_ENTITLEMENT_ITEM_ID = pce.CAGR_ENTITLEMENT_ITEM_ID
       AND  pce.CAGR_ENTITLEMENT_ID      = p_CAGR_ENTITLEMENT_ID;

  CURSOR csr_chk_step_fk_start IS
    SELECT  'Y'
      FROM  per_spinal_point_steps_f  pspf
     WHERE  pspf.step_id = p_step_id
       AND  p_validation_start_date
       BETWEEN pspf.effective_start_date AND pspf.effective_end_date ;
  --
  CURSOR csr_chk_step_fk_end IS
    SELECT  'Y'
      FROM  per_spinal_point_steps_f  pspf
     WHERE  pspf.step_id = p_step_id
       AND  p_validation_end_date
       BETWEEN pspf.effective_start_date   AND pspf.effective_end_date ;
  --
  -- Declare Local Variables
  --
  l_proc     VARCHAR2(72) := g_package || 'chk_step_id';
  l_dummy    VARCHAR2(1);
  l_cat      per_cagr_entitlement_items.category_name%TYPE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);

  -- Check category is pay scales

  OPEN  csr_chk_category;
  FETCH csr_chk_category INTO l_cat;
  --
  hr_utility.set_location(l_proc,20);

  IF (l_cat = 'PYS') then

     -- Check if  step_id is not null
     hr_api.mandatory_arg_error
 	(p_api_name	=> l_proc
        ,p_argument	=> 'step_id'
        ,p_argument_value => p_step_id);

     hr_utility.set_location('Leaving:'||l_proc, 30);
     --
     -- Only proceed with validation if :
     -- a) Inserting or
     -- b) The value for step_id has changed
     --

     IF ((p_cagr_entitlement_line_id IS NULL) OR
        ((p_cagr_entitlement_line_id IS NOT NULL) AND
         (per_pcl_shd.g_old_rec.step_id <> p_step_id))) THEN

  	   hr_utility.set_location(l_proc, 40);
           OPEN  csr_chk_step_fk_start;
           FETCH csr_chk_step_fk_start INTO l_dummy;
      	   hr_utility.set_location(l_proc, 50);

           IF csr_chk_step_fk_start%NOTFOUND THEN

              hr_utility.set_location(l_proc,60);
              CLOSE csr_chk_step_fk_start;
	      hr_utility.set_message(800, 'HR_289289_STEP_ID_DT_INVALID');
              hr_utility.raise_error;

           END IF;

           CLOSE csr_chk_step_fk_start;
	   hr_utility.set_location(l_proc,70);
	   OPEN  csr_chk_step_fk_end;
           FETCH csr_chk_step_fk_end INTO l_dummy;
      	   hr_utility.set_location(l_proc, 80);

	   IF csr_chk_step_fk_end%NOTFOUND THEN

             hr_utility.set_location(l_proc,90);
	     CLOSE csr_chk_step_fk_end;
	     hr_utility.set_message(800, 'HR_289289_STEP_ID_DT_INVALID');
             hr_utility.raise_error;

           END IF;
          --
	  hr_utility.set_location(l_proc, 100);
	  --
          CLOSE csr_chk_step_fk_end;
	  --
       END IF;
    --
  END IF;
  --
  CLOSE csr_chk_category;
  hr_utility.set_location('LEaving: '||l_proc,100);
  --
END chk_step_id;

--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_object_version_number >-----------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Checks that the OVN passed is not null on update and delete.
--
--  Pre-conditions :
--    None.
--
--  In Arguments :
--    p_object_version_number
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
procedure chk_object_version_number
  (
    p_object_version_number in  per_cagr_entitlement_lines_f.object_version_number%TYPE
  )	is
--
 l_proc  varchar2(72) := g_package||'chk_object_version_number';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- 	Check mandatory parameters have been set
  --
   hr_api.mandatory_arg_error
    (p_api_name	        => l_proc
    ,p_argument	        => 'object_version_number'
    ,p_argument_value	  => p_object_version_number
    );
    --
  hr_utility.set_location(' Leaving:'||l_proc, 3);
  --
end chk_object_version_number;



--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_update_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   parent entities when a datetrack update operation is taking place
--   and where there is no cascading of update defined for this entity.
--
-- Prerequisites:
--   This procedure is called from the update_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_validate
  (p_grade_spine_id                in number default hr_api.g_number
  ,p_step_id                       in number default hr_api.g_number
  ,p_from_step_id                  in number default hr_api.g_number
  ,p_to_step_id                    in number default hr_api.g_number
  ,p_datetrack_mode                in varchar2
  ,p_validation_start_date         in date
  ,p_validation_end_date           in date
  ) Is
--
  l_proc  varchar2(72) := g_package||'dt_update_validate';
  l_integrity_error Exception;
  l_table_name      all_tables.table_name%TYPE;
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Mode will be valid, as this is checked at the start of the upd.
  --
  -- Ensure the arguments are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
  --
  If ((nvl(p_grade_spine_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'per_grade_spines_f'
            ,p_base_key_column => 'GRADE_SPINE_ID'
            ,p_base_key_value  => p_grade_spine_id
            ,p_from_date       => p_validation_start_date
            ,p_to_date         => p_validation_end_date))) Then
     l_table_name := 'grade spines';
     raise l_integrity_error;
  End If;
  If ((nvl(p_step_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'per_spinal_point_steps_f'
            ,p_base_key_column => 'STEP_ID'
            ,p_base_key_value  => p_step_id
            ,p_from_date       => p_validation_start_date
            ,p_to_date         => p_validation_end_date))) Then
     l_table_name := 'spinal point steps';
     raise l_integrity_error;
  End If;
  If ((nvl(p_from_step_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'per_spinal_point_steps_f'
            ,p_base_key_column => 'STEP_ID'
            ,p_base_key_value  => p_from_step_id
            ,p_from_date       => p_validation_start_date
            ,p_to_date         => p_validation_end_date))) Then
     l_table_name := 'spinal point steps';
     raise l_integrity_error;
  End If;
  If ((nvl(p_to_step_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'per_spinal_point_steps_f'
            ,p_base_key_column => 'STEP_ID'
            ,p_base_key_value  => p_to_step_id
            ,p_from_date       => p_validation_start_date
            ,p_to_date         => p_validation_end_date))) Then
     l_table_name := 'spinal point steps';
     raise l_integrity_error;
  End If;
  --
Exception
  When l_integrity_error Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
    fnd_message.set_token('TABLE_NAME', l_table_name);
    fnd_message.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
End dt_update_validate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_delete_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   child entities when either a datetrack DELETE or ZAP is in operation
--   and where there is no cascading of delete defined for this entity.
--   For the datetrack mode of DELETE or ZAP we must ensure that no
--   datetracked child rows exist between the validation start and end
--   dates.
--
-- Prerequisites:
--   This procedure is called from the delete_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a row exists by determining the returning Boolean value from the
--   generic dt_api.rows_exist function then we must supply an error via
--   the use of the local exception handler l_rows_exist.
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_validate
  (p_cagr_entitlement_line_id         in number
  ,p_datetrack_mode                   in varchar2
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ) Is
--
  l_proc        varchar2(72)    := g_package||'dt_delete_validate';
  l_rows_exist  Exception;
  l_table_name  all_tables.table_name%TYPE;
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = hr_api.g_delete or
      p_datetrack_mode = hr_api.g_zap) then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_start_date'
      ,p_argument_value => p_validation_start_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_end_date'
      ,p_argument_value => p_validation_end_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'cagr_entitlement_line_id'
      ,p_argument_value => p_cagr_entitlement_line_id
      );
    --
  --
    --
  End If;
  --
Exception
  When l_rows_exist Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    fnd_message.set_name('PAY', 'HR_7215_DT_CHILD_EXISTS');
    fnd_message.set_token('TABLE_NAME', l_table_name);
    fnd_message.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  --
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE insert_validate
  (p_rec                   in per_pcl_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
  --
  l_collective_agreement_id  NUMBER;
  l_proc                     VARCHAR2(72) := g_package||'insert_validate';
  l_cagr_entitlement_item_id NUMBER;
  l_formula_criteria         per_cagr_entitlements.formula_criteria%TYPE;
  l_business_group_id        NUMBER;
  l_category_name            per_cagr_entitlement_items.category_name%TYPE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Call procedure that returns the collective agreement id
  -- and business_group_id that will be used in the chk procedures
  --
  per_pcl_shd.retrieve_cagr_info
    (p_cagr_entitlement_id     => p_rec.cagr_entitlement_id
    ,p_collective_agreement_id => l_collective_agreement_id
    ,p_business_group_id       => l_business_group_id);
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Call parent cagr_entitlement_item's set_security_group_id function
  --
  per_pce_bus.set_security_group_id
    (p_cagr_entitlement_id     => p_rec.cagr_entitlement_id
	,p_collective_agreement_id => l_collective_agreement_id);
  --
  -- Retrieve the entitlement_item_id and category name
  --
  per_pcl_shd.retrieve_entitlement_item_info
    (p_cagr_entitlement_id      => p_rec.cagr_entitlement_id
	,p_cagr_entitlement_item_id => l_cagr_entitlement_item_id
	,p_category_name            => l_category_name
	,p_formula_criteria         => l_formula_criteria);
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Validate mandatory
  --
  per_pcl_bus.chk_mandatory
  ( p_mandatory                => p_rec.mandatory
   ,p_cagr_entitlement_line_id => p_rec.cagr_entitlement_line_id
   ,p_effective_date           => p_effective_date
   ,p_validation_start_date    => p_validation_start_date
   ,p_validation_end_date      => p_validation_end_date);
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Validate value
  --
  per_pcl_bus.chk_value
    (p_value                    => p_rec.value
    ,p_cagr_entitlement_item_id => l_cagr_entitlement_item_id
	,p_cagr_entitlement_line_id => p_rec.cagr_entitlement_line_id
	,p_cagr_entitlement_id      => p_rec.cagr_entitlement_id
	,p_category_name            => l_category_name
	,p_effective_date           => p_effective_date);
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Validate Range_From
  --
  per_pcl_bus.chk_range_from
    (p_range_from               => p_rec.range_from
    ,p_cagr_entitlement_item_id => l_cagr_entitlement_item_id
	,p_cagr_entitlement_line_id => p_rec.cagr_entitlement_line_id
	,p_category_name            => l_category_name
	,p_effective_date           => p_effective_date);
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- Validate Range_To
  --
  per_pcl_bus.chk_range_to
    (p_range_to                 => p_rec.range_to
    ,p_cagr_entitlement_item_id => l_cagr_entitlement_item_id
	,p_cagr_entitlement_line_id => p_rec.cagr_entitlement_line_id
	,p_category_name            => l_category_name
	,p_effective_date           => p_effective_date);
  --
  hr_utility.set_location(l_proc, 65);
  --
  -- If the entitlement item has been defined as a DATE
  -- type then check that all the dates are valid.
  --
  per_pcl_bus.chk_dates_are_valid
    (p_cagr_entitlement_item_id => l_cagr_entitlement_item_id
	,p_value                    => p_rec.value
	,p_range_from               => p_rec.range_from
	,p_range_to                 => p_rec.range_to
	,p_effective_date           => p_effective_date);
  --
  hr_utility.set_location(l_proc, 70);
  --
  -- Validate grade_spine_id
  --
  per_pcl_bus.chk_grade_spine_id
  ( p_grade_spine_id           => p_rec.grade_spine_id
   ,p_cagr_entitlement_line_id => p_rec.cagr_entitlement_line_id
   ,p_cagr_entitlement_id      => p_rec.cagr_entitlement_id
   ,p_effective_date           => p_effective_date
   ,p_validation_start_date     => p_validation_start_date
   ,p_validation_end_date       => p_validation_end_date) ;
  --
  hr_utility.set_location(l_proc, 80);
  --
  -- Validate parent_spine_id
  --
  per_pcl_bus.chk_parent_spine_id
   (p_parent_spine_id          => p_rec.parent_spine_id
   ,p_cagr_entitlement_line_id => p_rec.cagr_entitlement_line_id
   ,p_cagr_entitlement_id      => p_rec.cagr_entitlement_id);
  --
  hr_utility.set_location(l_proc, 90);
  --
  -- Validate status
  --
  per_pcl_bus.chk_status
    (p_status                   => p_rec.status
    ,p_cagr_entitlement_line_id => p_rec.cagr_entitlement_line_id
    ,p_effective_date           => p_effective_date
    ,p_validation_start_date    => p_validation_start_date
    ,p_validation_end_date      => p_validation_end_date) ;
  --
  hr_utility.set_location(l_proc, 100);
  --
  -- Validate oipl_id
  --
  per_pcl_bus.chk_oipl_id
    (p_oipl_id                   => p_rec.oipl_id
    ,p_cagr_entitlement_line_id  => p_rec.cagr_entitlement_line_id
    ,p_effective_date            => p_effective_date
    ,p_validation_start_date     => p_validation_start_date
    ,p_validation_end_date       => p_validation_end_date) ;
  --
  hr_utility.set_location(l_proc, 110);
  --
  -- Validate step_id
  --
  per_pcl_bus.chk_step_id
    (p_step_id                  => p_rec.step_id
    ,p_cagr_entitlement_line_id => p_rec.cagr_entitlement_line_id
    ,p_cagr_entitlement_id      => p_rec.cagr_entitlement_id
    ,p_effective_date           => p_effective_date
    ,p_validation_start_date    => p_validation_start_date
    ,p_validation_end_date      => p_validation_end_date);
  --
  hr_utility.set_location(l_proc, 120);
  --
  -- Validate eligy_prfl_id
  --
  per_pcl_bus.chk_eligy_prfl_id
  ( p_eligy_prfl_id            => p_rec.eligy_prfl_id
   ,p_cagr_entitlement_line_id => p_rec.cagr_entitlement_line_id
   ,p_grade_spine_id           => p_rec.grade_spine_id
   ,p_category_name            => l_category_name
   ,p_cagr_entitlement_id      => p_rec.cagr_entitlement_id
   ,p_business_group_id        => l_business_group_id
   ,p_effective_date           => p_effective_date
   ,p_formula_criteria         => l_formula_criteria);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in per_pcl_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
  --
  l_proc                     varchar2(72) := g_package||'update_validate';
  l_cagr_entitlement_item_id per_cagr_entitlements.cagr_entitlement_item_id%TYPE;
  l_formula_criteria         per_cagr_entitlements.formula_criteria%TYPE;
  l_collective_agreement_id  NUMBER;
  l_business_group_id        NUMBER;
  l_category_name            per_cagr_entitlement_items.category_name%TYPE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
   --
  -- Call procedure that returns the collective agreement id
  -- and business_group_id that will be used in the chk procedures
  --
  per_pcl_shd.retrieve_cagr_info
    (p_cagr_entitlement_id     => p_rec.cagr_entitlement_id
    ,p_collective_agreement_id => l_collective_agreement_id
    ,p_business_group_id       => l_business_group_id);
  --
  -- Call parent cagr_entitlement_item's set_security_group_id function
  --
  per_pce_bus.set_security_group_id
    (p_cagr_entitlement_id     => p_rec.cagr_entitlement_id
	,p_collective_agreement_id => l_collective_agreement_id);
  --
  hr_utility.set_location(l_proc, 10);
  --
  chk_non_updateable_args
    (p_effective_date => p_effective_date
    ,p_rec            => p_rec);
  --
  -- Retrieve the entitlement_item_id and category name
  --
  per_pcl_shd.retrieve_entitlement_item_info
    (p_cagr_entitlement_id      => p_rec.cagr_entitlement_id
	,p_cagr_entitlement_item_id => l_cagr_entitlement_item_id
	,p_category_name            => l_category_name
	,p_formula_criteria         => l_formula_criteria);
  --
  -- Validate mandatory
  --
  per_pcl_bus.chk_mandatory
    (p_mandatory                => p_rec.mandatory
    ,p_cagr_entitlement_line_id => p_rec.cagr_entitlement_line_id
    ,p_effective_date           => p_effective_date
    ,p_validation_start_date    => p_validation_start_date
    ,p_validation_end_date      => p_validation_end_date);
  --
  hr_utility.set_location(l_proc, 20);

  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Validate value
  --
  per_pcl_bus.chk_value
    (p_value                    => p_rec.value
    ,p_cagr_entitlement_item_id => l_cagr_entitlement_item_id
	,p_cagr_entitlement_line_id => p_rec.cagr_entitlement_line_id
	,p_cagr_entitlement_id      => p_rec.cagr_entitlement_id
	,p_category_name            => l_category_name
	,p_effective_date           => p_effective_date);
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Validate Range_From
  --
  per_pcl_bus.chk_range_from
    (p_range_from               => p_rec.range_from
    ,p_cagr_entitlement_item_id => l_cagr_entitlement_item_id
	,p_cagr_entitlement_line_id => p_rec.cagr_entitlement_line_id
	,p_category_name            => l_category_name
	,p_effective_date           => p_effective_date);
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Validate Range_To
  --
  per_pcl_bus.chk_range_to
    (p_range_to                 => p_rec.range_to
    ,p_cagr_entitlement_item_id => l_cagr_entitlement_item_id
	,p_cagr_entitlement_line_id => p_rec.cagr_entitlement_line_id
	,p_category_name            => l_category_name
	,p_effective_date           => p_effective_date);
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- If the entitlement item has been defined as a DATE
  -- type then check that all the dates are valid.
  --
  per_pcl_bus.chk_dates_are_valid
    (p_cagr_entitlement_item_id     => l_cagr_entitlement_item_id
	,p_value                    => p_rec.value
	,p_range_from               => p_rec.range_from
	,p_range_to                 => p_rec.range_to
	,p_effective_date           => p_effective_date);
  --
  hr_utility.set_location(l_proc, 65);
  --
  -- Validate grade_spine_id
  --
  per_pcl_bus.chk_grade_spine_id
   (p_grade_spine_id           => p_rec.grade_spine_id
   ,p_cagr_entitlement_line_id => p_rec.cagr_entitlement_line_id
   ,p_cagr_entitlement_id      => p_rec.cagr_entitlement_id
   ,p_effective_date           => p_effective_date
   ,p_validation_start_date    => p_validation_start_date
   ,p_validation_end_date      => p_validation_end_date) ;
  --
  hr_utility.set_location(l_proc, 70);
  --
  -- Validate parent_spine_id
  --
  per_pcl_bus.chk_parent_spine_id
    (p_parent_spine_id          => p_rec.parent_spine_id
    ,p_cagr_entitlement_line_id => p_rec.cagr_entitlement_line_id
    ,p_cagr_entitlement_id      => p_rec.cagr_entitlement_id);
  --
  hr_utility.set_location(l_proc, 80);
  --
  -- Validate status
  --
  per_pcl_bus.chk_status
   (p_status                   => p_rec.status
   ,p_cagr_entitlement_line_id => p_rec.cagr_entitlement_line_id
   ,p_effective_date           => p_effective_date
   ,p_validation_start_date    => p_validation_start_date
   ,p_validation_end_date      => p_validation_end_date) ;
  --
  hr_utility.set_location(l_proc, 90);
  --
  -- Validate oipl_id
  --
  per_pcl_bus.chk_oipl_id
   (p_oipl_id                   => p_rec.oipl_id
   ,p_cagr_entitlement_line_id  => p_rec.cagr_entitlement_line_id
   ,p_effective_date            => p_effective_date
   ,p_validation_start_date      => p_validation_start_date
   ,p_validation_end_date        => p_validation_end_date) ;
  --
  hr_utility.set_location(l_proc, 100);
  --
  -- Validate step_id
  --
  per_pcl_bus.chk_step_id
   (p_step_id                  => p_rec.step_id
   ,p_cagr_entitlement_line_id => p_rec.cagr_entitlement_line_id
   ,p_cagr_entitlement_id      => p_rec.cagr_entitlement_id
   ,p_effective_date           => p_effective_date
   ,p_validation_start_date     => p_validation_start_date
   ,p_validation_end_date       => p_validation_end_date);
  --
  hr_utility.set_location(l_proc, 110);
  --
  -- Validate eligy_prfl_id
  --
  per_pcl_bus.chk_eligy_prfl_id
  ( p_eligy_prfl_id            => p_rec.eligy_prfl_id
   ,p_cagr_entitlement_line_id => p_rec.cagr_entitlement_line_id
   ,p_grade_spine_id           => p_rec.grade_spine_id
   ,p_category_name            => l_category_name
   ,p_cagr_entitlement_id      => p_rec.cagr_entitlement_id
   ,p_business_group_id        => l_business_group_id
   ,p_effective_date           => p_effective_date
   ,p_formula_criteria         => l_formula_criteria);
  --
  -- Validate object_version_number
  --
  per_pcl_bus.chk_object_version_number
   (p_object_version_number => p_rec.object_version_number );
  --
  hr_utility.set_location(l_proc, 120);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_grade_spine_id                 => p_rec.grade_spine_id
    ,p_step_id                        => p_rec.step_id
    ,p_from_step_id                   => p_rec.from_step_id
    ,p_to_step_id                     => p_rec.to_step_id
    ,p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  hr_utility.set_location(l_proc, 130);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in per_pcl_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --

per_pcl_bus.chk_object_version_number
  (
    p_object_version_number => p_rec.object_version_number );

  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_cagr_entitlement_line_id         => p_rec.cagr_entitlement_line_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_pcl_bus;

/
