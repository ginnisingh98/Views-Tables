--------------------------------------------------------
--  DDL for Package Body PQP_VAL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VAL_BUS" as
/* $Header: pqvalrhi.pkb 120.0.12010000.3 2008/08/08 07:22:41 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_val_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_vehicle_allocation_id       number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_vehicle_allocation_id                in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , pqp_vehicle_allocations_f val
     where val.vehicle_allocation_id = p_vehicle_allocation_id
       and pbg.business_group_id = val.business_group_id;
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
    ,p_argument           => 'vehicle_allocation_id'
    ,p_argument_value     => p_vehicle_allocation_id
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
         => nvl(p_associated_column1,'VEHICLE_ALLOCATION_ID')
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
  (p_vehicle_allocation_id                in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , pqp_vehicle_allocations_f val
     where val.vehicle_allocation_id = p_vehicle_allocation_id
       and pbg.business_group_id = val.business_group_id;
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
    ,p_argument           => 'vehicle_allocation_id'
    ,p_argument_value     => p_vehicle_allocation_id
    );
  --
  if ( nvl(pqp_val_bus.g_vehicle_allocation_id, hr_api.g_number)
       = p_vehicle_allocation_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqp_val_bus.g_legislation_code;
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
    pqp_val_bus.g_vehicle_allocation_id       := p_vehicle_allocation_id;
    pqp_val_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_ddf >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Developer Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Developer Descriptive Flexfield structure column and data values
--   are all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Developer Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_ddf
  (p_rec in pqp_val_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.vehicle_allocation_id is not null)  and (
    nvl(pqp_val_shd.g_old_rec.val_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.val_information_category, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_information1, hr_api.g_varchar2) <>
    nvl(p_rec.val_information1, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_information2, hr_api.g_varchar2) <>
    nvl(p_rec.val_information2, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_information3, hr_api.g_varchar2) <>
    nvl(p_rec.val_information3, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_information4, hr_api.g_varchar2) <>
    nvl(p_rec.val_information4, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_information5, hr_api.g_varchar2) <>
    nvl(p_rec.val_information5, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_information6, hr_api.g_varchar2) <>
    nvl(p_rec.val_information6, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_information7, hr_api.g_varchar2) <>
    nvl(p_rec.val_information7, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_information8, hr_api.g_varchar2) <>
    nvl(p_rec.val_information8, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_information9, hr_api.g_varchar2) <>
    nvl(p_rec.val_information9, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_information10, hr_api.g_varchar2) <>
    nvl(p_rec.val_information10, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_information11, hr_api.g_varchar2) <>
    nvl(p_rec.val_information11, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_information12, hr_api.g_varchar2) <>
    nvl(p_rec.val_information12, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_information13, hr_api.g_varchar2) <>
    nvl(p_rec.val_information13, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_information14, hr_api.g_varchar2) <>
    nvl(p_rec.val_information14, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_information15, hr_api.g_varchar2) <>
    nvl(p_rec.val_information15, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_information16, hr_api.g_varchar2) <>
    nvl(p_rec.val_information16, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_information17, hr_api.g_varchar2) <>
    nvl(p_rec.val_information17, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_information18, hr_api.g_varchar2) <>
    nvl(p_rec.val_information18, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_information19, hr_api.g_varchar2) <>
    nvl(p_rec.val_information19, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_information20, hr_api.g_varchar2) <>
    nvl(p_rec.val_information20, hr_api.g_varchar2) ))
    or (p_rec.vehicle_allocation_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PQP'
      ,p_descflex_name                   => 'Vehicle Allocation Info DDF'
      ,p_attribute_category              => p_rec.val_information_category
      ,p_attribute1_name                 => 'VAL_INFORMATION1'
      ,p_attribute1_value                => p_rec.val_information1
      ,p_attribute2_name                 => 'VAL_INFORMATION2'
      ,p_attribute2_value                => p_rec.val_information2
      ,p_attribute3_name                 => 'VAL_INFORMATION3'
      ,p_attribute3_value                => p_rec.val_information3
      ,p_attribute4_name                 => 'VAL_INFORMATION4'
      ,p_attribute4_value                => p_rec.val_information4
      ,p_attribute5_name                 => 'VAL_INFORMATION5'
      ,p_attribute5_value                => p_rec.val_information5
      ,p_attribute6_name                 => 'VAL_INFORMATION6'
      ,p_attribute6_value                => p_rec.val_information6
      ,p_attribute7_name                 => 'VAL_INFORMATION7'
      ,p_attribute7_value                => p_rec.val_information7
      ,p_attribute8_name                 => 'VAL_INFORMATION8'
      ,p_attribute8_value                => p_rec.val_information8
      ,p_attribute9_name                 => 'VAL_INFORMATION9'
      ,p_attribute9_value                => p_rec.val_information9
      ,p_attribute10_name                => 'VAL_INFORMATION10'
      ,p_attribute10_value               => p_rec.val_information10
      ,p_attribute11_name                => 'VAL_INFORMATION11'
      ,p_attribute11_value               => p_rec.val_information11
      ,p_attribute12_name                => 'VAL_INFORMATION12'
      ,p_attribute12_value               => p_rec.val_information12
      ,p_attribute13_name                => 'VAL_INFORMATION13'
      ,p_attribute13_value               => p_rec.val_information13
      ,p_attribute14_name                => 'VAL_INFORMATION14'
      ,p_attribute14_value               => p_rec.val_information14
      ,p_attribute15_name                => 'VAL_INFORMATION15'
      ,p_attribute15_value               => p_rec.val_information15
      ,p_attribute16_name                => 'VAL_INFORMATION16'
      ,p_attribute16_value               => p_rec.val_information16
      ,p_attribute17_name                => 'VAL_INFORMATION17'
      ,p_attribute17_value               => p_rec.val_information17
      ,p_attribute18_name                => 'VAL_INFORMATION18'
      ,p_attribute18_value               => p_rec.val_information18
      ,p_attribute19_name                => 'VAL_INFORMATION19'
      ,p_attribute19_value               => p_rec.val_information19
      ,p_attribute20_name                => 'VAL_INFORMATION20'
      ,p_attribute20_value               => p_rec.val_information20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
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
  (p_rec in pqp_val_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.vehicle_allocation_id is not null)  and (
    nvl(pqp_val_shd.g_old_rec.val_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.val_attribute_category, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.val_attribute1, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.val_attribute2, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.val_attribute3, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.val_attribute4, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.val_attribute5, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.val_attribute6, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.val_attribute7, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.val_attribute8, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.val_attribute9, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.val_attribute10, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.val_attribute11, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.val_attribute12, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.val_attribute13, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.val_attribute14, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.val_attribute15, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.val_attribute16, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.val_attribute17, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.val_attribute18, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.val_attribute19, hr_api.g_varchar2)  or
    nvl(pqp_val_shd.g_old_rec.val_attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.val_attribute20, hr_api.g_varchar2) ))
    or (p_rec.vehicle_allocation_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PQP'
      ,p_descflex_name                   => 'Vehicle Allocation Info DF'
      ,p_attribute_category              => p_rec.val_attribute_category
      ,p_attribute1_name                 => 'VAL_ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.val_attribute1
      ,p_attribute2_name                 => 'VAL_ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.val_attribute2
      ,p_attribute3_name                 => 'VAL_ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.val_attribute3
      ,p_attribute4_name                 => 'VAL_ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.val_attribute4
      ,p_attribute5_name                 => 'VAL_ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.val_attribute5
      ,p_attribute6_name                 => 'VAL_ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.val_attribute6
      ,p_attribute7_name                 => 'VAL_ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.val_attribute7
      ,p_attribute8_name                 => 'VAL_ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.val_attribute8
      ,p_attribute9_name                 => 'VAL_ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.val_attribute9
      ,p_attribute10_name                => 'VAL_ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.val_attribute10
      ,p_attribute11_name                => 'VAL_ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.val_attribute11
      ,p_attribute12_name                => 'VAL_ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.val_attribute12
      ,p_attribute13_name                => 'VAL_ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.val_attribute13
      ,p_attribute14_name                => 'VAL_ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.val_attribute14
      ,p_attribute15_name                => 'VAL_ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.val_attribute15
      ,p_attribute16_name                => 'VAL_ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.val_attribute16
      ,p_attribute17_name                => 'VAL_ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.val_attribute17
      ,p_attribute18_name                => 'VAL_ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.val_attribute18
      ,p_attribute19_name                => 'VAL_ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.val_attribute19
      ,p_attribute20_name                => 'VAL_ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.val_attribute20
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
  ,p_rec             in pqp_val_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pqp_val_shd.api_updating
      (p_vehicle_allocation_id            => p_rec.vehicle_allocation_id
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
  (p_datetrack_mode                in varchar2
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
    --
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
  (p_vehicle_allocation_id            in number
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
      ,p_argument       => 'vehicle_allocation_id'
      ,p_argument_value => p_vehicle_allocation_id
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
-----------------------------------------------------------------------------
----------------------Fuel card/Fuel Card Number /Fuel Benifit Check--------
-----------------------------------------------------------------------------
--Fuel Card:This is a check box and this is available only for company vehicle
--and will be validated in the APIs for private vehicle for that legislation.
--
--Fuel Card Number: Non-validated and optional field must be entered only
--when fuel card is checked and must not error when fuel card is checked
--and fuel card number is not entered.
--
--Fuel Benefit:Check box available for only company vehicles and
--need to be validated in API.

 FUNCTION pqp_check_cmyveh_fuel_card
                (p_rec               IN pqp_val_shd.g_rec_type,
                 p_vehicle_ownership IN VARCHAR2,
                 p_effective_date    IN  DATE ,
                 p_message           OUT NOCOPY VARCHAR2
                ) RETURN VARCHAR2 IS
  BEGIN

     --if vehicle ownership is company then fuelcard value should be
     -- "Y/N"and fuelCard number ,fuel benifit is optional
     --If vehicle ownership is private then fuelcard value should be
     -- "NULL" and fuelCard number,fuel benifit should be null
     IF  p_vehicle_ownership = 'C' THEN
       IF p_rec.fuel_card IS NULL THEN
           --fuel card should be selected
            p_message := 'Fuel card should be Y/N for company vehicle';
        RETURN -1;
       END IF;
     END IF;
     RETURN 0;
  END pqp_check_cmyveh_fuel_card;
--End of pqp_check_cmyveh_fuel_card
-----------------------------------------------------------------------------
----------------------- Get maximum company/Private allowed vehicle ---------
------------------------------------------------------------------------------
--
--Maximum Company Vehicles Allowed: The limitations
--on number of company vehicles
--that can be associated to an assignment can be set up here.
--The default is null which means that there is no limit for
--the number of company cars that can be assigned to an assignment.
--                or
--Maximum Private Vehicles Allowed: The limitations
--on number of private vehicles
--that can be associated with an assignment.
--If the number is reached then a new vehicle can be associated only after
--one of the existing allocated vehicles is removed.
--The default value is null (no limit).
FUNCTION pqp_get_max_allowed_veh
             ( p_rec                 IN pqp_val_shd.g_rec_type
              ,p_vehicle_ownership   IN VARCHAR2
              ,p_effective_date      IN DATE
             ) RETURN NUMBER IS

 --used to get the allocation count fr future and current date track
   CURSOR  c_alloc_count_cursor IS
   SELECT  COUNT(pva.vehicle_allocation_id)
    FROM   pqp_vehicle_repository_f   pvr
          ,pqp_vehicle_allocations_f  pva
     WHERE pvr.vehicle_repository_id = pva.vehicle_repository_id
      AND  pvr.business_group_id = pva.business_group_id
      AND  pvr.vehicle_ownership = p_vehicle_ownership
      AND  pva.assignment_id = p_rec.assignment_id
      AND  pva.business_group_id = p_rec.business_group_id
      AND  (p_effective_date BETWEEN
           pva.effective_start_date AND pva.effective_end_date
      OR   p_effective_date <= pva.effective_start_date)
      AND  p_effective_date between
           pvr.effective_start_date and pvr.effective_end_date;

  l_rowcount NUMBER;
BEGIN
  hr_utility.set_location('Entering pqp_get_max_allowed_veh', 21);
  OPEN c_alloc_count_cursor;
  FETCH c_alloc_count_cursor INTO l_rowcount;
  CLOSE c_alloc_count_cursor;
  hr_utility.set_location('maximum vehicles till now:'||l_rowcount, 25);
  RETURN l_rowcount ;
END pqp_get_max_allowed_veh;
-- end function

------------------------------------------------------------------------------
---------------------------------------------------------------------------
------------------------<Check Mandatory Fields>-------------------------
---------------------------------------------------------------------------
FUNCTION chk_mandatory
           (p_argument         IN   VARCHAR2,
            p_argument_value   IN   VARCHAR2,
            p_message          OUT  NOCOPY VARCHAR2
           ) RETURN NUMBER IS
BEGIN

    IF p_argument_value IS NULL THEN
       p_message := p_argument || 'Value should be Mandatory';
       RETURN -1;
    END IF;
    RETURN 0;
END chk_mandatory;
-- ---------------------------------------------------------------------------
-- |------------------------< Used to check the lookup codes >----------------
-- ---------------------------------------------------------------------------
--Used to check the passed lookup code is correct or not
FUNCTION chk_lookup
           (p_vehicle_allocation_id  IN  NUMBER
           ,p_lookup_type            IN  VARCHAR2
           ,p_lookup_code            IN  VARCHAR2
           ,p_effective_date         IN  DATE
           ,p_validation_start_date  IN  DATE
           ,p_validation_end_date    IN  DATE
           ) RETURN NUMBER IS

 --Local variables declaration
 l_old_argument_value    hr_lookups.lookup_code%TYPE;

 BEGIN
       --
       --  If argument value is not null then
       --  Check if the argument value exists in hr_lookups
       --  where the lookup_type is passed lookuptype
       --
       IF p_lookup_code IS NOT NULL then
          IF hr_api.not_exists_in_dt_hrstanlookups
             (p_effective_date        => p_effective_date
             ,p_validation_start_date => p_validation_start_date
             ,p_validation_end_date   => p_validation_end_date
             ,p_lookup_type           => p_lookup_type
             ,p_lookup_code           => p_lookup_code
             ) THEN
          RETURN -1;
         END IF;
       END IF;
   RETURN 0;
 END;

------------------------------------------------------------------------------
---------------------------Validating the Vehicle Status-----------------------
-------------------------------------------------------------------------------
--
--The selected vehicle must be validated for the eligibility for that employee
--and also the vehicle must be checked if the vehicle can be shared or status
-- is inactive.
--
FUNCTION pqp_veh_eligibility_check
                ( p_rec               IN  pqp_val_shd.g_rec_type
                 ,p_effective_date    IN  DATE
                 ,p_message           OUT NOCOPY VARCHAR2
                )RETURN NUMBER IS
  --get the values for vehicleStatus and SharedVehicle
 CURSOR   c__veh_data_cursor IS
   SELECT vehicle_status
     FROM PQP_VEHICLE_REPOSITORY_F
   WHERE  vehicle_repository_id = p_rec.vehicle_repository_id
     AND  p_effective_date between effective_start_date and effective_end_date
     AND  business_group_id = p_rec.business_group_id ;

   l_vehicle_status PQP_VEHICLE_REPOSITORY_F.vehicle_status%type;
BEGIN
  OPEN c__veh_data_cursor;
  FETCH c__veh_data_cursor INTO l_vehicle_status;
  CLOSE c__veh_data_cursor;
  -- check the vehicle status ,if it is InActive
  IF l_vehicle_status = 'I' THEN
     p_message := 'Vehicle status is Inactive,so vehicle cannot allocat';
     RETURN -1; -- vehicle is inActive
  END IF;
  RETURN 0;
END pqp_veh_eligibility_check;
-- end function
------------------------------------------------------------------------------
----------------------------<Foreign key constraint check>-------------------
-----------------------------------------------------------------------------
Procedure chk_vehicle_exst (
             p_rec                   in pqp_val_shd.g_rec_type
            ,p_effective_date        in date
            ,p_datetrack_mode        in varchar2
            ,p_validation_start_date in date
            ,p_validation_end_date   in date
            ) IS
   l_exist VARCHAR2(1);
Begin
 SELECT 'X'
   INTO l_exist
  FROM pqp_vehicle_repository_f pvr
 WHERE pvr.vehicle_repository_id=p_rec.vehicle_repository_id
   AND pvr.business_group_id=p_rec.business_group_id
   AND p_effective_date BETWEEN pvr.effective_start_date
                            AND pvr.effective_end_date;

EXCEPTION
---------
WHEN no_data_found then
fnd_message.raise_error;

WHEN others then
fnd_message.raise_error;


End;
------------------------------------------------------------------------------
----------------------------<Foreign key constraint check>-------------------
-----------------------------------------------------------------------------
Procedure chk_asg_exst
              ( p_rec                   in pqp_val_shd.g_rec_type
               ,p_effective_date        in date
               ,p_datetrack_mode        in varchar2
               ,p_validation_start_date in date
               ,p_validation_end_date   in date
          ) IS
  l_exist VARCHAR2(1);
Begin
SELECT 'X'
  INTO l_exist
  FROM per_all_assignments_f paa
 WHERE paa.assignment_id =p_rec.assignment_id
   AND paa.business_group_id=p_rec.business_group_id
   AND p_effective_date BETWEEN paa.effective_start_date
                            AND paa.effective_end_date;

EXCEPTION
---------
WHEN no_data_found then
fnd_message.raise_error;

WHEN others then
fnd_message.raise_error;
End;
-----------------------------------------------------------------------------
---------------------Check the Primary Vehicle Allocation-
-----------------------------------------------------------------------------
--
--Primary:One Primary vehicle is allocated to the user.
--Secondary:Any additional vehicle is recorded as a secondary vehicle.
--Multiple secondary cars can be allocated based on business rules.
--
FUNCTION  pqp_check_veh_alloc_process
                ( p_rec                  IN  pqp_val_shd.g_rec_type
                 ,p_vehicle_ownership    IN  VARCHAR2
                 ,p_effective_date       IN  DATE
                 ,p_message              OUT NOCOPY VARCHAR2
                ) RETURN NUMBER IS


  --Used to get the allocations count for company/private vehicles of
  --(primary/secondary)/(Essential/Casual) for assignment based current
  --and future date tracks
  CURSOR c_alloc_count_cursor IS
    SELECT COUNT(pva.vehicle_allocation_id)
     FROM  pqp_vehicle_repository_f   pvr
          ,pqp_vehicle_allocations_f  pva
     WHERE pvr.vehicle_repository_id = pva.vehicle_repository_id
       AND pvr.business_group_id = pva.business_group_id
       AND pvr.vehicle_ownership = p_vehicle_ownership
       AND pva.usage_type = p_rec.usage_type
       AND pva.assignment_id = p_rec.assignment_id
       AND pva.business_group_id=p_rec.business_group_id
       AND (p_effective_date between
           pva.effective_start_date and pva.effective_end_date
           OR  p_effective_date <= pva.effective_start_date)
       AND (p_effective_date between
           pvr.effective_start_date and pvr.effective_end_date);

  l_rowcount NUMBER ;

BEGIN
     hr_utility.set_location('Entering pqp_check_veh_alloc_process', 16);
     OPEN  c_alloc_count_cursor;
     FETCH c_alloc_count_cursor INTO l_rowcount;
     CLOSE c_alloc_count_cursor ;

   --check usage type is p/e then max count should be one.
   IF p_rec.usage_type = 'P' THEN
      -- if 0 then allowedrec
      IF l_rowcount > 0 THEN
           --This is max ,so user canot allocate
            hr_utility.set_location('Count for P or E:'||l_rowcount, 20);
            p_message :='Only one Primary vehicle is allocated to the user';
        RETURN -1;
      END IF;

   END IF;

  RETURN 0;
END pqp_check_veh_alloc_process;
-- end function
-----------------------------------------------------------------------------
----------------------purge delete function------------------------------
----------------------------------------------------------------------------
--
--There are any claims that spans across any date cannot be purged.
--
FUNCTION pqp_purge_veh_alloc
                (p_rec               IN  pqp_val_shd.g_rec_type
                ,p_effective_date    IN  DATE
                ,p_message           OUT NOCOPY VARCHAR2
                ) RETURN NUMBER IS

CURSOR c_claim_count_cursor
                    (cp_registration_number   VARCHAR2,
                     cp_assignment_id         NUMBER ) IS
    SELECT count(*)
      FROM pay_element_types_f pet
          ,pay_element_type_extra_info pete
           ,pay_element_entries_f pee
           ,pay_element_entry_values_f peev2
          ,pay_input_values_f    piv2
   WHERE pete.eei_information_category='PQP_VEHICLE_MILEAGE_INFO'
     AND pet.business_group_id=p_rec.business_group_id
     AND pete.element_type_id =pet.element_type_id
     AND substr(pete.eei_information1,0,1) in ('C','P')
     AND pee.assignment_id   =cp_assignment_id
     AND peev2.element_entry_id=pee.element_entry_id
     AND piv2.element_type_id=pet.element_type_id
     AND piv2.name in ('Vehicle Reg Number')
     AND piv2.input_value_id=peev2.input_value_id
     AND peev2.screen_entry_value =cp_registration_number;

 CURSOR c_claim_veh_det_cursor IS
 SELECT pvr.registration_number, pva.assignment_id
   FROM pqp_vehicle_allocations_f pva,
        pqp_vehicle_repository_f pvr
  WHERE pva.vehicle_allocation_id= p_rec.vehicle_allocation_id
    AND pva.vehicle_repository_id =pvr.vehicle_repository_id
    AND p_effective_date BETWEEN pva.effective_start_date
                             AND pva.effective_end_date
    AND p_effective_date BETWEEN pvr.effective_start_date
                             AND pvr.effective_end_date ;


 l_alloc_count          NUMBER ;
 l_registration_number pqp_vehicle_repository_f.registration_number%TYPE;
 l_assignment_id       pqp_vehicle_allocations_f.assignment_id%TYPE;

BEGIN

  --Curosr for getting the regnumber and assignment
  OPEN c_claim_veh_det_cursor;
  FETCH c_claim_veh_det_cursor INTO l_registration_number,l_assignment_id;
  CLOSE c_claim_veh_det_cursor;

  OPEN c_claim_count_cursor(l_registration_number,l_assignment_id);
  FETCH c_claim_count_cursor INTO l_alloc_count;
  CLOSE c_claim_count_cursor;
  --Check claims existence check
   IF l_alloc_count > 0 THEN
        p_message := 'There are any claims that spans across any date cannot' ||
                     'be purged';
        RETURN -1 ;
    END IF;
  RETURN 0;
END pqp_purge_veh_alloc;
-- end function


-----------------------------------------------------------------------------
-----------------Used to check the ShareCompany Car/Share Private -----------
-----------------------------------------------------------------------------
--
--Share Company Car:This field has a list of values 'Yes' and 'No'.
--'Yes' means the Primary vehicle can be shared across employees.
--'No' would mean the car will not be assigned to other assignments.
--Default value will be 'No'.
--                         or
--Share Private Car: This field has a list of values 'Yes' and 'No'.
--'Yes' means the Private vehicle can be shared across employees.
--'No' would mean the car will not be assigned to assignments.
--Default value will be 'No'.


FUNCTION pqp_config_shared_veh
               (p_rec                       IN  pqp_val_shd.g_rec_type,
                p_vehicle_ownership         IN  VARCHAR2 ,
                p_shared_vehicle            IN  VARCHAR2,
                p_effective_date            IN  DATE,
                p_legislation_code          IN  VARCHAR2,
                p_seg_col_name              IN  VARCHAR2,
                p_table_name                IN  VARCHAR2,
                p_information_category      IN  VARCHAR2,
                p_message                   OUT NOCOPY VARCHAR2
                )RETURN NUMBER IS
--Used to get the allocation count for regId and not for this
--assigment personId
--because if we use this assignment ,user can allocate vehicle
--irespective of shared
--vehicle setting at configuration

CURSOR c_person_alloc_count_cursor IS
 SELECT COUNT(pva.vehicle_allocation_id)
  FROM  pqp_vehicle_allocations_f pva,
        per_all_assignments_f    paa
  WHERE paa.assignment_id = pva.assignment_id
   AND  pva.assignment_id NOT IN ( SELECT assignment_id
                                FROM per_all_assignments_f
                                WHERE person_id = (SELECT DISTINCT person_id
                                FROM per_all_assignments_f
                                WHERE assignment_id=p_rec.assignment_id))
   AND pva.vehicle_repository_id = p_rec.vehicle_repository_id
   AND pva.business_group_id=p_rec.business_group_id
   AND p_effective_date BETWEEN
       paa.effective_start_date AND paa.effective_end_date
   AND p_effective_date BETWEEN
       pva.effective_start_date AND pva.effective_end_date ;

l_rowcount NUMBER ;
l_veh_shared VARCHAR2(20);

BEGIN
      hr_utility.set_location('Entering pqp_config_shared_veh',32);
      OPEN  c_person_alloc_count_cursor;
      FETCH c_person_alloc_count_cursor INTO l_rowcount ;
      CLOSE c_person_alloc_count_cursor ;
      hr_utility.set_location('alloc count  persons :'||l_rowcount,35);
      IF l_rowcount > 0 THEN

       --Checking the shared vehicle flag for this repositoryId
       IF p_shared_vehicle = 'N' THEN
             p_message := 'This vehicle is not Shared at '||
                          'repository level.so User cannot assign to '||
                          'multiple assignments to other personIds';
           RETURN -1;
       END IF;

   /*    --Check for Configuration Values veh shared flag
        l_veh_shared := pqp_vre_bus.PQP_GET_CONFIG_VALUE(
                                       p_rec.business_group_id,
                                       p_legislation_code,
                                       p_seg_col_name,
                                       p_table_name,
                                       p_information_category);


       --Yes means ,user can assign to differnt persons assignments
       IF l_veh_shared = 'N' THEN
             p_message := 'This vehicle is not Shared at '||
                          'configuration level.so User cannot assign to '||
                          'multiple assignments to other personIds';
           RETURN -1;
       END IF;
       */
     END IF;

      --If count is zero ,so User can allocate this veh to his assignment
     RETURN 0;
