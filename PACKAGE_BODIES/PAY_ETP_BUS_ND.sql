--------------------------------------------------------
--  DDL for Package Body PAY_ETP_BUS_ND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ETP_BUS_ND" as
/* $Header: pyetpmhi.pkb 120.3.12010000.3 2008/08/06 07:12:57 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_etp_bus_nd.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_element_type_id             number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_element_type_id                      in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_element_types_f etp
     where etp.element_type_id = p_element_type_id
       and pbg.business_group_id = etp.business_group_id;
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
    ,p_argument           => 'element_type_id'
    ,p_argument_value     => p_element_type_id
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
         => nvl(p_associated_column1,'ELEMENT_TYPE_ID')
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
  (p_element_type_id                      in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pay_element_types_f etp
     where etp.element_type_id = p_element_type_id
       and pbg.business_group_id (+) = etp.business_group_id;
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
    ,p_argument           => 'element_type_id'
    ,p_argument_value     => p_element_type_id
    );
  --
  if ( nvl(pay_etp_bus_nd.g_element_type_id, hr_api.g_number)
       = p_element_type_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_etp_bus_nd.g_legislation_code;
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
    pay_etp_bus_nd.g_element_type_id             := p_element_type_id;
    pay_etp_bus_nd.g_legislation_code  := l_legislation_code;
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
  (p_rec in pay_etp_shd_nd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.element_type_id is not null)  and
    (nvl(pay_etp_shd_nd.g_old_rec.element_information_category,
         hr_api.g_varchar2) <>
    nvl(p_rec.element_information_category, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.element_information1, hr_api.g_varchar2) <>
    nvl(p_rec.element_information1, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.element_information2, hr_api.g_varchar2) <>
    nvl(p_rec.element_information2, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.element_information3, hr_api.g_varchar2) <>
    nvl(p_rec.element_information3, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.element_information4, hr_api.g_varchar2) <>
    nvl(p_rec.element_information4, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.element_information5, hr_api.g_varchar2) <>
    nvl(p_rec.element_information5, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.element_information6, hr_api.g_varchar2) <>
    nvl(p_rec.element_information6, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.element_information7, hr_api.g_varchar2) <>
    nvl(p_rec.element_information7, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.element_information8, hr_api.g_varchar2) <>
    nvl(p_rec.element_information8, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.element_information9, hr_api.g_varchar2) <>
    nvl(p_rec.element_information9, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.element_information10, hr_api.g_varchar2) <>
    nvl(p_rec.element_information10, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.element_information11, hr_api.g_varchar2) <>
    nvl(p_rec.element_information11, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.element_information12, hr_api.g_varchar2) <>
    nvl(p_rec.element_information12, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.element_information13, hr_api.g_varchar2) <>
    nvl(p_rec.element_information13, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.element_information14, hr_api.g_varchar2) <>
    nvl(p_rec.element_information14, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.element_information15, hr_api.g_varchar2) <>
    nvl(p_rec.element_information15, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.element_information16, hr_api.g_varchar2) <>
    nvl(p_rec.element_information16, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.element_information17, hr_api.g_varchar2) <>
    nvl(p_rec.element_information17, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.element_information18, hr_api.g_varchar2) <>
    nvl(p_rec.element_information18, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.element_information19, hr_api.g_varchar2) <>
    nvl(p_rec.element_information19, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.element_information20, hr_api.g_varchar2) <>
    nvl(p_rec.element_information20, hr_api.g_varchar2) ))
    or (p_rec.element_type_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    /* hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PAY'
      ,p_descflex_name                   => 'Element Developer DF'
      ,p_attribute_category              => p_rec.element_information_category
      ,p_attribute1_name                 => 'ELEMENT_INFORMATION1'
      ,p_attribute1_value                => p_rec.element_information1
      ,p_attribute2_name                 => 'ELEMENT_INFORMATION2'
      ,p_attribute2_value                => p_rec.element_information2
      ,p_attribute3_name                 => 'ELEMENT_INFORMATION3'
      ,p_attribute3_value                => p_rec.element_information3
      ,p_attribute4_name                 => 'ELEMENT_INFORMATION4'
      ,p_attribute4_value                => p_rec.element_information4
      ,p_attribute5_name                 => 'ELEMENT_INFORMATION5'
      ,p_attribute5_value                => p_rec.element_information5
      ,p_attribute6_name                 => 'ELEMENT_INFORMATION6'
      ,p_attribute6_value                => p_rec.element_information6
      ,p_attribute7_name                 => 'ELEMENT_INFORMATION7'
      ,p_attribute7_value                => p_rec.element_information7
      ,p_attribute8_name                 => 'ELEMENT_INFORMATION8'
      ,p_attribute8_value                => p_rec.element_information8
      ,p_attribute9_name                 => 'ELEMENT_INFORMATION9'
      ,p_attribute9_value                => p_rec.element_information9
      ,p_attribute10_name                => 'ELEMENT_INFORMATION10'
      ,p_attribute10_value               => p_rec.element_information10
      ,p_attribute11_name                => 'ELEMENT_INFORMATION11'
      ,p_attribute11_value               => p_rec.element_information11
      ,p_attribute12_name                => 'ELEMENT_INFORMATION12'
      ,p_attribute12_value               => p_rec.element_information12
      ,p_attribute13_name                => 'ELEMENT_INFORMATION13'
      ,p_attribute13_value               => p_rec.element_information13
      ,p_attribute14_name                => 'ELEMENT_INFORMATION14'
      ,p_attribute14_value               => p_rec.element_information14
      ,p_attribute15_name                => 'ELEMENT_INFORMATION15'
      ,p_attribute15_value               => p_rec.element_information15
      ,p_attribute16_name                => 'ELEMENT_INFORMATION16'
      ,p_attribute16_value               => p_rec.element_information16
      ,p_attribute17_name                => 'ELEMENT_INFORMATION17'
      ,p_attribute17_value               => p_rec.element_information17
      ,p_attribute18_name                => 'ELEMENT_INFORMATION18'
      ,p_attribute18_value               => p_rec.element_information18
      ,p_attribute19_name                => 'ELEMENT_INFORMATION19'
      ,p_attribute19_value               => p_rec.element_information19
      ,p_attribute20_name                => 'ELEMENT_INFORMATION20'
      ,p_attribute20_value               => p_rec.element_information20
      );  */
    null;
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
  (p_rec in pay_etp_shd_nd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.element_type_id is not null)  and (
    nvl(pay_etp_shd_nd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(pay_etp_shd_nd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.element_type_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    /* hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PAY'
      ,p_descflex_name                   => 'PAY_ELEMENT_TYPES'
      ,p_attribute_category              => p_rec.attribute_category
      ,p_attribute1_name                 => 'ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.attribute1
      ,p_attribute2_name                 => 'ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.attribute2
      ,p_attribute3_name                 => 'ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.attribute3
      ,p_attribute4_name                 => 'ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.attribute4
      ,p_attribute5_name                 => 'ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.attribute5
      ,p_attribute6_name                 => 'ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.attribute6
      ,p_attribute7_name                 => 'ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.attribute7
      ,p_attribute8_name                 => 'ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.attribute8
      ,p_attribute9_name                 => 'ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.attribute9
      ,p_attribute10_name                => 'ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.attribute10
      ,p_attribute11_name                => 'ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.attribute11
      ,p_attribute12_name                => 'ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.attribute12
      ,p_attribute13_name                => 'ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.attribute13
      ,p_attribute14_name                => 'ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.attribute14
      ,p_attribute15_name                => 'ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.attribute15
      ,p_attribute16_name                => 'ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.attribute16
      ,p_attribute17_name                => 'ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.attribute17
      ,p_attribute18_name                => 'ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.attribute18
      ,p_attribute19_name                => 'ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.attribute19
      ,p_attribute20_name                => 'ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.attribute20
      ); */
      null;
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
  ,p_rec             in pay_etp_shd_nd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_etp_shd_nd.api_updating
      (p_element_type_id                  => p_rec.element_type_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
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
  (p_element_type_id                  in number
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
      ,p_argument       => 'element_type_id'
      ,p_argument_value => p_element_type_id
      );
    --
    If (dt_api.rows_exist
       (p_base_table_name => 'pay_input_values_f'
       ,p_base_key_column => 'element_type_id'
       ,p_base_key_value  => p_element_type_id
       ,p_from_date       => p_validation_start_date
       ,p_to_date         => p_validation_end_date
       )) Then
         fnd_message.set_name('PAY','HR_7215_DT_CHILD_EXISTS');
         fnd_message.set_token('TABLE_NAME','input values');
         hr_multi_message.add;
    End If;
    If (dt_api.rows_exist
       (p_base_table_name => 'ben_acty_base_rt_f'
       ,p_base_key_column => 'element_type_id'
       ,p_base_key_value  => p_element_type_id
       ,p_from_date       => p_validation_start_date
       ,p_to_date         => p_validation_end_date
       )) Then
         fnd_message.set_name('PAY','HR_7215_DT_CHILD_EXISTS');
         fnd_message.set_token('TABLE_NAME','acty base rt');
         hr_multi_message.add;
    End If;
    If (dt_api.rows_exist
       (p_base_table_name => 'pay_element_links_f'
       ,p_base_key_column => 'element_type_id'
       ,p_base_key_value  => p_element_type_id
       ,p_from_date       => p_validation_start_date
       ,p_to_date         => p_validation_end_date
       )) Then
         fnd_message.set_name('PAY','HR_7215_DT_CHILD_EXISTS');
         fnd_message.set_token('TABLE_NAME','element links');
         hr_multi_message.add;
    End If;
    If (dt_api.rows_exist
       (p_base_table_name => 'pay_element_type_usages_f'
       ,p_base_key_column => 'element_type_id'
       ,p_base_key_value  => p_element_type_id
       ,p_from_date       => p_validation_start_date
       ,p_to_date         => p_validation_end_date
       )) Then
         fnd_message.set_name('PAY','HR_7215_DT_CHILD_EXISTS');
         fnd_message.set_token('TABLE_NAME','element type usages');
         hr_multi_message.add;
    End If;
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
  --
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
-- |------------------------< chk_business_group_id >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure is used to validate the business group id against the
--   parent table
--
-- ----------------------------------------------------------------------------
Procedure chk_business_group_id
  (p_business_group_id in number
  ,p_effective_date    in date
  ) is
--
  l_proc        varchar2(72) := g_package||'chk_business_group_id';
  l_exists	    varchar2(1);
  Cursor c_chk_bg_id
  is
    select '1'
      from hr_all_organization_units
     where business_group_id = p_business_group_id;
       -- and p_effective_date between date_from
       -- and nvl(date_to, hr_api.g_eot);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Open c_chk_bg_id;
  Fetch c_chk_bg_id into l_exists;
  If c_chk_bg_id%notfound Then
    --
    Close c_chk_bg_id;
    fnd_message.set_name('PAY','PAY_33085_INVALID_FK');
    fnd_message.set_token('COLUMN','BUSINESS_GROUP_ID');
    fnd_message.set_token('TABLE','HR_ORGANIZATION_UNITS');
    fnd_message.raise_error;
    --
  End If;
  Close c_chk_bg_id;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_legislation_code >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure is used to validate the legislation code against the
--   parent table
--
-- ----------------------------------------------------------------------------
Procedure chk_legislation_code
  (p_legislation_code  in varchar2)
  is
--
  l_proc        varchar2(72) := g_package||'chk_legislation_code';
  l_exists	    varchar2(1);
  Cursor c_chk_leg_code
  is
    select '1'
      from fnd_territories
     where territory_code = p_legislation_code;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If p_legislation_code is not null then

  	Open c_chk_leg_code;
  	Fetch c_chk_leg_code into l_exists;
  	If c_chk_leg_code%notfound Then
  	  --
  	  Close c_chk_leg_code;
  	  fnd_message.set_name('PAY','PAY_33085_INVALID_FK');
  	  fnd_message.set_token('COLUMN','LEGISLATION_CODE');
  	  fnd_message.set_token('TABLE','FND_TERRITORIES');
  	  fnd_message.raise_error;
  	  --
  	End If;
  	Close c_chk_leg_code;

  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_formula_id >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate the following business rules:
--
--   a) The Formula Type of the formula_id (ie. Skip Rule) must be
--      'Element Skip'.
--   b) The formula_id must be null if process_in_run_flag is 'N' or
--      indirect_only_flag is 'Y' or adjustment_only_flag is 'Y'.
--
-- Prerequisites:
--   This procedure is called from the insert_validate and update_validate.
--
-- In Parameters:
--   p_effective_date
--   p_validation_start_date
--   p_validation_end_date
--   p_formula_id
--   p_process_in_run_flag
--   p_indirect_only_flag
--   p_adjustment_only_flag
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If any one of the business rule validation fails then an error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_formula_id
  (p_effective_date	   in date
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ,p_formula_id 	   in number
  ,p_process_in_run_flag   in varchar2
  ,p_indirect_only_flag    in varchar2
  ,p_adjustment_only_flag  in varchar2
  ) is
--
  l_proc        varchar2(72) := g_package||'chk_formula_id';
  l_exists	varchar2(1);
  Cursor c_chk_formula_type
  is
    select '1'
      from ff_formulas_f fml, ff_formula_types ftp
     where fml.formula_id = p_formula_id
       and p_effective_date between fml.effective_start_date
       and fml.effective_end_date
       and ftp.formula_type_id = fml.formula_type_id
       and upper(ftp.formula_type_name) = 'ELEMENT SKIP';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If p_formula_id is not null Then
    If not (dt_api.rows_exist
	 (p_base_table_name => 'FF_FORMULAS_F'
	 ,p_base_key_column => 'FORMULA_ID'
	 ,p_base_key_value  => p_formula_id
	 ,p_from_date       => p_validation_start_date
	 ,p_to_date         => p_validation_end_date
	 )) Then
      --
      fnd_message.set_name('PAY','PAY_33085_INVALID_FK');
      fnd_message.set_token('COLUMN','FORMULA_ID');
      fnd_message.set_token('TABLE','FF_FORMULAS_F');
      fnd_message.raise_error;
      --
    End If;
    --
    If (p_process_in_run_flag  = 'N' or
        p_indirect_only_flag   = 'Y' or
        p_adjustment_only_flag = 'Y') Then
    --
    fnd_message.set_name('PAY','HR_6951_PAY_ELE_NO_SKIP_RULE');
    fnd_message.raise_error;
    --
    End If;
    --
    Open c_chk_formula_type;
    Fetch c_chk_formula_type into l_exists;
    If c_chk_formula_type%notfound Then
      --
      Close c_chk_formula_type;
      fnd_message.set_name('PAY','PAY_34130_ELE_FTYPE_INVALID');
      fnd_message.raise_error;
      --
    End If;
    Close c_chk_formula_type;
  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_currency_codes >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate the following business rules:
--
--   a) If an input_currency_code is specified, then an output_currency_code
-- 	must also be specified and vice versa
--   b) Both input_currency_code and output_currency_code must be
--      present in  FND_CURRENCIES (currency_code) for the current
--      session date.
--   c) For element classification 'Payments', the output currency should be
--      same as that defined in pay_legislation_rules.
--
-- Prerequisites:
--   This procedure is called from the insert_validate.
--
-- In Parameters:
--   p_effective_date
--   p_input_currency_code
--   p_output_currency_code
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If any one of the business rule validation fails then an error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_currency_codes
  (p_effective_date  	   in date
  ,p_classification_id	   in number
  ,p_business_group_id     in number
  ,p_input_currency_code   in varchar2
  ,p_output_currency_code  in varchar2
  ) is
