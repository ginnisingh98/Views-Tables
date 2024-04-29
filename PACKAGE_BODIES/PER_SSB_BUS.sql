--------------------------------------------------------
--  DDL for Package Body PER_SSB_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SSB_BUS" as
/* $Header: pessbrhi.pkb 115.1 2003/08/06 01:25:57 kavenkat noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_ssb_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_setup_sub_task_code         varchar2(60)   default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_setup_sub_task_code                  in varchar2
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor

  cursor csr_sec_grp is
    select null --pbg.security_group_id,
          -- pbg.legislation_code
      from -- per_business_groups_perf pbg
           per_ri_setup_sub_tasks ssb
      --   , EDIT_HERE table_name(s) 333
     where ssb.setup_sub_task_code = p_setup_sub_task_code;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  l_legislation_code  varchar2(150);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'setup_sub_task_code'
    ,p_argument_value     => p_setup_sub_task_code
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id  ;
                       -- , l_legislation_code;
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
        => nvl(p_associated_column1,'SETUP_SUB_TASK_CODE')
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
    --
    -- Set the sessions legislation context in HR_SESSION_DATA
    --
    hr_api.set_legislation_context(l_legislation_code);
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
  (p_setup_sub_task_code                  in     varchar2
  )
  Return Varchar2 Is
  --
  -- Declare cursor

  cursor csr_leg_code is
    select Null -- pbg.legislation_code
      from -- per_business_groups_perf     pbg
           per_ri_setup_sub_tasks ssb
      --   , EDIT_HERE table_name(s) 333
     where ssb.setup_sub_task_code = p_setup_sub_task_code;
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
    ,p_argument           => 'setup_sub_task_code'
    ,p_argument_value     => p_setup_sub_task_code
    );
  --
  if ( nvl(per_ssb_bus.g_setup_sub_task_code, hr_api.g_varchar2)
       = p_setup_sub_task_code) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_ssb_bus.g_legislation_code;
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
    per_ssb_bus.g_setup_sub_task_code         := p_setup_sub_task_code;
    per_ssb_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in per_ssb_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_ssb_shd.api_updating
      (p_setup_sub_task_code               => p_rec.setup_sub_task_code
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
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_setup_task_type >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the following business rules are met:
--    a)Validate against HR_LOOKUPS.lookup_code
--      where LOOKUP_TYPE = 'PER_RI_TASK_TYPE' (I,U)
--
--  Pre-conditions:
--    workbench_item_code must have been successfully validated.
--
--  In Arguments:
--    p_workbench_item_code
--    p_effective_date
--    p_object_version_number
--    p_workbench_item_type
--
--  Post Success:
--    If the above business rules are satisfied then processing continues.
--
--  Post Failure:
--    If the above business rules then an application error will be raised and
--    processing is terminated.
--
--  Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

Procedure chk_setup_sub_task_type(p_setup_sub_task_code          Varchar2
                             ,p_effective_date           Varchar2
                             ,p_object_version_number    Number
                             ,p_setup_sub_task_type          Varchar2
                             ) Is

 l_proc varchar2(72)  :=  g_package||'chk_setup_sub_task_type';

Begin
  hr_utility.set_location('Entering:'|| l_proc, 1);

  If p_setup_sub_task_type Is Not Null Then

       hr_api.mandatory_arg_error
	       (p_api_name       => l_proc
	       ,p_argument       => 'EFFECTIVE_DATE'
	       ,p_argument_value => p_effective_date
          );
       If hr_api.not_exists_in_hr_lookups
           (p_effective_date => p_effective_date
           ,p_lookup_type    => 'PER_RI_SUB_TASK_TYPE'
           ,p_lookup_code    => p_setup_sub_task_type
           ) Then
          fnd_message.set_name('PER', 'HR_52966_INVALID_LOOKUP');
          fnd_message.set_token('COLUMN ', p_setup_sub_task_type);
          fnd_message.set_token('LOOKUP_TYPE ', 'PER_RI_SUB_TASK_TYPE');
          fnd_message.set_token('STEP ', '5');
          fnd_message.raise_error;
       End If;

  End If;

  hr_utility.set_location('Leaving:'|| l_proc, 1);

End chk_setup_sub_task_type;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_ssb_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate Dependent Attributes
  --
  chk_setup_sub_task_type(p_setup_sub_task_code     => p_rec.setup_sub_task_code
                         ,p_effective_date          => p_effective_date
                         ,p_object_version_number   => p_rec.object_version_number
                         ,p_setup_sub_task_type     => p_rec.setup_sub_task_type
                         ) ;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_ssb_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  --
  --
    chk_setup_sub_task_type(p_setup_sub_task_code     => p_rec.setup_sub_task_code
                           ,p_effective_date          => p_effective_date
                           ,p_object_version_number   => p_rec.object_version_number
                           ,p_setup_sub_task_type     => p_rec.setup_sub_task_type
                         ) ;

  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_ssb_shd.g_rec_type
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
end per_ssb_bus;

/