END pqp_config_shared_veh;
-- end function

--------------------------------------------------------------------------
------------------Check reg exist for alloc------------------------------
-------------------------------------------------------------------------
FUNCTION chk_reg_exist_for_alloc
            (p_rec               IN  pqp_val_shd.g_rec_type
             ,p_effective_date   IN  DATE
             ,p_message          out NOCOPY VARCHAR2
            ) RETURN NUMBER IS

CURSOR c_alloc_count_cursor IS
 SELECT COUNT(pva.vehicle_allocation_id)
   FROM pqp_vehicle_allocations_f  pva
  WHERE pva.assignment_id = p_rec.assignment_id
    AND pva.vehicle_repository_id = p_rec.vehicle_repository_id
    AND  pva.business_group_id = p_rec.business_group_id
    AND  (p_effective_date
         BETWEEN pva.effective_start_date AND pva.effective_end_date
    OR   p_effective_date <= pva.effective_start_date);

l_rowcount NUMBER;

BEGIN
  hr_utility.set_location('Entering chk_reg_exist_for_alloc', 7);
  OPEN c_alloc_count_cursor;
  FETCH c_alloc_count_cursor INTO l_rowcount;
  CLOSE c_alloc_count_cursor;
  hr_utility.set_location('Vehicle Reg Exist:'||l_rowcount, 10);
  IF l_rowcount > 0 THEN
     p_message := 'Registration number is already exist in this date tracks';
     RETURN -1 ;
  END IF;
  RETURN 0;