--
  l_proc              varchar2(72) := g_package||'chk_currency_codes';
  l_exists	      varchar2(1);
  l_non_payments_flag varchar2(30);
  l_rule_mode         pay_legislation_rules.rule_mode%type;

  Cursor c_chk_currency(p_currency_code varchar2)
  is
    select '1'
      from fnd_currencies
     where currency_code = p_currency_code
       and enabled_flag = 'Y'
       and currency_flag = 'Y'
       and p_effective_date between nvl(start_date_active,p_effective_date)
       and nvl(end_date_active,p_effective_date);

  Cursor c_non_payments
  is
    select non_payments_flag
      from pay_element_classifications
     where classification_id = p_classification_id;

  Cursor c_leg_rule_currency
  is
    select rule_mode
      from pay_legislation_rules
     where legislation_code = hr_api.return_legislation_code
                              (p_business_group_id)
       and rule_type        = 'DC';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Open c_non_payments;
  Fetch c_non_payments into l_non_payments_flag;
  Close c_non_payments;
  --
  If (l_non_payments_flag = 'N' and
      (p_input_currency_code is null or p_output_currency_code is null)) Then
  --
    fnd_message.set_name('PAY','PAY_34131_ELE_CURR_REQD1');
    fnd_message.raise_error;
  --
  End If;
  --
  If (p_input_currency_code is not null and p_output_currency_code is null
      or
      p_input_currency_code is null and p_output_currency_code is not null
      ) Then
  --
    fnd_message.set_name('PAY','PAY_34150_ELE_CURR_REQD2');
    fnd_message.raise_error;
  --
  End If;
  --
  If p_input_currency_code is not null Then
  --
    Open c_chk_currency(p_input_currency_code);
    Fetch c_chk_currency into l_exists;
    If c_chk_currency%notfound Then
    --
      Close c_chk_currency;
      fnd_message.set_name('PAY','HR_51855_QUA_CCY_INV');
      fnd_message.raise_error;
    --
    End If;
    Close c_chk_currency;
  --
  End If;
  --
  If p_output_currency_code is not null Then
  --
    Open c_chk_currency(p_output_currency_code);
    Fetch c_chk_currency into l_exists;
    If c_chk_currency%notfound Then
    --
      Close c_chk_currency;
      fnd_message.set_name('PAY','HR_51855_QUA_CCY_INV');
      fnd_message.raise_error;
    --
    End If;
    Close c_chk_currency;
  --
  End If;
  --
  If l_non_payments_flag = 'N' Then
    --
    Open c_leg_rule_currency;
    Fetch c_leg_rule_currency into l_rule_mode;
    If c_leg_rule_currency%found Then
      If p_output_currency_code <> l_rule_mode then
        Close c_leg_rule_currency;
        fnd_message.set_name('PAY','PAY_34152_ELE_INVALID_CURR');
        fnd_message.raise_error;
      End If;
    End if;
    Close c_leg_rule_currency;
    --
  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_classification_id >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate the following business rule:
