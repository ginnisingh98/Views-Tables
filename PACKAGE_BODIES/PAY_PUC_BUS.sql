--------------------------------------------------------
--  DDL for Package Body PAY_PUC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PUC_BUS" as
/* $Header: pypucrhi.pkb 115.1 2003/10/29 21:15 tvankayl noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_puc_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_user_column_id              number         default null;
--
-- Cached values for the validation formula.
--
g_formula_type_name varchar2(30) := 'User Table Validation';
g_formula_type_id number := null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_user_column_id                       in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_user_columns puc
     where puc.user_column_id = p_user_column_id
       and pbg.business_group_id = puc.business_group_id;
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
    ,p_argument           => 'user_column_id'
    ,p_argument_value     => p_user_column_id
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
        => nvl(p_associated_column1,'USER_COLUMN_ID')
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
  (p_user_column_id                       in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pay_user_columns puc
     where puc.user_column_id = p_user_column_id
       and pbg.business_group_id (+) = puc.business_group_id;
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
    ,p_argument           => 'user_column_id'
    ,p_argument_value     => p_user_column_id
    );
  --
  if ( nvl(pay_puc_bus.g_user_column_id, hr_api.g_number)
       = p_user_column_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_puc_bus.g_legislation_code;
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
    pay_puc_bus.g_user_column_id              := p_user_column_id;
    pay_puc_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in pay_puc_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_puc_shd.api_updating
      (p_user_column_id                    => p_rec.user_column_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(pay_puc_shd.g_old_rec.business_group_id, hr_api.g_number) then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'BUSINESS_GROUP_ID'
     ,p_base_table => pay_puc_shd.g_tab_nam
     );
  end if;
  --
  if nvl(p_rec.legislation_code, hr_api.g_varchar2) <>
     nvl(pay_puc_shd.g_old_rec.legislation_code, hr_api.g_varchar2) then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'LEGISLATION_CODE'
     ,p_base_table => pay_puc_shd.g_tab_nam
     );
  end if;
  --
  if nvl(p_rec.user_table_id, hr_api.g_number) <>
     pay_puc_shd.g_old_rec.user_table_id then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'USER_TABLE_ID'
     ,p_base_table => pay_puc_shd.g_tab_nam
     );
  end if;
End chk_non_updateable_args;
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
       (p_associated_column1 => 'PAY_USER_COLUMNS.LEGISLATION_CODE'
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
-- |--------------------------< chk_user_table_id >---------------------------|
-- ----------------------------------------------------------------------------
procedure chk_user_table_id
(p_user_table_id     in number
,p_legislation_code  in varchar2
,p_business_group_id in number
) is
--
cursor csr_user_table_id(p_user_table_id in number) is
select put.legislation_code
,      put.business_group_id
from   pay_user_tables put
where  put.user_table_id = p_user_table_id
;
--
l_busgrpid number;
l_legcode  varchar2(100);
l_proc   varchar2(100) := g_package || 'chk_user_table_id';
begin
  --
  -- USER_TABLE_ID is mandatory.
  --
  hr_api.mandatory_arg_error
  (p_api_name       =>  l_proc
  ,p_argument       =>  'USER_TABLE_ID'
  ,p_argument_value =>  p_user_table_id
  );
  --
  open csr_user_table_id(p_user_table_id => p_user_table_id);
  fetch csr_user_table_id
  into  l_legcode
  ,     l_busgrpid
  ;
  if csr_user_table_id%notfound then
    close csr_user_table_id;
    fnd_message.set_name('PAY', 'PAY_33174_PARENT_ID_INVALID');
    fnd_message.set_token('PARENT' , 'User Table Id' );
    fnd_message.raise_error;
  end if;
  close csr_user_table_id;
  --
  -- Confirm that the parent USER_TABLE's startup mode is compatible
  -- with this PAY_USER_COLUMNS row.
  --
  if not pay_put_shd.chk_startup_mode_compatible
         (p_parent_bgid    => l_busgrpid
         ,p_parent_legcode => l_legcode
         ,p_child_bgid     => p_business_group_id
         ,p_child_legcode  => p_legislation_code
         ) then
    fnd_message.set_name('PAY', 'PAY_33175_BGLEG_MISMATCH');
    fnd_message.set_token('CHILD', 'User Column');
    fnd_message.set_token('PARENT' , 'User Table');
    fnd_message.raise_error;
  end if;
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PAY_USER_COLUMNS.USER_TABLE_ID'
       ) then
      raise;
    end if;
  when others then
    if csr_user_table_id%isopen then
      close csr_user_table_id;
    end if;
    raise;
end chk_user_table_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_user_column_name >--------------------------|
-- ----------------------------------------------------------------------------
procedure chk_user_column_name
(p_user_column_id        in number
,p_object_version_number in number
,p_user_column_name      in varchar2
,p_user_table_id         in number
,p_business_group_id     in number
,p_legislation_code      in varchar2
) is
--
cursor csr_name_exists
(p_user_column_name in varchar2
,p_user_table_id    in number
) is
select null
from   pay_user_columns puc
where  puc.user_table_id = p_user_table_id
and    upper(puc.user_column_name) = p_user_column_name
and   (p_business_group_id is null
         or ( p_business_group_id is not null and p_business_group_id = puc.business_group_id )
         or ( p_business_group_id is not null and
			puc.legislation_code is null and puc.business_group_id is null )
	 or ( p_business_group_id is not null and
		        puc.legislation_code = hr_api.return_legislation_code(p_business_group_id )))
and   (p_legislation_code is null
	 or ( p_legislation_code is not null and p_legislation_code = puc.legislation_code )
	 or ( p_legislation_code is not null and
			puc.legislation_code is null and puc.business_group_id is null)
	 or ( p_legislation_code is not null and
			p_legislation_code = hr_api.return_legislation_code(puc.business_group_id )));
--
l_proc   varchar2(100) := g_package || 'chk_user_column_name';
l_name   varchar2(200);
l_exists varchar2(1);
begin
  if hr_multi_message.no_exclusive_error
     (p_check_column1      => 'PAY_USER_COLUMNS.USER_TABLE_ID'
     ,p_associated_column1 => 'PAY_USER_COLUMNS.USER_COLUMN_NAME'
     ) and (
       not pay_puc_shd.api_updating
           (p_user_column_id        => p_user_column_id
           ,p_object_version_number => p_object_version_number
           ) or
       nvl(p_user_column_name, hr_api.g_varchar2) <>
       pay_puc_shd.g_old_rec.user_column_name
    ) then
    --
    -- The name is mandatory.
    --
    hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'USER_COLUMN_NAME'
    ,p_argument_value =>  p_user_column_name
    );
    --
    l_name := upper(p_user_column_name);
    open csr_name_exists(l_name, p_user_table_id);
    fetch csr_name_exists
    into l_exists;
    if csr_name_exists%found then
      close csr_name_exists;
      fnd_message.set_name('PAY','PAY_7885_USER_TABLE_UNIQUE');
      fnd_message.raise_error;
    end if;
    close csr_name_exists;
  end if;
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PAY_USER_COLUMNS.USER_COLUMN_NAME'
       ) then
      raise;
    end if;
  when others then
    if csr_name_exists%isopen then
      close csr_name_exists;
    end if;
    raise;
end chk_user_column_name;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< set_formula_type_id >--------------------------|
-- ----------------------------------------------------------------------------
procedure set_formula_type_id is
begin
  if pay_puc_bus.g_formula_type_id is null then
    select fft.formula_type_id
    into   pay_puc_bus.g_formula_type_id
    from   ff_formula_types fft
    where  formula_type_name = pay_puc_bus.g_formula_type_name
    ;
  end if;
end set_formula_type_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_formula_id >-----------------------------|
-- ----------------------------------------------------------------------------
procedure chk_formula_id
(p_user_column_id        in     number
,p_object_version_number in     number
,p_formula_id            in     number
,p_business_group_id     in     number
,p_legislation_code      in     varchar2
,p_formula_warning          out nocopy boolean
) is
cursor csr_formula_exists(p_formula_id in number) is
select ff.business_group_id
,      ff.legislation_code
from   ff_formulas_f ff
where  ff.formula_id = p_formula_id
and    ff.formula_type_id = pay_puc_bus.g_formula_type_id
;
--
l_updating boolean;
l_ftypeid  number;
l_busgrpid number;
l_legcode  varchar2(150);
begin
  l_updating :=
  pay_puc_shd.api_updating
  (p_user_column_id        => p_user_column_id
  ,p_object_version_number => p_object_version_number
  );
  --
  if not l_updating or
     nvl(p_formula_id, hr_api.g_number) <>
     nvl(pay_puc_shd.g_old_rec.formula_id, hr_api.g_number) then
    --
    -- No need to warn and do anything further if no formula is to be
    -- referenced.
    --
    if p_formula_id is null then
      p_formula_warning := false;
      return;
    --
    -- Potential for table values to become invalid because of a new formula.
    --
    elsif l_updating then
      p_formula_warning := true;
    end if;
    --
    set_formula_type_id;
    open csr_formula_exists(p_formula_id => p_formula_id);
    fetch csr_formula_exists
    into  l_busgrpid
    ,     l_legcode
    ;
    if csr_formula_exists%notfound then
      close csr_formula_exists;
      --
      fnd_message.set_name('PAY', 'PAY_33176_UCOL_FF_NOT_FOUND');
      fnd_message.set_token('FORMULA_TYPE', pay_puc_bus.g_formula_type_name);
      fnd_message.raise_error;
    end if;
    close csr_formula_exists;
    --
    -- Confirm that formula's startup mode is compatible with this
    -- PAY_USER_COLUMNS row. The formula is the parent.
    --
    if not pay_put_shd.chk_startup_mode_compatible
           (p_parent_bgid    => l_busgrpid
           ,p_parent_legcode => l_legcode
           ,p_child_bgid     => p_business_group_id
           ,p_child_legcode  => p_legislation_code
           ) then
      fnd_message.set_name('PAY', 'PAY_33175_BGLEG_MISMATCH');
      fnd_message.set_token('CHILD', 'User Column');
      fnd_message.set_token('PARENT' , 'Formula');
      fnd_message.raise_error;
    end if;
  end if;
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PAY_USER_COLUMNS.FORMULA_ID'
       ) then
      raise;
    end if;
  when others then
    if csr_formula_exists%isopen then
      close csr_formula_exists;
    end if;
    raise;
end chk_formula_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_delete >------------------------------|
-- ----------------------------------------------------------------------------
procedure chk_delete
(p_user_column_id in number
) is
--
-- Only interested in child rows from PAY_USER_COLUMN_INSTANCES_F.
--
cursor csr_values_exist
(p_user_column_id in number
) is
select 'Y'
from   pay_user_column_instances_f uci
where  uci.user_column_id = p_user_column_id
;
--
l_ret  varchar2(1);
begin
  open csr_values_exist(p_user_column_id => p_user_column_id);
  fetch csr_values_exist
  into l_ret;
  if csr_values_exist%found then
    close csr_values_exist;
    fnd_message.set_name('PAY', 'HR_6980_USERTAB_VALUES_FIRST');
    fnd_message.set_token( 'ROWCOL' , 'column' ) ;
    fnd_message.raise_error;
  end if;
  close csr_values_exist;
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PAY_USER_COLUMNS.USER_COLUMN_ID'
       ) then
      raise;
    end if;
  when others then
    if csr_values_exist%isopen then
      close csr_values_exist;
    end if;
    raise;
end chk_delete;
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
  (p_rec                          in pay_puc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_formula_warning boolean;
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
       ,p_associated_column1 => pay_puc_shd.g_tab_nam
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

  chk_user_table_id
  (p_user_table_id     => p_rec.user_table_id
  ,p_business_group_id => p_rec.business_group_id
  ,p_legislation_code  => p_rec.legislation_code
  );
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  chk_user_column_name
  (p_user_table_id         => p_rec.user_table_id
  ,p_user_column_name      => p_rec.user_column_name
  ,p_user_column_id        => p_rec.user_column_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_business_group_id     => p_rec.business_group_id
  ,p_legislation_code      => p_rec.legislation_code
  );
  --
  chk_formula_id
  (p_user_column_id        => p_rec.user_column_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_formula_id            => p_rec.formula_id
  ,p_business_group_id     => p_rec.business_group_id
  ,p_legislation_code      => p_rec.legislation_code
  ,p_formula_warning       => l_formula_warning
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in pay_puc_shd.g_rec_type
  ,p_formula_warning              out nocopy boolean
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
       ,p_associated_column1 => pay_puc_shd.g_tab_nam
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
  chk_user_column_name
  (p_user_table_id         => p_rec.user_table_id
  ,p_user_column_name      => p_rec.user_column_name
  ,p_user_column_id        => p_rec.user_column_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_business_group_id     => p_rec.business_group_id
  ,p_legislation_code      => p_rec.legislation_code
  );
  --
  chk_formula_id
  (p_user_column_id        => p_rec.user_column_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_formula_id            => p_rec.formula_id
  ,p_business_group_id     => p_rec.business_group_id
  ,p_legislation_code      => p_rec.legislation_code
  ,p_formula_warning       => p_formula_warning
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pay_puc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    --
  chk_startup_action(false
		    ,pay_puc_shd.g_old_rec.business_group_id
                    ,pay_puc_shd.g_old_rec.legislation_code
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
  chk_delete(p_user_column_id => p_rec.user_column_id);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_puc_bus;

/