END chk_reg_exist_for_alloc;
-- end function
-----------------------------------------------------------------------------
----------------------End date delete----------------------------------------
-----------------------------------------------------------------------------
--
--There are no pending claims that spans across this date
--
FUNCTION pqp_enddate_veh_alloc
                   (p_rec                IN  pqp_val_shd.g_rec_type
                    ,p_effective_date    IN  DATE
                    ,p_message           OUT NOCOPY VARCHAR2
                   ) RETURN NUMBER IS
--Get the claim count for future and current date tracks
CURSOR c_claim_count_cursor(cp_registration_number   VARCHAR2,
                            cp_assignment_id NUMBER ) IS
 SELECT count(*)
      FROM pay_element_types_f pet
          ,pay_element_type_extra_info pete
           ,pay_element_entries_f pee
           ,pay_element_entry_values_f peev2
          ,pay_input_values_f    piv2
   WHERE pete.EEI_INFORMATION_CATEGORY='PQP_VEHICLE_MILEAGE_INFO'
     AND pet.business_group_id=p_rec.business_group_id
     AND pete.element_type_id =pet.element_type_id
     AND substr(pete.EEI_INFORMATION1,0,1) in ('C','P')
     AND pee.assignment_id   =cp_assignment_id
     AND peev2.element_entry_id=pee.element_entry_id
     AND piv2.element_type_id=pet.element_type_id
     AND piv2.name in ('Vehicle Reg Number')
     AND piv2.input_value_id=peev2.input_value_id
     AND peev2.SCREEN_ENTRY_VALUE =cp_registration_number
     AND p_effective_date < pee.effective_end_date;