--
--   a) An element with an 'Initial Balance' classification must have
--      adjustment_only_flag as 'Y', process_in_run_flag as 'Y', processing_type
--      as 'N' (Non recurring) and indirect_only_flag as 'N'.
--
-- Prerequisites:
--   This procedure is called from the insert_validate and update_validate.
--
-- In Parameters:
--   p_classification_id
--   p_adjustment_only_flag
--   p_process_in_run_flag
--   p_processing_type
--   p_indirect_only_flag
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If the business rule validation fails then an error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_classification_id
  (p_classification_id		in number
  ,p_adjustment_only_flag	in varchar2
  ,p_process_in_run_flag	in varchar2
  ,p_processing_type		in varchar2
  ,p_indirect_only_flag		in varchar2
  ) is
--
  l_proc        varchar2(72) := g_package||'chk_class_id';
  l_exists	varchar2(1);
  Cursor c_get_class_bal_init
  is
    select '1'
      from pay_element_classifications
     where classification_id = p_classification_id
       and nvl(balance_initialization_flag,'N') = 'Y';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Open c_get_class_bal_init;
  Fetch c_get_class_bal_init into l_exists;
  If c_get_class_bal_init%found then
  --
    If     (p_adjustment_only_flag <> 'Y' or
            p_process_in_run_flag  <> 'Y' or
            p_processing_type      <> 'N' or
            p_indirect_only_flag   <> 'N') Then
    --
      Close c_get_class_bal_init;
      fnd_message.set_name('PAY','PAY_34132_ELE_CLASS_VLDTN');
      fnd_message.raise_error;
    --
    End If;
  End If;
  Close c_get_class_bal_init;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_addl_entry_allowed >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate the following business rule:
--
--   a) Additional_entry_allowed_flag must be 'N' when the processing_type
--      is 'N'.
--
-- Prerequisites:
--   This procedure is called from insert_validate and update_validate.
--
-- In Parameters:
--   p_addl_entry_allowed_flag
--   p_processing_type
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If the business rule validation fails then an error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_addl_entry_allowed
  (p_effective_date	      in date
  ,p_addl_entry_allowed_flag  in varchar2
  ,p_processing_type	      in varchar2
  ) is
--
  l_proc        varchar2(72) := g_package||'chk_addl_entry_alld';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If hr_api.not_exists_in_hr_lookups
	(p_effective_date
	,'YES_NO'
	,p_addl_entry_allowed_flag) Then
	--
	fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
	fnd_message.set_token('COLUMN','ADDITIONAL_ENTRY_ALLOWED_FLAG');
	fnd_message.set_token('LOOKUP_TYPE','YES_NO');
	fnd_message.raise_error;
	--
  End If;
  --
  If (p_addl_entry_allowed_flag = 'Y' and p_processing_type = 'N') Then
  --
    fnd_message.set_name('PAY','PAY_6142_ELEMENT_NO_ADD_ENTRY');
    fnd_message.raise_error;
  --
  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_adjustment_only_flag >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate the following business rules:
--
--   a) Adjustment_only_flag must be 'N' when the Processing_type is 'R'.
--   b) If adjustment_only_flag is 'Y' then indirect_only_flag must be 'N'
--      and vice versa.
--   c) Indirect_only_flag must be 'N' when the Processing_type is 'R'.
--
-- Prerequisites:
--   This procedure is called from insert_validate and update_validate.
--
-- In Parameters:
--   p_adjustment_only_flag
--   p_processing_type
--   p_indirect_only_flag
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If the business rule validation fails then an error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_adjustment_only_flag
  (p_effective_date		in date
  ,p_adjustment_only_flag	in varchar2
  ,p_closed_for_entry_flag	in varchar2
  ,p_processing_type		in varchar2
  ,p_indirect_only_flag  	in varchar2
  ) is
--
  l_proc        varchar2(72) := g_package||'chk_adj_only_flag';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If hr_api.not_exists_in_hr_lookups
	(p_effective_date
	,'YES_NO'
	,p_adjustment_only_flag) Then
	--
	fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
	fnd_message.set_token('COLUMN','ADJUSTMENT_ONLY_FLAG');
	fnd_message.set_token('LOOKUP_TYPE','YES_NO');
	fnd_message.raise_error;
	--
  End If;
  --
  If hr_api.not_exists_in_hr_lookups
	(p_effective_date
	,'YES_NO'
	,p_closed_for_entry_flag) Then
	--
	fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
	fnd_message.set_token('COLUMN','CLOSED_FOR_ENTRY_FLAG');
	fnd_message.set_token('LOOKUP_TYPE','YES_NO');
	fnd_message.raise_error;
	--
  End If;
  --
  If (p_adjustment_only_flag = 'Y' and p_processing_type = 'R') Then
  --
    fnd_message.set_name('PAY','PAY_6712_ELEMENT_NO_REC_ADJ');
    fnd_message.raise_error;
  --
  End If;
  --
  If (p_adjustment_only_flag = 'Y' and p_indirect_only_flag = 'Y') Then
  --
    fnd_message.set_name('PAY','PAY_34133_ELE_ADJ_INDIRECT');
    fnd_message.raise_error;
  --
  End If;
  --
  If (p_processing_type = 'R' and p_indirect_only_flag = 'Y') Then
  --
    fnd_message.set_name('PAY','PAY_6707_ELEMENT_NO_REC_IND');
    fnd_message.raise_error;
  --
  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_element_name >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate the following business rules:
--
--   a) Element name must be unique within a Legislation or Business group for
--      entire lifetime of the Element
--   b) Element name must be a valid db item name.
--
-- Prerequisites:
--   This procedure is called from insert_validate and update_validate.
--
-- In Parameters:
--   p_element_name
--   p_business_group_id
--   p_legislation_code
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If the business rule validation fails then an error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_element_name
  (p_element_name	   in     varchar2
  ,p_element_type_id	   in     number   default null
  ,p_business_group_id	   in     number
  ,p_legislation_code	   in     varchar2
  ) is
--
  l_proc        	varchar2(72) := g_package||'chk_element_name';
  l_dummy		varchar2(100);
  l_checkformat_error   boolean;
  l_unformatted_value   varchar2(255) := p_element_name;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If p_element_name is not null and
     pay_element_types_pkg.name_is_not_unique
           (p_element_name      => p_element_name
	   ,p_element_type_id   => p_element_type_id
	   ,p_business_group_id => p_business_group_id
	   ,p_legislation_code  => p_legislation_code
	   ,p_error_if_true     => FALSE
	    ) Then
  --
    fnd_message.set_name('PAY','PAY_6137_ELEMENT_DUP_NAME');
    fnd_message.raise_error;
  --
  End If;
  --
  Begin
    hr_chkfmt.checkformat(l_unformatted_value,
	     		  'PAY_NAME',
			  l_dummy,
			  null,
			  null,
			  'N',
			  l_dummy,
			  null);
  Exception
    when hr_utility.hr_error then
      l_checkformat_error := True;
  End;
  If (l_checkformat_error) then
  --
    fnd_message.set_name('PAY','PAY_6365_ELEMENT_NO_DB_NAME');
    fnd_message.raise_error;
  --
  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_multiple_entries_allowed >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate the following business rules:
--
--   a) Multiple_entries_allowed_flag must be set to 'N' if the Cobra_flag on
--      the benefit classification of the Recurring Element is set to 'Y'.
--   b) Multiple_entries_allowed_flag can only be updated if:
--      There exist no formula result rules where this element type
--      is the subject of "Stop entry" or "Update recurring" result
--      rules, unless the target of the rule is the same element as the
--      source
--
-- Prerequisites:
--   This procedure is called from insert_validate and update_validate.
--
-- In Parameters:
--   p_element_type_id
--   p_validation_start_date
--   p_validation_end_date
--   p_multiple_entries_allowed_flg
--   p_benefit_classification_id
--   p_processing_type
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If the business rule validation fails then an error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_multiple_entries_allowed
  (p_effective_date		    in date
  ,p_element_type_id    	    in number	default null
  ,p_validation_start_date	    in date	default null
  ,p_validation_end_date  	    in date     default null
  ,p_multiple_entries_allowed_flg   in varchar2
  ,p_benefit_classification_id      in number
  ,p_processing_type		    in varchar2
  ) is
