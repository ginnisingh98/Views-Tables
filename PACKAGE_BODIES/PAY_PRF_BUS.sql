--------------------------------------------------------
--  DDL for Package Body PAY_PRF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PRF_BUS" as
/* $Header: pyprfrhi.pkb 120.0 2005/05/29 07:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_prf_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_range_table_id              number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_range_table_id                       in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_range_tables_f tax
     where tax.range_table_id = p_range_table_id
       and pbg.business_group_id (+) = tax.business_group_id;
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
    ,p_argument           => 'range_table_id'
    ,p_argument_value     => p_range_table_id
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
        => nvl(p_associated_column1,'RANGE_TABLE_ID')
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
  (p_range_table_id                       in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_range_tables_f tax
     where tax.range_table_id = p_range_table_id
       and pbg.business_group_id (+) = tax.business_group_id;
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
    ,p_argument           => 'range_table_id'
    ,p_argument_value     => p_range_table_id
    );
  --
  if ( nvl(pay_prf_bus.g_range_table_id, hr_api.g_number)
       = p_range_table_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_prf_bus.g_legislation_code;
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
    pay_prf_bus.g_range_table_id              := p_range_table_id;
    pay_prf_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in pay_prf_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.range_table_id is not null )  and (
    nvl(pay_prf_shd.g_old_rec.ran_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information_category, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.ran_information1, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information1, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.ran_information2, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information2, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.ran_information3, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information3, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.ran_information4, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information4, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.ran_information5, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information5, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.ran_information6, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information6, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.ran_information7, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information7, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.ran_information8, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information8, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.ran_information9, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information9, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.ran_information10, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information10, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.ran_information11, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information11, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.ran_information12, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information12, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.ran_information13, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information13, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.ran_information14, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information14, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.ran_information15, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information15, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.ran_information16, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information16, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.ran_information17, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information17, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.ran_information18, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information18, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.ran_information19, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information19, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.ran_information20, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information20, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.ran_information21, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information21, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.ran_information22, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information22, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.ran_information23, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information23, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.ran_information24, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information24, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.ran_information25, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information25, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.ran_information26, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information26, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.ran_information27, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information27, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.ran_information28, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information28, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.ran_information29, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information29, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.ran_information30, hr_api.g_varchar2) <>
    nvl(p_rec.ran_information30, hr_api.g_varchar2) ))
    or (p_rec.range_table_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PAY'
      ,p_descflex_name                   => 'Further Tax Table DF'
      ,p_attribute_category              => p_rec.ran_information_category
      ,p_attribute1_name                 => 'RAN_INFORMATION1'
      ,p_attribute1_value                => p_rec.ran_information1
      ,p_attribute2_name                 => 'RAN_INFORMATION2'
      ,p_attribute2_value                => p_rec.ran_information2
      ,p_attribute3_name                 => 'RAN_INFORMATION3'
      ,p_attribute3_value                => p_rec.ran_information3
      ,p_attribute4_name                 => 'RAN_INFORMATION4'
      ,p_attribute4_value                => p_rec.ran_information4
      ,p_attribute5_name                 => 'RAN_INFORMATION5'
      ,p_attribute5_value                => p_rec.ran_information5
      ,p_attribute6_name                 => 'RAN_INFORMATION6'
      ,p_attribute6_value                => p_rec.ran_information6
      ,p_attribute7_name                 => 'RAN_INFORMATION7'
      ,p_attribute7_value                => p_rec.ran_information7
      ,p_attribute8_name                 => 'RAN_INFORMATION8'
      ,p_attribute8_value                => p_rec.ran_information8
      ,p_attribute9_name                 => 'RAN_INFORMATION9'
      ,p_attribute9_value                => p_rec.ran_information9
      ,p_attribute10_name                => 'RAN_INFORMATION10'
      ,p_attribute10_value               => p_rec.ran_information10
      ,p_attribute11_name                => 'RAN_INFORMATION11'
      ,p_attribute11_value               => p_rec.ran_information11
      ,p_attribute12_name                => 'RAN_INFORMATION12'
      ,p_attribute12_value               => p_rec.ran_information12
      ,p_attribute13_name                => 'RAN_INFORMATION13'
      ,p_attribute13_value               => p_rec.ran_information13
      ,p_attribute14_name                => 'RAN_INFORMATION14'
      ,p_attribute14_value               => p_rec.ran_information14
      ,p_attribute15_name                => 'RAN_INFORMATION15'
      ,p_attribute15_value               => p_rec.ran_information15
      ,p_attribute16_name                => 'RAN_INFORMATION16'
      ,p_attribute16_value               => p_rec.ran_information16
      ,p_attribute17_name                => 'RAN_INFORMATION17'
      ,p_attribute17_value               => p_rec.ran_information17
      ,p_attribute18_name                => 'RAN_INFORMATION18'
      ,p_attribute18_value               => p_rec.ran_information18
      ,p_attribute19_name                => 'RAN_INFORMATION19'
      ,p_attribute19_value               => p_rec.ran_information19
      ,p_attribute20_name                => 'RAN_INFORMATION20'
      ,p_attribute20_value               => p_rec.ran_information20
      ,p_attribute21_name                => 'RAN_INFORMATION21'
      ,p_attribute21_value               => p_rec.ran_information21
      ,p_attribute22_name                => 'RAN_INFORMATION22'
      ,p_attribute22_value               => p_rec.ran_information22
      ,p_attribute23_name                => 'RAN_INFORMATION23'
      ,p_attribute23_value               => p_rec.ran_information23
      ,p_attribute24_name                => 'RAN_INFORMATION24'
      ,p_attribute24_value               => p_rec.ran_information24
      ,p_attribute25_name                => 'RAN_INFORMATION25'
      ,p_attribute25_value               => p_rec.ran_information25
      ,p_attribute26_name                => 'RAN_INFORMATION26'
      ,p_attribute26_value               => p_rec.ran_information26
      ,p_attribute27_name                => 'RAN_INFORMATION27'
      ,p_attribute27_value               => p_rec.ran_information27
      ,p_attribute28_name                => 'RAN_INFORMATION28'
      ,p_attribute28_value               => p_rec.ran_information28
      ,p_attribute29_name                => 'RAN_INFORMATION29'
      ,p_attribute29_value               => p_rec.ran_information29
      ,p_attribute30_name                => 'RAN_INFORMATION30'
      ,p_attribute30_value               => p_rec.ran_information30
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
  (p_rec in pay_prf_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.range_table_id is not null)  and (
    nvl(pay_prf_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(pay_prf_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    or (p_rec.range_table_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PAY'
      ,p_descflex_name                   => 'Tax Table DF'
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
      ,p_attribute21_name                => 'ATTRIBUTE21'
      ,p_attribute21_value               => p_rec.attribute21
      ,p_attribute22_name                => 'ATTRIBUTE22'
      ,p_attribute22_value               => p_rec.attribute22
      ,p_attribute23_name                => 'ATTRIBUTE23'
      ,p_attribute23_value               => p_rec.attribute23
      ,p_attribute24_name                => 'ATTRIBUTE24'
      ,p_attribute24_value               => p_rec.attribute24
      ,p_attribute25_name                => 'ATTRIBUTE25'
      ,p_attribute25_value               => p_rec.attribute25
      ,p_attribute26_name                => 'ATTRIBUTE26'
      ,p_attribute26_value               => p_rec.attribute26
      ,p_attribute27_name                => 'ATTRIBUTE27'
      ,p_attribute27_value               => p_rec.attribute27
      ,p_attribute28_name                => 'ATTRIBUTE28'
      ,p_attribute28_value               => p_rec.attribute28
      ,p_attribute29_name                => 'ATTRIBUTE29'
      ,p_attribute29_value               => p_rec.attribute29
      ,p_attribute30_name                => 'ATTRIBUTE30'
      ,p_attribute30_value               => p_rec.attribute30
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
  (p_rec in pay_prf_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_prf_shd.api_updating
      (p_range_table_id                    => p_rec.range_table_id
      ,p_object_version_number             => p_rec.object_version_number
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
  (p_rec                          in pay_prf_shd.g_rec_type
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
  -- Commented because in this Business Group ID can be NULL.
 /*
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
       ,p_associated_column1 => pay_prf_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
     -- after validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;

 */

  /*   --
  --
  --
  -- Validate Dependent Attributes
  --
  --
  pay_prf_bus.chk_ddf(p_rec);
  --
  pay_prf_bus.chk_df(p_rec);

  */
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in pay_prf_shd.g_rec_type
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

   -- Commented because in this Business Group ID can be NULL.
 /*

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
       ,p_associated_column1 => pay_prf_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');

     --
     -- After validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;

 */
  --
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  --
  pay_prf_bus.chk_ddf(p_rec);
  --
  pay_prf_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pay_prf_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    --
-- Commented Because in this case BG can NULL, so no check in done.
/*
 chk_startup_action(false
                    ,pay_prf_shd.g_old_rec.business_group_id
                    ,pay_prf_shd.g_old_rec.legislation_code
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
*/
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_prf_bus;

/