CURSOR c_clm_veh_det_cursor IS
   SELECT pvr.registration_number, pva.assignment_id
     FROM pqp_vehicle_allocations_f pva,
          pqp_vehicle_repository_f  pvr
    WHERE pva.vehicle_allocation_id= p_rec.vehicle_allocation_id
      AND pva.vehicle_repository_id =pvr.vehicle_repository_id
      AND p_effective_date BETWEEN pva.effective_start_date
                                 AND pva.effective_end_date
      AND p_effective_date BETWEEN pvr.effective_start_date
                             AND pvr.effective_end_date ;

 l_alloc_count         NUMBER ;
 l_registration_number pqp_vehicle_repository_f.registration_number%TYPE;
 l_assignment_id       pqp_vehicle_allocations_f.assignment_id%TYPE;

BEGIN
  OPEN  c_clm_veh_det_cursor;
  FETCH c_clm_veh_det_cursor INTO l_registration_number,l_assignment_id;
  CLOSE c_clm_veh_det_cursor;

  OPEN c_claim_count_cursor(l_registration_number,l_assignment_id);
  FETCH c_claim_count_cursor INTO l_alloc_count;
  CLOSE c_claim_count_cursor;
  --Check claims existence check
   IF l_alloc_count > 0 THEN
        p_message := 'There are pending cliams in future,so we cannot enddated';
        RETURN -1 ;
    END IF;
   RETURN 0;