--
  l_proc        varchar2(72) := g_package||'chk_multiple_entries';
  l_exists		varchar2(1);
  Cursor c_chk_ben_cobra_flag
  is
    select '1'
      from ben_benefit_classifications
     where benefit_classification_id = p_benefit_classification_id
       and cobra_flag = 'Y';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If hr_api.not_exists_in_hr_lookups
	(p_effective_date
	,'YES_NO'
	,p_multiple_entries_allowed_flg) Then
	--
	fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
	fnd_message.set_token('COLUMN','MULTIPLE_ENTRIES_ALLOWED_FLAG');
	fnd_message.set_token('LOOKUP_TYPE','YES_NO');
	fnd_message.raise_error;
	--
  End If;
  --
  Open c_chk_ben_cobra_flag;
  Fetch c_chk_ben_cobra_flag into l_exists;
  Close c_chk_ben_cobra_flag;
  If (p_multiple_entries_allowed_flg = 'Y' and p_processing_type = 'R'
     and l_exists is not null) Then
  --
    fnd_message.set_name('PAY','PAY_6964_ELEMENT_COBRA_MULTI');
    fnd_message.raise_error;
  --
  End If;
  If p_element_type_id is not null and
     (p_multiple_entries_allowed_flg <>
      pay_etp_shd_nd.g_old_rec.multiple_entries_allowed_flag) Then
     --
     If pay_element_types_pkg.stop_entry_rules_exist
         (p_element_type_id
         ,p_validation_start_date
         ,p_validation_end_date) Then
       --
       fnd_message.set_name('PAY','HR_6953_PAY_ELE_NO_STOP_ENTRY');
       fnd_message.raise_error;
       --
     End If;
     If pay_element_types_pkg.update_recurring_rules_exist
          (p_element_type_id
          ,p_validation_start_date
          ,p_validation_end_date) Then
       --
       fnd_message.set_name('PAY','HR_6953_PAY_ELE_NO_STOP_ENTRY');
       fnd_message.raise_error;
       --
     End If;
  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_process_in_run_flag >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate the following business rules:
--
--   a) If Process_in_run_flag is set to 'N', then Indirect_only_flag,
--      Adjustment_only_flag, Multiply_value_flag and Once_each_period_flag
--      must all be set to 'N'.
--
-- Prerequisites:
--   This procedure is called from insert_validate and update_validate.
--
-- In Parameters:
--   p_process_in_run_flag
--   p_adjustment_only_flag
--   p_indirect_only_flag
--   p_multiply_value_flag
--   p_once_each_period_flag
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If the business rule validation fails then an error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_process_in_run_flag
  (p_effective_date	    in date
  ,p_process_in_run_flag    in varchar2
  ,p_adjustment_only_flag   in varchar2
  ,p_indirect_only_flag     in varchar2
  ,p_multiply_value_flag    in varchar2
  ,p_post_termination_rule  in varchar2
  ,p_once_each_period_flag  in varchar2
  ) is
--
  l_proc        varchar2(72) := g_package||'chk_proc_in_run';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If hr_api.not_exists_in_hr_lookups
	(p_effective_date
	,'YES_NO'
	,p_process_in_run_flag) Then
	--
	fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
	fnd_message.set_token('COLUMN','PROCESS_IN_RUN_FLAG');
	fnd_message.set_token('LOOKUP_TYPE','YES_NO');
	fnd_message.raise_error;
	--
  End If;
  --
  If hr_api.not_exists_in_hr_lookups
	(p_effective_date
	,'YES_NO'
	,p_indirect_only_flag) Then
	--
	fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
	fnd_message.set_token('COLUMN','INDIRECT_ONLY_FLAG');
	fnd_message.set_token('LOOKUP_TYPE','YES_NO');
	fnd_message.raise_error;
	--
  End If;
  --
  If hr_api.not_exists_in_hr_lookups
	(p_effective_date
	,'YES_NO'
	,p_multiply_value_flag) Then
	--
	fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
	fnd_message.set_token('COLUMN','MULTIPLY_VALUE_FLAG');
	fnd_message.set_token('LOOKUP_TYPE','YES_NO');
	fnd_message.raise_error;
	--
  End If;
  --
  If hr_api.not_exists_in_hr_lookups
	(p_effective_date
	,'TERMINATION_RULE'
	,p_post_termination_rule) Then
	--
	fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
	fnd_message.set_token('COLUMN','POST_TERMINATION_RULE');
	fnd_message.set_token('LOOKUP_TYPE','TERMINATION_RULE');
	fnd_message.raise_error;
	--
  End If;
  --
  If hr_api.not_exists_in_hr_lookups
        (p_effective_date
        ,'YES_NO'
        ,p_once_each_period_flag) Then
        --
        fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
        fnd_message.set_token('COLUMN','ONCE_EACH_PERIOD_FLAG');
        fnd_message.set_token('LOOKUP_TYPE','YES_NO');
        fnd_message.raise_error;
        --
  End If;
  If (p_process_in_run_flag = 'N' and
      (p_adjustment_only_flag  = 'Y' or
       p_indirect_only_flag    = 'Y' or
       p_multiply_value_flag   = 'Y' or
       p_once_each_period_flag = 'Y')) Then
  --
    fnd_message.set_name('PAY','PAY_34134_ELE_PROC_RUN_VLDTN');
    fnd_message.raise_error;
  --
  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_processing_priority >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate the following business rules:
--
--   a) The Processing_priority can lie outside of the range for the
--      classification; the user is warned if this will be the case.
--   b) Processing_priority should not violate any formula result rules.
--
-- Prerequisites:
--   This procedure is called from insert_validate and update_validate.
--
-- In Parameters:
--   p_element_type_id
--   p_validation_start_date
--	 p_validation_end_date
--	 p_processing_priority
--	 p_classification_id
--
-- Post Success:
--   Processing continues. Also p_processing_priority_warning parameter is set
--   to true if business rule a) is violated.
--
-- Post Failure:
--   If the business rule validation fails then an error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_processing_priority
  (p_element_type_id    	 in  number default null
  ,p_validation_start_date	 in  date   default null
  ,p_validation_end_date  	 in  date   default null
  ,p_processing_priority 	 in  number
  ,p_classification_id   	 in  number
  ,p_processing_priority_warning out nocopy boolean
  ) is
--
  l_proc        	varchar2(72) := g_package||'chk_processing_priority';
  l_high_priority	pay_element_classifications.default_high_priority%type;
  l_low_priority	pay_element_classifications.default_low_priority%type;
  Cursor c_get_ele_class_priority
  is
    select default_high_priority,
 	   default_low_priority
      from pay_element_classifications
     where classification_id = p_classification_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Open c_get_ele_class_priority;
  Fetch c_get_ele_class_priority into l_high_priority, l_low_priority;
  Close c_get_ele_class_priority;
  --
  If p_processing_priority not between l_high_priority and l_low_priority Then
    p_processing_priority_warning := True;
  End If;
  If p_element_type_id is not null and
     (p_processing_priority <> pay_etp_shd_nd.g_old_rec.processing_priority) Then
    --
    If pay_element_types_pkg.priority_result_rule_violated
         (p_element_type_id,
	  p_processing_priority,
	  p_validation_start_date,
	  p_validation_end_date,
	  p_error_if_true => FALSE) Then
    --
    fnd_message.set_name('PAY','PAY_6149_ELEMENT_PRIORITY_UPD');
    fnd_message.raise_error;
    --
    End If;
  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_processing_type >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate the following business rules:
--
--   a) If Processing_type is Non-Recurring the Benefit_classification_id
--      cannot be set.
--
-- Prerequisites:
--   This procedure is called from insert_validate.
--
-- In Parameters:
--   p_processing_type
--   p_benefit_classification_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If the business rule validation fails then an error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_processing_type
  (p_effective_date		in date
  ,p_processing_type		in varchar2
  ,p_benefit_classification_id  in number
  ) is
--
  l_proc        varchar2(72) := g_package||'chk_processing_type';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If hr_api.not_exists_in_hr_lookups
	(p_effective_date
	,'PROCESSING_TYPE'
	,p_processing_type) Then
	--
	fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
	fnd_message.set_token('COLUMN','PROCESSING_TYPE');
	fnd_message.set_token('LOOKUP_TYPE','PROCESSING_TYPE');
	fnd_message.raise_error;
	--
  End If;
  --
  If (p_processing_type = 'N' and p_benefit_classification_id is not null) Then
    --
    fnd_message.set_name('PAY','PAY_34135_ELE_BEN_CLASS_VLDTN');
    fnd_message.raise_error;
    --
  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_standard_link_flag >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate the following business rules:
--
--   a) Standard_link_flag cannot be 'Y' when the Processing_type is 'N'
--      or Multiple_entries_allowed_flag is 'Y'.
--
-- Prerequisites:
--   This procedure is called from insert_validate and update_validate.
--
-- In Parameters:
--   p_standard_link_flag
--   p_processing_type
--   p_multiple_entries_allowed_flg
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If the business rule validation fails then an error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_standard_link_flag
  (p_effective_date		  in date
  ,p_standard_link_flag		  in varchar2
  ,p_processing_type  		  in varchar2
  ,p_multiple_entries_allowed_flg in varchar2
  ) is
