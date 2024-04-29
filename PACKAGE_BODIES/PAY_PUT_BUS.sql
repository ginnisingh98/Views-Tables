--------------------------------------------------------
--  DDL for Package Body PAY_PUT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PUT_BUS" as
/* $Header: pyputrhi.pkb 115.0 2003/09/23 08:07 tvankayl noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_put_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_user_table_id               number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_user_table_id                        in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups_perf pbg
         , pay_user_tables put
     where put.user_table_id = p_user_table_id
       and pbg.business_group_id = put.business_group_id;
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
    ,p_argument           => 'user_table_id'
    ,p_argument_value     => p_user_table_id
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
        => nvl(p_associated_column1,'USER_TABLE_ID')
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
  (p_user_table_id                        in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_user_tables put
     where put.user_table_id = p_user_table_id
       and pbg.business_group_id (+) = put.business_group_id;
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
    ,p_argument           => 'user_table_id'
    ,p_argument_value     => p_user_table_id
    );
  --
  if ( nvl(pay_put_bus.g_user_table_id, hr_api.g_number)
       = p_user_table_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_put_bus.g_legislation_code;
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
    pay_put_bus.g_user_table_id               := p_user_table_id;
    pay_put_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_legislation_code>-------------------------|
-- ----------------------------------------------------------------------------
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
       (p_associated_column1 => 'PAY_USER_TABLES.LEGISLATION_CODE'
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
-- |--------------------------< chk_range_or_match >--------------------------|
-- ----------------------------------------------------------------------------
procedure chk_range_or_match
(p_effective_date in date
,p_range_or_match in varchar2
) is
begin
  if hr_api.not_exists_in_hrstanlookups
     (p_effective_date => p_effective_date
     ,p_lookup_type    => 'RANGE_MATCH'
     ,p_lookup_code    => p_range_or_match
     ) then
    pay_put_shd.constraint_error('PAY_UTAB_RANGE_OR_MATCH_CHK');
  end if;
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PAY_USER_TABLES.RANGE_OR_MATCH'
       ) then
      raise;
    end if;
end chk_range_or_match;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_user_key_units >--------------------------|
-- ----------------------------------------------------------------------------
procedure chk_user_key_units
(p_effective_date in date
,p_range_or_match in varchar2
,p_user_key_units in varchar2
) is
l_associated_column2 varchar2(80) := null;
begin
  if hr_multi_message.no_exclusive_error
     (p_check_column1      => 'PAY_USER_TABLES.RANGE_OR_MATCH'
     ,p_associated_column1 => 'PAY_USER_TABLES.USER_KEY_UNITS'
     ) then
    if hr_api.not_exists_in_hrstanlookups
       (p_effective_date => p_effective_date
       ,p_lookup_type    => 'DATA_TYPE'
       ,p_lookup_code    => p_user_key_units
       ) then
      pay_put_shd.constraint_error('PAY_UTAB_USER_KEY_UNITS_CHK');
    elsif p_range_or_match = 'R' and p_user_key_units <> 'N' then
      l_associated_column2 := 'PAY_USER_TABLES.RANGE_OR_MATCH';
      fnd_message.set_name('PAY','PAY_33173_UTAB_BAD_RANGE_UNITS');
      fnd_message.raise_error;
    end if;
  end if;
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PAY_USER_TABLES.USER_KEY_UNITS'
       ,p_associated_column2 => l_associated_column2
       ) then
      raise;
    end if;
end chk_user_key_units;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_user_table_name >--------------------------|
-- ----------------------------------------------------------------------------
procedure chk_user_table_name
(p_user_table_id         in number
,p_object_version_number in number
,p_user_table_name       in varchar2
,p_business_group_id     in number
,p_legislation_code      in varchar2
) is
--
-- GENERIC row name clash.
--
cursor csr_name_exists_generic
(p_user_table_name in varchar2
) is
select null
from   pay_user_tables put
where  upper(put.user_table_name) = p_user_table_name
;
--
-- STARTUP row name clash.
--
cursor csr_name_exists_startup
(p_user_table_name  in varchar2
,p_legislation_code in varchar2
) is
select null
from   pay_user_tables put
,      per_business_groups_perf pbg
where  upper(put.user_table_name) = p_user_table_name
and    ((put.business_group_id = pbg.business_group_id and
         pbg.legislation_code = p_legislation_code) or
        (put.legislation_code = p_legislation_code) or
        (put.legislation_code is null and put.business_group_id is null))
;
--
-- USER row name clash.
--
cursor csr_name_exists_user
(p_user_table_name   in varchar2
,p_business_group_id in number
) is
select null
from   pay_user_tables put
,      per_business_groups_perf pbg
where  upper(put.user_table_name) = p_user_table_name
and    ((put.business_group_id = p_business_group_id) or
        (pbg.business_group_id = p_business_group_id and
         pbg.legislation_code = put.legislation_code) or
        (put.legislation_code is null and put.business_group_id is null))
;
--
l_proc   varchar2(100) := g_package || 'chk_user_table_name';
l_name   varchar2(200);
l_exists varchar2(1);
begin
  if not pay_put_shd.api_updating
         (p_user_table_id         => p_user_table_id
         ,p_object_version_number => p_object_version_number
         ) or
     nvl(p_user_table_name, hr_api.g_varchar2) <>
     pay_put_shd.g_old_rec.user_table_name then
    --
    -- The name is mandatory.
    --
    hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'USER_TABLE_NAME'
    ,p_argument_value =>  p_user_table_name
    );
    --
    l_name := upper(p_user_table_name);
    if hr_startup_data_api_support.g_startup_mode = 'USER' then
      open csr_name_exists_user(l_name, p_business_group_id);
      fetch csr_name_exists_user
      into l_exists;
      if csr_name_exists_user%found then
        l_exists := 'Y';
      end if;
      close csr_name_exists_user;
    elsif hr_startup_data_api_support.g_startup_mode = 'STARTUP' then
      open csr_name_exists_startup(l_name, p_legislation_code);
      fetch csr_name_exists_startup
      into l_exists;
      if csr_name_exists_startup%found then
        l_exists := 'Y';
      end if;
      close csr_name_exists_startup;
    elsif hr_startup_data_api_support.g_startup_mode = 'GENERIC' then
      open csr_name_exists_generic(l_name);
      fetch csr_name_exists_generic
      into l_exists;
      if csr_name_exists_generic%found then
        l_exists := 'Y';
      end if;
      close csr_name_exists_generic;
    end if;
    --
    -- Raise an error if the name already exists.
    --
    if l_exists = 'Y' then
      fnd_message.set_name('PAY','PAY_7689_USER_TAB_TAB_UNIQUE');
      fnd_message.raise_error;
    end if;
  end if;
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PAY_USER_TABLES.USER_TABLE_NAME'
       ) then
      raise;
    end if;
  when others then
    if csr_name_exists_user%isopen then
      close csr_name_exists_user;
    elsif csr_name_exists_startup%isopen then
      close csr_name_exists_startup;
    elsif  csr_name_exists_generic%isopen then
      close csr_name_exists_generic;
    end if;
    raise;
end chk_user_table_name;
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
  (p_rec in pay_put_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_put_shd.api_updating
      (p_user_table_id                     => p_rec.user_table_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(pay_put_shd.g_old_rec.business_group_id, hr_api.g_number) then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'BUSINESS_GROUP_ID'
     ,p_base_table => pay_put_shd.g_tab_nam
     );
  end if;
  --
  if nvl(p_rec.legislation_code, hr_api.g_varchar2) <>
     nvl(pay_put_shd.g_old_rec.legislation_code, hr_api.g_varchar2) then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'LEGISLATION_CODE'
     ,p_base_table => pay_put_shd.g_tab_nam
     );
  end if;
  --
  if nvl(p_rec.user_key_units, hr_api.g_varchar2) <>
     pay_put_shd.g_old_rec.user_key_units then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'USER_KEY_UNITS'
     ,p_base_table => pay_put_shd.g_tab_nam
     );
  end if;
  --
  if nvl(p_rec.range_or_match, hr_api.g_varchar2) <>
     pay_put_shd.g_old_rec.range_or_match then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'RANGE_OR_MATCH'
     ,p_base_table => pay_put_shd.g_tab_nam
     );
  end if;
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_delete >------------------------------|
-- ----------------------------------------------------------------------------
procedure chk_delete
(p_user_table_id in number
) is
cursor csr_rows_exist
(p_user_table_id in number
) is
select 'Y'
from   pay_user_rows_f pur
where  pur.user_table_id = p_user_table_id
;
--
cursor csr_columns_exist
(p_user_table_id in number
) is
select null
from   pay_user_columns puc
where  puc.user_table_id = p_user_table_id
;
--
l_ret  varchar2(1);
begin
  open csr_rows_exist(p_user_table_id => p_user_table_id);
  fetch csr_rows_exist
  into l_ret;
  if csr_rows_exist%found then
    close csr_rows_exist;
    fnd_message.set_name('PAY', 'PAY_6369_USERTAB_ROWS_FIRST');
    hr_multi_message.add(p_associated_column1 => 'PAY_USER_TABLES.USER_TABLE_ID');
  else
    close csr_rows_exist;
  end if;
  --
  open csr_columns_exist(p_user_table_id => p_user_table_id);
  fetch csr_columns_exist
  into l_ret;
  if csr_columns_exist%found then
    close csr_columns_exist;
    fnd_message.set_name('PAY', 'PAY_6368_USERTAB_COLUMNS_FIRST');
    hr_multi_message.add(p_associated_column1 => 'PAY_USER_TABLES.USER_TABLE_ID');
  else
    close csr_columns_exist;
  end if;
exception
  when others then
    if csr_rows_exist%isopen then
      close csr_rows_exist;
    elsif csr_columns_exist%isopen then
      close csr_columns_exist;
    end if;
    raise;
end chk_delete;
--
-- ---------------------------------------------------------------------------
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
  ,p_rec                          in pay_put_shd.g_rec_type
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
       ,p_associated_column1 => pay_put_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
     --
     -- after validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  if hr_startup_data_api_support.g_startup_mode not in ('GENERIC','USER') then

     --
     -- Validate Important Attributes
     --
        chk_legislation_code(p_legislation_code => p_rec.legislation_code);
     --
        hr_multi_message.end_validation_set;

  end if;
  --
  --
  -- Validate Dependent Attributes
  --
  --
  chk_range_or_match
  (p_effective_date => p_effective_date
  ,p_range_or_match => p_rec.range_or_match
  );
  --
  chk_user_key_units
  (p_effective_date => p_effective_date
  ,p_range_or_match => p_rec.range_or_match
  ,p_user_key_units => p_rec.user_key_units
  );
  --
  chk_user_table_name
  (p_user_table_id         => p_rec.user_table_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_user_table_name       => p_rec.user_table_name
  ,p_business_group_id     => p_rec.business_group_id
  ,p_legislation_code      => p_rec.legislation_code
  );
  --
  -- ROW_TITLE is not validated.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in pay_put_shd.g_rec_type
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
       ,p_associated_column1 => pay_put_shd.g_tab_nam
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
    (p_rec              => p_rec
    );
  --
  chk_user_table_name
  (p_user_table_id         => p_rec.user_table_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_user_table_name       => p_rec.user_table_name
  ,p_business_group_id     => p_rec.business_group_id
  ,p_legislation_code      => p_rec.legislation_code
  );
  --
  -- ROW_TITLE is not validated.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pay_put_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    --
  chk_startup_action(false
                    ,pay_put_shd.g_old_rec.business_group_id
                    ,pay_put_shd.g_old_rec.legislation_code
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
  chk_delete(p_user_table_id => p_rec.user_table_id);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_put_bus;

/