END pqp_enddate_veh_alloc;
-- end function

-----------------------------------------------------------------------------
---------------------Check the DefaultVehicle Allocation---------------------
-----------------------------------------------------------------------------
--
--Default Vehicle:Checking only one default private vehicle is allocated at
--any point of time to that assignment
--
FUNCTION  chk_defult_private_veh
                ( p_rec                  IN  pqp_val_shd.g_rec_type
                 ,p_vehicle_ownership    IN  VARCHAR2
                 ,p_effective_date       IN  DATE
                 ,p_message              OUT NOCOPY VARCHAR2
                ) RETURN NUMBER IS


  --Used to get the allocations count for private vehicle default count
  CURSOR c_alloc_count_cursor IS
    SELECT COUNT(pva.vehicle_allocation_id)
     FROM  pqp_vehicle_repository_f   pvr
          ,pqp_vehicle_allocations_f  pva
     WHERE pvr.vehicle_repository_id = pva.vehicle_repository_id
       AND pvr.business_group_id = pva.business_group_id
       AND pvr.vehicle_ownership = p_vehicle_ownership
       AND pva.default_vehicle = 'Y'
       AND pva.assignment_id = p_rec.assignment_id
       AND pva.business_group_id=p_rec.business_group_id
       AND (p_effective_date between
           pva.effective_start_date and pva.effective_end_date
           OR  p_effective_date <= pva.effective_start_date)
       AND (p_effective_date between
           pvr.effective_start_date and pvr.effective_end_date);

  l_rowcount NUMBER ;

BEGIN
     hr_utility.set_location('Entering pqp_check_veh_alloc_process', 16);
     OPEN  c_alloc_count_cursor;
     FETCH c_alloc_count_cursor INTO l_rowcount;
     CLOSE c_alloc_count_cursor ;

        IF l_rowcount > 0 THEN
           --This is max default vehicle ,so user canot allocate
            hr_utility.set_location('Count for default:'||l_rowcount, 20);
            p_message :='Only one Default vehicle allocated to the user';
        RETURN -1;
      END IF;
  RETURN 0;
END chk_defult_private_veh;
-- end function

-----------------------------------------------------------------------------
--Delete process for NI car Primary element entry
----------------------------------------------------------------------------

Procedure del_ni_car_entry (p_business_group_id IN NUMBER
                       ,p_assignment_id     IN NUMBER
                       ,p_allocation_id     IN NUMBER
                       ,p_effective_date    IN DATE
                       )
is
CURSOR c_chk_ni_car_pri
IS
SELECT pee.element_entry_id element_entry_id
                          FROM pay_element_entries_f PEE
                               ,pay_element_links_f pel
                               ,pay_element_types_f pet
                         WHERE pee.assignment_id=p_assignment_id
                          AND pel.business_group_id=p_business_group_id
                          and p_effective_date BETWEEN  pee.effective_start_date
                                          AND pee.effective_end_date
                          and p_effective_date BETWEEN  pel.effective_start_date
                                          AND pel.effective_end_date
                          and p_effective_date BETWEEN  pet.effective_start_date
                                          AND pet.effective_end_date
                          and pee.element_link_id=pel.element_link_id
                          AND pel.element_type_id=pet.element_type_id
                          AND pet.element_name = 'NI Car Primary';

CURSOR c_chk_sec_car (cp_allocation_id     IN NUMBER)
is
SELECT pee.element_entry_id  element_entry_id
                          FROM pay_element_entries_f PEE
                               ,pay_element_links_f pel
                               ,pay_element_types_f pet
                               ,pay_input_values_f piv
                               , pay_element_entry_values_f peev
                               , pqp_vehicle_allocations_f pva
                               ,pqp_vehicle_repository_f pvr
                         WHERE pee.ASSIGNMENT_ID=p_assignment_id
                          AND pel.business_group_id=p_business_group_id
                          AND pee.element_link_id=pel.element_link_id
                          AND pel.element_type_id=pet.element_type_id
                          AND pet.element_name = 'NI Car Secondary'
                          AND piv.element_type_id =  pet.element_type_id
                          AND  piv.name = 'Registration Number'
                          AND peev.input_value_id=piv.input_value_id
                          AND  peev.element_entry_id=pee.element_entry_id
                          AND pva.vehicle_allocation_id=cp_allocation_id
                          AND pva.vehicle_repository_id=pvr.VEHICLE_REPOSITORY_ID
                          AND peev.screen_entry_value=pvr.registration_number
                           AND pel.business_group_id=piv.business_group_id
                           AND piv.business_group_id=pva.business_group_id
                           AND piv.business_group_id=pvr.business_group_id
                           AND pet.legislation_code='GB'
                          AND p_effective_date BETWEEN  pee.effective_start_date
                                          AND pee.effective_end_date
                          AND p_effective_date BETWEEN  pel.effective_start_date
                                          AND pel.effective_end_date
                          AND p_effective_date BETWEEN  pet.effective_start_date
                                          AND pet.effective_end_date
                          AND p_effective_date BETWEEN  piv.effective_start_date
                                          AND piv.effective_end_date
                           AND p_effective_date BETWEEN  peev.effective_start_date
                                          AND peev.effective_end_date
                           AND p_effective_date BETWEEN  pva.effective_start_date
                                          AND pva.effective_end_date
                           AND p_effective_date BETWEEN  pvr.effective_start_date
                                          AND pvr.effective_end_date;
l_chk_ni_car_pri c_chk_ni_car_pri%ROWTYPE;
l_chk_sec_car    c_chk_sec_car%ROWTYPE;