--
  l_proc        varchar2(72) := g_package||'chk_standard_link';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If hr_api.not_exists_in_hr_lookups
	(p_effective_date
	,'YES_NO'
	,p_standard_link_flag) Then
	--
	fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
	fnd_message.set_token('COLUMN','STANDARD_LINK_FLAG');
	fnd_message.set_token('LOOKUP_TYPE','YES_NO');
	fnd_message.raise_error;
	--
  End If;
  --
  If (p_standard_link_flag = 'Y' and p_processing_type = 'N') Then
    --
    fnd_message.set_name('PAY','PAY_6140_ELEMENT_NO_STANDARD');
    fnd_message.raise_error;
    --
  End If;
  If (p_standard_link_flag = 'Y' and p_multiple_entries_allowed_flg = 'Y') Then
    --
    fnd_message.set_name('PAY','HR_6952_PAY_ELE_NO_STD_MULTI');
    fnd_message.raise_error;
    --
  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_qualifying_factors >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate the following business rules:
--
--   a) Qualifying_age should not be negative and should be between range
--      0 to 99.
--   b) Qualifying_length_of_service should not be negative.
--   c) Qualifying_units must be specified if qualifying_length_of_service is
--      specified.
--
-- Prerequisites:
--   This procedure is called from insert_validate and update_validate.
--
-- In Parameters:
--   p_qualifying_age
--   p_qualifying_length_of_service
--   p_qualifying_units
--	 p_effective_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If the business rule validation fails then an error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_qualifying_factors
  (p_qualifying_age    			in number
  ,p_qualifying_length_of_service	in number
  ,p_qualifying_units             	in varchar2
  ,p_effective_date			in date
  ) is
--
  l_proc        varchar2(72) := g_package||'chk_qual_factors';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If nvl(p_qualifying_age,hr_api.g_number) <> hr_api.g_number Then
    If (sign(p_qualifying_age) = -1) or (p_qualifying_age not between 0 and 99)
    then
      --
      fnd_message.set_name('PAY','PAY_33096_QUALI_AGE_CHECK');
      fnd_message.raise_error;
      --
    End If;
  Elsif nvl(p_qualifying_length_of_service,hr_api.g_number) <> hr_api.g_number
  then
    If (sign(p_qualifying_length_of_service) = -1) Then
      --
      fnd_message.set_name('PAY','PAY_34143_QUALI_LOS_VLDTN');
      fnd_message.raise_error;
      --
    End If;
    --
    If nvl(p_qualifying_units,hr_api.g_varchar2) = hr_api.g_varchar2 Then
      --
      fnd_message.set_name('PAY','PAY_34137_QUALI_FACTORS_VLDTN');
      fnd_message.raise_error;
      --
    Else
      --
      If hr_api.not_exists_in_hr_lookups
      	  (p_effective_date
	  ,'QUALIFYING_UNITS'
	  ,p_qualifying_units) Then
	--
	fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
	fnd_message.set_token('COLUMN','QUALIFYING_UNITS');
	fnd_message.set_token('LOOKUP_TYPE','QUALIFYING_UNITS');
	fnd_message.raise_error;
	--
      End If;
      --
    End If;
  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
End;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_third_party_pay_only_flag >-------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate the following business rules:
--
--   a) Third_party_pay_only_flag cannot be updated when element entries
--      exist.
--
-- Prerequisites:
--   This procedure is called from insert_validate and update_validate.
--
-- In Parameters:
--	 p_effective_date
--   p_element_type_id
--   p_third_party_pay_only_flag
--   p_indirect_only_flag
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If the business rule validation fails then an error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_third_party_pay_only_flag
  (p_effective_date		in date
  ,p_element_type_id		in number   default null
  ,p_third_party_pay_only_flag  in varchar2
  ,p_indirect_only_flag         in varchar2
  ) is
--
  l_proc        varchar2(72) := g_package||'chk_third_party_pay';
  l_exists		varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If hr_api.not_exists_in_hr_lookups
	(p_effective_date
	,'YES_NO'
	,nvl(p_third_party_pay_only_flag,'N')) Then
	--
	fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
	fnd_message.set_token('COLUMN','THIRD_PARTY_PAY_ONLY_FLAG');
	fnd_message.set_token('LOOKUP_TYPE','YES_NO');
	fnd_message.raise_error;
	--
  End If;
  If p_element_type_id is not null and
     (p_third_party_pay_only_flag <>
      nvl(pay_etp_shd_nd.g_old_rec.third_party_pay_only_flag,hr_api.g_varchar2))
     Then
    --
    If pay_element_types_pkg.element_entries_exist
        (p_element_type_id
        ,FALSE) Then
      --
      fnd_message.set_name('PAY','PAY_34139_ELE_3RD_NO_UPD');
      fnd_message.raise_error;
      --
    End If;
  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_iterative_rules >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate the following business rules:
