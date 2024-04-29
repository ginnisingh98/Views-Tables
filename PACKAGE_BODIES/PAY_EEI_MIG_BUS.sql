--------------------------------------------------------
--  DDL for Package Body PAY_EEI_MIG_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_EEI_MIG_BUS" as
/* $Header: pyeeimhi.pkb 120.0 2005/12/16 14:58:55 ndorai noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_eei_mig_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_element_type_extra_info_id  number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_element_type_extra_info_id           in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_element_type_extra_info eei
         , pay_element_types_f pet
     where eei.element_type_extra_info_id = p_element_type_extra_info_id
     and pbg.business_group_id = pet.business_group_id
     and pet.element_type_id = eei.element_type_id;

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
    ,p_argument           => 'element_type_extra_info_id'
    ,p_argument_value     => p_element_type_extra_info_id
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
     fnd_message.raise_error;
     --
  end if;
  close csr_sec_grp;
  --
  -- Set the security_group_id in CLIENT_INFO
  --
  hr_api.set_security_group_id
    (p_security_group_id => l_security_group_id
    );
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
  (p_element_type_extra_info_id           in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , pay_element_type_extra_info eei
         , pay_element_types_f pet
     where eei.element_type_extra_info_id = p_element_type_extra_info_id
     and pbg.business_group_id = pet.business_group_id
     and pet.element_type_id = eei.element_type_id;
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
    ,p_argument           => 'element_type_extra_info_id'
    ,p_argument_value     => p_element_type_extra_info_id
    );
  --
  if ( nvl(pay_eei_mig_bus.g_element_type_extra_info_id, hr_api.g_number)
       = p_element_type_extra_info_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_eei_mig_bus.g_legislation_code;
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
    pay_eei_mig_bus.g_element_type_extra_info_id := p_element_type_extra_info_id;
    pay_eei_mig_bus.g_legislation_code           := l_legislation_code;
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
  (p_rec in pay_eei_mig_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.element_type_extra_info_id is not null)  and (
    nvl(pay_eei_mig_shd.g_old_rec.information_type, hr_api.g_varchar2) <>
    nvl(p_rec.information_type, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information_category, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information1, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information1, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information2, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information2, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information3, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information3, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information4, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information4, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information5, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information5, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information6, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information6, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information7, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information7, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information8, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information8, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information9, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information9, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information10, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information10, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information11, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information11, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information12, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information12, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information13, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information13, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information14, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information14, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information15, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information15, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information16, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information16, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information17, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information17, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information18, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information18, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information19, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information19, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information20, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information20, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information21, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information21, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information22, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information22, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information23, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information23, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information24, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information24, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information25, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information25, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information26, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information26, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information27, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information27, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information28, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information28, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information29, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information29, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_information30, hr_api.g_varchar2) <>
    nvl(p_rec.eei_information30, hr_api.g_varchar2) ))
    or (p_rec.element_type_extra_info_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --

    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PAY'
      ,p_descflex_name                   => 'Extra Element Info DDF'
      ,p_attribute_category              => p_rec.eei_information_category
      ,p_attribute1_name                 => 'EEI_INFORMATION1'
      ,p_attribute1_value                => p_rec.eei_information1
      ,p_attribute2_name                 => 'EEI_INFORMATION2'
      ,p_attribute2_value                => p_rec.eei_information2
      ,p_attribute3_name                 => 'EEI_INFORMATION3'
      ,p_attribute3_value                => p_rec.eei_information3
      ,p_attribute4_name                 => 'EEI_INFORMATION4'
      ,p_attribute4_value                => p_rec.eei_information4
      ,p_attribute5_name                 => 'EEI_INFORMATION5'
      ,p_attribute5_value                => p_rec.eei_information5
      ,p_attribute6_name                 => 'EEI_INFORMATION6'
      ,p_attribute6_value                => p_rec.eei_information6
      ,p_attribute7_name                 => 'EEI_INFORMATION7'
      ,p_attribute7_value                => p_rec.eei_information7
      ,p_attribute8_name                 => 'EEI_INFORMATION8'
      ,p_attribute8_value                => p_rec.eei_information8
      ,p_attribute9_name                 => 'EEI_INFORMATION9'
      ,p_attribute9_value                => p_rec.eei_information9
      ,p_attribute10_name                => 'EEI_INFORMATION10'
      ,p_attribute10_value               => p_rec.eei_information10
      ,p_attribute11_name                => 'EEI_INFORMATION11'
      ,p_attribute11_value               => p_rec.eei_information11
      ,p_attribute12_name                => 'EEI_INFORMATION12'
      ,p_attribute12_value               => p_rec.eei_information12
      ,p_attribute13_name                => 'EEI_INFORMATION13'
      ,p_attribute13_value               => p_rec.eei_information13
      ,p_attribute14_name                => 'EEI_INFORMATION14'
      ,p_attribute14_value               => p_rec.eei_information14
      ,p_attribute15_name                => 'EEI_INFORMATION15'
      ,p_attribute15_value               => p_rec.eei_information15
      ,p_attribute16_name                => 'EEI_INFORMATION16'
      ,p_attribute16_value               => p_rec.eei_information16
      ,p_attribute17_name                => 'EEI_INFORMATION17'
      ,p_attribute17_value               => p_rec.eei_information17
      ,p_attribute18_name                => 'EEI_INFORMATION18'
      ,p_attribute18_value               => p_rec.eei_information18
      ,p_attribute19_name                => 'EEI_INFORMATION19'
      ,p_attribute19_value               => p_rec.eei_information19
      ,p_attribute20_name                => 'EEI_INFORMATION20'
      ,p_attribute20_value               => p_rec.eei_information20
      ,p_attribute21_name                => 'EEI_INFORMATION21'
      ,p_attribute21_value               => p_rec.eei_information21
      ,p_attribute22_name                => 'EEI_INFORMATION22'
      ,p_attribute22_value               => p_rec.eei_information22
      ,p_attribute23_name                => 'EEI_INFORMATION23'
      ,p_attribute23_value               => p_rec.eei_information23
      ,p_attribute24_name                => 'EEI_INFORMATION24'
      ,p_attribute24_value               => p_rec.eei_information24
      ,p_attribute25_name                => 'EEI_INFORMATION25'
      ,p_attribute25_value               => p_rec.eei_information25
      ,p_attribute26_name                => 'EEI_INFORMATION26'
      ,p_attribute26_value               => p_rec.eei_information26
      ,p_attribute27_name                => 'EEI_INFORMATION27'
      ,p_attribute27_value               => p_rec.eei_information27
      ,p_attribute28_name                => 'EEI_INFORMATION28'
      ,p_attribute28_value               => p_rec.eei_information28
      ,p_attribute29_name                => 'EEI_INFORMATION29'
      ,p_attribute29_value               => p_rec.eei_information29
      ,p_attribute30_name                => 'EEI_INFORMATION30'
      ,p_attribute30_value               => p_rec.eei_information30
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
  (p_rec in pay_eei_mig_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.element_type_extra_info_id is not null)  and (
    nvl(pay_eei_mig_shd.g_old_rec.eei_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.eei_attribute_category, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.eei_attribute1, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.eei_attribute2, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.eei_attribute3, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.eei_attribute4, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.eei_attribute5, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.eei_attribute6, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.eei_attribute7, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.eei_attribute8, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.eei_attribute9, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.eei_attribute10, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.eei_attribute11, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.eei_attribute12, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.eei_attribute13, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.eei_attribute14, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.eei_attribute15, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.eei_attribute16, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.eei_attribute17, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.eei_attribute18, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.eei_attribute19, hr_api.g_varchar2)  or
    nvl(pay_eei_mig_shd.g_old_rec.eei_attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.eei_attribute20, hr_api.g_varchar2) ))
    or (p_rec.element_type_extra_info_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PAY'
      ,p_descflex_name                   => 'Extra Element Info Details DF'
      ,p_attribute_category              => p_rec.eei_attribute_category
      ,p_attribute1_name                 => 'EEI_ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.eei_attribute1
      ,p_attribute2_name                 => 'EEI_ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.eei_attribute2
      ,p_attribute3_name                 => 'EEI_ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.eei_attribute3
      ,p_attribute4_name                 => 'EEI_ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.eei_attribute4
      ,p_attribute5_name                 => 'EEI_ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.eei_attribute5
      ,p_attribute6_name                 => 'EEI_ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.eei_attribute6
      ,p_attribute7_name                 => 'EEI_ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.eei_attribute7
      ,p_attribute8_name                 => 'EEI_ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.eei_attribute8
      ,p_attribute9_name                 => 'EEI_ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.eei_attribute9
      ,p_attribute10_name                => 'EEI_ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.eei_attribute10
      ,p_attribute11_name                => 'EEI_ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.eei_attribute11
      ,p_attribute12_name                => 'EEI_ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.eei_attribute12
      ,p_attribute13_name                => 'EEI_ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.eei_attribute13
      ,p_attribute14_name                => 'EEI_ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.eei_attribute14
      ,p_attribute15_name                => 'EEI_ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.eei_attribute15
      ,p_attribute16_name                => 'EEI_ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.eei_attribute16
      ,p_attribute17_name                => 'EEI_ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.eei_attribute17
      ,p_attribute18_name                => 'EEI_ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.eei_attribute18
      ,p_attribute19_name                => 'EEI_ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.eei_attribute19
      ,p_attribute20_name                => 'EEI_ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.eei_attribute20
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
  (p_rec in pay_eei_mig_shd.g_rec_type
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
  IF NOT pay_eei_mig_shd.api_updating
      (p_element_type_extra_info_id           => p_rec.element_type_extra_info_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  --
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_qualifier >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_qualifier
  (p_pay_source_value  in varchar2,
   p_qualifier         in varchar2,
   p_element_type_id   in number
  ) is
--
  l_proc   varchar2(72) := g_package||'chk_qualifier';
  l_exists varchar2(10);
  l_business_group_id pay_rates.business_group_id%type ;

  cursor c_input_value is
  select 'Y'
  from pay_input_values_f paf
  where element_type_id = p_element_type_id
  and   upper(name) = upper(p_qualifier)
  and   ((   paf.business_group_id is not null
         and paf.business_group_id = nvl(l_business_group_id,paf.business_group_id))
         or (   paf.legislation_code is not null
            and paf.business_group_id is null)
         or ( paf.legislation_code is null and paf.business_group_id is null )) ;

  cursor c_global is
  select 'Y'
  from ff_globals_f fg
  where upper(fg.global_name) = upper(p_qualifier)
  and   (( fg.business_group_id is not null
         and fg.business_group_id = nvl(l_business_group_id,fg.business_group_id))
         or (   fg.legislation_code is not null
            and fg.business_group_id is null)
         or ( fg.legislation_code is null and fg.business_group_id is null )) ;


  cursor c_grade_rate is
  select 'Y'
  from pay_rates pr
  where upper(name) = upper(p_qualifier)
  and rate_type = 'G'
  and pr.business_group_id = nvl(l_business_group_id,pr.business_group_id) ;

  cursor c_grade_rate_like is
  select 'Y'
  from pay_rates pr
  where upper(name) like upper(p_qualifier)
  and rate_type = 'G'
  and pr.business_group_id = nvl(l_business_group_id,pr.business_group_id);


  cursor c_spinal_point is
  select 'Y'
  from pay_rates pr
  where upper(name) = upper(p_qualifier)
  and rate_type = 'SP'
  and pr.business_group_id = nvl(l_business_group_id,pr.business_group_id) ;

  cursor c_spinal_point_like is
  select 'Y'
  from pay_rates pr
  where upper(name) like upper(p_qualifier)
  and rate_type = 'SP'
  and pr.business_group_id = nvl(l_business_group_id,pr.business_group_id);

  cursor c_get_bus_grp_id is
  select business_group_id
  from   pay_element_types_f pet
  where  pet.element_type_id = p_element_type_id ;

--  Add Cursors to check the entered Rate type and element Name.

  CURSOR c_element_name IS
  SELECT 'Y'
  FROM   PAY_ELEMENT_TYPES_F pet
  WHERE  UPPER(pet.element_name) = UPPER(p_qualifier)
    AND  (( pet.business_group_id is not null
         and pet.business_group_id = nvl(l_business_group_id,
	                              pet.business_group_id))
         or (   pet.legislation_code is not null
            and pet.business_group_id is null)
         or ( pet.legislation_code is null
	      and pet.business_group_id is null )) ;

  CURSOR c_rate_type IS
  SELECT 'Y'
  FROM    hr_lookups hrl
  WHERE   hrl.lookup_type    = 'PQP_RATE_TYPE'
    and   UPPER(hrl.meaning) = UPPER(p_qualifier)
    and   hrl.enabled_flag   = 'Y' ;
--
Begin
--
  hr_utility.set_location('Entering:'||l_proc, 5);

--
  open c_get_bus_grp_id ;
  fetch c_get_bus_grp_id into l_business_group_id;

  if  l_business_group_id is null then
    --
      l_business_group_id := fnd_global.per_business_group_id ;
    --
  end if;

  close c_get_bus_grp_id ;

--

  if p_pay_source_value = 'IV' then
  --
    open c_input_value;
    fetch c_input_value into l_exists;
    close c_input_value;

    if l_exists is null then
    --
      hr_utility.set_message(8303, 'PQP_230515_INVALID_QUALIFIER');
      hr_utility.raise_error;
    --
    end if;
  --
  elsif p_pay_source_value = 'GV' then
  --
    open c_global;
    fetch c_global into l_exists;
    close c_global;

    if l_exists is null then
    --
      hr_utility.set_message(8303, 'PQP_230515_INVALID_QUALIFIER');
      hr_utility.raise_error;
    --
    end if;
  --
  elsif p_pay_source_value = 'GR' then
  --
    open c_grade_rate;
    fetch c_grade_rate into l_exists;
    --
      if c_grade_rate%rowcount = 0 then
      --
        open c_grade_rate_like ;
        fetch c_grade_rate_like into l_exists ;
        close c_grade_rate_like ;
      --
      end if;
    --
    close c_grade_rate;

    if l_exists is null then
    --
      hr_utility.set_message(8303, 'PQP_230515_INVALID_QUALIFIER');
      hr_utility.raise_error;
    --
    end if;
  --
  elsif p_pay_source_value = 'SP' then
  --
    open c_spinal_point;
    fetch c_spinal_point into l_exists;
    --
      if c_spinal_point%rowcount = 0 then
      --
        open c_spinal_point_like ;
        fetch c_spinal_point_like into l_exists ;
        close c_spinal_point_like ;
      --
     end if;
    --
    close c_spinal_point;

    if l_exists is null then
    --
      hr_utility.set_message(8303, 'PQP_230515_INVALID_QUALIFIER');
      hr_utility.raise_error;
    --
    end if;
  --
  elsif p_pay_source_value = 'RT' then
  --
    open  c_rate_type ;
    fetch c_rate_type into l_exists ;
    close c_rate_type ;

    if l_exists is null then
    --
      hr_utility.set_message(8303, 'PQP_230515_INVALID_QUALIFIER');
      hr_utility.raise_error;
    --
    end if;
  --
    elsif p_pay_source_value = 'EN' then
  --
    open  c_element_name ;
    fetch c_element_name into l_exists ;
    close c_element_name ;

    if l_exists is null then
    --
      hr_utility.set_message(8303, 'PQP_230515_INVALID_QUALIFIER');
      hr_utility.raise_error;
    --
    end if;
    --
  end if;

  hr_utility.set_location('Entering:'||l_proc, 10);
--
end chk_qualifier;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_input_value >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_input_value
  ( p_input_Value       in varchar2
   ,p_element_type_id   in number
  ) is
  l_proc   varchar2(72) := g_package||'chk_input_value';
  l_exists varchar2(1) ;
  CURSOR c_input_value IS
  SELECT 'Y'
    FROM PAY_INPUT_VALUES_F
   WHERE element_type_id = p_element_type_id
     AND UPPER(name)     = UPPER(p_input_value) ;
begin

  open  c_input_value ;
  fetch c_input_value into l_exists ;
  close c_input_value ;

  if l_exists is null then
  --
    hr_utility.set_message(8303, 'PQP_230021_INVALID_INPUT_VALUE');
    hr_utility.raise_error;
  --
  end if;

end chk_input_value ;
-- ----------------------------------------------------------------------------
-- |------------------------< chk_mandatory_params >--------------------------|
-- ----------------------------------------------------------------------------
-- p_eei_information2 - Pay Source Value
-- p_eei_information7 - % or Factor
-- p_eei_information8 - % or Factor Value
-- p_eei_information9 - % or Factor Input Value
-- p_eei_information10- Linked to Assignment

Procedure chk_mandatory_params
   ( p_eei_information2  IN VARCHAR2
    ,p_eei_information7  IN VARCHAR2
    ,p_eei_information8  IN NUMBER
    ,p_eei_information9  IN VARCHAR2
    ,p_eei_information10 IN VARCHAR2
    ,p_element_type_id   IN NUMBER
   ) is
  l_proc   varchar2(72) := g_package||'chk_input_value';
begin

  hr_utility.set_location('Entering:'||l_proc,10);

    if p_eei_information2 not in ('RT','EN') then

      -- % or Factor Value OR % or Factor Input Value
      -- should be entered only when Pay Source Value
      -- is Element Name or Rate Type

      if p_eei_information8 is not null or
         p_eei_information9 is not null then
         hr_utility.set_message(8303, 'PQP_230017_CALC_TYPE');
         hr_utility.raise_error;
      end if;

    else

     -- If Pay Source Value is in Element Name or Rate Type

      -- % or Factor Type is Mandatory
       if p_eei_information7 is null then
         hr_utility.set_message(8303, 'PQP_230018_CALC_TYPE_MAND');
         hr_utility.raise_error;
       end if;

       -- When the Pay Source Value is either Rate Type or Element Name
       -- then either Calculation Value or Input Value Name should be entered.
       -- ( please note that only one should be entered )
       if p_eei_information8 is null and
          p_eei_information9 is null then
         hr_utility.set_message(8303, 'PQP_230019_CALC_VAL_OR_INPUT');
         hr_utility.raise_error;
       end if;
       if p_eei_information8 is not null and
          p_eei_information9 is not null then
         hr_utility.set_message(8303, 'PQP_230019_CALC_VAL_OR_INPUT');
         hr_utility.raise_error;
       end if;
    end if;

    -- Validate that Input Value Name entered is correct
    if p_eei_information9 is not null then
      pay_eei_mig_bus.chk_input_value(p_input_Value     => p_eei_information9
                                 ,p_element_type_id => p_element_type_id);
    end if;

    -- If Pay Source Value is other than Input Value then
    -- Link to Assignment is Mandatory.
   if p_eei_information2 <> 'IV' then
     if p_eei_information10 is null then
         hr_utility.set_message(8303, 'PQP_230020_ASSIGN_MAND');
         hr_utility.raise_error;
     end if;
  end if;
  hr_utility.set_location('Leaving:'||l_proc,20);

end chk_mandatory_params;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_duplicate_rate_type >--------------------|
-- ----------------------------------------------------------------------------
Procedure chk_duplicate_rate_type
  (p_element_type_extra_info_id  in number,
   p_element_type_id             in number,
   p_rate_type                   in varchar2
  ) is
--
  l_proc   varchar2(72) := g_package||'chk_duplicate_rate_type';
  l_result number;

cursor c_duplicate is
select 1
from pay_element_type_extra_info
where element_type_id = p_element_type_id
and element_type_extra_info_id <> nvl(p_element_type_extra_info_id, -1)
and information_type = 'PQP_UK_RATE_TYPE'
and eei_information1 = p_rate_type;

begin
--
  hr_utility.set_location('Entering:'||l_proc, 5);

  open c_duplicate;
  fetch c_duplicate into l_result;
  close c_duplicate;

  if l_result = 1 then
  --
    hr_utility.set_message(8303, 'PQP_230516_DUPLICATE_RATE_TYPE');
    hr_utility.raise_error;
  --
  end if;

  hr_utility.set_location('Leaving:'||l_proc, 10);
--
end chk_duplicate_rate_type;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_duplicate_element_code >--------------------|
-- ----------------------------------------------------------------------------
Procedure chk_duplicate_element_code
  (p_element_type_id             in number
  ,p_element_code                in varchar2
  ,p_information_type            in varchar2
  ) is
--
  l_proc   varchar2(72) := g_package||'chk_duplicate_element_code';
  l_result number;

cursor c_duplicate is
select 1
from pay_element_type_extra_info
where element_type_id <> p_element_type_id
  and information_type = p_information_type
  and upper(eei_information2) = upper(p_element_code);

cursor c_element_code_exists
        (
        p_info_type   VARCHAR2
        )
IS
    select 1
    from pay_element_type_extra_info
    where element_type_id = p_element_type_id
      and information_type = p_info_type;
begin
--
  hr_utility.set_location('Entering:'||l_proc, 5);

  open c_duplicate;
  fetch c_duplicate into l_result;
  close c_duplicate;

  if l_result = 1 then
  --
    if p_information_type = 'PQP_GB_PENSERV_ALLOWANCE_INFO' then
        hr_utility.set_message(8303, 'PQP_230501_DUP_ALLOWANCE_CODE');
    elsif p_information_type = 'PQP_GB_PENSERV_BONUS_INFO' then
        hr_utility.set_message(8303, 'PQP_230502_DUP_BONUS_CODE');
    end if;

    hr_utility.raise_error;
  --
  end if;

  -- check if other information type exist.
  if p_information_type = 'PQP_GB_PENSERV_ALLOWANCE_INFO' then
      -- check if the element has Bonus info
      OPEN c_element_code_exists
            (
            p_info_type   =>  'PQP_GB_PENSERV_BONUS_INFO'
            );
      FETCH c_element_code_exists INTO l_result;
      CLOSE c_element_code_exists;

      IF l_result = 1 THEN
        hr_utility.set_message(8303, 'PQP_230227_ELEMENT_CODE_EXIST');
        hr_utility.set_message_token('TOKEN1','Bonus');
        hr_utility.set_message_token('TOKEN2','Allowance');
        hr_utility.raise_error;
      END IF;

  elsif p_information_type = 'PQP_GB_PENSERV_BONUS_INFO' then
      -- check if the element has Bonus info
      OPEN c_element_code_exists
            (
            p_info_type   =>  'PQP_GB_PENSERV_ALLOWANCE_INFO'
            );
      FETCH c_element_code_exists INTO l_result;
      CLOSE c_element_code_exists;

      IF l_result = 1 THEN
        hr_utility.set_message(8303, 'PQP_230227_ELEMENT_CODE_EXIST');
        hr_utility.set_message_token('TOKEN1','Allowance');
        hr_utility.set_message_token('TOKEN2','Bonus');
        hr_utility.raise_error;
      END IF;

  end if;

  hr_utility.set_location('Leaving:'||l_proc, 10);
--
end chk_duplicate_element_code;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in pay_eei_mig_shd.g_rec_type
  ) is
--
  cursor row_type(p_element_type_id number)
  is
  select business_group_id
  from   pay_element_types_f
  where  element_type_id = p_element_type_id
  and    business_group_id is not null
  and    rownum = 1;
  --
  l_bg    pay_element_types_f.business_group_id%type;
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  -- Bug 3041843
  --
  open row_type(p_rec.element_type_id);
  fetch row_type into l_bg;
  if row_type%found then
  --
    close row_type;
    pay_etp_bus.set_security_group_id
               (p_element_type_id => p_rec.element_type_id);
  else
    close row_type;
    --
    -- if no row is found them must be seeded row, so hard code the
    -- security group. This is not a satisfactory solution.
    --
    hr_api.set_security_group_id(p_security_group_id => 0);
    --
  end if;
  --
  if (pay_element_eit_swi.g_migration) then
     pay_eei_mig_bus.chk_ddf(p_rec);
  end if;

  --
  pay_eei_mig_bus.chk_df(p_rec);
  --

  if (p_rec.information_type = 'PQP_UK_ELEMENT_ATTRIBUTION') then
  --
    pay_eei_mig_bus.chk_qualifier(p_pay_source_value => p_rec.eei_information2,
                              p_qualifier        => p_rec.eei_information3,
                              p_element_type_id  => p_rec.element_type_id );



    pay_eei_mig_bus.chk_mandatory_params(
                        p_eei_information2  => p_rec.eei_information2
                       ,p_eei_information7  => p_rec.eei_information7
                       ,p_eei_information8  => p_rec.eei_information8
                       ,p_eei_information9  => p_rec.eei_information9
                       ,p_eei_information10 => p_rec.eei_information10
		       ,p_element_type_id   => p_rec.element_type_id
                       ) ;
  --
  end if;

  if (p_rec.information_type = 'PQP_UK_RATE_TYPE') then
  --
    pay_eei_mig_bus.chk_duplicate_rate_type (
         p_element_type_extra_info_id => p_rec.element_type_extra_info_id,
         p_element_type_id            => p_rec.element_type_id,
         p_rate_type                  => p_rec.eei_information1
         );
  --
  end if;

  if (p_rec.information_type = 'PQP_GB_PENSERV_ALLOWANCE_INFO') OR
      (p_rec.information_type = 'PQP_GB_PENSERV_BONUS_INFO')then
  --
    pay_eei_mig_bus.chk_duplicate_element_code (
          p_element_type_id           => p_rec.element_type_id
         ,p_element_code              => p_rec.eei_information2
         ,p_information_type          => p_rec.information_type
         );
  --
  end if;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in pay_eei_mig_shd.g_rec_type
  ) is
--
  cursor row_type(p_element_type_id number)
  is
  select business_group_id
  from   pay_element_types_f
  where  element_type_id = p_element_type_id
  and    business_group_id is not null
  and    rownum = 1;
  --
  l_bg    pay_element_types_f.business_group_id%type;
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  open row_type(p_rec.element_type_id);
  fetch row_type into l_bg;
  if row_type%found then
  --
    close row_type;
    pay_etp_bus.set_security_group_id
               (p_element_type_id => p_rec.element_type_id);
  else
    close row_type;
    --
    -- if no row is found them must be seeded row, so hard code the
    -- security group. This is not a satisfactory solution.
    --
    hr_api.set_security_group_id(p_security_group_id => 0);
    --
  end if;
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  --
  if (pay_element_eit_swi.g_migration) then
     pay_eei_mig_bus.chk_ddf(p_rec);
  end if;
  --
  pay_eei_mig_bus.chk_df(p_rec);
  --

  if (p_rec.information_type = 'PQP_UK_ELEMENT_ATTRIBUTION') then
  --
    pay_eei_mig_bus.chk_qualifier(p_pay_source_value => p_rec.eei_information2,
                              p_qualifier        => p_rec.eei_information3,
                              p_element_type_id  => p_rec.element_type_id);
  --

      pay_eei_mig_bus.chk_mandatory_params(
                        p_eei_information2  => p_rec.eei_information2
                       ,p_eei_information7  => p_rec.eei_information7
                       ,p_eei_information8  => p_rec.eei_information8
                       ,p_eei_information9  => p_rec.eei_information9
                       ,p_eei_information10 => p_rec.eei_information10
		       ,p_element_type_id   => p_rec.element_type_id
                       ) ;

  end if;
  if (p_rec.information_type = 'PQP_UK_RATE_TYPE') then
  --
    pay_eei_mig_bus.chk_duplicate_rate_type (
         p_element_type_extra_info_id => p_rec.element_type_extra_info_id,
         p_element_type_id            => p_rec.element_type_id,
         p_rate_type                  => p_rec.eei_information1
         );
  --
  end if;

  if (p_rec.information_type = 'PQP_GB_PENSERV_ALLOWANCE_INFO') OR
      (p_rec.information_type = 'PQP_GB_PENSERV_BONUS_INFO')then
  --
    pay_eei_mig_bus.chk_duplicate_element_code (
          p_element_type_id           => p_rec.element_type_id
         ,p_element_code              => p_rec.eei_information2
         ,p_information_type          => p_rec.information_type
         );
  --
  end if;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pay_eei_mig_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
---
end pay_eei_mig_bus;

/
