--------------------------------------------------------
--  DDL for Package Body PAY_UCI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_UCI_BUS" as
/* $Header: pyucirhi.pkb 120.0.12010000.2 2009/07/22 15:13:11 npannamp ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_uci_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_user_column_instance_id     number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_user_column_instance_id              in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_user_column_instances_f uci
     where uci.user_column_instance_id = p_user_column_instance_id
       and pbg.business_group_id = uci.business_group_id;
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
    ,p_argument           => 'user_column_instance_id'
    ,p_argument_value     => p_user_column_instance_id
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
         => nvl(p_associated_column1,'USER_COLUMN_INSTANCE_ID')
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
  (p_user_column_instance_id              in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pay_user_column_instances_f uci
     where uci.user_column_instance_id = p_user_column_instance_id
       and pbg.business_group_id (+) = uci.business_group_id;
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
    ,p_argument           => 'user_column_instance_id'
    ,p_argument_value     => p_user_column_instance_id
    );
  --
  if ( nvl(pay_uci_bus.g_user_column_instance_id, hr_api.g_number)
       = p_user_column_instance_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_uci_bus.g_legislation_code;
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
    pay_uci_bus.g_user_column_instance_id     := p_user_column_instance_id;
    pay_uci_bus.g_legislation_code  := l_legislation_code;
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
  (p_effective_date  in date
  ,p_rec             in pay_uci_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_uci_shd.api_updating
      (p_user_column_instance_id          => p_rec.user_column_instance_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  --
  if nvl(p_rec.user_row_id, hr_api.g_number) <>
     pay_uci_shd.g_old_rec.user_row_id then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'USER_ROW_ID'
     ,p_base_table => pay_uci_shd.g_tab_nam
     );
  end if;
  --
  if nvl(p_rec.user_column_id, hr_api.g_number) <>
     pay_uci_shd.g_old_rec.user_column_id then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'USER_COLUMN_ID'
     ,p_base_table => pay_uci_shd.g_tab_nam
     );
  end if;
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(pay_uci_shd.g_old_rec.business_group_id, hr_api.g_number) then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'BUSINESS_GROUP_ID'
     ,p_base_table => pay_uci_shd.g_tab_nam
     );
  end if;
  --
  if nvl(p_rec.legislation_code, hr_api.g_varchar2) <>
     nvl(pay_uci_shd.g_old_rec.legislation_code, hr_api.g_varchar2) then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'LEGISLATION_CODE'
     ,p_base_table => pay_uci_shd.g_tab_nam
     );
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_update_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   parent entities when a datetrack update operation is taking place
--   and where there is no cascading of update defined for this entity.
--
-- Prerequisites:
--   This procedure is called from the update_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_validate
  (p_user_row_id                   in number default hr_api.g_number
  ,p_datetrack_mode                in varchar2
  ,p_validation_start_date         in date
  ,p_validation_end_date           in date
  ) Is
--
  l_proc  varchar2(72) := g_package||'dt_update_validate';
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Mode will be valid, as this is checked at the start of the upd.
  --
  -- Ensure the arguments are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
  --
  If ((nvl(p_user_row_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'pay_user_rows_f'
            ,p_base_key_column => 'USER_ROW_ID'
            ,p_base_key_value  => p_user_row_id
            ,p_from_date       => p_validation_start_date
            ,p_to_date         => p_validation_end_date))) Then
     fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
     fnd_message.set_token('TABLE_NAME','user rows');
     hr_multi_message.add
       (p_associated_column1 => pay_uci_shd.g_tab_nam || '.USER_ROW_ID');
  End If;
  --
Exception
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
End dt_update_validate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_delete_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   child entities when either a datetrack DELETE or ZAP is in operation
--   and where there is no cascading of delete defined for this entity.
--   For the datetrack mode of DELETE or ZAP we must ensure that no
--   datetracked child rows exist between the validation start and end
--   dates.
--
-- Prerequisites:
--   This procedure is called from the delete_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a row exists by determining the returning Boolean value from the
--   generic dt_api.rows_exist function then we must supply an error via
--   the use of the local exception handler l_rows_exist.
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_validate
  (p_user_column_instance_id          in number
  ,p_datetrack_mode                   in varchar2
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ) Is
--
  l_proc        varchar2(72)    := g_package||'dt_delete_validate';
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = hr_api.g_delete or
      p_datetrack_mode = hr_api.g_zap) then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_start_date'
      ,p_argument_value => p_validation_start_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_end_date'
      ,p_argument_value => p_validation_end_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'user_column_instance_id'
      ,p_argument_value => p_user_column_instance_id
      );
    --
  --
    --
  End If;
  --
Exception
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  --
End dt_delete_validate;
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
       (p_associated_column1 => 'PAY_USER_COLUMN_INSTANCES_F.LEGISLATION_CODE'
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
-- |--------------------------< chk_user_row_id >-----------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that the user_row_id exists in pay_user_rows_f for the life span
--    of the row being inserted.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_user_row_id
--    p_legislation_code
--    p_business_group_id
--    p_validation_start_date
--    p_validation_end_date
--
--  Post Success:
--    Processing continues if the user_row_id is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the user_row_id is invalid.
--
--  Developer/Implementation Notes:
--    None
--
--  Access Status:
--    Internal Row Handler Use Only
--
procedure chk_user_row_id
(p_user_row_id     in number
,p_legislation_code  in varchar2
,p_business_group_id in number
,p_validation_start_date in date
,p_validation_end_date in date
) is
--
cursor csr_user_row_id is
select pur.legislation_code , pur.business_group_id , min(effective_start_date) , max(effective_end_date)
from   pay_user_rows_f pur
where  pur.user_row_id = p_user_row_id group by pur.business_group_id , pur.legislation_code ;

--
l_busgrpid PAY_USER_ROWS_F.BUSINESS_GROUP_ID%TYPE;
l_legcode  PAY_USER_ROWS_F.LEGISLATION_CODE%TYPE;
l_min_esd  PAY_USER_ROWS_F.EFFECTIVE_START_DATE%TYPE;
l_max_eed  PAY_USER_ROWS_F.EFFECTIVE_END_DATE%TYPE;
l_proc   varchar2(100) := g_package || 'chk_user_row_id';
--
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- USER_ROW_ID is mandatory.
  --
  hr_api.mandatory_arg_error
  (p_api_name       =>  l_proc
  ,p_argument       =>  'USER_ROW_ID'
  ,p_argument_value =>  p_user_row_id
  );
  --
  --
  open csr_user_row_id;
  fetch csr_user_row_id into l_legcode, l_busgrpid , l_min_esd , l_max_eed;

  if not (l_min_esd <= p_validation_start_date and l_max_eed >= p_validation_end_date ) then
    close csr_user_row_id;
    fnd_message.set_name('PAY', 'PAY_33174_PARENT_ID_INVALID');
    fnd_message.set_token('PARENT' , 'User Row Id' );
    fnd_message.raise_error;
  end if;
  close csr_user_row_id;
  --
  -- Confirm that the parent USER_ROW's startup mode is compatible
  -- with this row.
  --
  if not pay_put_shd.chk_startup_mode_compatible
         (p_parent_bgid    => l_busgrpid
         ,p_parent_legcode => l_legcode
         ,p_child_bgid     => p_business_group_id
         ,p_child_legcode  => p_legislation_code
         ) then
     fnd_message.set_name('PAY', 'PAY_33175_BGLEG_MISMATCH');
     fnd_message.set_token('CHILD', 'User Value');
     fnd_message.set_token('PARENT' , 'User Row');
     fnd_message.raise_error;
  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PAY_USER_COLUMN_INSTANCES_F.USER_ROW_ID'
       ) then
      raise;
    end if;
  when others then
    if csr_user_row_id%isopen then
      close csr_user_row_id;
    end if;
    raise;

end chk_user_row_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_user_column_id >--------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that the user_column_id exists in pay_user_columns
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_user_table_id
--    p_legislation_code
--    p_business_group_id
--
--  Post Success:
--    Processing continues if the user_column_id is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the user_column_id is invalid.
--
--  Developer/Implementation Notes:
--    None
--
--  Access Status:
--    Internal Row Handler Use Only
--
procedure chk_user_column_id
(p_user_column_id     in number
,p_legislation_code  in varchar2
,p_business_group_id in number
) is
--
cursor csr_user_column_id is
select puc.legislation_code , puc.business_group_id
from   pay_user_columns puc
where  puc.user_column_id = p_user_column_id ;
--
l_busgrpid PAY_USER_COLUMNS.BUSINESS_GROUP_ID%TYPE;
l_legcode  PAY_USER_COLUMNS.LEGISLATION_CODE%TYPE;

l_proc   varchar2(100) := g_package || 'chk_user_column_id';
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- USER_COLUMN_ID is mandatory.
  --
  hr_api.mandatory_arg_error
  (p_api_name       =>  l_proc
  ,p_argument       =>  'USER_COLUMN_ID'
  ,p_argument_value =>  p_user_column_id
  );
  --
  open csr_user_column_id;
  fetch csr_user_column_id into l_legcode, l_busgrpid ;

  if csr_user_column_id%notfound then
    close csr_user_column_id;
    fnd_message.set_name('PAY', 'PAY_33174_PARENT_ID_INVALID');
    fnd_message.set_token('PARENT' , 'User Column Id' );
    fnd_message.raise_error;
  end if;
  close csr_user_column_id;
  --
  -- Confirm that the parent USER_COLUMN's startup mode is compatible
  -- with this child row.
  --
  if not pay_put_shd.chk_startup_mode_compatible
         (p_parent_bgid    => l_busgrpid
         ,p_parent_legcode => l_legcode
         ,p_child_bgid     => p_business_group_id
         ,p_child_legcode  => p_legislation_code
         ) then
      fnd_message.set_name('PAY', 'PAY_33175_BGLEG_MISMATCH');
      fnd_message.set_token('CHILD', 'User Value');
      fnd_message.set_token('PARENT' , 'User Column');
      fnd_message.raise_error;
  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PAY_USER_COLUMN_INSTANCES_F.USER_COLUMN_ID'
       ) then
      raise;
    end if;
  when others then
    if csr_user_column_id%isopen then
      close csr_user_column_id;
    end if;
    raise;

end chk_user_column_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_row_column_id >-----------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that there may only one row in PAY_USER_COLUMN_INSTANCES_F
--    with the combination of USER_ROW_ID and USER_COLUMN_ID for the life time
--    of the row being insert for the specified and in a particular business
--    group or legislation.
--
--  Pre-Requisites:
--    User row id and User column id must be validated.
--
--  In Parameters:
--    p_user_row_id
--    p_user_column_id
--    p_legislation_code
--    p_business_group_id
--    p_validation_start_date
--    p_validation_end_date
--
--  Post Success:
--    Processing continues if the combination is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the combination is invalid.
--
--  Developer/Implementation Notes:
--    None
--
--  Access Status:
--    Internal Row Handler Use Only
--
procedure chk_row_column_id
( p_user_row_id in number
 ,p_user_column_id  in number
 ,p_business_group_id in number
 ,p_legislation_code in varchar2
 ,p_validation_start_date in date
 ,p_validation_end_date in date
) is
--
cursor csr_row_column_id is
select  null
from pay_user_column_instances_f uci
where uci.user_row_id = p_user_row_id
and uci.user_column_id = p_user_column_id
and ( p_business_group_id is null
        or ( p_business_group_id is not null and p_business_group_id = uci.business_group_id )
	or ( p_business_group_id is not null and
		uci.legislation_code is null and uci.business_group_id is null )
	or ( p_business_group_id is not null and
	        uci.legislation_code = hr_api.return_legislation_code(p_business_group_id )))
and ( p_legislation_code is null
	or ( p_legislation_code is not null and p_legislation_code = uci.legislation_code )
	or ( p_legislation_code is not null and
		uci.legislation_code is null and uci.business_group_id is null)
	or ( p_legislation_code is not null and
		p_legislation_code = hr_api.return_legislation_code(uci.business_group_id )))
and (uci.effective_start_date <= p_validation_end_date and
			uci.effective_end_date >= p_validation_start_date );

l_proc   varchar2(100) := g_package || 'chk_row_column_id';
l_exists varchar2(1);
--
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);

  if hr_multi_message.no_exclusive_error
     (p_check_column1      => 'PAY_USER_COLUMN_INSTANCES_F.USER_ROW_ID'
     ,p_check_column2      => 'PAY_USER_COLUMN_INSTANCES_F.USER_COLUMN_ID'
     ,p_associated_column1 => 'PAY_USER_COLUMN_INSTANCES_F.USER_ROW_ID'
     ,p_associated_column2 => 'PAY_USER_COLUMN_INSTANCES_F.USER_COLUMN_ID'
     ) then
    --
	    open csr_row_column_id;
	    fetch csr_row_column_id into l_exists;

  	    if csr_row_column_id%found then
	        close csr_row_column_id;
	        fnd_message.set_name('PAY', 'PAY_7038_USERTAB_VALUE_UNIQUE');
                fnd_message.raise_error;
	    end if;

	    close csr_row_column_id;

  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);

exception

    when app_exception.application_exception then
       if hr_multi_message.exception_add
         (p_associated_column1 => 'PAY_USER_COLUMN_INSTANCES_F.USER_ROW_ID',
          p_associated_column2 => 'PAY_USER_COLUMN_INSTANCES_F.USER_COLUMN_ID') then
	      raise;
       end if;

    when others then
	if csr_row_column_id%isopen then
		close csr_row_column_id ;
	end if;
       raise;

end chk_row_column_id ;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_value > ---------------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    If formula_id on the column identified by user_column_id is not null
--    then p_value is validated by calling the formula. This is done for
--    multiple date-track versions of the formula if applicable.
--
--  Pre-Requisites:
--    User Column Id must be validate
--
--  In Parameters:
--    p_user_column_instance_id
--    p_user_column_id
--    p_value
--    p_effective_date
--    p_object_version_number
--    p_business_group_id
--    p_validation_start_date
--    p_validation_end_date
--
--  Post Success:
--    Processing continues if the p_value is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the p_value is invalid.
--
--  Developer/Implementation Notes:
--    None
--
--  Access Status:
--    Internal Row Handler Use Only
--
Procedure chk_value
  (p_user_column_instance_id in number
  ,p_user_column_id        in number
  ,p_value                 in varchar2
  ,p_business_group_id     in number
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ,p_object_version_number in number
  ,p_effective_date        in date
  ) is
--

l_formula_id PAY_USER_COLUMNS.FORMULA_ID%TYPE;
l_min_esd PAY_USER_COLUMN_INSTANCES_F.EFFECTIVE_START_DATE%TYPE;
l_max_eed PAY_USER_COLUMN_INSTANCES_F.EFFECTIVE_END_DATE%TYPE;

l_version_esd PAY_USER_COLUMN_INSTANCES_F.EFFECTIVE_START_DATE%TYPE;
l_version_eed PAY_USER_COLUMN_INSTANCES_F.EFFECTIVE_END_DATE%TYPE;

l_proc              varchar2(72) := g_package||'chk_value';
l_formula_status    varchar2(10);
l_formula_message   fnd_new_messages.message_text%type;
l_inputs            ff_exec.inputs_t;
l_outputs           ff_exec.outputs_t;

cursor csr_formula_id  is
select puc.formula_id
from pay_user_columns puc
where puc.user_column_id = p_user_column_id;

cursor csr_formula_exists is
select min(ff.effective_start_date) , max(ff.effective_end_date)
from ff_formulas_f ff
where ff.formula_id = l_formula_id ;

cursor csr_formula_versions is
select ff.effective_start_date , ff.effective_end_date
from ff_formulas_f ff
where ff.formula_id = l_formula_id
and ff.effective_start_date <= p_validation_end_date
and ff.effective_end_date >= p_validation_start_date ;

--

Begin

  hr_utility.set_location(' Entering:'||l_proc, 10);
  --

  if hr_multi_message.no_exclusive_error
     (p_check_column1      => 'PAY_USER_COLUMN_INSTANCES_F.USER_COLUMN_ID'
     ,p_associated_column1 => 'PAY_USER_COLUMN_INSTANCES_F.VALUE'
     ) and (
       not pay_uci_shd.api_updating
              (p_user_column_instance_id  => p_user_column_instance_id
	      ,p_effective_date        => p_effective_date
	      ,p_object_version_number => p_object_version_number
              ) or
       nvl(p_value, hr_api.g_varchar2) <>
       nvl(pay_uci_shd.g_old_rec.value, hr_api.g_varchar2)
     ) then
    --
	open csr_formula_id;
	fetch csr_formula_id into l_formula_id;
	close csr_formula_id;

	if l_formula_id is not null then

		open csr_formula_exists;
		fetch csr_formula_exists into  l_min_esd , l_max_eed ;
		close csr_formula_exists;

		if l_min_esd <= p_validation_start_date and l_max_eed >= p_validation_end_date then

 		    open csr_formula_versions;

		    loop

		 	fetch csr_formula_versions into l_version_esd , l_version_eed;
			exit when csr_formula_versions%NOTFOUND;

			ff_exec.init_formula(l_formula_id,
                        		     l_version_esd,
                         		     l_inputs,
                                             l_outputs );

 			if l_inputs.count >= 1 then
			       -- Set up the inputs and contexts to formula.

		        for i in l_inputs.first..l_inputs.last loop

         	 		if l_inputs(i).name = 'BUSINESS_GROUP_ID' then
			             -- Set the business_group_id context.
			             l_inputs(i).value := p_business_group_id;
			        elsif l_inputs(i).name = 'ENTRY_VALUE' then
			             -- Set the input to the entry value to be validated.
             			     l_inputs(i).value := p_value;
         	 		else
			             -- No context recognised.
			             close csr_formula_versions;
			             fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
			             fnd_message.set_token('PROCEDURE', l_proc);
			             fnd_message.set_token('STEP','20');
				     fnd_message.raise_error;
			        end if;
		        end loop;
                        end if;

			ff_exec.run_formula(l_inputs, l_outputs);

		        if l_outputs.count <> 2 then
			        close csr_formula_versions;
			        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
			        fnd_message.set_token('PROCEDURE', l_proc);
			        fnd_message.set_token('STEP','30');
			        fnd_message.raise_error;
			end if;

			--

			for i in l_outputs.first..l_outputs.last loop

				if l_outputs(i).name = 'FORMULA_MESSAGE' then
		          		l_formula_message := l_outputs(i).value;
        			elsif l_outputs(i).name = 'FORMULA_STATUS' then
          				l_formula_status := upper(l_outputs(i).value);
        			else
			                close csr_formula_versions;
          				fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
				        fnd_message.set_token('PROCEDURE', l_proc);
				        fnd_message.set_token('STEP','40');
				        fnd_message.raise_error;

        			End if;
			End loop;

			If l_formula_status <> 'S' then
		                close csr_formula_versions;
				if l_formula_message is null then
					-- User not defined an error message.
				        --
				        fnd_message.set_name('PAY','PAY_33180_INVALID_USER_VALUE');
				        fnd_message.raise_error;
			        Else
				        -- User has defined message and so we can raise it.
					fnd_message.set_name( 'PAY' , 'HR_7998_ALL_EXEMACRO_MESSAGE') ;
				        fnd_message.set_token( 'MESSAGE' , l_formula_message ) ;
				        fnd_message.raise_error;
			        End if;
			        --
			End if;
			--
		    end loop;
 		    close csr_formula_versions;
	        else
			fnd_message.set_name('PAY','PAY_33181_UVAL_FF_NOT_FOUND');
			fnd_message.raise_error;
		end if;
	end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 50);

Exception
    when app_exception.application_exception then
       if hr_multi_message.exception_add
         (p_associated_column1 => 'PAY_USER_COLUMN_INSTANCES_F.VALUE') then
	      raise;
       end if;

    when others then
	if csr_formula_id%isopen then
		close csr_formula_id ;
	end if;
	if csr_formula_exists%isopen then
		close csr_formula_exists ;
	end if;
	if csr_formula_versions%isopen then
		close csr_formula_versions ;
	end if;
       raise;

End chk_value;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in pay_uci_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_validate';
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
       ,p_associated_column1 => pay_uci_shd.g_tab_nam
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

  chk_user_row_id
  (p_user_row_id => p_rec.user_row_id
  ,p_legislation_code => p_rec.legislation_code
  ,p_business_group_id => p_rec.business_group_id
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date => p_validation_end_date
  );

  chk_user_column_id
  (p_user_column_id => p_rec.user_column_id
  ,p_legislation_code => p_rec.legislation_code
  ,p_business_group_id =>p_rec.business_group_id
  );

  chk_row_column_id
  (p_user_row_id => p_rec.user_row_id
  ,p_user_column_id  => p_rec.user_column_id
  ,p_business_group_id => p_rec.business_group_id
  ,p_legislation_code  => p_rec.legislation_code
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date => p_validation_end_date
  );
/* The chk_value is not required when run from hrglobal through LDT upload */
/* Bug 8636760 */
IF hr_startup_data_api_support.g_startup_mode NOT IN ('STARTUP') THEN
  chk_value
  (p_user_column_instance_id => p_rec.user_column_instance_id
  ,p_user_column_id => p_rec.user_column_id
  ,p_value => p_rec.value
  ,p_business_group_id => p_rec.business_group_id
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  ,p_object_version_number => p_rec.object_version_number
  ,p_effective_date        => p_effective_date
  );
END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in pay_uci_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'update_validate';
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
       ,p_associated_column1 => pay_uci_shd.g_tab_nam
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
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_user_row_id                    => p_rec.user_row_id
    ,p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );
  --
/* The chk_value is not required when run from hrglobal through LDT upload */
/* Bug 8636760 */
IF hr_startup_data_api_support.g_startup_mode NOT IN ('STARTUP') THEN
  chk_value
  (p_user_column_instance_id => p_rec.user_column_instance_id
  ,p_user_column_id => p_rec.user_column_id
  ,p_value => p_rec.value
  ,p_business_group_id => p_rec.business_group_id
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  ,p_object_version_number => p_rec.object_version_number
  ,p_effective_date        => p_effective_date
  );
END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in pay_uci_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    --
  chk_startup_action(false
                    ,pay_uci_shd.g_old_rec.business_group_id
                    ,pay_uci_shd.g_old_rec.legislation_code
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
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_user_column_instance_id          => p_rec.user_column_instance_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_uci_bus;

/