Begin

 OPEN c_chk_ni_car_pri;
  FETCH c_chk_ni_car_pri INTO l_chk_ni_car_pri;
 CLOSE c_chk_ni_car_pri;

 IF l_chk_ni_car_pri.element_entry_id IS NOT NULL THEN
  hr_entry_api.delete_element_entry
  (
   p_dt_delete_mode        =>    'DELETE',
   p_session_date          =>     p_effective_date,
   p_element_entry_id      =>     l_chk_ni_car_pri.element_entry_id
  );
 END IF;

 OPEN c_chk_sec_car (p_allocation_id);
  FETCH c_chk_sec_car INTO l_chk_sec_car;
 CLOSE c_chk_sec_car;

 IF l_chk_sec_car.element_entry_id IS NOT NULL THEN
  hr_entry_api.delete_element_entry
  (
   p_dt_delete_mode         =>   'DELETE',
   p_session_date           =>    p_effective_date,
   p_element_entry_id       =>    l_chk_sec_car.element_entry_id
  );
 END IF;

EXCEPTION
--------
WHEN OTHERS THEN
NULL;

End;

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in pqp_val_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is

    --Used to get the ownership for repId at once
    CURSOR c_veh_det_cursor IS
        SELECT  pvr.vehicle_ownership
               ,pvr.vehicle_status
               ,pvr.shared_vehicle
               ,pvr.initial_registration
               ,pvr.registration_number
          FROM  pqp_vehicle_repository_f pvr
         WHERE  pvr.vehicle_repository_id = p_rec.vehicle_repository_id
           AND  pvr.business_group_id=  p_rec.business_group_id
           AND  p_effective_date BETWEEN
                pvr.effective_start_date AND
                pvr.effective_end_date;
--
  l_proc                 varchar2(72) := g_package||'insert_validate';
  l_return_status        NUMBER ;
  l_return_count         NUMBER;
  l_number_value         NUMBER;
  l_cmy_veh_alloc_count  NUMBER;
  l_pri_veh_alloc_count  NUMBER;
  l_message              VARCHAR2(2500) ;
  l_max_conf_count       VARCHAR2(10);
  l_vehicle_ownership    pqp_vehicle_repository_f.vehicle_ownership%type;
  l_legislation_code     varchar2(150);
  l_vehicle_status       pqp_vehicle_repository_f.vehicle_status%type;
  l_shared_vehicle       pqp_vehicle_repository_f.shared_vehicle%type;
  l_initial_registration pqp_vehicle_repository_f.initial_registration%type;
  l_registration_number  pqp_vehicle_repository_f.registration_number%type;
--

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => pqp_val_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');

  --Used to get the ownership for repId at once
  OPEN c_veh_det_cursor;
  FETCH c_veh_det_cursor INTO l_vehicle_ownership,
                          l_vehicle_status,l_shared_vehicle,
                          l_initial_registration,l_registration_number;
  CLOSE c_veh_det_cursor;


   --Checking the vehicle status ,if it Inactive then
   --vehicle cannot be allocate
    IF l_vehicle_status = 'I' THEN
      fnd_message.set_name('PQP', 'PQP_230925_INACTIVE_VEH_ASSIGN');
      fnd_message.raise_error;
    END IF;

   --Fixing the bug #2864591
   --Checking the allocation effective start date is
   --greter than or equal to veh reg date
    IF l_initial_registration IS NOT NULL THEN
      IF l_initial_registration > p_effective_date THEN
         fnd_message.set_name('PQP', 'PQP_230926_REG_DATE_ASSIGN_ERR');
         fnd_message.set_token('TOKEN',l_registration_number);
         fnd_message.raise_error;
      END IF;
   END IF;


  --Checking Usage Type Mandatory
 IF p_rec.usage_type='P' OR p_rec.usage_type='S' THEN
  l_return_status := chk_mandatory(
                       p_argument        =>'Usage Type'
                      ,p_argument_value  => p_rec.usage_type
                      ,p_message         => l_message);

  IF l_return_status = -1 THEN
    fnd_message.set_name('PQP', 'PQP_230734_FLD_MANDTRY');
    fnd_message.set_token('FEILD','Usage Type');
    fnd_message.raise_error;
  END IF;
 END IF;

  --Checking usage Type lookup validation
  --Usage type lookup type will vary based on ownership
  --IF l_vehicle_ownership = 'C' THEN
   IF  l_vehicle_ownership in ('C','PL_LEC','PL_LC') THEN
     l_return_status := chk_lookup(
                      p_vehicle_allocation_id  => p_rec.vehicle_allocation_id
                     ,p_lookup_type            =>'PQP_COMPANY_VEHICLE_USER'
                     ,p_lookup_code            => p_rec.usage_type
                     ,p_effective_date         => p_effective_date
                     ,p_validation_start_date  => p_validation_start_date
                     ,p_validation_end_date    => p_validation_end_date);

     IF l_return_status = -1 THEN
        fnd_message.set_name('PQP','PQP_230722_VLD_USG_OWNRSHP');
        fnd_message.raise_error;
     END IF;
  ELSE
    /*
      l_return_status := chk_lookup(
                      p_vehicle_allocation_id  => p_rec.vehicle_allocation_id
                     ,p_lookup_type            =>'PQP_PRIVATE_VEHICLE_USER'
                     ,p_lookup_code            => p_rec.usage_type
                     ,p_effective_date         => p_effective_date
                     ,p_validation_start_date  => p_validation_start_date
                     ,p_validation_end_date    => p_validation_end_date);

      IF l_return_status = -1 THEN
        fnd_message.set_name('PQP','PQP_230722_VLD_USG_OWNRSHP');
        fnd_message.raise_error;
      END IF;*/
  NULL;
  END IF;

  --Checking calculation method lookup validation
  l_return_status := chk_lookup(
                      p_vehicle_allocation_id  => p_rec.vehicle_allocation_id
                     ,p_lookup_type            =>'PQP_VEHICLE_CALC_METHOD'
                     ,p_lookup_code            => p_rec.calculation_method
                     ,p_effective_date         => p_effective_date
                     ,p_validation_start_date  => p_validation_start_date
                     ,p_validation_end_date    => p_validation_end_date);

  IF l_return_status = -1 THEN
     fnd_message.set_name('PQP','PQP_230824_VALID_CALC_METHOD');
     fnd_message.raise_error;
  END IF;

    --Checking the regnumber exist
    l_return_status := chk_reg_exist_for_alloc(
                           p_rec               => p_rec
                          ,p_effective_date    => p_effective_date
                          ,p_message           => l_message );

    IF l_return_status = -1 THEN
      fnd_message.set_name('PQP', 'PQP_230759_ALLOC_REG_EXIST');
      fnd_message.raise_error;
    END IF;


    --Checking the fuelcard/fuelNumber/fuelbenifit value
    --for cmy vehicle allocation
   IF  l_vehicle_ownership in ('C','PL_LEC','PL_LC') THEN

       l_return_status := pqp_check_cmyveh_fuel_card (
                           p_rec               => p_rec
                          ,p_vehicle_ownership => l_vehicle_ownership
                          ,p_effective_date    => p_effective_date
                          ,p_message           => l_message );

      IF l_return_status = -1 THEN
         fnd_message.set_name('PQP', 'PQP_230738_COMP_OWNR_MNDTRY');
         fnd_message.set_token('TOKEN','Fuel Card');
         fnd_message.raise_error;
      END IF;
    END IF;

    --Getting the legislationId for business groupId
    l_legislation_code :=
                   pqp_vre_bus.get_legislation_code(p_rec.business_group_id);


    --Checking the Primary vehicle allocation
    --If usage type is 'PRIMARY' then check is there any P vehicle
    --for this assignment
    IF p_rec.usage_type = 'P'  THEN
      l_return_count := pqp_check_veh_alloc_process(
                                p_rec               =>p_rec
                               ,p_vehicle_ownership =>l_vehicle_ownership
                               ,p_effective_date    =>p_effective_date
                               ,p_message           => l_message );

     -- If there is already allocation then throw error
     -- because it should be only one entry for P/E
     IF l_return_count = -1 THEN
        fnd_message.set_name('PQP', 'PQP_230708_PMRY_RESTRICT');
       fnd_message.raise_error;
     END IF;
  END IF;



  --If  company vehcicle then check max limit is reached or not.
 IF  l_vehicle_ownership in ('C','PL_LEC','PL_LC') THEN
   --call max allocations count for assignment for this ownership
   l_cmy_veh_alloc_count := pqp_get_max_allowed_veh(
                                 p_rec               =>p_rec
                                ,p_vehicle_ownership =>l_vehicle_ownership
                                ,p_effective_date    =>p_effective_date );



   --call configuration max allowed cmy vehicles
   l_max_conf_count := pqp_vre_bus.PQP_GET_CONFIG_VALUE(
                               p_business_group_id    => p_rec.business_group_id,
                               p_legislation_code     => l_legislation_code,
                               p_seg_col_name         =>'MaxCmyVehAllow',
                               p_table_name           =>'p_table_name',
                               p_information_category =>'PQP_VEHICLE_MILEAGE');
   hr_utility.set_location('Count conf maximum count:'||l_max_conf_count,23);
    --if null then no limit
    IF l_max_conf_count IS NOT NULL THEN
      Begin
       l_number_value := fnd_number.CANONICAL_TO_NUMBER(l_max_conf_count);
      End;
      IF l_cmy_veh_alloc_count >= l_number_value THEN
         l_message := 'person already reached the maximum limit';
         fnd_message.set_name('PQP', 'PQP_230709_MAX_COMP_ALLOC');
         fnd_message.raise_error;
      END IF;
    END IF;

    --Checking the Share Company Car validation
     l_return_count := pqp_config_shared_veh(
                           p_rec       => p_rec,
                           p_vehicle_ownership    => l_vehicle_ownership,
                           p_shared_vehicle       => l_shared_vehicle,
                           p_effective_date       => p_effective_date,
                           p_legislation_code     => l_legislation_code,
                           p_seg_col_name         =>'ShareCmyCar',
                           p_table_name           =>'p_table_name',
                           p_information_category =>'PQP_VEHICLE_MILEAGE',
                           p_message              => l_message );

    IF l_return_count = -1 THEN
      fnd_message.set_name('PQP', 'PQP_230707_VEH_ALLOC_INFO');
      fnd_message.raise_error;
    END IF;
  END IF;



