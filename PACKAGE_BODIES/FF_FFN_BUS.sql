--------------------------------------------------------
--  DDL for Package Body FF_FFN_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_FFN_BUS" as
/* $Header: ffffnrhi.pkb 120.1 2005/10/05 01:50 adkumar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ff_ffn_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_function_id                 number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_function_id                          in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , ff_functions ffn
     where ffn.function_id = p_function_id
       and pbg.business_group_id (+) = ffn.business_group_id;
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
    ,p_argument           => 'function_id'
    ,p_argument_value     => p_function_id
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
        => nvl(p_associated_column1,'FUNCTION_ID')
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
  (p_function_id                          in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , ff_functions ffn
     where ffn.function_id = p_function_id
       and pbg.business_group_id (+) = ffn.business_group_id;
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
    ,p_argument           => 'function_id'
    ,p_argument_value     => p_function_id
    );
  --
  if ( nvl(ff_ffn_bus.g_function_id, hr_api.g_number)
       = p_function_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ff_ffn_bus.g_legislation_code;
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
    ff_ffn_bus.g_function_id                 := p_function_id;
    ff_ffn_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_legislation_code>-------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that the legislation code exists in fnd_territories
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_legislation_code
--
--  Post Success:
--    Processing continues if the legislation_code is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the legislation_code is invalid.
--
--  Developer/Implementation Notes:
--    None
--
--  Access Status:
--    Internal Row Handler Use Only
--
procedure chk_legislation_code
( p_legislation_code  in varchar2 )
is
--
cursor csr_legislation_code is
select null
from fnd_territories
where territory_code = p_legislation_code ;
--
l_exists varchar2(1);
l_proc   varchar2(100) := g_package || 'chk_legislation_code';
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  open csr_legislation_code;
  fetch csr_legislation_code into l_exists ;

  if csr_legislation_code%notfound then
    close csr_legislation_code;
    fnd_message.set_name('PAY', 'PAY_33177_LEG_CODE_INVALID');
    fnd_message.raise_error;
  end if;
  close csr_legislation_code;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'FF_FUNCTIONS.LEGISLATION_CODE'
       ) then
      raise;
    end if;
  when others then
    if csr_legislation_code%isopen then
      close csr_legislation_code;
    end if;
    raise;
end chk_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_class >-----------------------------------|
-- ----------------------------------------------------------------------------
procedure chk_class
(p_effective_date               in date
,p_class                        in varchar2
) is
--
l_proc   varchar2(100) := g_package || 'chk_class';
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- CLASS is mandatory.
  --
  hr_api.mandatory_arg_error
  (p_api_name       =>  l_proc
  ,p_argument       =>  'CLASS'
  ,p_argument_value =>  p_class
  );
  hr_utility.set_location('Entering:'|| l_proc, 20);
  if hr_api.not_exists_in_hrstanlookups
    (p_effective_date => p_effective_date
    ,p_lookup_type    => 'FUNCTION_CLASS'
    ,p_lookup_code    => p_class
       ) then
      ff_ffn_shd.constraint_error('FF_FUNC_CLASS_CHK');
  end if;
  --
  hr_utility.set_location('Entering:'|| l_proc, 30);
  -- User defined functions are not allowed.
  if (p_class = 'U') then
      ff_ffn_shd.constraint_error('FF_FUNC_CLASS_CHK');
  end if;
  --
  hr_utility.set_location('Entering:'|| l_proc, 40);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'FF_FUNCTIONS.CLASS'
       ) then
      raise;
    end if;
end chk_class;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_data_type >-------------------------------|
-- ----------------------------------------------------------------------------
procedure chk_data_type
(p_effective_date               in date
,p_data_type                    in varchar2
) is
--
l_proc   varchar2(100) := g_package || 'chk_data_type';
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- DATA_TYPE is mandatory.
  --
  hr_api.mandatory_arg_error
  (p_api_name       =>  l_proc
  ,p_argument       =>  'DATA_TYPE'
  ,p_argument_value =>  p_data_type
  );

  if hr_api.not_exists_in_hrstanlookups
    (p_effective_date => p_effective_date
    ,p_lookup_type    => 'DATA_TYPE'
    ,p_lookup_code    => p_data_type
       ) then
      ff_ffn_shd.constraint_error('FF_FUNC_DATA_TYPE_CHK');
  end if;
  --
  hr_utility.set_location('Entering:'|| l_proc, 20);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'FF_FUNCTIONS.DATA_TYPE'
       ) then
      raise;
    end if;
end chk_data_type;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_name >------------------------------------|
-- ----------------------------------------------------------------------------
procedure chk_name
(p_name                        in varchar2
) is
--
l_proc   varchar2(100) := g_package || 'chk_name';
dummy    varchar2(80);
l_name   varchar2(80);
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- NAME is mandatory.
  --
  hr_api.mandatory_arg_error
  (p_api_name       =>  l_proc
  ,p_argument       =>  'NAME'
  ,p_argument_value =>  p_name
  );
  --
   if (p_name is not null) then
      l_name := p_name;
      hr_chkfmt.checkformat (l_name,
	                    'PAY_NAME',
		             dummy,
                             null,
                             null,
                             'N',
                             dummy,
                             null);
   end if;
  --
  hr_utility.set_location('Entering:'|| l_proc, 20);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'FF_FUNCTIONS.NAME'
       ) then
      raise;
    end if;
end chk_name;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_alias_name >----------------------------|
-- ----------------------------------------------------------------------------
procedure chk_alias_name
(p_alias_name            in varchar2
,p_name                  in varchar2
) is
--
l_proc   varchar2(100) := g_package || 'chk_alias_name';
dummy    varchar2(80);
l_name   varchar2(80);
begin

    --
    -- The Alias Name cannot be same as Name.
    --
    if (p_alias_name = p_name) then
      fnd_message.set_name('FF','FF_52245_BAD_ALIAS_NAME');
      fnd_message.raise_error;
    end if;

   -- Special character can not be used in alias name.
   --
   if (p_alias_name is not null) then
      l_name := p_alias_name;
      hr_chkfmt.checkformat (l_name,
	                    'PAY_NAME',
		             dummy,
                             null,
                             null,
                             'N',
                             dummy,
                             null);
   end if;
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'FF_FUNCTIONS.ALIAS_NAME'
       ) then
      raise;
    end if;
end chk_alias_name;
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
  ,p_rec in ff_ffn_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ff_ffn_shd.api_updating
      (p_function_id                       => p_rec.function_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(ff_ffn_shd.g_old_rec.business_group_id, hr_api.g_number) then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'BUSINESS_GROUP_ID'
     ,p_base_table => ff_ffn_shd.g_tab_nam
     );
  end if;
  --
  if nvl(p_rec.legislation_code, hr_api.g_varchar2) <>
     nvl(ff_ffn_shd.g_old_rec.legislation_code, hr_api.g_varchar2) then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'LEGISLATION_CODE'
     ,p_base_table => ff_ffn_shd.g_tab_nam
     );
  end if;

  if nvl(p_rec.function_id, hr_api.g_number) <>
     nvl(ff_ffn_shd.g_old_rec.function_id, hr_api.g_number) then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'FUNCTION_ID'
     ,p_base_table => ff_ffn_shd.g_tab_nam
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

  IF (p_insert) THEN

	if p_business_group_id is not null and p_legislation_code is not null then
        fnd_message.set_name('PAY', 'PAY_33179_BGLEG_INVALID');
        fnd_message.raise_error;
    end if;

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
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in ff_ffn_shd.g_rec_type
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
       ,p_associated_column1 => ff_ffn_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
     --
     -- after validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;

  --
  -- ----------------------------------------------------------------------------
  IF hr_startup_data_api_support.g_startup_mode
                     IN ('STARTUP') THEN

   chk_legislation_code
       (p_legislation_code    => p_rec.legislation_code);
  End if;
  --
  -- ----------------------------------------------------------------------------

  --
  --
  -- Validate Dependent Attributes
  --
 -----------------------------------------------------------------------------
  chk_class(p_effective_date  => p_effective_date
           ,p_class           => p_rec.class
           );
  -----------------------------------------------------------------------------
  chk_data_type(p_effective_date => p_effective_date
               ,p_data_type      => p_rec.data_type
               );

  -----------------------------------------------------------------------------
  chk_name(p_name  => p_rec.name);

  -----------------------------------------------------------------------------
  chk_alias_name(p_alias_name            => p_rec.alias_name
                ,p_name                  => p_rec.name
                );
  -----------------------------------------------------------------------------
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);

End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in ff_ffn_shd.g_rec_type
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
       ,p_associated_column1 => ff_ffn_shd.g_tab_nam
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
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
 -----------------------------------------------------------------------------
  chk_class(p_effective_date  => p_effective_date
           ,p_class           => p_rec.class
           );
  -----------------------------------------------------------------------------
  chk_data_type(p_effective_date => p_effective_date
               ,p_data_type      => p_rec.data_type
               );

  -----------------------------------------------------------------------------
  chk_name(p_name  => p_rec.name);

  -----------------------------------------------------------------------------
  chk_alias_name(p_alias_name            => p_rec.alias_name
                ,p_name                  => p_rec.name
                );
  -----------------------------------------------------------------------------
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in ff_ffn_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    --
  chk_startup_action(false
                    ,ff_ffn_shd.g_old_rec.business_group_id
                    ,ff_ffn_shd.g_old_rec.legislation_code
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
end ff_ffn_bus;

/