--
--   a) If Iterative_flag is 'N' then Iterative_formula_id and
--      Iterative_priority cannot be set.
--   b) The Formula Type of the Iterative_formula_id must be 'Net to Gross'.
--   c) If Iterative_flag is 'Y' then Iterative_formula_id must be specified.
--   d) If Grossup_flag is 'Y', then Iterative_flag must be 'Y'.
--   e) Process_mode value must be 'P', 'N' or 'S'
--
-- Prerequisites:
--   This procedure is called from insert_validate and update_validate.
--
-- In Parameters:
--	  p_iterative_flag
--    p_iterative_formula_id
--    p_iterative_priority
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If the business rule validation fails then an error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_iterative_rules
  (p_iterative_flag        in varchar2
  ,p_iterative_formula_id  in number
  ,p_iterative_priority    in number
  ,p_grossup_flag	   in varchar2
  ,p_process_mode	   in varchar2
  ,p_effective_date	   in date
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc         varchar2(72) := g_package||'chk_iterative_rules';
  l_formula_type ff_formula_types.formula_type_name%type;

  Cursor c_formula_type
  is
    select formula_type_name
      from ff_formula_types ftp, ff_formulas_f fml
     where fml.formula_id = p_iterative_formula_id
       and p_effective_date between fml.effective_start_date
       and fml.effective_end_date
       and ftp.formula_type_id = fml.formula_type_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If nvl(p_iterative_formula_id,hr_api.g_number) <> hr_api.g_number Then
    If not (dt_api.rows_exist
           (p_base_table_name => 'FF_FORMULAS_F'
           ,p_base_key_column => 'FORMULA_ID'
           ,p_base_key_value  => p_iterative_formula_id
           ,p_from_date       => p_validation_start_date
           ,p_to_date         => p_validation_end_date
           )) Then
    	--
    	fnd_message.set_name('PAY','PAY_33085_INVALID_FK');
    	fnd_message.set_token('COLUMN','FORMULA_ID');
    	fnd_message.set_token('TABLE','FF_FORMULAS_F');
    	fnd_message.raise_error;
    	--
    End If;
  End If;
  --
  If hr_api.not_exists_in_hr_lookups
	(p_effective_date
	,'YES_NO'
	,nvl(p_iterative_flag,'N')) Then
	--
	fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
	fnd_message.set_token('COLUMN','ITERATIVE_FLAG');
	fnd_message.set_token('LOOKUP_TYPE','YES_NO');
	fnd_message.raise_error;
	--
  End If;
  --
  If hr_api.not_exists_in_hr_lookups
	(p_effective_date
	,'YES_NO'
	,nvl(p_grossup_flag,'N')) Then
	--
	fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
	fnd_message.set_token('COLUMN','GROSSUP_FLAG');
	fnd_message.set_token('LOOKUP_TYPE','YES_NO');
	fnd_message.raise_error;
	--
  End If;
  --
  If p_iterative_flag = 'N' and
     (p_iterative_formula_id is not null or
      p_iterative_priority is not null) Then
    --
    fnd_message.set_name('PAY','PAY_34144_ELE_ITR_NO_FORML_PRI');
    fnd_message.raise_error;
    --
  End If;
  If p_iterative_flag = 'Y' and p_iterative_formula_id is null Then
    --
    fnd_message.set_name('PAY','PAY_34146_ELE_ITR_FORML_REQD');
    fnd_message.raise_error;
    --
  End If;
  If p_iterative_formula_id is not null Then
    --
    Open c_formula_type;
    Fetch c_formula_type into l_formula_type;
    Close c_formula_type;
    --
    If upper(l_formula_type) <> 'NET TO GROSS' Then
      --
      fnd_message.set_name('PAY','PAY_34145_ELE_ITR_FTYPE');
      fnd_message.raise_error;
      --
    End If;
    --
  End If;
  If (p_grossup_flag = 'Y' and p_iterative_flag <> 'Y') Then
    --
    fnd_message.set_name('PAY','PAY_34147_ELE_ITR_GROSSUP');
    fnd_message.raise_error;
    --
  End If;
  If p_process_mode not in ('P','N','S') Then
    --
    fnd_message.set_name('PAY','PAY_34148_ELE_PROC_MODE');
    fnd_message.raise_error;
    --
  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_proration_values >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure is used to validate the following attributes against the
--   respective parent table.
--
--   a) retro_summ_ele_id
--   b) proration_group_id
--   c) proration_formula_id
--   d) recalc_event_group_id
--
-- ----------------------------------------------------------------------------
Procedure chk_proration_values
  (p_retro_summ_ele_id 	   in number
  ,p_proration_group_id    in number
  ,p_proration_formula_id  in number
  ,p_recalc_event_group_id in number
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc             varchar2(72) := g_package||'chk_proration_values';
  l_exists	         varchar2(1);
  p_event_group_type pay_event_groups.event_group_type%type;

  Cursor c_chk_event_group_id(p_event_group_id number)
  is
    select '1', event_group_type
      from pay_event_groups
     where event_group_id = p_event_group_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If nvl(p_retro_summ_ele_id,hr_api.g_number) <> hr_api.g_number Then
  	If not (dt_api.rows_exist
  	       (p_base_table_name => 'PAY_ELEMENT_TYPES_F'
  	       ,p_base_key_column => 'ELEMENT_TYPE_ID'
  	       ,p_base_key_value  => p_retro_summ_ele_id
  	       ,p_from_date       => p_validation_start_date
      	       ,p_to_date         => p_validation_end_date
      	       )) Then
    	--
    	fnd_message.set_name('PAY','PAY_33085_INVALID_FK');
    	fnd_message.set_token('COLUMN','RETRO_SUMM_ELE_ID');
    	fnd_message.set_token('TABLE','PAY_ELEMENT_TYPES_F');
    	fnd_message.raise_error;
    	--
  	End If;
  End If;
  --
  If nvl(p_proration_formula_id,hr_api.g_number) <> hr_api.g_number Then
  	If not (dt_api.rows_exist
  	       (p_base_table_name => 'FF_FORMULAS_F'
  	       ,p_base_key_column => 'FORMULA_ID'
  	       ,p_base_key_value  => p_proration_formula_id
     	       ,p_from_date       => p_validation_start_date
      	       ,p_to_date         => p_validation_end_date
      	       )) Then
    	--
    	fnd_message.set_name('PAY','PAY_33085_INVALID_FK');
    	fnd_message.set_token('COLUMN','PRORATION_FORMULA_ID');
    	fnd_message.set_token('TABLE','FF_FORMULAS_F');
    	fnd_message.raise_error;
    	--
    End If;
  End If;
  --
  If nvl(p_proration_group_id,hr_api.g_number) <> hr_api.g_number Then
    --
    Open c_chk_event_group_id(p_proration_group_id);
    Fetch c_chk_event_group_id into l_exists, p_event_group_type;
    If c_chk_event_group_id%notfound Then
      --
      Close c_chk_event_group_id;
      fnd_message.set_name('PAY','PAY_33085_INVALID_FK');
      fnd_message.set_token('COLUMN','PRORATION_GROUP_ID');
      fnd_message.set_token('TABLE','PAY_EVENT_GROUPS');
      fnd_message.raise_error;
      --
    Elsif p_event_group_type <> 'P' Then
      --
      Close c_chk_event_group_id;
      fnd_message.set_name('PAY','PAY_34141_ELE_PRORATION');
      fnd_message.raise_error;
      --
    End If;
    Close c_chk_event_group_id;
    --
  End If;
  --
  If nvl(p_recalc_event_group_id,hr_api.g_number) <> hr_api.g_number Then
    --
    Open c_chk_event_group_id(p_recalc_event_group_id);
    Fetch c_chk_event_group_id into l_exists, p_event_group_type;
    If c_chk_event_group_id%notfound Then
      --
      Close c_chk_event_group_id;
      fnd_message.set_name('PAY','PAY_33085_INVALID_FK');
      fnd_message.set_token('COLUMN','RECALC_EVENT_GROUP_ID');
      fnd_message.set_token('TABLE','PAY_EVENT_GROUPS');
      fnd_message.raise_error;
      --
    Elsif p_event_group_type <> 'R' Then
      --
      Close c_chk_event_group_id;
      fnd_message.set_name('PAY','PAY_34149_ELE_RECALC_EVENT');
      fnd_message.raise_error;
      --
    End If;
    Close c_chk_event_group_id;
    --
  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_time_definition>----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	This procedure is used to check whether the specified time definition
--	is valid or not.
-- In parameters:
--	P_TIME_DEFINITION_ID : ID of the time defintion specified.
-- Post success:
--	Processing continues.
-- Post failure:
--	Raise an error and stops the process.
-- Access Status:
--	Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_time_definition(p_time_definition_id number) is
--
	l_proc  varchar2(72) := g_package||'chk_time_definition';
	l_flag  varchar2(1);

	Cursor  csr_time_definition is
	select  'Y'
	from	pay_time_definitions
	where   time_definition_id = p_time_definition_id;

Begin
--
	hr_utility.set_location('Entering:'||l_proc, 5);
	open csr_time_definition;
	fetch csr_time_definition into l_flag;
	If (csr_time_definition%notfound) then
		close csr_time_definition;
		fnd_message.set_name('PAY','PAY_33085_INVALID_FK');
		fnd_message.set_token('COLUMN','TIME_DEFINTION_ID');
		fnd_message.set_token('TABLE','PAY_TIME_DEFINITIONS');
		fnd_message.raise_error;
	end if;
	close csr_time_definition;
	hr_utility.set_location('Leaving:'||l_proc, 10);
--
End chk_time_definition;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_time_definition_type>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	This procedure is used to check whether the specified time definition
--	type is valid or not.
-- In parameters:
--	P_TIME_DEFINITION_TYPE : time defintion type specified.
-- Post success:
--	Processing continues.
-- Post failure:
--	Raise an error and stops the process.
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_time_definition_type(p_effective_date date
				  ,p_time_definition_type varchar2) is
--
	l_proc  varchar2(72) := g_package||'chk_time_definition_type';
--
Begin
--
	hr_utility.set_location('Entering:'||l_proc, 5);
	/* If hr_api.not_exists_in_hr_lookups
	(p_effective_date
	,'PAY_TIME_DEFINITION_TYPE'
	,p_time_definition_type) Then
	--
		fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
		fnd_message.set_token('COLUMN','TIME_DEFINITION_TYPE');
		fnd_message.set_token('LOOKUP_TYPE','PAY_TIME_DEFINITION_TYPE');
		fnd_message.raise_error;
	--
	End If; */
	hr_utility.set_location('Leaving:'||l_proc, 10);
--
End chk_time_definition_type;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_update_allowed >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate the following business rules:
--
--   a) Indirect_Only_Flag, Additional_Entry_Allowed_Flag, Standard_Link_Flag,
--      Adjustment_Only_Flag, Post_Termination_Rule, Process_In_Run_Flag and
--      Once_Each_Period_Flag can only be updated if:
--
--       i. There are no element links for the element.
--      ii. The change will take effect for the complete lifetime of element
--          type (ie. cannot perform the update if the element has been
--          date-effectively updated).
--   b) Adjustment_Only_Flag can only be updated if:
--
--       - There exists no formula result rules where the element type
--         is the subject of indirect results.
--
--   c) Post_Termination_Rule, Process_In_Run_Flag and Once_Each_Period_Flag
--      can only be updated if:
--
--       - There exists no run results for the element.
--
-- Prerequisites:
--   This procedure is called from update_validate.
--
-- In Parameters:
--   p_element_type_id
--   p_Indirect_Only_Flag
--   p_Additional_Entry_Allowed_Flg
--   p_Standard_Link_Flag
--   p_Adjustment_Only_Flag
--   p_Post_Termination_Rule
--   p_Process_In_Run_Flag
--   p_validation_start_date
--   p_validation_end_date
--
-- Post Success:
--   Processing continues. The OUT parameter p_datetrack_update_mode will be
--   set to 'CORRECTION' if rule a-ii is satisified.
--
-- Post Failure:
--   If the business rule validation fails then an error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_update_allowed
  (p_element_type_id				in     number
  ,p_indirect_only_flag 			in     varchar2
  ,p_additional_entry_allowed_flg		in     varchar2
  ,p_standard_link_flag				in     varchar2
  ,p_adjustment_only_flag			in     varchar2
  ,p_post_termination_rule 			in     varchar2
  ,p_process_in_run_flag			in     varchar2
  ,p_validation_start_date 			in     date
  ,p_validation_end_date   			in     date
  ,p_once_each_period_flag                      in     varchar2
  ) is
