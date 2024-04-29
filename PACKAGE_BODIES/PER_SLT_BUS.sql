--------------------------------------------------------
--  DDL for Package Body PER_SLT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SLT_BUS" as
/* $Header: pesltrhi.pkb 115.2 2003/08/07 23:59:21 vkonda noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_slt_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_solution_type_name          varchar2(120)  default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_solution_type_name                   in varchar2
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- per_solution_types and PER_BUSINESS_GROUPS
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_solution_types slt
      --   , EDIT_HERE table_name(s) 333
     where slt.solution_type_name = p_solution_type_name;
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
    ,p_argument           => 'solution_type_name'
    ,p_argument_value     => p_solution_type_name
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
     hr_multi_message.add
       (p_associated_column1
        => nvl(p_associated_column1,'SOLUTION_TYPE_NAME')
       );
     --
  else
    close csr_sec_grp;
    --
    -- Set the security_group_id in CLIENT_INFO
    --
    hr_api.set_security_group_id
      (p_security_group_id => l_security_group_id
      );
  end if;
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
  (p_solution_type_name                   in     varchar2
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- per_solution_types and PER_BUSINESS_GROUPS
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , per_solution_types slt
      --   , EDIT_HERE table_name(s) 333
     where slt.solution_type_name = p_solution_type_name;
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
    ,p_argument           => 'solution_type_name'
    ,p_argument_value     => p_solution_type_name
    );
  --
  if ( nvl(per_slt_bus.g_solution_type_name, hr_api.g_varchar2)
       = p_solution_type_name) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_slt_bus.g_legislation_code;
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
    per_slt_bus.g_solution_type_name          := p_solution_type_name;
    per_slt_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
--  ---------------------------------------------------------------------------
--  |--------------------<  chk_solution_category  >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks that a solution category value is valid
--    - Validates that the solution category exists as a lookup code on
--      HR_STANDARD_LOOKUPS for the lookup type 'PER_SOLUTION_CATEGORIES' with
--      an enabled flag set to 'Y' and the effective date between the
--      start date active and end date active on HR_STANDARD_LOOKUPS.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_solution_type_name
--    p_solution_category
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - solution category exists as a lookup code in HR_STANDARD_LOOKUPS
--        for the lookup type 'PER_SOLUTION_CATEGORIES' where the enabled
--        flag is 'Y' and the effective date is between start date active
--        and end date active on HR_STANDARD_LOOKUPS.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - solution category doesn't exist as a lookup code in HR_STANDARD_LOOKUPS
--        for the lookup type 'PER_SOLUTION_CATEGORIES' where the enabled
--        flag is 'Y' and the effective date is between start date active
--        and end date active on HR_STANDARD_LOOKUPS.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_solution_category
  (p_solution_type_name       in   per_solution_types.solution_type_name%TYPE
  ,p_solution_category        in   per_solution_types.solution_category%TYPE
  ,p_effective_date           in   date
  ,p_object_version_number    in   per_solution_types.object_version_number%TYPE
  )
is
  --
  l_exists         varchar2(1);
  l_proc           varchar2(72)  :=  g_package||'chk_solution_category';
  l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The solution category value has changed
  --  c) A record is being inserted
  --
  hr_utility.set_location(l_proc, 30);
  l_api_updating := per_slt_shd.api_updating
    (p_solution_type_name    => p_solution_type_name
    ,p_object_version_number => p_object_version_number
    );
  if ((l_api_updating
      and nvl(per_slt_shd.g_old_rec.solution_category, hr_api.g_varchar2)
      <> nvl(p_solution_category,hr_api.g_varchar2))
    or
      (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 40);
    --
    --  Check if solution category is set
    --
    if p_solution_category is not null then
      --
      -- Check that the solution category exists in HR_STANDARD_LOOKUPS for the
      -- lookup type 'PER_SOLUTION_CATEGORIES' with an enabled flag set to 'Y'
      -- and that the effective date is between start date
      -- active and end date active in HR_STANDARD_LOOKUPS.
      --
      if hr_api.not_exists_in_hrstanlookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'PER_SOLUTION_CATEGORIES'
        ,p_lookup_code           => p_solution_category
        )
      then
        --
        hr_utility.set_message(801, 'HR_EDIT');
        hr_utility.raise_error;
        --
      end if;
      hr_utility.set_location(l_proc, 50);
      --
    end if;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_solution_category;
--
--  ---------------------------------------------------------------------------
--  |-----------------------<  chk_updateable  >------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks that the updateable flag value is valid
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_solution_type_name
--    p_updateable
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - updateable exists as a lookup code in HR_STANDARD_LOOKUPS
--        for the lookup type 'YES_NO' where the enabled
--        flag is 'Y' and the effective date is between start date active
--        and end date active on HR_STANDARD_LOOKUPS.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - updateable doesn't exist as a lookup code in HR_STANDARD_LOOKUPS
--        for the lookup type 'YES_NO' where the enabled
--        flag is 'Y' and the effective date is between start date active
--        and end date active on HR_STANDARD_LOOKUPS.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_updateable
  (p_solution_type_name    in   per_solution_types.solution_type_name%TYPE
  ,p_updateable            in   per_solution_types.updateable%TYPE
  ,p_effective_date        in   date
  ,p_object_version_number in   per_solution_types.object_version_number%TYPE
  )
is
  --
  l_exists         varchar2(1);
  l_proc           varchar2(72)  :=  g_package||'chk_updateable';
  l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'updateable'
    ,p_argument_value =>  p_updateable
    );
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The solution category value has changed
  --  c) A record is being inserted
  --
  l_api_updating := per_slt_shd.api_updating
    (p_solution_type_name    => p_solution_type_name
    ,p_object_version_number => p_object_version_number
    );
  if ((l_api_updating
      and nvl(per_slt_shd.g_old_rec.updateable, hr_api.g_varchar2)
      <> nvl(p_updateable,hr_api.g_varchar2))
    or
      (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 40);
    --
    --  Check if updateable is set
    --
    if p_updateable is not null then
      --
      -- Check that the updateable flag exists in HR_STANDARD_LOOKUPS for the
      -- lookup type 'YES_NO' with an enabled flag set to 'Y'
      -- and that the effective date is between start date
      -- active and end date active in HR_STANDARD_LOOKUPS.
      --
      if hr_api.not_exists_in_hrstanlookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'YES_NO'
        ,p_lookup_code           => p_updateable
        )
      then
        --
        hr_utility.set_message(801, 'HR_EDIT');
        hr_utility.raise_error;
        --
      end if;
      hr_utility.set_location(l_proc, 50);
      --
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_updateable;
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
  ,p_rec in per_slt_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_slt_shd.api_updating
      (p_solution_type_name                => p_rec.solution_type_name
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- EDIT_HERE: Add checks to ensure non-updateable args have
  --            not been updated.
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_slt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --  No business group context.  HR_STANDARD_LOOKUPS used for validation."
  --
  -- Validate Dependent Attributes
  --
  --
  chk_solution_category
    (p_solution_type_name       =>  p_rec.solution_type_name
    ,p_solution_category        =>  p_rec.solution_category
    ,p_effective_date           =>  p_effective_date
    ,p_object_version_number    =>  p_rec.object_version_number
    );
  --
  chk_updateable
    (p_solution_type_name       =>  p_rec.solution_type_name
    ,p_updateable               =>  p_rec.updateable
    ,p_effective_date           =>  p_effective_date
    ,p_object_version_number    =>  p_rec.object_version_number
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
  ,p_rec                          in per_slt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date   => p_effective_date
    ,p_rec              => p_rec
    );
  --
  chk_solution_category
    (p_solution_type_name       =>  p_rec.solution_type_name
    ,p_solution_category        =>  p_rec.solution_category
    ,p_effective_date           =>  p_effective_date
    ,p_object_version_number    =>  p_rec.object_version_number
    );
  --
  chk_updateable
    (p_solution_type_name       =>  p_rec.solution_type_name
    ,p_updateable               =>  p_rec.updateable
    ,p_effective_date           =>  p_effective_date
    ,p_object_version_number    =>  p_rec.object_version_number
    );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_slt_shd.g_rec_type
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
end per_slt_bus;

/
