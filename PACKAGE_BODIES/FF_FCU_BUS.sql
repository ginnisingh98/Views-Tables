--------------------------------------------------------
--  DDL for Package Body FF_FCU_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_FCU_BUS" as
/* $Header: fffcurhi.pkb 120.1 2005/10/05 01:51 adkumar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ff_fcu_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_function_id                 number         default null;
g_sequence_number             number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_function_id                          in number
  ,p_sequence_number                      in number
  ,p_associated_column1                   in varchar2 default null
  ,p_associated_column2                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- ff_function_context_usages and PER_BUSINESS_GROUPS_PERF
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , ff_functions fnc
     where fnc.function_id = p_function_id
       and pbg.business_group_id(+) = fnc.business_group_id;
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
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'sequence_number'
    ,p_argument_value     => p_sequence_number
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
      ,p_associated_column2
        => nvl(p_associated_column2,'SEQUENCE_NUMBER')
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
  ,p_sequence_number                      in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- ff_function_context_usages and PER_BUSINESS_GROUPS_PERF
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , ff_function_context_usages fcu
         , ff_functions fff
     where fcu.function_id = fff.function_id
       and fcu.function_id = p_function_id
       and fcu.sequence_number = p_sequence_number
       and pbg.business_group_id = fff.business_group_id;
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
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'sequence_number'
    ,p_argument_value     => p_sequence_number
    );
  --
  if (( nvl(ff_fcu_bus.g_function_id, hr_api.g_number)
       = p_function_id)
  and ( nvl(ff_fcu_bus.g_sequence_number, hr_api.g_number)
       = p_sequence_number)) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ff_fcu_bus.g_legislation_code;
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
    ff_fcu_bus.g_function_id                 := p_function_id;
    ff_fcu_bus.g_sequence_number             := p_sequence_number;
    ff_fcu_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in ff_fcu_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ff_fcu_shd.api_updating
      (p_function_id                       => p_rec.function_id
      ,p_sequence_number                   => p_rec.sequence_number
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
    --
  --
  if nvl(p_rec.function_id, hr_api.g_number) <>
     ff_fcu_shd.g_old_rec.function_id then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'FUNCTION_ID'
     ,p_base_table => ff_fcu_shd.g_tab_nam
     );
  end if;
  --
  if nvl(p_rec.sequence_number, hr_api.g_number) <>
     ff_fcu_shd.g_old_rec.sequence_number then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'SEQUENCE_NUMBER'
     ,p_base_table => ff_fcu_shd.g_tab_nam
     );
  end if;
  --
End chk_non_updateable_args;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_function_id >---------------------------|
-- ----------------------------------------------------------------------------
procedure chk_function_id
(p_function_id     in number
) is
--
cursor csr_function_id(p_function_id in number) is
select NULL
from   FF_FUNCTIONS fnc
where  fnc.function_id = p_function_id
;
--
l_proc   varchar2(100) := g_package || 'chk_function_id';
l_exists varchar2(1);

begin
  --
  -- FUNCTION_ID is mandatory.
  --
  hr_api.mandatory_arg_error
  (p_api_name       =>  l_proc
  ,p_argument       =>  'FUNCTION_ID'
  ,p_argument_value =>  p_function_id
  );
  --
  open csr_function_id(p_function_id => p_function_id);
  fetch csr_function_id into l_exists;
  if csr_function_id%notfound then
    close csr_function_id;
    ff_fcu_shd.constraint_error('FF_FUNCTION_CONTEXT_USAGES_FK1');
  end if;
  close csr_function_id;
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'FF_FUNCTION_CONTEXT_USAGES.FUNCTION_ID'
       ) then
      raise;
    end if;
  when others then
    if csr_function_id%isopen then
      close csr_function_id;
    end if;
    raise;
end chk_function_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_context_id >---------------------------|
-- ----------------------------------------------------------------------------
procedure chk_context_id
(p_context_id      in number
) is
--
  cursor csr_context is
  select NULL
    from FF_CONTEXTS fc
   where fc.context_id = p_context_id;

  --
  l_proc   varchar2(100) := g_package || 'chk_context_id';
  l_exists varchar2(1);
begin
  -- CONTEXT_ID is mandatory.
  --
  hr_api.mandatory_arg_error
  (p_api_name       =>  l_proc
  ,p_argument       =>  'CONTEXT_ID'
  ,p_argument_value =>  p_context_id
  );
  --
  open csr_context;
  fetch csr_context into l_exists;
  if csr_context%notfound then
    close csr_context;
    ff_fcu_shd.constraint_error('FF_FUNCTION_CONTEXT_USAGES_FK2');
  end if;
  close csr_context;
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'FF_FUNCTION_CONTEXT_USAGES.CONTEXT_ID'
       ) then
      raise;
    end if;
  when others then
    if csr_context%isopen then
      close csr_context;
    end if;
    raise;
end chk_context_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_unique >----------------------------------|
-- ----------------------------------------------------------------------------
procedure chk_unique
(p_function_id     in number
,p_context_id      in number
,p_sequence_number in number
) is
--
cursor csr_unique_context
is
select NULL
from ff_function_context_usages ffcu
where ffcu.function_id = p_function_id
and ffcu.context_id = p_context_id
and ffcu.sequence_number <> nvl(p_sequence_number,-1);
--
l_proc   varchar2(100) := g_package || 'chk_unique';
l_exists varchar2(1);

begin
  --
  --
  if hr_multi_message.no_exclusive_error
     (p_check_column1      => 'FF_FUNCTION_CONTEXT_USAGES.FUNCTION_ID'
     ,p_check_column2      => 'FF_FUNCTION_CONTEXT_USAGES.CONTEXT_ID'
     ,p_associated_column1 => 'FF_FUNCTION_CONTEXT_USAGES.FUNCTION_ID'
     ,p_associated_column2 => 'FF_FUNCTION_CONTEXT_USAGES.CONTEXT_ID'
     ) then

     open csr_unique_context;
     fetch csr_unique_context into l_exists;
     if csr_unique_context%found then
       close csr_unique_context;
       ff_fcu_shd.constraint_error('FF_FUNCTION_CONTEXT_USAGES_UK2');
     end if;
     close csr_unique_context;
  end if;
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_same_associated_columns => 'Y'
       ) then
      raise;
    end if;
  when others then
    if csr_unique_context%isopen then
      close csr_unique_context;
    end if;
    raise;
end chk_unique;
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
  (p_rec                          in ff_fcu_shd.g_rec_type
  ) is
--
  cursor csr_business_group is
  select  business_group_id
        , legislation_code
    from FF_FUNCTIONS fnc
   where fnc.function_id = p_rec.function_id;
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_business_group_id ff_functions.business_group_id%type;
  l_legislation_code  ff_functions.legislation_code%type;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
   -- Call all supporting business operations
  --
  -----------------------------------------------------------------------------
  chk_function_id(p_function_id  => p_rec.function_id);
  -----------------------------------------------------------------------------
  open csr_business_group;
  fetch csr_business_group into l_business_group_id,l_legislation_code;
  close csr_business_group;

  chk_startup_action(true
                    ,l_business_group_id
                    ,l_legislation_code
                    );

  --

  -- Validate Dependent Attributes
  --
  -----------------------------------------------------------------------------
  chk_context_id(p_context_id   => p_rec.context_id);

  -----------------------------------------------------------------------------
  chk_unique(p_function_id  => p_rec.function_id
            ,p_context_id   => p_rec.context_id
	    ,p_sequence_number => p_rec.sequence_number);

  hr_utility.set_location(' Leaving:'||l_proc, 10);

End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in ff_fcu_shd.g_rec_type
  ) is
--
  cursor csr_business_group is
  select  business_group_id
        , legislation_code
    from FF_FUNCTIONS fnc
   where fnc.function_id = p_rec.function_id;
--
  l_business_group_id ff_functions.business_group_id%type;
  l_legislation_code  ff_functions.legislation_code%type;
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -----------------------------------------------------------------------------
  chk_function_id(p_function_id  => p_rec.function_id);
  -----------------------------------------------------------------------------
  open csr_business_group;
  fetch csr_business_group into l_business_group_id,l_legislation_code;
  close csr_business_group;

  chk_startup_action(true
                    ,l_business_group_id
                    ,l_legislation_code
                    );

  --

  -- Validate Dependent Attributes
  --
  -----------------------------------------------------------------------------
  chk_context_id(p_context_id   => p_rec.context_id);

  -----------------------------------------------------------------------------
  chk_unique(p_function_id  => p_rec.function_id
            ,p_context_id   => p_rec.context_id
	    ,p_sequence_number => p_rec.sequence_number);

  -----------------------------------------------------------------------------
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
  (p_rec                          in ff_fcu_shd.g_rec_type
  ) is
--
  cursor csr_business_group is
  select  business_group_id
        , legislation_code
    from FF_FUNCTIONS fnc
   where fnc.function_id = p_rec.function_id;
--
  l_business_group_id ff_functions.business_group_id%type;
  l_legislation_code  ff_functions.legislation_code%type;
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -----------------------------------------------------------------------------
  chk_function_id(p_function_id  => p_rec.function_id);
  -----------------------------------------------------------------------------
  open csr_business_group;
  fetch csr_business_group into l_business_group_id,l_legislation_code;
  close csr_business_group;

  chk_startup_action(true
                    ,l_business_group_id
                    ,l_legislation_code
                    );
  --
  -- Validate Dependent Attributes
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ff_fcu_bus;

/
