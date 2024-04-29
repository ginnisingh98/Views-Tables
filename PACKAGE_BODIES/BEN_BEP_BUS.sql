--------------------------------------------------------
--  DDL for Package Body BEN_BEP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BEP_BUS" as
/* $Header: bebeprhi.pkb 120.0.12010000.2 2008/08/05 14:07:52 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_bep_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_elig_obj_elig_prfl_id       number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_elig_obj_elig_prfl_id                in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , ben_elig_obj_elig_profl_f bep
     where bep.elig_obj_elig_prfl_id = p_elig_obj_elig_prfl_id
       and pbg.business_group_id = bep.business_group_id;
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
    ,p_argument           => 'elig_obj_elig_prfl_id'
    ,p_argument_value     => p_elig_obj_elig_prfl_id
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
         => nvl(p_associated_column1,'ELIG_OBJ_ELIG_PRFL_ID')
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
  (p_elig_obj_elig_prfl_id                in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , ben_elig_obj_elig_profl_f bep
     where bep.elig_obj_elig_prfl_id = p_elig_obj_elig_prfl_id
       and pbg.business_group_id = bep.business_group_id;
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
    ,p_argument           => 'elig_obj_elig_prfl_id'
    ,p_argument_value     => p_elig_obj_elig_prfl_id
    );
  --
  if ( nvl(ben_bep_bus.g_elig_obj_elig_prfl_id, hr_api.g_number)
       = p_elig_obj_elig_prfl_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ben_bep_bus.g_legislation_code;
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
    ben_bep_bus.g_elig_obj_elig_prfl_id       := p_elig_obj_elig_prfl_id;
    ben_bep_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_df >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_df
  (p_rec in ben_bep_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.elig_obj_elig_prfl_id is not null)  and (
    nvl(ben_bep_shd.g_old_rec.bep_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.bep_attribute_category, hr_api.g_varchar2)  or
    nvl(ben_bep_shd.g_old_rec.bep_attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.bep_attribute1, hr_api.g_varchar2)  or
    nvl(ben_bep_shd.g_old_rec.bep_attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.bep_attribute2, hr_api.g_varchar2)  or
    nvl(ben_bep_shd.g_old_rec.bep_attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.bep_attribute3, hr_api.g_varchar2)  or
    nvl(ben_bep_shd.g_old_rec.bep_attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.bep_attribute4, hr_api.g_varchar2)  or
    nvl(ben_bep_shd.g_old_rec.bep_attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.bep_attribute5, hr_api.g_varchar2)  or
    nvl(ben_bep_shd.g_old_rec.bep_attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.bep_attribute6, hr_api.g_varchar2)  or
    nvl(ben_bep_shd.g_old_rec.bep_attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.bep_attribute7, hr_api.g_varchar2)  or
    nvl(ben_bep_shd.g_old_rec.bep_attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.bep_attribute8, hr_api.g_varchar2)  or
    nvl(ben_bep_shd.g_old_rec.bep_attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.bep_attribute9, hr_api.g_varchar2)  or
    nvl(ben_bep_shd.g_old_rec.bep_attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.bep_attribute10, hr_api.g_varchar2)  or
    nvl(ben_bep_shd.g_old_rec.bep_attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.bep_attribute11, hr_api.g_varchar2)  or
    nvl(ben_bep_shd.g_old_rec.bep_attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.bep_attribute12, hr_api.g_varchar2)  or
    nvl(ben_bep_shd.g_old_rec.bep_attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.bep_attribute13, hr_api.g_varchar2)  or
    nvl(ben_bep_shd.g_old_rec.bep_attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.bep_attribute14, hr_api.g_varchar2)  or
    nvl(ben_bep_shd.g_old_rec.bep_attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.bep_attribute15, hr_api.g_varchar2)  or
    nvl(ben_bep_shd.g_old_rec.bep_attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.bep_attribute16, hr_api.g_varchar2)  or
    nvl(ben_bep_shd.g_old_rec.bep_attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.bep_attribute17, hr_api.g_varchar2)  or
    nvl(ben_bep_shd.g_old_rec.bep_attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.bep_attribute18, hr_api.g_varchar2)  or
    nvl(ben_bep_shd.g_old_rec.bep_attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.bep_attribute19, hr_api.g_varchar2)  or
    nvl(ben_bep_shd.g_old_rec.bep_attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.bep_attribute20, hr_api.g_varchar2) ))
    or (p_rec.elig_obj_elig_prfl_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'BEN'
      ,p_descflex_name                   => 'EDIT_HERE: Enter descflex name'
      ,p_attribute_category              => 'BEP_ATTRIBUTE_CATEGORY'
      ,p_attribute1_name                 => 'BEP_ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.bep_attribute1
      ,p_attribute2_name                 => 'BEP_ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.bep_attribute2
      ,p_attribute3_name                 => 'BEP_ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.bep_attribute3
      ,p_attribute4_name                 => 'BEP_ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.bep_attribute4
      ,p_attribute5_name                 => 'BEP_ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.bep_attribute5
      ,p_attribute6_name                 => 'BEP_ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.bep_attribute6
      ,p_attribute7_name                 => 'BEP_ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.bep_attribute7
      ,p_attribute8_name                 => 'BEP_ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.bep_attribute8
      ,p_attribute9_name                 => 'BEP_ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.bep_attribute9
      ,p_attribute10_name                => 'BEP_ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.bep_attribute10
      ,p_attribute11_name                => 'BEP_ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.bep_attribute11
      ,p_attribute12_name                => 'BEP_ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.bep_attribute12
      ,p_attribute13_name                => 'BEP_ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.bep_attribute13
      ,p_attribute14_name                => 'BEP_ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.bep_attribute14
      ,p_attribute15_name                => 'BEP_ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.bep_attribute15
      ,p_attribute16_name                => 'BEP_ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.bep_attribute16
      ,p_attribute17_name                => 'BEP_ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.bep_attribute17
      ,p_attribute18_name                => 'BEP_ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.bep_attribute18
      ,p_attribute19_name                => 'BEP_ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.bep_attribute19
      ,p_attribute20_name                => 'BEP_ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.bep_attribute20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_df;
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
  ,p_rec             in ben_bep_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ben_bep_shd.api_updating
      (p_elig_obj_elig_prfl_id            => p_rec.elig_obj_elig_prfl_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
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
  (p_elig_obj_id                   in number default hr_api.g_number
  ,p_elig_prfl_id                  in number default hr_api.g_number
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
  If ((nvl(p_elig_obj_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_elig_obj_f'
            ,p_base_key_column => 'ELIG_OBJ_ID'
            ,p_base_key_value  => p_elig_obj_id
            ,p_from_date       => p_validation_start_date
            ,p_to_date         => p_validation_end_date))) Then
     fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
     fnd_message.set_token('TABLE_NAME','elig obj');
     hr_multi_message.add
       (p_associated_column1 => ben_bep_shd.g_tab_nam || '.ELIG_OBJ_ID');
  End If;
  --
  If ((nvl(p_elig_prfl_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_eligy_prfl_f'
            ,p_base_key_column => 'ELIGY_PRFL_ID'
            ,p_base_key_value  => p_elig_prfl_id
            ,p_from_date       => p_validation_start_date
            ,p_to_date         => p_validation_end_date))) Then
     fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
     fnd_message.set_token('TABLE_NAME','eligy prfl');
     hr_multi_message.add
       (p_associated_column1 => ben_bep_shd.g_tab_nam || '.ELIG_PRFL_ID');
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
  (p_elig_obj_elig_prfl_id            in number
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
      ,p_argument       => 'elig_obj_elig_prfl_id'
      ,p_argument_value => p_elig_obj_elig_prfl_id
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
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in ben_bep_shd.g_rec_type
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
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => ben_bep_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  --
--  ben_bep_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in ben_bep_shd.g_rec_type
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
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => ben_bep_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_elig_obj_id                    => p_rec.elig_obj_id
    ,p_elig_prfl_id                   => p_rec.elig_prfl_id
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
--  ben_bep_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in ben_bep_shd.g_rec_type
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
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_elig_obj_elig_prfl_id            => p_rec.elig_obj_elig_prfl_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ben_bep_bus;

/