--If Private vehcicle then check max limit is reached or not.
  IF l_vehicle_ownership in ('P','PL_PC') THEN

   --Checking default private Vehicle already exist or not
   --If no private default vehicle ,then user can allocate private vehicle
   --If there is already default vehicle allocated ,user cannot allocate
   --one more default vehicle.

    IF p_rec.default_vehicle = 'Y' THEN
       l_return_count := chk_defult_private_veh(
                                p_rec               =>p_rec
                               ,p_vehicle_ownership =>l_vehicle_ownership
                               ,p_effective_date    =>p_effective_date
                               ,p_message           =>l_message );
       -- If there is already allocation then throw error
       -- because it should be only one entry for default
       IF l_return_count = -1 THEN
          fnd_message.set_name('PQP', 'PQP_230746_ONE_ESS_RSTRICT');
          fnd_message.raise_error;
       END IF;
     END IF;


   --call max allocations count for assignment for this ownership
   l_pri_veh_alloc_count := pqp_get_max_allowed_veh(
                                  p_rec               =>p_rec
                                 ,p_vehicle_ownership =>l_vehicle_ownership
                                 ,p_effective_date    =>p_effective_date );

   --call configuration max allowed Pri vehicles
   l_max_conf_count := pqp_vre_bus.PQP_GET_CONFIG_VALUE(
                              p_business_group_id    => p_rec.business_group_id ,
                              p_legislation_code     => l_legislation_code,
                              p_seg_col_name         =>'MaxPriVehAllow',
                              p_table_name           =>'p_table_name',
                              p_information_category =>'PQP_VEHICLE_MILEAGE');

    --if null then no limit
    IF l_max_conf_count IS NOT NULL THEN
      Begin
       l_number_value := fnd_number.CANONICAL_TO_NUMBER(l_max_conf_count);
      End;

      IF l_pri_veh_alloc_count >= l_number_value THEN
        l_message := 'person already reached the maximum limit';
        fnd_message.set_name('PQP', 'PQP_230710_MAX_PVT_ALLOC');
        fnd_message.raise_error;
      END IF;
    END IF;
     -- cheking for share Private car
     l_return_count := pqp_config_shared_veh(
                           p_rec                  => p_rec,
                           p_vehicle_ownership    => l_vehicle_ownership,
                           p_shared_vehicle       => l_shared_vehicle,
                           p_effective_date       => p_effective_date,
                           p_legislation_code     => l_legislation_code,
                           p_seg_col_name         =>'SharePriCar',
                           p_table_name           =>'p_table_name',
                           p_information_category =>'PQP_VEHICLE_MILEAGE',
                           p_message              => l_message );

    IF l_return_count = -1 THEN
      fnd_message.set_name('PQP', 'PQP_230707_VEH_ALLOC_INFO');
      fnd_message.raise_error;
    END IF;
  END IF;
  Exception
   when app_exception.application_exception then
   IF hr_multi_message.exception_add
         (
          p_same_associated_columns => 'Y'
        ) then
      raise;
  END IF;


  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  --
  pqp_val_bus.chk_ddf(p_rec);
  --
  pqp_val_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in pqp_val_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is

  --Used to get the ownership for repId at once
  CURSOR c_veh_det_cursor IS
        SELECT  pvr.vehicle_ownership
               ,pvr.vehicle_status
               ,pvr.initial_registration
               ,pvr.registration_number
          FROM  pqp_vehicle_repository_f pvr
         WHERE  pvr.vehicle_repository_id = p_rec.vehicle_repository_id
           AND  pvr.business_group_id=  p_rec.business_group_id
           AND  p_effective_date BETWEEN
                pvr.effective_start_date
            AND pvr.effective_end_date;

--
  l_proc                    varchar2(72) := g_package||'update_validate';
  l_validation_start_date   date;
  l_validation_end_date     date;
  l_return_status           NUMBER ;
  l_vehicle_status          pqp_vehicle_repository_f.vehicle_status%type;
  l_return_count            NUMBER;
  l_message                 VARCHAR2(2500) ;
  l_vehicle_ownership       pqp_vehicle_repository_f.vehicle_ownership%TYPE;
  l_initial_registration    pqp_vehicle_repository_f.initial_registration%type;
  l_registration_number     pqp_vehicle_repository_f.registration_number%type;


