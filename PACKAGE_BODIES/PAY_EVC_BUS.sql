--------------------------------------------------------
--  DDL for Package Body PAY_EVC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_EVC_BUS" as
/* $Header: pyevcrhi.pkb 115.6 2003/05/27 17:21:31 jford noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_evc_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_event_value_change_id       number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_event_value_change_id                in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_event_value_changes_f evc
     where evc.event_value_change_id = p_event_value_change_id
       and pbg.business_group_id = evc.business_group_id;
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
    ,p_argument           => 'event_value_change_id'
    ,p_argument_value     => p_event_value_change_id
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
         => nvl(p_associated_column1,'EVENT_VALUE_CHANGE_ID')
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
  (p_event_value_change_id                in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pay_event_value_changes_f evc
     where evc.event_value_change_id = p_event_value_change_id
       and pbg.business_group_id (+) = evc.business_group_id;
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
    ,p_argument           => 'event_value_change_id'
    ,p_argument_value     => p_event_value_change_id
    );
  --
  if ( nvl(pay_evc_bus.g_event_value_change_id, hr_api.g_number)
       = p_event_value_change_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_evc_bus.g_legislation_code;
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
    pay_evc_bus.g_event_value_change_id       := p_event_value_change_id;
    pay_evc_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec             in pay_evc_shd.g_rec_type
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
  IF NOT pay_evc_shd.api_updating
      (p_event_value_change_id            => p_rec.event_value_change_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- Checks to ensure non-updateable args have
  --   not been updated.
  if (nvl(p_rec.event_value_change_id, hr_api.g_number) <>
     nvl(pay_evc_shd.g_old_rec.event_value_change_id,hr_api.g_number)
     ) then
     l_argument := 'event_value_change_id';
     raise l_error;
  END IF;
  --
  if (nvl(p_rec.event_qualifier_id, hr_api.g_number) <>
     nvl(pay_evc_shd.g_old_rec.event_qualifier_id,hr_api.g_number)
     ) then
     l_argument := 'event_qualifier_id';
     raise l_error;
  END IF;
  --
  if (nvl(p_rec.datetracked_event_id, hr_api.g_number) <>
     nvl(pay_evc_shd.g_old_rec.datetracked_event_id,hr_api.g_number)
     ) then
     l_argument := 'datetracked_event_id';
     raise l_error;
  END IF;
  --
  if (nvl(p_rec.default_event, hr_api.g_varchar2) <>
     nvl(pay_evc_shd.g_old_rec.default_event,hr_api.g_varchar2)
     ) then
     l_argument := 'default_event';
     raise l_error;
  END IF;
  --
  if (nvl(p_rec.qualifier_value, hr_api.g_varchar2) <>
     nvl(pay_evc_shd.g_old_rec.qualifier_value,hr_api.g_varchar2)
     ) then
     l_argument := 'qualifier_value';
     raise l_error;
  END IF;
  --
  if (nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(pay_evc_shd.g_old_rec.business_group_id,hr_api.g_number)
     ) then
     l_argument := 'business_group_id';
     raise l_error;
  END IF;
  --
  if (nvl(p_rec.legislation_code, hr_api.g_varchar2) <>
     nvl(pay_evc_shd.g_old_rec.legislation_code,hr_api.g_varchar2)
     ) then
     l_argument := 'legislation_code';
     raise l_error;
  END IF;
  --
  --

  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_default_event >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--   This procedure validates the default value passed actually exists
--   in the appropriate lookup.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Error if incorrect value is being attempted to insert.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End of comments}
--
Procedure chk_default_event
  (p_rec                   in pay_evc_shd.g_rec_type
  ,p_effective_date        in date
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_default_event';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check that the mandatory effective date is not null.
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'effective_date'
  ,p_argument_value => p_effective_date
  );
  --
  IF p_rec.business_group_id <> null then
  --got BG so validate against hr_lookups
     if hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'YES_NO',
             p_lookup_code    => p_rec.default_event,
             p_effective_date => p_effective_date)
     then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
      fnd_message.set_name('PAY', 'INVALID_LOOKUP_CODE');
      fnd_message.set_token('LOOKUP_TYPE', 'YES_NO');
      fnd_message.set_token('VALUE', p_rec.default_event);
      fnd_message.raise_error;
    end if;
  ELSE
    -- Validate against hr_standard_lookups as DateTracked and no bg context.
    if hr_api.not_exists_in_dt_hrstanlookups
       (p_effective_date         => p_effective_date
       ,p_validation_start_date  => p_validation_start_date
       ,p_validation_end_date    => p_validation_end_date
       ,p_lookup_type            => 'YES_NO'
       ,p_lookup_code            => p_rec.default_event
       )
    then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
      fnd_message.set_name('PAY', 'INVALID_LOOKUP_CODE');
      fnd_message.set_token('LOOKUP_TYPE', 'YES_NO');
      fnd_message.set_token('VALUE', p_rec.default_event);
      fnd_message.raise_error;
    end if;
  END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End chk_default_event;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_valid_event >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--   This procedure validates the valid event value passed actually exists
--   in the appropriate lookup.
--
-- In Parameters:
--   A Pl/Sql record structure. Dates
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Error if incorrect value is being attempted to insert.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End of comments}
--
Procedure chk_valid_event
  (p_rec                   in pay_evc_shd.g_rec_type
  ,p_effective_date        in date
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_valid_event';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check that the mandatory effective date is not null.
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'effective_date'
  ,p_argument_value => p_effective_date
  );

  IF p_rec.business_group_id <> null then
    --got BG so validate against hr_lookups
    if hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'YES_NO',
             p_lookup_code    => p_rec.valid_event,
             p_effective_date => p_effective_date)
    then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
      fnd_message.set_name('PAY', 'INVALID_LOOKUP_CODE');
      fnd_message.set_token('LOOKUP_TYPE', 'YES_NO');
      fnd_message.set_token('VALUE', p_rec.valid_event);
      fnd_message.raise_error;
    end if;
  ELSE
    -- Validate against hr_standard_lookups as DateTracked and no bg context.
    if hr_api.not_exists_in_dt_hrstanlookups
       (p_effective_date         => p_effective_date
       ,p_validation_start_date  => p_validation_start_date
       ,p_validation_end_date    => p_validation_end_date
       ,p_lookup_type            => 'YES_NO'
       ,p_lookup_code            => p_rec.valid_event
       )
    then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
      fnd_message.set_name('PAY', 'INVALID_LOOKUP_CODE');
      fnd_message.set_token('LOOKUP_TYPE', 'YES_NO');
      fnd_message.set_token('VALUE', p_rec.valid_event);
      fnd_message.raise_error;
    end if;
  END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End chk_valid_event;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_proration_style >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--   This procedure validates the valid event value passed actually exists
--   in the appropriate lookup.
--
-- In Parameters:
--   A Pl/Sql record structure. Dates
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Error if incorrect value is being attempted to insert.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End of comments}
--

--
Procedure chk_proration_style
  (p_rec                   in pay_evc_shd.g_rec_type
  ,p_effective_date        in date
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_proration_style';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check that the mandatory effective date is not null.
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'effective_date'
  ,p_argument_value => p_effective_date
  );

  IF p_rec.business_group_id <> null then
    --got BG so validate against hr_lookups
    if hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'PAY_PRORATION_STYLE',
             p_lookup_code    => p_rec.proration_style,
             p_effective_date => p_effective_date)
    then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
      fnd_message.set_name('PAY', 'INVALID_LOOKUP_CODE');
      fnd_message.set_token('LOOKUP_TYPE', 'PAY_PRORATION_STYLE');
      fnd_message.set_token('VALUE', p_rec.proration_style);
      fnd_message.raise_error;
    end if;
  ELSE
    -- Validate against hr_standard_lookups as DateTracked and no bg context.
    if hr_api.not_exists_in_dt_hrstanlookups
       (p_effective_date         => p_effective_date
       ,p_validation_start_date  => p_validation_start_date
       ,p_validation_end_date    => p_validation_end_date
       ,p_lookup_type            => 'PAY_PRORATION_STYLE'
       ,p_lookup_code            => p_rec.proration_style
       )
    then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
      fnd_message.set_name('PAY', 'INVALID_LOOKUP_CODE');
      fnd_message.set_token('LOOKUP_TYPE', 'PAY_PRORATION_STYLE');
      fnd_message.set_token('VALUE', p_rec.proration_style);
      fnd_message.raise_error;
    end if;
  END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End chk_proration_style;

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
  (p_event_qualifier_id            in number default hr_api.g_number
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
  If ((nvl(p_event_qualifier_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'pay_event_qualifiers_f'
            ,p_base_key_column => 'EVENT_QUALIFIER_ID'
            ,p_base_key_value  => p_event_qualifier_id
            ,p_from_date       => p_validation_start_date
            ,p_to_date         => p_validation_end_date))) Then
     fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
     fnd_message.set_token('TABLE_NAME','event qualifiers');
     hr_multi_message.add
       (p_associated_column1 => pay_evc_shd.g_tab_nam || '.EVENT_QUALIFIER_ID');
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
  (p_event_value_change_id            in number
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
      ,p_argument       => 'event_value_change_id'
      ,p_argument_value => p_event_value_change_id
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
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in pay_evc_shd.g_rec_type
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
       ,p_associated_column1 => pay_evc_shd.g_tab_nam
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
  chk_default_event(p_rec, p_effective_date
                   ,p_validation_start_date ,p_validation_end_date);
  chk_valid_event(p_rec, p_effective_date
                   ,p_validation_start_date ,p_validation_end_date);
  chk_proration_style(p_rec, p_effective_date
                   ,p_validation_start_date ,p_validation_end_date);

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in pay_evc_shd.g_rec_type
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
       ,p_associated_column1 => pay_evc_shd.g_tab_nam
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
  chk_default_event(p_rec, p_effective_date
                   ,p_validation_start_date ,p_validation_end_date);
  chk_valid_event(p_rec, p_effective_date
                   ,p_validation_start_date ,p_validation_end_date);
  chk_proration_style(p_rec, p_effective_date
                   ,p_validation_start_date ,p_validation_end_date);
  --
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_event_qualifier_id             => p_rec.event_qualifier_id
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in pay_evc_shd.g_rec_type
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
                    ,pay_evc_shd.g_old_rec.business_group_id
                    ,pay_evc_shd.g_old_rec.legislation_code
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
    ,p_event_value_change_id            => p_rec.event_value_change_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_evc_bus;

/