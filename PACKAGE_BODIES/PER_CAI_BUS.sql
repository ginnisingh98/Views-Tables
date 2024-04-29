--------------------------------------------------------
--  DDL for Package Body PER_CAI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CAI_BUS" as
/* $Header: pecairhi.pkb 115.1 2002/12/04 05:50:07 raranjan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)    := '  per_cai_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_cagr_api_id                 number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_cagr_api_id                          in number
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- per_cagr_apis and PER_BUSINESS_GROUPS
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_cagr_apis cai
      --   , EDIT_HERE table_name(s) 333
     where cai.cagr_api_id = p_cagr_api_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
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
    ,p_argument           => 'cagr_api_id'
    ,p_argument_value     => p_cagr_api_id
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
--  hr_api.set_security_group_id
   -- (p_security_group_id => l_security_group_id
  --  );
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
  (p_cagr_api_id                          in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- per_cagr_apis and PER_BUSINESS_GROUPS
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , per_cagr_apis cai
      --   , EDIT_HERE table_name(s) 333
     where cai.cagr_api_id = p_cagr_api_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
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
    ,p_argument           => 'cagr_api_id'
    ,p_argument_value     => p_cagr_api_id
    );
  --
  if ( nvl(per_cai_bus.g_cagr_api_id, hr_api.g_number)
       = p_cagr_api_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_cai_bus.g_legislation_code;
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
    per_cai_bus.g_cagr_api_id       := p_cagr_api_id;
    per_cai_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
--  ---------------------------------------------------------------------------
--  |-----------------------------< chk_api_name >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that that the api name is unique
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_cagr_api_id
--    p_api_name
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
PROCEDURE chk_api_name
  (p_cagr_api_id IN per_cagr_apis.cagr_api_id%TYPE
  ,p_api_name    IN per_cagr_apis.api_name%TYPE) is
  --
  l_proc  VARCHAR2(72) := g_package||'chk_api_name';
  l_dummy per_cagr_apis.api_name%TYPE;
  --
  CURSOR csr_api_name IS
    SELECT null
    FROM   per_cagr_apis per
    WHERE  ((per.cagr_api_id <> p_cagr_api_id) OR
	        (p_cagr_api_id IS NULL))
    AND    per.api_name = p_api_name;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory api_name is set
  --
  IF p_api_name IS NULL THEN
    --
    hr_utility.set_message(800, 'HR_289209_API_NAME_NULL');
    hr_utility.raise_error;
    --
  END IF;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if :
  -- a) on insert (cagr_api_id is a non-updateable param)
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for consultation type has changed
  --
  IF ( (p_cagr_api_id IS NULL) OR
       ((p_cagr_api_id IS NOT NULL) AND
        (per_cai_shd.g_old_rec.api_name <> p_api_name))) THEN
     --
     hr_utility.set_location(l_proc, 30);
     --
     -- Check that the person_id is in the per_people_f view on the effective_date.
     --
     OPEN csr_api_name;
     FETCH csr_api_name INTO l_dummy;
     --
     IF csr_api_name%FOUND THEN
       --
       hr_utility.set_location(l_proc, 40);
       --
       CLOSE csr_api_name;
       --
       hr_utility.set_message(800,'HR_289210_API_NAME_INVALID');
       hr_utility.raise_error;
       --
     ELSE
       --
       hr_utility.set_location(l_proc, 50);
       --
       CLOSE csr_api_name;
       --
     END IF;
     --
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
  --
END chk_api_name;
--
--  ---------------------------------------------------------------------------
--  |-----------------------------< chk_category_name >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that that the category name is valid
--
--
--  Pre-conditions :
--
--
--  In Arguments :
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
PROCEDURE chk_category_name
  (p_cagr_api_id    IN per_cagr_apis.cagr_api_id%TYPE
  ,p_category_name  IN per_cagr_apis.category_name%TYPE
  ,p_effective_date IN DATE) IS
  --
  l_proc  VARCHAR2(72) := g_package||'chk_category_name';
  --
BEGIN
  --
  hr_utility.set_location('Entering :'||l_proc,10);
  --
   IF p_category_name IS NULL THEN
    --
    hr_utility.set_message(800, 'HR_289211_CATEGORY_NAME_NULL');
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
  IF ( (p_cagr_api_id IS NULL) OR
       ((p_cagr_api_id IS NOT NULL) AND
        (per_cai_shd.g_old_rec.category_name <> p_category_name))) THEN
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
  hr_utility.set_location('Leaving  :'||l_proc,100);
  --
END chk_category_name;
--
--  ---------------------------------------------------------------------------
--  |-----------------------------< chk_api_use >-----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that on delete that the api is not being referenced
--    by a entitlement item.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
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
PROCEDURE chk_api_use
  (p_cagr_api_id IN per_cagr_apis.cagr_api_id%TYPE) IS
  --
  l_proc     varchar2(72) := g_package || 'chk_api_use';
  l_dummy    per_cagr_entitlement_items.item_name%TYPE;
  --
  CURSOR csr_get_entitlement_item IS
    SELECT cei.item_name
    FROM   per_cagr_entitlement_items cei
    WHERE  cei.cagr_api_id = p_cagr_api_id;
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
    hr_utility.set_message(800, 'HR_289213_API_IN_USE');
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
END chk_api_use;
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
  ,p_rec in per_cai_shd.g_rec_type
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
  IF NOT per_cai_shd.api_updating
      (p_cagr_api_id                          => p_rec.cagr_api_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  IF nvl(p_rec.api_name, hr_api.g_varchar2) <>
     nvl(per_cai_shd.g_old_rec.api_name,hr_api.g_varchar2) THEN
    --
    l_argument := 'api_name';
    RAISE l_error;
    --
  END IF;
  --
  IF nvl(p_rec.cagr_api_id, hr_api.g_number) <>
     nvl(per_cai_shd.g_old_rec.cagr_api_id,hr_api.g_number) THEN
    --
    l_argument := 'cagr_api_id';
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
  ,p_rec                          in per_cai_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Call all supporting business operations
  --
  -- Check category name
  --
  per_cai_bus.chk_category_name
    (p_cagr_api_id    => p_rec.cagr_api_id
    ,p_category_name  => p_rec.category_name
    ,p_effective_date => p_effective_date);
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Check api name
  --
  per_cai_bus.chk_api_name
    (p_cagr_api_id => p_rec.cagr_api_id
    ,p_api_name    => p_rec.api_name);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
  --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_cai_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Call all supporting business operations
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
    ,p_rec              => p_rec
    );
  --
  hr_utility.set_location(l_proc,20);
  --
  -- Check category name
  --
  per_cai_bus.chk_category_name
    (p_cagr_api_id    => p_rec.cagr_api_id
    ,p_category_name  => p_rec.category_name
    ,p_effective_date => p_effective_date);
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Check api name
  --
  per_cai_bus.chk_api_name
    (p_cagr_api_id => p_rec.cagr_api_id
    ,p_api_name    => p_rec.api_name);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_cai_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check the API is not being referenced
  --
  per_cai_bus.chk_api_use
    (p_cagr_api_id => p_rec.cagr_api_id);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_cai_bus;

/