--
  l_proc             varchar2(72) := g_package||'chk_update_allowed';
  l_element_links    boolean;
  l_indirect_results boolean;
  l_run_results	     boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
     (p_indirect_only_flag <> pay_etp_shd_nd.g_old_rec.indirect_only_flag)
     or
     (p_additional_entry_allowed_flg <>
      pay_etp_shd_nd.g_old_rec.additional_entry_allowed_flag)
     or
     (p_standard_link_flag <> pay_etp_shd_nd.g_old_rec.standard_link_flag)
     or
     (p_adjustment_only_flag <> pay_etp_shd_nd.g_old_rec.adjustment_only_flag)
     or
     (p_post_termination_rule <> pay_etp_shd_nd.g_old_rec.post_termination_rule)
     or
     (p_process_in_run_flag <> pay_etp_shd_nd.g_old_rec.process_in_run_flag)
     or
     (p_once_each_period_flag <> pay_etp_shd_nd.g_old_rec.once_each_period_flag)
     ) Then
    --
    l_element_links := pay_element_types_pkg.links_exist
    			 (p_element_type_id,
                          p_validation_start_date,
                          p_validation_end_date);
    --
    If l_element_links Then
      --
      fnd_message.set_name('PAY','PAY_6147_ELEMENT_LINK_UPDATE');
      fnd_message.raise_error;
      --
    End If;
    If (p_adjustment_only_flag <> pay_etp_shd_nd.g_old_rec.adjustment_only_flag
       )Then
      --
      l_indirect_results := pay_element_types_pkg.fed_by_indirect_results
      				  (p_element_type_id,
	                           p_validation_start_date,
	                           p_validation_end_date);
      --
      If l_indirect_results Then
        --
        fnd_message.set_name('PAY','PAY_34138_ELE_NO_ADJ_FRR_UPD');
        fnd_message.raise_error;
        --
      End If;
      --
    End If;
    If ((p_post_termination_rule <> pay_etp_shd_nd.g_old_rec.post_termination_rule)
       or
       (p_process_in_run_flag <> pay_etp_shd_nd.g_old_rec.process_in_run_flag)
       or
       (p_once_each_period_flag <> pay_etp_shd_nd.g_old_rec.once_each_period_flag)
       ) Then
      --
      l_run_results:= pay_element_types_pkg.run_results_exist
					    (p_element_type_id,	                                                             p_validation_start_date,	                                                     p_validation_end_date);
      --
      If l_run_results Then
        --
        fnd_message.set_name('PAY','PAY_6909_ELEMENT_NO_UPD_RR');
        fnd_message.raise_error;
        --
      End If;
      --
    End If;
    --
  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_delete_allowed >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate the delete business rules.
--
-- Prerequisites:
--   This procedure is called from delete_validate.
--
-- In Parameters:
--   p_element_type_id
--   p_processing_priority
--   p_validation_start_date
--   p_validation_end_date
--   p_datetrack_delete_mode
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If the business rule validation fails then an error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_delete_allowed
  (p_element_type_id        in number
  ,p_processing_priority    in number
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ,p_datetrack_delete_mode  in varchar2
  ) is
--
  l_proc          varchar2(72) := g_package||'chk_delete_allowed';
  --
  -- Returns TRUE if there are accrual plans for the parameter element type
  --
  Function accrual_plan_exists
    (p_element_type_id number) return boolean is
    --
    l_accrual_exists boolean := FALSE;
    l_dummy_number   number(1);
    --
    cursor csr_accrual
    is
      select null
        from pay_accrual_plans
       where accrual_plan_element_type_id = p_element_type_id;
    --
  begin
    --
    hr_utility.set_location (' ACCRUAL_PLAN_EXISTS',1);
    --
    open csr_accrual;
    fetch csr_accrual into l_dummy_number;
    l_accrual_exists := csr_accrual%found;
    close csr_accrual;
    --
    return l_accrual_exists;
    --
  end;
  --
  -- Returns TRUE if there are benefit contributions which refer to the
  -- specified element
  --
  Function benefit_contributions_exist
    (p_element_type_id       number,
     p_validation_start_date date,
     p_validation_end_date   date
    ) return boolean is
    --
    l_contribution_exists   boolean := FALSE;
    l_dummy_number	    number(1);
    --
    Cursor csr_contribution
    is
      select 1
       from ben_benefit_contributions_f
      where element_type_id = p_element_type_id
        and effective_start_date <= p_validation_end_date
        and effective_end_date   >= p_validation_start_date;
    --
    begin
      --
      hr_utility.set_location(' benefit_contributions_exist',1);
      --
      open csr_contribution;
      fetch csr_contribution into l_dummy_number;
      l_contribution_exists := csr_contribution%found;
      close csr_contribution;
      --
      return l_contribution_exists;
      --
    end;
  --
  -- Returns TRUE if the element has an input value which is used as a pay
  -- basis.
  --
  Function element_used_as_pay_basis
    (p_element_type_id       number)
    return boolean is
  --
  l_pay_basis_element  boolean := FALSE;
  l_dummy_number       number(1);
  --
  cursor csr_pay_basis
  is
    select 1
      from per_pay_bases  BASIS,
           pay_input_values_f  IV
     where iv.input_value_id = basis.input_value_id
       and iv.element_type_id = p_element_type_id;
  --
  begin
    --
    open csr_pay_basis;
    fetch csr_pay_basis into l_dummy_number;
    l_pay_basis_element := csr_pay_basis%found;
    close csr_pay_basis;
    --
    return l_pay_basis_element;
    --
  end;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If p_datetrack_delete_mode = 'DELETE_NEXT_CHANGE' Then
    If pay_element_types_pkg.priority_result_rule_violated
          (p_element_type_id,
	   p_processing_priority,
	   p_validation_start_date,
	   p_validation_end_date) Then
      --
      fnd_message.set_name('PAY','PAY_6149_ELEMENT_PRIORITY_UPD');
      fnd_message.raise_error;
      --
    Elsif pay_element_types_pkg.cobra_benefits_exist
    			     (p_element_type_id,
                              p_validation_start_date,
                              p_validation_end_date) Then
      --
      fnd_message.set_name('PAY','PAY_COBRA_BENS_NO_DEL');
      fnd_message.raise_error;
      --
    End If;
  End If;
  --
  If p_datetrack_delete_mode = 'DELETE' Then
  --
    If pay_element_types_pkg.links_exist
      			    (p_element_type_id,
			     p_validation_start_date,
			     p_validation_end_date) Then
      --
      fnd_message.set_name('PAY','PAY_6155_ELEMENT_NO_DEL_LINK');
      fnd_message.raise_error;
	  --
    Elsif pay_element_types_pkg.run_results_exist
    		 (p_element_type_id,
		  p_validation_start_date,
		  p_validation_end_date) Then
      --
      fnd_message.set_name('PAY','PAY_6242_ELEMENTS_NO_DEL_RR');
      fnd_message.raise_error;
      --
    Elsif pay_element_types_pkg.stop_entry_rules_exist(p_element_type_id) Then
      --
      fnd_message.set_name('PAY','PAY_6157_ELEMENT_NO_DEL_FRR');
      fnd_message.raise_error;
      --
    End If;
  --
  End If;
  --
  If p_datetrack_delete_mode = 'ZAP' Then
    --
    If pay_element_types_pkg.element_is_in_an_element_set
         (p_element_type_id) Then
      --
      fnd_message.set_name('PAY','PAY_6713_ELEMENT_NO_DEL_RULE');
      fnd_message.raise_error;
      --
    Elsif pay_element_types_pkg.links_exist
                      (p_element_type_id,
		       p_validation_start_date,
		       p_validation_end_date) Then
      --
      fnd_message.set_name('PAY','PAY_6155_ELEMENT_NO_DEL_LINK');
      fnd_message.raise_error;
      --
    Elsif pay_element_types_pkg.stop_entry_rules_exist(p_element_type_id) Then
      --
      fnd_message.set_name('PAY','PAY_6157_ELEMENT_NO_DEL_FRR');
      fnd_message.raise_error;
      --
    Elsif accrual_plan_exists(p_element_type_id) Then
      --
      fnd_message.set_name('PAY','PAY_34142_ELE_NO_DEL_ACCRUAL');
      fnd_message.raise_error;
      --
    Elsif pay_element_types_pkg.run_results_exist
    		 (p_element_type_id,
	     	  p_validation_start_date,
	     	  p_validation_end_date) Then
      --
      fnd_message.set_name('PAY','PAY_6242_ELEMENTS_NO_DEL_RR');
      fnd_message.raise_error;
      --
    Elsif benefit_contributions_exist
		    (p_element_type_id,
		     p_validation_start_date,
		     p_validation_end_date) Then
      --
      fnd_message.set_name('PAY','PAY_34140_ELE_BEN_CONT_NO_DEL');
      fnd_message.raise_error;
      --
    Elsif pay_element_types_pkg.cobra_benefits_exist
    			     (p_element_type_id,
                              p_validation_start_date,
                              p_validation_end_date) Then
      --
      fnd_message.set_name('PAY','PAY_COBRA_BENS_NO_DEL');
      fnd_message.raise_error;
      --
    Elsif element_used_as_pay_basis(p_element_type_id) Then
      --
      fnd_message.set_name('PAY','PAY_6965_INPVAL_NO_DEL_SB');
      fnd_message.raise_error;
      --
    End If;
  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   		 in  pay_etp_shd_nd.g_rec_type
  ,p_effective_date        		 in  date
  ,p_datetrack_mode        		 in  varchar2
  ,p_validation_start_date 		 in  date
  ,p_validation_end_date   		 in  date
  ,p_processing_priority_warning         out nocopy boolean
  ) is
