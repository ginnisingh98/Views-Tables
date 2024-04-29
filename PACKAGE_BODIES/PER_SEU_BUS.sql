--------------------------------------------------------
--  DDL for Package Body PER_SEU_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SEU_BUS" as
/* $Header: peseurhi.pkb 120.4 2005/11/09 13:59:48 vbanner noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := 'per_seu_bus.';  -- Global package name
g_debug    boolean      := hr_utility.debug_enabled;
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_security_user_id            number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_security_user_id                     in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Fetch the security group and legislation code for the business group
  -- context.
  -- WARNING: the business group context is taken from the security profile
  -- but the business_group_id will be null for Global security profiles.
  -- In this case, the cursor will not return a row and a primary key
  -- error will be raised.  For this reason, this procedure is not called
  -- from anywhere else in the row-handler and it is recommended that
  -- this remains the case; lookup validation should use hr_standard_lookups
  -- not hr_lookups.
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , per_security_users seu
         , per_security_profiles psp
     where seu.security_user_id = p_security_user_id
     and   seu.security_profile_id = psp.security_profile_id
     and   psp.business_group_id is not null
     and   pbg.business_group_id = psp.business_group_id;
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
    ,p_argument           => 'security_user_id'
    ,p_argument_value     => p_security_user_id
    );
  --
  -- A row will not be returned for global security profiles.
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id
                       , l_legislation_code;
  --
  if csr_sec_grp%notfound then
     --
     -- Occurs for global security profiles.
     --
     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     hr_multi_message.add
       (p_associated_column1
        => nvl(p_associated_column1,'SECURITY_USER_ID')
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
  (p_security_user_id                     in     number
  )
  Return Varchar2 Is
  --
  -- Fetch the legislation code from the business group.
  -- WARNING: the business group context is taken from the security profile
  -- but the business_group_id will be null for Global security profiles.
  -- In this case, the cursor will not return a row and a primary key
  -- error will be raised.  For this reason, this procedure is not called
  -- from anywhere else in the row-handler and it is recommended that
  -- this remains the case; lookup validation should use hr_standard_lookups
  -- not hr_lookups.

  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , per_security_users seu
         , per_security_profiles psp
     where seu.security_user_id = p_security_user_id
     and   seu.security_profile_id = psp.security_profile_id
     and   psp.business_group_id is not null
     and   pbg.business_group_id = psp.business_group_id;
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
    ,p_argument           => 'security_user_id'
    ,p_argument_value     => p_security_user_id
    );
  --
  if ( nvl(per_seu_bus.g_security_user_id, hr_api.g_number)
       = p_security_user_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_seu_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    --
    -- A row will not be returned for global security profiles.
    --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      -- The primary key is invalid therefore we must error;
      -- occurs for global security profiles.
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
    per_seu_bus.g_security_user_id  := p_security_user_id;
    per_seu_bus.g_legislation_code  := l_legislation_code;
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
--
Procedure chk_non_updateable_args
  (p_effective_date               in date
  ,p_rec in per_seu_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_seu_shd.api_updating
      (p_security_user_id                  => p_rec.security_user_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- All values (besides the primary key) can be updated so there is
  -- no additional non-updateable argument checking.
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_user_id >------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_user_id
  (p_security_user_id      in number
  ,p_user_id               in number
  ,p_object_version_number in number
  ,p_effective_date        in date
  ) IS

  --
  -- Local variables.
  --
  l_proc         varchar2(72) := g_package || 'chk_user_id';
  l_api_updating boolean;
  l_user_id      number;

  --
  -- Verifies the user exists and is effective.
  --
  CURSOR csr_chk_user IS
  SELECT fndu.user_id
  FROM   fnd_user_view fndu
  WHERE  fndu.user_id = p_user_id
  AND    p_effective_date BETWEEN
         fndu.start_date and NVL(fndu.end_date, hr_api.g_eot);
--
Begin

  IF g_debug THEN
    hr_utility.set_location('Entering: '||l_proc, 10);
  END IF;

  --
  -- Only proceed with validation if:
  --  a) inserting or
  --  b) updating and the parameters used within this chk procedure
  --     have not changed.
  --
  l_api_updating := per_seu_shd.api_updating
    (p_security_user_id      => p_security_user_id
    ,p_object_version_number => p_object_version_number);

  IF (l_api_updating
  AND NVL(per_seu_shd.g_old_rec.user_id, hr_api.g_number)
    = NVL(p_user_id, hr_api.g_number)) THEN
    RETURN;
  END IF;

  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_user_id',
                             p_argument_value => p_user_id);


  OPEN  csr_chk_user;
  FETCH csr_chk_user INTO l_user_id;
  CLOSE csr_chk_user;

  IF l_user_id IS NULL THEN
    --
    -- If the user_id is null, the user either does not exist, or
    -- is not effective as of the effective date passed in.
    --
    IF g_debug THEN
      hr_utility.set_location(l_proc, 20);
    END IF;

    hr_utility.set_message(800, 'HR_50128_INVALID_USER');
    hr_multi_message.add
      (p_associated_column1 => 'PER_SECURITY_USERS.USER_ID');

  END IF;

  IF g_debug THEN
    hr_utility.set_location(' Leaving:'|| l_proc, 999);
  END IF;

End chk_user_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_security_profile_id >------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_security_profile_id
  (p_security_user_id      in number
  ,p_security_profile_id   in number
  ,p_object_version_number in number
  ) IS

  --
  -- Local variables.
  --
  l_proc         varchar2(72) := g_package || 'chk_security_profile_id';
  l_api_updating boolean;
  l_security_profile_id number;

  --
  -- Verifies the security profile exists.
  --
  CURSOR csr_chk_sec_prof IS
  SELECT psp.security_profile_id
  FROM   per_security_profiles psp
  WHERE  psp.security_profile_id = p_security_profile_id;

--
Begin

  IF g_debug THEN
    hr_utility.set_location('Entering: '||l_proc, 10);
  END IF;

  --
  -- Only proceed with validation if:
  --  a) inserting or
  --  b) updating and the parameters used within this chk procedure
  --     have not changed.
  --
  l_api_updating := per_seu_shd.api_updating
    (p_security_user_id      => p_security_user_id
    ,p_object_version_number => p_object_version_number);

  IF (l_api_updating
  AND NVL(per_seu_shd.g_old_rec.security_profile_id, hr_api.g_number)
    = NVL(p_security_profile_id, hr_api.g_number)) THEN
    RETURN;
  END IF;

  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_security_profile_id',
                             p_argument_value => p_security_profile_id);


  OPEN  csr_chk_sec_prof;
  FETCH csr_chk_sec_prof INTO l_security_profile_id;
  CLOSE csr_chk_sec_prof;

  IF l_security_profile_id IS NULL THEN
    --
    -- If the security_profile_id is null, then the security profile
    -- does not exist.
    --
    IF g_debug THEN
      hr_utility.set_location(l_proc, 20);
    END IF;

    hr_utility.set_message(800, 'HR_50143_INVALID_SEC_PROF');
    hr_multi_message.add
      (p_associated_column1 => 'PER_SECURITY_USERS.SECURITY_PROFILE_ID');

  END IF;

  IF g_debug THEN
    hr_utility.set_location(' Leaving:'|| l_proc, 999);
  END IF;

END chk_security_profile_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_association_unique >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_association_unique
  (p_security_user_id      in number
  ,p_user_id               in number
  ,p_security_profile_id   in number
  ,p_object_version_number in number
  ) IS

  --
  -- Local variables.
  --
  l_proc         varchar2(72) := g_package || 'chk_association_unique';
  l_api_updating boolean;
  l_user_id      number;

  --
  -- Verifies that a row does not already exist for this user in this
  -- security profile.
  --
  CURSOR csr_chk_unique IS
  SELECT seu.user_id
  FROM   per_security_users seu
  WHERE  seu.user_id = p_user_id
  AND    seu.security_profile_id = p_security_profile_id
  AND    seu.security_user_id <> NVL(p_security_profile_id, hr_api.g_number);

--
Begin

  IF g_debug THEN
    hr_utility.set_location('Entering: '||l_proc, 10);
  END IF;

  --
  -- Only proceed with validation if:
  --  a) inserting or
  --  b) updating and the parameters used within this chk procedure
  --     have not changed.
  --
  l_api_updating := per_seu_shd.api_updating
    (p_security_user_id      => p_security_user_id
    ,p_object_version_number => p_object_version_number);

  IF (l_api_updating
  AND NVL(per_seu_shd.g_old_rec.user_id, hr_api.g_number)
    = NVL(p_user_id, hr_api.g_number)
  AND NVL(per_seu_shd.g_old_rec.security_profile_id, hr_api.g_number)
    = NVL(p_security_profile_id, hr_api.g_number)) THEN
    RETURN;
  END IF;

  IF hr_multi_message.no_exclusive_error
    (p_check_column1 => 'PER_SECURITY_USERS.USER_ID'
    ,p_check_column2 => 'PER_SECURITY_USERS.SECURITY_PROFILE_ID')
  THEN
    --
    -- Only proceed if the dependent validation has not errored.
    --
    IF g_debug THEN
      hr_utility.set_location(l_proc, 20);
    END IF;

    OPEN  csr_chk_unique;
    FETCH csr_chk_unique INTO l_user_id;
    CLOSE csr_chk_unique;

    IF l_user_id IS NOT NULL THEN
      --
      -- If the user_id is set then this user / security profile association
      -- is not unique; raise an error.
      --
      IF g_debug THEN
        hr_utility.set_location(l_proc, 30);
      END IF;

      hr_utility.set_message(800, 'HR_50145_SEU_NOT_UNIQUE');
      hr_multi_message.add
        (p_associated_column1 => 'PER_SECURITY_USERS.USER_ID'
        ,p_associated_column2 => 'PER_SECURITY_USERS.SECURITY_PROFILE_ID');

    END IF;

  END IF;

  IF g_debug THEN
    hr_utility.set_location(' Leaving:'|| l_proc, 999);
  END IF;

END chk_association_unique;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_process_in_next_run_flag >-----------------------|
-- ----------------------------------------------------------------------------
--
-- bug 4338667
Procedure chk_process_in_next_run_flag
  (p_security_user_id         in number
  ,p_process_in_next_run_flag in varchar2
  ,p_object_version_number    in number
  ) IS

  --
  -- Local variables.
  --
  l_proc         varchar2(72) := g_package || 'chk_process_in_next_run_flag';
  l_api_updating boolean;

--
Begin

  IF g_debug THEN
    hr_utility.set_location('Entering: '||l_proc, 10);
  END IF;
  --
  -- Only proceed with validation if:
  --  a) inserting or
  --  b) updating and the parameters used within this chk procedure
  --     have not changed.
  --
  l_api_updating := per_seu_shd.api_updating
    (p_security_user_id      => p_security_user_id
    ,p_object_version_number => p_object_version_number);

  IF (l_api_updating
    AND NVL(per_seu_shd.g_old_rec.process_in_next_run_flag, hr_api.g_varchar2)
      = NVL(p_process_in_next_run_flag, hr_api.g_varchar2)) THEN
    RETURN;
  END IF;

  IF p_process_in_next_run_flag NOT IN (NULL,'Y','N')
  THEN
    --
    -- If the process_in_next_run_flag is not null, Y or N
    -- raise an error message informing the user of this fact.
    --
    hr_utility.set_message(800, 'HR_50292_INVALID_PINR_FLAG');
    hr_multi_message.add
      (p_associated_column1 => 'PER_SECURITY_USERS.PROCESS_IN_NEXT_RUN_FLAG');

    IF g_debug THEN
      hr_utility.set_location(l_proc, 69);
      hr_utility.set_location('process_in_next_run_flag is not null Y or N',69);
    END IF;
  END IF;

  IF g_debug THEN
    hr_utility.set_location(' Leaving:'|| l_proc, 999);
  END IF;

END chk_process_in_next_run_flag;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_seu_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin

  IF g_debug THEN
    hr_utility.set_location('Entering:'||l_proc, 5);
  END IF;

  --
  -- Call all supporting business operations
  --
  --
  -- This table does not have a mandatory business_group_id
  -- column, so client_info is not populated by calling the
  -- per_seu_bus.set_security_group_id procedure.
  -- Here, validation is performed without a business group context,
  -- so any lookup code validation should use HR_STANDARD_LOOKUPS and not
  -- HR_LOOKUPs.
  --

  --
  -- Exclusive validation.
  --
  -- Validate the security profile.
  --
  per_seu_bus.chk_security_profile_id
    (p_security_user_id      => p_rec.security_user_id
    ,p_security_profile_id   => p_rec.security_profile_id
    ,p_object_version_number => p_rec.object_version_number);

  IF g_debug THEN
    hr_utility.set_location(l_proc, 10);
  END IF;

  --
  -- Validate the user.
  --
  per_seu_bus.chk_user_id
    (p_security_user_id      => p_rec.security_user_id
    ,p_user_id               => p_rec.user_id
    ,p_object_version_number => p_rec.object_version_number
    ,p_effective_date        => p_effective_date);

  --
  -- Validate the process_in_next_run_flag
  --
  per_seu_bus.chk_process_in_next_run_flag
  (p_security_user_id       => p_rec.security_user_id
  ,p_process_in_next_run_flag  => p_rec.process_in_next_run_flag
  ,p_object_version_number => p_rec.object_version_number);

  --
  -- End exclusive validation.
  --
  hr_multi_message.end_validation_set;

  IF g_debug THEN
    hr_utility.set_location(l_proc, 20);
  END IF;

  --
  -- Dependent validation.
  --
  -- Association uniqueness check.
  --
  per_seu_bus.chk_association_unique
    (p_security_user_id      => p_rec.security_user_id
    ,p_user_id               => p_rec.user_id
    ,p_security_profile_id   => p_rec.security_profile_id
    ,p_object_version_number => p_rec.object_version_number);

  IF g_debug THEN
    hr_utility.set_location(' Leaving:'||l_proc, 999);
  END IF;

End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_seu_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin

  IF g_debug THEN
    hr_utility.set_location('Entering:'||l_proc, 5);
  END IF;

  --
  -- Call all supporting business operations
  --
  --
  -- This table does not have a mandatory business_group_id
  -- column, so client_info is not populated by calling the
  -- per_seu_bus.set_security_group_id procedure.
  -- Here, validation is performed without a business group context,
  -- so any lookup code validation should use HR_STANDARD_LOOKUPS and not
  -- HR_LOOKUPS.
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date     => p_effective_date
    ,p_rec                => p_rec
    );

  --
  -- Validate the security profile.
  --
  per_seu_bus.chk_security_profile_id
    (p_security_user_id      => p_rec.security_user_id
    ,p_security_profile_id   => p_rec.security_profile_id
    ,p_object_version_number => p_rec.object_version_number);

  IF g_debug THEN
    hr_utility.set_location(l_proc, 10);
  END IF;

  --
  -- Validate the user.
  --
  per_seu_bus.chk_user_id
    (p_security_user_id      => p_rec.security_user_id
    ,p_user_id               => p_rec.user_id
    ,p_object_version_number => p_rec.object_version_number
    ,p_effective_date        => p_effective_date);

  --
  -- Validate the process_in_next_run_flag
  --
  per_seu_bus.chk_process_in_next_run_flag
  (p_security_user_id       => p_rec.security_user_id
  ,p_process_in_next_run_flag  => p_rec.process_in_next_run_flag
  ,p_object_version_number => p_rec.object_version_number);

  --
  -- End exclusive validation.
  --
  hr_multi_message.end_validation_set;

  IF g_debug THEN
    hr_utility.set_location(l_proc, 20);
  END IF;

  --
  -- Dependent validation.
  --
  -- Association uniqueness check.
  --
  per_seu_bus.chk_association_unique
    (p_security_user_id      => p_rec.security_user_id
    ,p_user_id               => p_rec.user_id
    ,p_security_profile_id   => p_rec.security_profile_id
    ,p_object_version_number => p_rec.object_version_number);

  IF g_debug THEN
    hr_utility.set_location(' Leaving:'||l_proc, 999);
  END IF;

End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_seu_shd.g_rec_type
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
end per_seu_bus;

/
