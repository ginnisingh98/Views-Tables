--------------------------------------------------------
--  DDL for Package Body PER_ABC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ABC_BUS" as
/* $Header: peabcrhi.pkb 120.1 2005/09/28 05:04 snukala noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_abc_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_absence_case_id             number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_absence_case_id                      in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , per_absence_cases abc
     where abc.absence_case_id = p_absence_case_id
       and pbg.business_group_id = abc.business_group_id;
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
    ,p_argument           => 'absence_case_id'
    ,p_argument_value     => p_absence_case_id
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
        => nvl(p_associated_column1,'ABSENCE_CASE_ID')
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
  (p_absence_case_id                      in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , per_absence_cases pbc
     where pbc.absence_case_id = p_absence_case_id
       and pbg.business_group_id = pbc.business_group_id;
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
    ,p_argument           => 'absence_case_id'
    ,p_argument_value     => p_absence_case_id
    );
  --
  if ( nvl(per_abc_bus.g_absence_case_id, hr_api.g_number)
       = p_absence_case_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_abc_bus.g_legislation_code;
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
    per_abc_bus.g_absence_case_id             := p_absence_case_id;
    per_abc_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in per_abc_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.absence_case_id is not null)  and (
    nvl(per_abc_shd.g_old_rec.ac_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information_category, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.ac_information1, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information1, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.ac_information2, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information2, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.ac_information3, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information3, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.ac_information4, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information4, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.ac_information5, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information5, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.ac_information6, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information6, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.ac_information7, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information7, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.ac_information8, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information8, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.ac_information9, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information9, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.ac_information10, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information10, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.ac_information11, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information11, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.ac_information12, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information12, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.ac_information13, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information13, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.ac_information14, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information14, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.ac_information15, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information15, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.ac_information16, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information16, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.ac_information17, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information17, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.ac_information18, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information18, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.ac_information19, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information19, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.ac_information20, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information20, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.ac_information21, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information21, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.ac_information22, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information22, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.ac_information23, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information23, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.ac_information24, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information24, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.ac_information25, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information25, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.ac_information26, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information26, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.ac_information27, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information27, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.ac_information28, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information28, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.ac_information29, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information29, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.ac_information30, hr_api.g_varchar2) <>
    nvl(p_rec.ac_information30, hr_api.g_varchar2) ))
    or (p_rec.absence_case_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_ABS_CASE_DEVELOPER_DF'
      ,p_attribute_category              => p_rec.ac_information_category
      ,p_attribute1_name                 => 'AC_INFORMATION1'
      ,p_attribute1_value                => p_rec.ac_information1
      ,p_attribute2_name                 => 'AC_INFORMATION2'
      ,p_attribute2_value                => p_rec.ac_information2
      ,p_attribute3_name                 => 'AC_INFORMATION3'
      ,p_attribute3_value                => p_rec.ac_information3
      ,p_attribute4_name                 => 'AC_INFORMATION4'
      ,p_attribute4_value                => p_rec.ac_information4
      ,p_attribute5_name                 => 'AC_INFORMATION5'
      ,p_attribute5_value                => p_rec.ac_information5
      ,p_attribute6_name                 => 'AC_INFORMATION6'
      ,p_attribute6_value                => p_rec.ac_information6
      ,p_attribute7_name                 => 'AC_INFORMATION7'
      ,p_attribute7_value                => p_rec.ac_information7
      ,p_attribute8_name                 => 'AC_INFORMATION8'
      ,p_attribute8_value                => p_rec.ac_information8
      ,p_attribute9_name                 => 'AC_INFORMATION9'
      ,p_attribute9_value                => p_rec.ac_information9
      ,p_attribute10_name                => 'AC_INFORMATION10'
      ,p_attribute10_value               => p_rec.ac_information10
      ,p_attribute11_name                => 'AC_INFORMATION11'
      ,p_attribute11_value               => p_rec.ac_information11
      ,p_attribute12_name                => 'AC_INFORMATION12'
      ,p_attribute12_value               => p_rec.ac_information12
      ,p_attribute13_name                => 'AC_INFORMATION13'
      ,p_attribute13_value               => p_rec.ac_information13
      ,p_attribute14_name                => 'AC_INFORMATION14'
      ,p_attribute14_value               => p_rec.ac_information14
      ,p_attribute15_name                => 'AC_INFORMATION15'
      ,p_attribute15_value               => p_rec.ac_information15
      ,p_attribute16_name                => 'AC_INFORMATION16'
      ,p_attribute16_value               => p_rec.ac_information16
      ,p_attribute17_name                => 'AC_INFORMATION17'
      ,p_attribute17_value               => p_rec.ac_information17
      ,p_attribute18_name                => 'AC_INFORMATION18'
      ,p_attribute18_value               => p_rec.ac_information18
      ,p_attribute19_name                => 'AC_INFORMATION19'
      ,p_attribute19_value               => p_rec.ac_information19
      ,p_attribute20_name                => 'AC_INFORMATION20'
      ,p_attribute20_value               => p_rec.ac_information20
      ,p_attribute21_name                => 'AC_INFORMATION21'
      ,p_attribute21_value               => p_rec.ac_information21
      ,p_attribute22_name                => 'AC_INFORMATION22'
      ,p_attribute22_value               => p_rec.ac_information22
      ,p_attribute23_name                => 'AC_INFORMATION23'
      ,p_attribute23_value               => p_rec.ac_information23
      ,p_attribute24_name                => 'AC_INFORMATION24'
      ,p_attribute24_value               => p_rec.ac_information24
      ,p_attribute25_name                => 'AC_INFORMATION25'
      ,p_attribute25_value               => p_rec.ac_information25
      ,p_attribute26_name                => 'AC_INFORMATION26'
      ,p_attribute26_value               => p_rec.ac_information26
      ,p_attribute27_name                => 'AC_INFORMATION27'
      ,p_attribute27_value               => p_rec.ac_information27
      ,p_attribute28_name                => 'AC_INFORMATION28'
      ,p_attribute28_value               => p_rec.ac_information28
      ,p_attribute29_name                => 'AC_INFORMATION29'
      ,p_attribute29_value               => p_rec.ac_information29
      ,p_attribute30_name                => 'AC_INFORMATION30'
      ,p_attribute30_value               => p_rec.ac_information30
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
  (p_rec in per_abc_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.absence_case_id is not null)  and (
    nvl(per_abc_shd.g_old_rec.ac_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.ac_attribute_category, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(per_abc_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    or (p_rec.absence_case_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_ABSENCE_CASES'
      ,p_attribute_category              => p_rec.ac_attribute_category
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
  (p_rec in per_abc_shd.g_rec_type
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
  IF NOT per_abc_shd.api_updating
      (p_absence_case_id                   => p_rec.absence_case_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  hr_utility.set_location(l_proc, 2);
  if nvl(p_rec.absence_case_id,hr_api.g_number) <>
     per_abc_shd.g_old_rec.absence_case_id then
     l_argument := 'absence_case_id';
     raise l_error;
  end if;
  --
  hr_utility.set_location(l_proc, 3);
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     per_abc_shd.g_old_rec.business_group_id then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  --
  hr_utility.set_location(l_proc, 4);
  if nvl(p_rec.person_id, hr_api.g_number) <>
     per_abc_shd.g_old_rec.person_id then
     l_argument := 'person_id';
     raise l_error;
  end if;
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
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in per_abc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => per_abc_shd.g_tab_nam
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
  per_abc_bus.chk_ddf(p_rec);
  --
  per_abc_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in per_abc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => per_abc_shd.g_tab_nam
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
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  --
  per_abc_bus.chk_ddf(p_rec);
  --
  per_abc_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_abc_shd.g_rec_type
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
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_min_abs_start_date >-------------------------|
-- ----------------------------------------------------------------------------
--
function get_min_abs_start_date
      (p_absence_case_id                   number
       ) return date as
--
      cursor c_abs_case_exists is
        select absence_case_id
        from   per_absence_cases
        where  absence_case_id = p_absence_case_id;
--
      cursor c_abs_list is
        select min(date_start)
        from   per_absence_attendances
        where  absence_case_id = p_absence_case_id;
--
      temp date;
      temp2 number(15);
      l_proc  varchar2(72) := g_package||'get_min_abs_start_date';
--
Begin
   hr_utility.set_location('Entering:'||l_proc, 5);
   --
   open c_abs_case_exists;
   fetch c_abs_case_exists into temp2;
   --
   If c_abs_case_exists%notfound Then
        close c_abs_case_exists;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
   End If;
   close c_abs_case_exists;
   --
   open c_abs_list;
   fetch c_abs_list into temp;
   close c_abs_list;
   --
   hr_utility.set_location(' Leaving:'||l_proc, 10);
   return temp;
End get_min_abs_start_date;
--
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_max_abs_end_date >---------------------------|
-- ----------------------------------------------------------------------------
--
function get_max_abs_end_date
      (p_absence_case_id                   number
       ) return date as
--
      cursor c_abs_case_exists is
        select absence_case_id
        from   per_absence_cases
        where  absence_case_id = p_absence_case_id;
--
      cursor c_abs_list is
        select max(date_end)
        from   per_absence_attendances
        where  absence_case_id = p_absence_case_id;
--
      temp date;
      temp2 number(15);
      l_proc  varchar2(72) := g_package||'get_min_abs_end_date';
--
Begin
   hr_utility.set_location('Entering:'||l_proc, 5);
   --
   open c_abs_case_exists;
   fetch c_abs_case_exists into temp2;
   --
   If c_abs_case_exists%notfound Then
        close c_abs_case_exists;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
   End If;
   close c_abs_case_exists;
   --
   open c_abs_list;
   fetch c_abs_list into temp;
   close c_abs_list;
   --
   hr_utility.set_location(' Leaving:'||l_proc, 10);
   return temp;
End get_max_abs_end_date;
--
end per_abc_bus;

/
