--------------------------------------------------------
--  DDL for Package Body PQH_CRF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CRF_BUS" as
/* $Header: pqcrfrhi.pkb 120.0 2005/10/06 14:52 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_crf_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_criteria_rate_factor_id     number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_criteria_rate_factor_id              in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , pqh_criteria_rate_factors crf
     where crf.criteria_rate_factor_id = p_criteria_rate_factor_id
       and pbg.business_group_id (+) = crf.business_group_id;
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
    ,p_argument           => 'criteria_rate_factor_id'
    ,p_argument_value     => p_criteria_rate_factor_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id
                       , l_legislation_code;
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
        => nvl(p_associated_column1,'CRITERIA_RATE_FACTOR_ID')
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
  (p_criteria_rate_factor_id              in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , pqh_criteria_rate_factors crf
     where crf.criteria_rate_factor_id = p_criteria_rate_factor_id
       and pbg.business_group_id (+) = crf.business_group_id;
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
    ,p_argument           => 'criteria_rate_factor_id'
    ,p_argument_value     => p_criteria_rate_factor_id
    );
  --
  if ( nvl(pqh_crf_bus.g_criteria_rate_factor_id, hr_api.g_number)
       = p_criteria_rate_factor_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqh_crf_bus.g_legislation_code;
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
    pqh_crf_bus.g_criteria_rate_factor_id     := p_criteria_rate_factor_id;
    pqh_crf_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in pqh_crf_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pqh_crf_shd.api_updating
      (p_criteria_rate_factor_id           => p_rec.criteria_rate_factor_id
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
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
	     nvl(pqh_crf_shd.g_old_rec.business_group_id
	        ,hr_api.g_number
	        ) then
	    hr_api.argument_changed_error
	      (p_api_name   => l_proc
	      ,p_argument   => 'BUSINESS_GROUP_ID'
	      ,p_base_table => pqh_crf_shd.g_tab_nam
	      );
  end if;
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_startup_action >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will check that the current action is allowed according
--  to the current startup mode.
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_startup_action
  (p_insert               IN boolean
  ,p_business_group_id    IN number
  ,p_legislation_code     IN varchar2
  ,p_legislation_subgroup IN varchar2 DEFAULT NULL) IS
--
BEGIN
  --
  -- Call the supporting procedure to check startup mode
  -- EDIT_HERE: The following call should be edited if certain types of rows
  -- are not permitted.
  IF (p_insert) THEN
    hr_startup_data_api_support.chk_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  ELSE
    hr_startup_data_api_support.chk_upd_del_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  END IF;
  --
END chk_startup_action;

-- ----------------------------------------------------------------------------
-- |------< chk_criteria_rate_defn_id>------|
-- ----------------------------------------------------------------------------

-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_criteria_rate_factor_id PK
--   p_criteria_rate_defn_id ID of FK column
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_criteria_rate_defn_id (p_criteria_rate_factor_id          in number,
                            p_criteria_rate_defn_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_criteria_rate_defn_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --

  cursor c1 is
    select null from PQH_CRITERIA_RATE_DEFN a
    where  a.criteria_rate_defn_id = p_criteria_rate_defn_id;

  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,10);
  --

  l_api_updating := pqh_crf_shd.api_updating
     (p_criteria_rate_factor_id            => p_criteria_rate_factor_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_criteria_rate_defn_id,hr_api.g_number)
     <> nvl(pqh_crf_shd.g_old_rec.criteria_rate_defn_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if criteria_rate_defn_id value exists in
    -- PQH_CRITERIA_RATE_DEFN table
    --
    open c1;
      --

     fetch c1 into l_dummy;

      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in PQH_CRITERIA_RATE_DEFN
        -- table.
        --
        pqh_crf_shd.constraint_error('PQH_CRITERIA_RATE_FACTORS_FK1');
        --
      end if;
      --
    close c1;

    --
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,90);
  --
End chk_criteria_rate_defn_id;
--



-- ----------------------------------------------------------------------------
-- |------< chk_parent_rate_matrix_id >------|
-- ----------------------------------------------------------------------------

-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_criteria_rate_factor_id PK
--   p_parent_rate_matrix_id ID of FK column
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_parent_rate_matrix_id (p_criteria_rate_factor_id          in number,
                            p_parent_rate_matrix_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_parent_rate_matrix_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null from BEN_PL_F a
    where  a.pl_id = p_parent_rate_matrix_id;

  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,10);
  --

  l_api_updating := pqh_crf_shd.api_updating
     (p_criteria_rate_factor_id            => p_criteria_rate_factor_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_parent_rate_matrix_id,hr_api.g_number)
     <> nvl(pqh_crf_shd.g_old_rec.parent_rate_matrix_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if PL_ID value exists in
    -- BEN_PL_F table
    --
    open c1;
      --
        fetch c1 into l_dummy;

      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in BEN_PL_F
        -- table.
        --
        pqh_crf_shd.constraint_error('PQH_CRITERIA_RATE_FACTORS_FK4');
        --
      end if;
      --
    close c1;

    --
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,90);
  --
End chk_parent_rate_matrix_id;
--





-- ----------------------------------------------------------------------------
-- |------< chk_business_group_id>------|
-- ----------------------------------------------------------------------------

-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_criteria_rate_factor_id PK
--   p_business_group_id ID of FK column
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_business_group_id (p_criteria_rate_factor_id          in number,
                            p_business_group_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_business_group_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null from   HR_ALL_ORGANIZATION_UNITS a
    where  a.business_group_id = p_business_group_id;

  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,10);
  --

  l_api_updating := pqh_crf_shd.api_updating
     (p_criteria_rate_factor_id            => p_criteria_rate_factor_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_business_group_id,hr_api.g_number)
     <> nvl(pqh_crf_shd.g_old_rec.business_group_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if business_group_id value exists in
    -- HR_ALL_ORGANIZATION_UNITS table
    --
    open c1;
      --

       fetch c1 into l_dummy;

      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in HR_ALL_ORGANIZATION_UNITS
        -- table.
        --
        pqh_crf_shd.constraint_error('PQH_CRITERIA_RATE_FACTORS_FK3');
        --
      end if;
      --
    close c1;

    --
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,90);
  --
End chk_business_group_id;
--



















--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in pqh_crf_shd.g_rec_type
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
  chk_startup_action(true
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     hr_api.validate_bus_grp_id
       (p_business_group_id => p_rec.business_group_id
       ,p_associated_column1 => pqh_crf_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
     --
     -- after validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  --
  -- Validate Dependent Attributes
  --
  --

  chk_criteria_rate_defn_id
 				   (
                            p_criteria_rate_factor_id        => p_rec.criteria_rate_factor_id,
				    p_criteria_rate_defn_id          => p_rec.criteria_rate_defn_id,
				    p_object_version_number =>	 p_rec.object_version_number
                            );

 IF p_rec.parent_rate_matrix_id IS NOT NULL THEN
  chk_parent_rate_matrix_id
				  (p_criteria_rate_factor_id        => p_rec.criteria_rate_factor_id,
				   p_parent_rate_matrix_id          => p_rec.parent_rate_matrix_id,
				   p_object_version_number          => p_rec.object_version_number);
 END IF;


  -- check parent_criteria_rate_defn_id
  chk_criteria_rate_defn_id
 				   (
                            p_criteria_rate_factor_id        => p_rec.criteria_rate_factor_id,
				    p_criteria_rate_defn_id          => p_rec.parent_criteria_rate_defn_id,
				    p_object_version_number =>	 p_rec.object_version_number
                            );


 IF p_rec.business_group_id IS NOT NULL THEN
  chk_business_group_id
  (p_criteria_rate_factor_id          => p_rec.criteria_rate_factor_id,
   p_business_group_id          => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
 END IF;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in pqh_crf_shd.g_rec_type
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
  chk_startup_action(false
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     hr_api.validate_bus_grp_id
       (p_business_group_id => p_rec.business_group_id
       ,p_associated_column1 => pqh_crf_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
     --
     -- After validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  --
  -- Validate Dependent Attributes
  --
 chk_criteria_rate_defn_id
 				   (
                            p_criteria_rate_factor_id        => p_rec.criteria_rate_factor_id,
				    p_criteria_rate_defn_id          => p_rec.criteria_rate_defn_id,
				    p_object_version_number =>	 p_rec.object_version_number
                            );

 IF p_rec.parent_rate_matrix_id IS NOT NULL THEN
  chk_parent_rate_matrix_id
				  (p_criteria_rate_factor_id        => p_rec.criteria_rate_factor_id,
				   p_parent_rate_matrix_id          => p_rec.parent_rate_matrix_id,
				   p_object_version_number          => p_rec.object_version_number);
 END IF;


  --- check parent_criteria_rate_defn_id
  chk_criteria_rate_defn_id
 				   (
                            p_criteria_rate_factor_id        => p_rec.criteria_rate_factor_id,
				    p_criteria_rate_defn_id          => p_rec.parent_criteria_rate_defn_id,
				    p_object_version_number =>	 p_rec.object_version_number
                            );


 IF p_rec.business_group_id IS NOT NULL THEN
  chk_business_group_id
  (p_criteria_rate_factor_id          => p_rec.criteria_rate_factor_id,
   p_business_group_id          => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
 END IF;

  chk_non_updateable_args
    (p_rec              => p_rec
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
  (p_rec                          in pqh_crf_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    --
  chk_startup_action(false
                    ,pqh_crf_shd.g_old_rec.business_group_id
                    ,pqh_crf_shd.g_old_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     --
     -- After validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pqh_crf_bus;

/
