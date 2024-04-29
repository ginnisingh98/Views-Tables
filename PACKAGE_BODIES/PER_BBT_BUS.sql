--------------------------------------------------------
--  DDL for Package Body PER_BBT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BBT_BUS" as
/* $Header: pebbtrhi.pkb 115.7 2002/12/02 13:20:16 apholt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_bbt_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_balance_type_id             number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_balance_type_id                      in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select inf.org_information14
      from hr_organization_information inf
         , per_bf_balance_types bbt
     where bbt.balance_type_id = p_balance_type_id
       and inf.organization_id   = bbt.business_group_id
       and inf.org_information_context || '' = 'Business Group Information';
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
  hr_api.mandatory_arg_error(p_api_name           => l_proc
                            ,p_argument           => 'BALANCE_TYPE_ID'
                            ,p_argument_value     => p_balance_type_id);
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
     fnd_message.set_name('PER','HR_7220_INVALID_PRIMARY_KEY');
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
  (p_balance_type_id                      in number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , per_bf_balance_types bbt
     where bbt.balance_type_id = p_balance_type_id
       and pbg.business_group_id = bbt.business_group_id;
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
  hr_api.mandatory_arg_error(p_api_name           => l_proc
                            ,p_argument           => 'BALANCE_TYPE_ID'
                            ,p_argument_value     => p_balance_type_id);
  --
  if ( nvl(g_balance_type_id, hr_api.g_number)
       = p_balance_type_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := g_legislation_code;
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
      fnd_message.set_name('PER','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    g_balance_type_id                   := p_balance_type_id;
    g_legislation_code                  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |----------------------< check_non_updateable_args >-----------------------|
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
  (p_rec in per_bbt_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'check_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_bbt_shd.api_updating
      (p_balance_type_id                      => p_rec.balance_type_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE ', l_proc);
     hr_utility.set_message_token('STEP ', '5');
  END IF;
  --
  hr_utility.set_location(l_proc,10);
  --
  --
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
  hr_utility.set_location(' Leaving:'||l_proc,20);
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_input_value_details >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks to ensure :
--   a) If the column INPUT_VALUE_ID is not null, then a check will be made to
--      ensure that the value exists in PAY_INPUT_VALUES_F for a input value
--      of the same business group.
--   b) If the INPUT_VALUE_ID is not null, and the UOM column is not null, then
--      a check will be made to ensure that the UOM is the same as the UOM on
--      PAY_INPUT_VALUES_F.
--   c) If INPUT_VALUE_ID is not null, and CURRENCY is not null, a check will
--      be made to ensure that the output_currency_code on the Element Type
--      for the input value is the same.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_input_value_id
--   p_business_group_id
--   p_currency_code
--   p_uom
--   p_effective_date
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
PROCEDURE CHK_INPUT_VALUE_DETAILS
   (p_input_value_id     IN NUMBER
   ,p_business_group_id  IN NUMBER
   ,p_currency_code      IN VARCHAR2
   ,p_uom                IN VARCHAR2
   ,p_effective_date     IN DATE
   ,p_balance_type_id    IN NUMBER
   ,p_object_version_number IN NUMBER
   )
IS
 --
 CURSOR csr_get_input_details IS
 SELECT iv.effective_start_date
       ,iv.effective_end_date
       ,et.output_currency_code
       ,iv.uom
 FROM pay_element_types_f et
    , pay_input_values_f  iv
 WHERE iv.input_value_id = p_input_value_id
   AND iv.element_type_id= et.element_type_id
   AND iv.business_group_id = p_business_group_id;
  --
  l_output_currency_code   VARCHAR2(30);
  l_uom	                   VARCHAR2(30);
  l_effective_start_date   DATE;
  l_effective_end_date     DATE;
  l_api_updating           BOOLEAN;
  --
BEGIN
  --
  l_api_updating := per_bbt_shd.api_updating
    (p_balance_type_id => p_balance_type_id
    ,p_object_version_number => p_object_version_number);
  --
  -- Run the test when input value is not null
  -- and input_value is not equal to the default
  --
  IF   ( p_input_value_id IS NOT NULL
    AND p_input_value_id <> hr_api.g_number ) THEN
    --
    OPEN csr_get_input_details;
    FETCH csr_get_input_details INTO
      l_effective_start_date
     ,l_effective_end_date
     ,l_output_currency_code
     , l_uom;
    --
    IF csr_get_input_details%NOTFOUND THEN
      --
      CLOSE csr_get_input_details;
      --
      -- The input_value_id that is being entered isn't in the table
      -- PAY_INPUT_VALUES_F in the same bg so error.
      --
      hr_utility.set_message (800,'HR_52939_INVALID_INPUT_ID');
      hr_utility.raise_error;
      --
    END IF;
    --
    IF (p_effective_date < l_effective_start_date
      OR p_effective_date > l_effective_end_date )    THEN
      --
      CLOSE csr_get_input_details;
      --
      -- The input value does exist, but isn't valid for the
      -- effective date that is being inserted.
      --
      hr_utility.set_message(800,'HR_52940_IV_OUTSIDE_DATES');
      hr_utility.raise_error;
      --
    END IF;
    --
    IF (p_uom IS NOT NULL AND p_uom <> l_uom) THEN
      --
      CLOSE csr_get_input_details;
      --
      -- The UOM exists and is different than the UOM on the input value.
      --
      hr_utility.set_message (800,'HR_52941_UOM_DIFFERENT');
      hr_utility.raise_error;
      --
    END IF;
    --
    IF (p_currency_code IS NOT NULL
      AND p_currency_code <> l_output_currency_code) THEN
      --
      CLOSE csr_get_input_details;
      --
      -- The currency exists but is different than the currency on the type.
      --
      hr_utility.set_message(800,'HR_52942_CURR_DIFFERENT');
      hr_utility.raise_error;
      --
    END IF;
    --
    CLOSE csr_get_input_details;
    --
  END IF;
END CHK_INPUT_VALUE_DETAILS;
-- ----------------------------------------------------------------------------
-- |------------------------< chk_display_name_uniq >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks to ensure :
--      The display_name is unique within a BG.
-- Pre Conditions:
--
-- In Arguments:
--   p_balance_type_id
--   p_display_name
--   p_business_group_id
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
PROCEDURE CHK_DISPLAY_NAME_UNIQ
 ( p_balance_type_id        IN NUMBER
 , p_object_version_number  IN NUMBER
 , p_displayed_name         IN VARCHAR2
 , p_business_group_id      IN NUMBER)
IS
  --
  l_proc     varchar2(72) := g_package || 'chk_display_name_uniq';
  --
  CURSOR c_check_display_name_uniq IS
  SELECT 1
  FROM per_bf_balance_types
  WHERE(  (p_balance_type_id IS NULL)
       or (balance_type_id <> p_balance_type_id))
    AND displayed_name = p_displayed_name
    AND business_group_id  = p_business_group_id ;
  --
  l_temp   VARCHAR2(1);
  --
  l_api_updating BOOLEAN;
  --
BEGIN
  hr_utility.set_location ('Entering:'|| l_proc, 1);
  --
  l_api_updating := per_bbt_shd.api_updating
    (p_balance_type_id => p_balance_type_id
    ,p_object_version_number => p_object_version_number);
  --
  -- Only perform the tests if inserting or updating when the value has changed
  --
  IF ((NOT l_api_updating)
    OR (l_api_updating
       AND p_displayed_name <> hr_api.g_varchar2
       and p_displayed_name IS NOT NULL)) THEN
    --
    --
    -- Check that the business_group_id is not null.
    --
    hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'business_group_id'
    ,p_argument_value   => p_business_group_id
    );
    --
    OPEN c_check_display_name_uniq ;
    FETCH c_check_display_name_uniq INTO l_temp;
    --
    IF c_check_display_name_uniq%FOUND   THEN
      --
      -- Another row exists with the same displayed name in the same context
      -- so error.
      --
      close c_check_display_name_uniq ;
      --
      per_bbt_shd.constraint_error('HR_52611_DISPLAYED_NOT_UNQ');
      --
    END IF;
    --
    close c_check_display_name_uniq ;
  END IF;
END CHK_DISPLAY_NAME_UNIQ;
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_internal_name_uniq >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks to ensure :
--      The internal_name is unique within a BG.
-- Pre Conditions:
--
-- In Arguments:
--   p_balance_type_id
--   p_internal_name
--   p_business_group_id
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
PROCEDURE CHK_INTERNAL_NAME_UNIQ
( p_balance_type_id        IN NUMBER
 , p_object_version_number  IN NUMBER
 , p_internal_name         IN VARCHAR2
 , p_business_group_id      IN NUMBER)
IS
  --
  l_proc     varchar2(72) := g_package || 'chk_internal_name_uniq';
  --
  CURSOR c_check_internal_name_uniq IS
  SELECT 1
  FROM per_bf_balance_types
  WHERE(  (p_balance_type_id IS NULL)
       or (balance_type_id <> p_balance_type_id))
    AND internal_name = p_internal_name
    AND business_group_id  = p_business_group_id ;
  --
  l_temp   VARCHAR2(1);
  --
  l_api_updating BOOLEAN;
  --
BEGIN
  hr_utility.set_location ('Entering:'|| l_proc, 1);
  --
  l_api_updating := per_bbt_shd.api_updating
    (p_balance_type_id => p_balance_type_id
    ,p_object_version_number => p_object_version_number);
  --
  -- Only perform the tests if inserting or updating when the value has changed
  --
  IF ((NOT l_api_updating)
    OR (l_api_updating
       AND p_internal_name <> hr_api.g_varchar2
       and p_internal_name IS NOT NULL)) THEN
    --
    --
    -- Check that the business_group_id is not null.
    --
    hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'business_group_id'
    ,p_argument_value   => p_business_group_id
    );
    --
    OPEN c_check_internal_name_uniq ;
    FETCH c_check_internal_name_uniq INTO l_temp;
    --
    IF c_check_internal_name_uniq%FOUND   THEN
      --
      -- Another row exists with the same internal name in the same context
      -- so error.
      --
      close c_check_internal_name_uniq ;
      --
      per_bbt_shd.constraint_error('HR_52613_INTERNAL_NOT_UNQ') ;
      --
    END IF;
    --
    close c_check_internal_name_uniq ;
  END IF;
END CHK_INTERNAL_NAME_UNIQ;
-- ----------------------------------------------------------------------------
-- |------------------------------------< chk_uom >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   If the UOM is not null, check that it is contained in HR_LOOKUPS
-- Pre Conditions:
--
-- In Arguments:
--   p_uom
--   p_balance_type_id
--   p_effective_date
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error is raised.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE CHK_UOM
  (p_uom	           IN VARCHAR2
  ,p_balance_type_id       IN NUMBER
  ,p_object_version_number IN NUMBER
  ,p_effective_date        IN DATE)
IS
  --
  CURSOR csr_chk_uom_exists IS
  SELECT start_date_active, end_date_active, enabled_flag
  FROM hr_lookups
  WHERE lookup_type = 'UNITS'
  and lookup_code = p_uom;
  --
  l_start_date 	DATE;
  l_end_date 	DATE;
  l_enabled_flag VARCHAR2(1);
  l_api_updating BOOLEAN;
--
BEGIN
  --
  l_api_updating := per_bbt_shd.api_updating
    (p_balance_type_id => p_balance_type_id
    ,p_object_version_number => p_object_version_number);
  --
  -- Only perform the tests if a uom exists
  --
  IF (p_uom IS NOT NULL
    OR (l_api_updating
       AND p_uom <> hr_api.g_varchar2
       and p_uom IS NOT NULL)) THEN
    --
    -- Cursor selects the start and end active dates rather than including them
    -- as part of the where clause in order to give a more meaningful message.
    --
    OPEN csr_chk_uom_exists;
    FETCH csr_chk_uom_exists INTO l_start_date, l_end_date, l_enabled_flag;
    --
    IF csr_chk_uom_exists%NOTFOUND THEN
      --
      -- The lookup code entered doesn't exist in hr_lookups
      -- so error.
      --
      hr_utility.set_message(800, 'HR_52943_UOM_NOT_EXIST');
      hr_utility.raise_error;
      --
    END IF;
    --
    IF l_enabled_flag = 'N' THEN
      --
      -- The lookup exists, but isn't enabled
      --
      hr_utility.set_message(800,'HR_52609_UOM_LOOKUP_OFF');
      hr_utility.raise_error;
      --
    END IF;
    --
    IF p_effective_date not between NVL (l_start_date, hr_api.g_sot)
				and NVL (l_end_date, hr_api.g_eot)  THEN
      --
      -- The lookup exists, but it isn't valid for the effective date
      -- so error.
      --
      hr_utility.set_message(800,'HR_52944_UOM_NOT_VALID');
      hr_utility.raise_error;
      --
    END IF;
    --
  END IF;
END chk_uom;
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_uom_input >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   If the input_value_id is null, check that the UOM is not null.
--   If the UOM is 'M' ensure a currency exists
-- Pre Conditions:
--
-- In Arguments:
--   p_uom
--   p_input_value_id
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error is raised.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE CHK_UOM_INPUT
  (p_uom	           IN VARCHAR2
  ,p_currency_code         IN VARCHAR2
  ,p_input_value_id        IN NUMBER
  ,p_balance_type_id       IN NUMBER
  ,p_object_version_number IN NUMBER)
IS
  l_uom   		VARCHAR2(30) DEFAULT p_uom;
  l_input_value_id      NUMBER       DEFAULT p_input_value_id;
  l_currency_code 	VARCHAR2(30) DEFAULT p_currency_code;
  --
  l_api_updating BOOLEAN;
  --
BEGIN
  --
  l_api_updating := per_bbt_shd.api_updating
    (p_balance_type_id => p_balance_type_id
    ,p_object_version_number => p_object_version_number);
  --
  -- If updating, and the value isn't being altered then use the old value
  --
  IF (l_api_updating
    AND l_input_value_id = hr_api.g_number) THEN
    --
    l_input_value_id := per_bbt_shd.g_old_rec.input_value_id;
    --
  END IF;
  --
  IF (l_api_updating
    AND l_currency_code  = hr_api.g_varchar2) THEN
    --
    l_currency_code := per_bbt_shd.g_old_rec.currency;
    --
  END IF;
  --
  IF (l_api_updating
    AND l_uom = hr_api.g_varchar2) THEN
    --
    l_uom := per_bbt_shd.g_old_rec.uom;
    --
  END IF;
  --
  IF l_uom IS NULL and l_input_value_id IS NULL THEN
    --
    -- If there is not input value, there should be a UOM.
    --
    hr_utility.set_message(800, 'HR_52612_UOM_INPUT_BAD');
    hr_utility.raise_error;
  END IF;
  --
  --
  IF (l_currency_code IS NULL and l_uom = 'M') THEN
    -- This handles the case for both inserts and updates
    hr_utility.set_message(800,'HR_52746_NEED_CURR_UOM');
    hr_utility.raise_error;
  END IF;
END CHK_UOM_INPUT;
-- ----------------------------------------------------------------------------
-- |-------------------------------< chk_category >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   If the CATEGORY is not null, check that it is contained in HR_LOOKUPS
--   and is valid
-- Pre Conditions:
--
-- In Arguments:
--   p_category
--   p_effective_date
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error is raised.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE chk_category
  (p_category        IN VARCHAR2
  ,p_balance_type_id IN NUMBER
  ,p_object_version_number IN NUMBER
  ,p_effective_date  IN DATE)
IS
  --
  CURSOR csr_check_category IS
  SELECT start_date_active, end_date_active , enabled_flag
  FROM hr_lookups
  WHERE lookup_type = 'BACKFEED_BT_CATEGORY'
    AND  lookup_code = p_category;
  --
  l_start_date 	DATE;
  l_end_date 	DATE;
  l_enabled_flag VARCHAR2(1);
  --
  l_api_updating BOOLEAN;
  --
BEGIN
  --
  --  Only carry out the test if inserting and category isn't null
  --  or updating and category isn't null and has changed
  --
  l_api_updating := per_bbt_shd.api_updating
    (p_balance_type_id => p_balance_type_id
    ,p_object_version_number => p_object_version_number);
  --
  IF (p_category IS NOT NULL AND NOT l_api_updating
    OR (l_api_updating
       AND p_category <> hr_api.g_varchar2
       and p_category IS NOT NULL))
THEN
    --
    -- Cursor selects the start and end active dates rather than including them
    -- as part of the where clause in order to give a more meaningful message.
    --
    OPEN csr_check_category;
    FETCH csr_check_category INTO l_start_date, l_end_date, l_enabled_flag;
    --
    IF csr_check_category%NOTFOUND THEN
      --
      -- The lookup code entered doesn't exist in hr_lookups
      -- so error.
      --
      hr_utility.set_message(800, 'HR_52945_CAT_NOT_EXIST');
      hr_utility.raise_error;
      --
    END IF;
    --
    IF l_enabled_flag = 'N' THEN
      --
      -- The lookup exists, but isn't enabled
      --
      hr_utility.set_message(800,'HR_52610_CAT_LOOKUP_OFF');
      hr_utility.raise_error;
      --
    END IF;
    IF p_effective_date not between NVL (l_start_date, hr_api.g_sot)
				and NVL (l_end_date, hr_api.g_eot)  THEN
      --
      -- The lookup exists, but it isn't valid for the effective date
      -- so error.
      --
      hr_utility.set_message(800,'HR_52946_CAT_NOT_VALID');
      hr_utility.raise_error;
      --
    END IF;
  END IF;
    --
END chk_category;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_bbt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  CHK_INPUT_VALUE_DETAILS
   (p_input_value_id         => p_rec.input_value_id
   ,p_business_group_id      => p_rec.business_group_id
   ,p_currency_code          => p_rec.currency
   ,p_uom                    => p_rec.uom
   ,p_effective_date         => p_effective_date
   ,p_balance_type_id        => p_rec.balance_type_id
   ,p_object_version_number  => p_rec.object_version_number
   );
  --
  CHK_DISPLAY_NAME_UNIQ
   (p_balance_type_id       => p_rec.balance_type_id
   ,p_object_version_number => p_rec.object_version_number
   ,p_displayed_name        => p_rec.displayed_name
   , p_business_group_id    => p_rec.business_group_id);
  --
 CHK_INTERNAL_NAME_UNIQ
   (p_balance_type_id       => p_rec.balance_type_id
   ,p_object_version_number => p_rec.object_version_number
   ,p_internal_name         => p_rec.internal_name
   ,p_business_group_id     => p_rec.business_group_id);
  --
  chk_category
  ( p_category              => p_rec.category
   ,p_balance_type_id       => p_rec.balance_type_id
   ,p_object_version_number => p_rec.object_version_number
   ,p_effective_date        => p_effective_date);
  --
  chk_uom_input
  (p_uom	            => p_rec.uom
  ,p_currency_code          => p_rec.currency
  ,p_input_value_id         => p_rec.input_value_id
  ,p_balance_type_id        => p_rec.balance_type_id
  ,p_object_version_number  => p_rec.object_version_number);
  --
  CHK_UOM
  (p_uom	    => p_rec.uom
  ,p_balance_type_id      => p_rec.balance_type_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_effective_date => p_effective_date
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_bbt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  CHK_INPUT_VALUE_DETAILS
   (p_input_value_id         => p_rec.input_value_id
   ,p_business_group_id      => p_rec.business_group_id
   ,p_currency_code          => p_rec.currency
   ,p_uom                    => p_rec.uom
   ,p_effective_date         => p_effective_date
   ,p_balance_type_id        => p_rec.balance_type_id
   ,p_object_version_number  => p_rec.object_version_number
   );
  --
  CHK_DISPLAY_NAME_UNIQ
   (p_balance_type_id       => p_rec.balance_type_id
   ,p_object_version_number => p_rec.object_version_number
   ,p_displayed_name        => p_rec.displayed_name
   , p_business_group_id    => p_rec.business_group_id);
  --
  CHK_INTERNAL_NAME_UNIQ
   (p_balance_type_id       => p_rec.balance_type_id
   ,p_object_version_number => p_rec.object_version_number
   ,p_internal_name         => p_rec.internal_name
   ,p_business_group_id     => p_rec.business_group_id);
  --
  chk_category
  ( p_category              => p_rec.category
   ,p_balance_type_id       => p_rec.balance_type_id
   ,p_object_version_number => p_rec.object_version_number
   ,p_effective_date        => p_effective_date);
  --
  chk_uom_input
  (p_uom	            => p_rec.uom
  ,p_currency_code          => p_rec.currency
  ,p_input_value_id         => p_rec.input_value_id
  ,p_balance_type_id        => p_rec.balance_type_id
  ,p_object_version_number  => p_rec.object_version_number);
  --
  CHK_UOM
  (p_uom	    => p_rec.uom
  ,p_balance_type_id      => p_rec.balance_type_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_effective_date => p_effective_date
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_bbt_shd.g_rec_type
  ) is
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
end per_bbt_bus;

/