--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => pqp_val_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --

  --
  -- Validate Dependent Attributes
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );
  --
  chk_vehicle_exst ( p_rec                   =>p_rec
                    ,p_effective_date        =>p_effective_date
                    ,p_datetrack_mode        =>p_datetrack_mode
                    ,p_validation_start_date =>p_validation_start_date
                    ,p_validation_end_date   =>p_validation_end_date
                    );

  chk_asg_exst    ( p_rec                   =>p_rec
                    ,p_effective_date        =>p_effective_date
                    ,p_datetrack_mode        =>p_datetrack_mode
                    ,p_validation_start_date =>p_validation_start_date
                    ,p_validation_end_date   =>p_validation_end_date
                    );


  OPEN c_veh_det_cursor;
  FETCH c_veh_det_cursor INTO l_vehicle_ownership,l_vehicle_status,
                              l_initial_registration,l_registration_number;
  CLOSE c_veh_det_cursor;

   --Used to get the ownership for repId at once
 IF pqp_val_shd.g_old_rec.vehicle_repository_id <>
               p_rec.vehicle_repository_id THEN

    IF l_vehicle_status = 'I' THEN
      l_message := 'Vehicle status is Inactive,so vehicle cannot update';
      fnd_message.set_name('PQP', 'PQP_230925_INACTIVE_VEH_ASSIGN');
      fnd_message.raise_error;
    END IF;
  END IF;

  --Fixing the bug #2864591
   --Checking the allocation effective start date is
   --greter than or equal to veh reg date
   IF l_initial_registration IS NOT NULL THEN
      IF l_initial_registration > p_effective_date THEN
         fnd_message.set_name('PQP', 'PQP_230926_REG_DATE_ASSIGN_ERR');
         fnd_message.set_token('TOKEN',l_registration_number);
         fnd_message.raise_error;
      END IF;
   END IF;

 --Checking for value change
 IF ( nvl(pqp_val_shd.g_old_rec.usage_type,hr_api.g_varchar2)
       <> nvl(p_rec.usage_type,hr_api.g_varchar2) ) THEN

    --Checking usage Type lookup validation
    --Usage type lookup type will vary based on ownership
     IF  l_vehicle_ownership in ('C','PL_LEC','PL_LC') THEN
        --If not equal then Checking usage_type lookup validation
          l_return_status := chk_lookup(
                      p_vehicle_allocation_id  => p_rec.vehicle_allocation_id
                     ,p_lookup_type            =>'PQP_COMPANY_VEHICLE_USER'
                     ,p_lookup_code            => p_rec.usage_type
                     ,p_effective_date         => p_effective_date
                     ,p_validation_start_date  => p_validation_start_date
                     ,p_validation_end_date    => p_validation_end_date);
         IF l_return_status = -1 THEN
            fnd_message.set_name('PQP','PQP_230722_VLD_USG_OWNRSHP');
            fnd_message.raise_error;
         END IF;
    ELSE
     /*
      l_return_status := chk_lookup(
                      p_vehicle_allocation_id  => p_rec.vehicle_allocation_id
                     ,p_lookup_type            =>'PQP_PRIVATE_VEHICLE_USER'
                     ,p_lookup_code            => p_rec.usage_type
                     ,p_effective_date         => p_effective_date
                     ,p_validation_start_date  => p_validation_start_date
                     ,p_validation_end_date    => p_validation_end_date);
      IF l_return_status = -1 THEN
        fnd_message.set_name('PQP','PQP_230722_VLD_USG_OWNRSHP');
        fnd_message.raise_error;
      END IF;*/
     NULL;
    END IF;
  END IF;

   --Checking for value change
   IF ( nvl(pqp_val_shd.g_old_rec.calculation_method,hr_api.g_varchar2)
       <> nvl(p_rec.calculation_method,hr_api.g_varchar2) ) THEN
      --Checking calculation method lookup validation
      l_return_status := chk_lookup(
                      p_vehicle_allocation_id  => p_rec.vehicle_allocation_id
                     ,p_lookup_type            =>'PQP_VEHICLE_CALC_METHOD'
                     ,p_lookup_code            => p_rec.calculation_method
                     ,p_effective_date         => p_effective_date
                     ,p_validation_start_date  => p_validation_start_date
                     ,p_validation_end_date    => p_validation_end_date);

     IF l_return_status = -1 THEN
        fnd_message.set_name('PQP','PQP_230824_VALID_CALC_METHOD');
        fnd_message.raise_error;
     END IF;
  END IF;


   --checking only if there is change in UsageType for update
   IF pqp_val_shd.g_old_rec.usage_type <> p_rec.usage_type THEN

     --If usage type is 'PRIMARY'  then check is there any
     --Private vehicles for this assignment
     IF p_rec.usage_type = 'P'  THEN
        l_return_count := pqp_check_veh_alloc_process(
                              p_rec               =>p_rec
                             ,p_vehicle_ownership =>l_vehicle_ownership
                             ,p_effective_date    =>p_effective_date
                             ,p_message           =>l_message );

      -- If there is already allocation then throw error,because it
      --should be only one entry for P
      IF l_return_count = -1 THEN
         fnd_message.set_name('PQP', 'PQP_230708_PMRY_RESTRICT');
         fnd_message.raise_error;
      END IF;
    END IF;
   END IF;




  IF pqp_val_shd.g_old_rec.default_vehicle = 'N'  THEN

     IF p_rec.default_vehicle = 'Y' THEN

     --Checking default private Vehicle already exist or not
     --If no private default vehicle ,then user can allocate private vehicle
     --If there is already default vehicle allocated ,user cannot allocate
     --one more default vehicle.
       l_return_count := chk_defult_private_veh(
                                p_rec               =>p_rec
                               ,p_vehicle_ownership =>l_vehicle_ownership
                               ,p_effective_date    =>p_effective_date
                               ,p_message           =>l_message );
      --If there is already allocation then throw error
      --because it should be only one entry for default
      IF l_return_count = -1 THEN
         fnd_message.set_name('PQP', 'PQP_230746_ONE_ESS_RSTRICT');
         fnd_message.raise_error;
      END IF;
     END IF;
  END IF;

   Exception
   when app_exception.application_exception then
   IF hr_multi_message.exception_add
         (
          p_same_associated_columns => 'Y'
        ) then
      raise;
  END IF;
  pqp_val_bus.chk_ddf(p_rec);
  --
  pqp_val_bus.chk_df(p_rec);
  --
   hr_multi_message.end_validation_set;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in pqp_val_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_validate';
  l_return_status NUMBER ;
  l_message VARCHAR2(2500) ;

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
    ,p_vehicle_allocation_id            => p_rec.vehicle_allocation_id
    );
  --


 --Checking the vehicle availability before delete or purge.
 IF p_datetrack_mode = 'ZAP' THEN
    --This is for purge
       l_return_status := pqp_purge_veh_alloc
                             (p_rec             =>p_rec
                             ,p_effective_date  =>p_effective_date
                             ,p_message         => l_message );
    hr_utility.set_location('Purge delete status:'||l_return_status,40);
    IF l_return_status = -1 THEN
        fnd_message.set_name('PQP', 'PQP_230724_DEL_ALLOC_RESTRICT');
        fnd_message.raise_error;
     END IF;

  ELSIF p_datetrack_mode = 'DELETE' THEN
       --This is for enddate
       l_return_status := pqp_enddate_veh_alloc
                              (p_rec             =>p_rec
                               ,p_effective_date  =>p_effective_date
                               ,p_message         => l_message );
       hr_utility.set_location('En date delete status :'||l_return_status,45);
       IF l_return_status = -1 THEN
         fnd_message.set_name('PQP', 'PQP_230700_CANCEL_INFO');
         fnd_message.raise_error;
       END IF;
  END IF;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pqp_val_bus;

/