--
  l_proc 			varchar2(72) := g_package||'insert_validate';
  l_processing_priority_warning boolean;
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
       ,p_associated_column1 => pay_etp_shd_nd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
     --
     -- after validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  -- Validate Dependent Attributes
  --
  if (p_rec.business_group_id is not null) then
  chk_business_group_id
    (p_rec.business_group_id
    ,p_effective_date);
  end if;
  --
  If (p_rec.legislation_code is not null) then
  chk_legislation_code
    (p_rec.legislation_code);
  end if;
  --
  chk_formula_id
    (p_effective_date
    ,p_validation_start_date
    ,p_validation_end_date
    ,p_rec.formula_id
    ,p_rec.process_in_run_flag
    ,p_rec.indirect_only_flag
    ,p_rec.adjustment_only_flag);
  --
  chk_currency_codes
    (p_effective_date
    ,p_rec.classification_id
    ,p_rec.business_group_id
    ,p_rec.input_currency_code
    ,p_rec.output_currency_code);
  --
  chk_classification_id
    (p_rec.classification_id
    ,p_rec.adjustment_only_flag
    ,p_rec.process_in_run_flag
    ,p_rec.processing_type
    ,p_rec.indirect_only_flag);
  --
  chk_addl_entry_allowed
    (p_effective_date
    ,p_rec.additional_entry_allowed_flag
    ,p_rec.processing_type);
  --
  chk_adjustment_only_flag
    (p_effective_date
    ,p_rec.adjustment_only_flag
    ,p_rec.closed_for_entry_flag
    ,p_rec.processing_type
    ,p_rec.indirect_only_flag);
  --
  chk_element_name
    (p_rec.element_name
    ,null
    ,p_rec.business_group_id
    ,p_rec.legislation_code
    );
  --
  chk_multiple_entries_allowed
    (p_effective_date 		    => p_effective_date
    ,p_multiple_entries_allowed_flg => p_rec.multiple_entries_allowed_flag
    ,p_benefit_classification_id    => p_rec.benefit_classification_id
    ,p_processing_type 		    => p_rec.processing_type);
  --
  chk_process_in_run_flag
    (p_effective_date
    ,p_rec.process_in_run_flag
    ,p_rec.adjustment_only_flag
    ,p_rec.indirect_only_flag
    ,p_rec.multiply_value_flag
    ,p_rec.post_termination_rule
    ,p_rec.once_each_period_flag);
  --
  chk_processing_priority
    (p_processing_priority 	   => p_rec.processing_priority
    ,p_classification_id   	   => p_rec.classification_id
    ,p_processing_priority_warning => l_processing_priority_warning);
  --
  p_processing_priority_warning := l_processing_priority_warning;
  --
  chk_processing_type
    (p_effective_date
    ,p_rec.processing_type
    ,p_rec.benefit_classification_id);
  --
  chk_standard_link_flag
    (p_effective_date
    ,p_rec.standard_link_flag
    ,p_rec.processing_type
    ,p_rec.multiple_entries_allowed_flag);
  --
  chk_qualifying_factors
    (p_rec.qualifying_age
    ,p_rec.qualifying_length_of_service
    ,p_rec.qualifying_units
    ,p_effective_date);
  --
  chk_third_party_pay_only_flag
    (p_effective_date		 => p_effective_date
    ,p_third_party_pay_only_flag => p_rec.third_party_pay_only_flag
    ,p_indirect_only_flag        => p_rec.indirect_only_flag);
  --
  chk_iterative_rules
    (p_rec.iterative_flag
    ,p_rec.iterative_formula_id
    ,p_rec.iterative_priority
    ,p_rec.grossup_flag
    ,p_rec.process_mode
    ,p_effective_date
    ,p_validation_start_date
    ,p_validation_end_date);
  --
  chk_proration_values
    (p_rec.retro_summ_ele_id
    ,p_rec.proration_group_id
    ,p_rec.proration_formula_id
    ,p_rec.recalc_event_group_id
    ,p_validation_start_date
    ,p_validation_end_date);
  --
  If (p_rec.time_definition_id is not null) then
	chk_time_definition(p_rec.time_definition_id);
  end if;
  --
  If (p_rec.time_definition_type is not null) then
	chk_time_definition_type(p_effective_date
				,p_rec.time_definition_type);
  end if;
  --
  pay_etp_bus_nd.chk_ddf(p_rec);
  --
  pay_etp_bus_nd.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                         in     pay_etp_shd_nd.g_rec_type
  ,p_effective_date              in     date
  ,p_datetrack_mode              in     varchar2
  ,p_validation_start_date       in     date
  ,p_validation_end_date         in     date
  ,p_processing_priority_warning out nocopy boolean
  ) is
--
  l_proc           		varchar2(72) := g_package||'update_validate';
  l_processing_priority_warning boolean;
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
       ,p_associated_column1 => pay_etp_shd_nd.g_tab_nam
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
  chk_formula_id
    (p_effective_date
    ,p_validation_start_date
    ,p_validation_end_date
    ,p_rec.formula_id
    ,p_rec.process_in_run_flag
    ,p_rec.indirect_only_flag
    ,p_rec.adjustment_only_flag);
  --
  chk_classification_id
    (p_rec.classification_id
    ,p_rec.adjustment_only_flag
    ,p_rec.process_in_run_flag
    ,p_rec.processing_type
    ,p_rec.indirect_only_flag);
  --
  chk_addl_entry_allowed
    (p_effective_date
    ,p_rec.additional_entry_allowed_flag
    ,p_rec.processing_type);
  --
  chk_adjustment_only_flag
    (p_effective_date
    ,p_rec.adjustment_only_flag
    ,p_rec.closed_for_entry_flag
    ,p_rec.processing_type
    ,p_rec.indirect_only_flag);
  --
  chk_element_name
    (p_rec.element_name
    ,p_rec.element_type_id
    ,p_rec.business_group_id
    ,p_rec.legislation_code
    );
  --
  chk_multiple_entries_allowed
    (p_effective_date
    ,p_rec.element_type_id
    ,p_validation_start_date
    ,p_validation_end_date
    ,p_rec.multiple_entries_allowed_flag
    ,p_rec.benefit_classification_id
    ,p_rec.processing_type);
  --
  chk_process_in_run_flag
    (p_effective_date
    ,p_rec.process_in_run_flag
    ,p_rec.adjustment_only_flag
    ,p_rec.indirect_only_flag
    ,p_rec.multiply_value_flag
    ,p_rec.post_termination_rule
    ,p_rec.once_each_period_flag);
  --
  chk_processing_priority
    (p_rec.element_type_id
    ,p_validation_start_date
    ,p_validation_end_date
    ,p_rec.processing_priority
    ,p_rec.classification_id
    ,l_processing_priority_warning);
  --
  p_processing_priority_warning := l_processing_priority_warning;
  --
  chk_processing_type
    (p_effective_date
    ,p_rec.processing_type
    ,p_rec.benefit_classification_id);
  --
  chk_standard_link_flag
    (p_effective_date
    ,p_rec.standard_link_flag
    ,p_rec.processing_type
    ,p_rec.multiple_entries_allowed_flag);
  --
  chk_qualifying_factors
    (p_rec.qualifying_age
    ,p_rec.qualifying_length_of_service
    ,p_rec.qualifying_units
    ,p_effective_date);
  --
  chk_third_party_pay_only_flag
    (p_effective_date
    ,p_rec.element_type_id
    ,p_rec.third_party_pay_only_flag
    ,p_rec.indirect_only_flag);
  --
  chk_iterative_rules
    (p_rec.iterative_flag
    ,p_rec.iterative_formula_id
    ,p_rec.iterative_priority
    ,p_rec.grossup_flag
    ,p_rec.process_mode
    ,p_effective_date
    ,p_validation_start_date
    ,p_validation_end_date);
  --
  chk_proration_values
    (p_rec.retro_summ_ele_id
    ,p_rec.proration_group_id
    ,p_rec.proration_formula_id
    ,p_rec.recalc_event_group_id
    ,p_validation_start_date
    ,p_validation_end_date);
  --
  If (p_rec.time_definition_id is not null) then
	chk_time_definition(p_rec.time_definition_id);
  end if;
  --
  If (p_rec.time_definition_type is not null) then
	chk_time_definition_type(p_effective_date
				,p_rec.time_definition_type);
  end if;
  --
  chk_update_allowed
    (p_rec.element_type_id
    ,p_rec.indirect_only_flag
    ,p_rec.additional_entry_allowed_flag
    ,p_rec.standard_link_flag
    ,p_rec.adjustment_only_flag
    ,p_rec.post_termination_rule
    ,p_rec.process_in_run_flag
    ,p_validation_start_date
    ,p_validation_end_date
    ,p_rec.once_each_period_flag
    );
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
  pay_etp_bus_nd.chk_ddf(p_rec);
  --
  pay_etp_bus_nd.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in pay_etp_shd_nd.g_rec_type
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
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code
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
  chk_delete_allowed
    (p_rec.element_type_id
    ,p_rec.processing_priority
    ,p_validation_start_date
    ,p_validation_end_date
    ,p_datetrack_mode);
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_element_type_id                  => p_rec.element_type_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_etp_bus_nd;

/
