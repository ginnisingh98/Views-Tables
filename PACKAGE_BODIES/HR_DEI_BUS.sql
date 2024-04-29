--------------------------------------------------------
--  DDL for Package Body HR_DEI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DEI_BUS" as
/* $Header: hrdeirhi.pkb 120.1.12010000.3 2010/05/20 12:01:59 tkghosh ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_dei_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_document_extra_info_id      number         default null;
g_person_id                   number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_document_extra_info_id               in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , hr_document_extra_info dei
         , per_all_people_f  ppf
     where dei.document_extra_info_id = p_document_extra_info_id
       and ppf.person_id = dei.person_id
       and pbg.business_group_id = ppf.business_group_id;
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
    ,p_argument           => 'document_extra_info_id'
    ,p_argument_value     => p_document_extra_info_id
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
        => nvl(p_associated_column1,'DOCUMENT_EXTRA_INFO_ID')
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
  (p_document_extra_info_id               in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , hr_document_extra_info dei
         , per_all_people_f ppf
     where dei.document_extra_info_id = p_document_extra_info_id
       and ppf.person_id = dei.person_id
       and pbg.business_group_id = ppf.business_group_id;
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
    ,p_argument           => 'document_extra_info_id'
    ,p_argument_value     => p_document_extra_info_id
    );
  --
  if ( nvl(hr_dei_bus.g_document_extra_info_id, hr_api.g_number)
       = p_document_extra_info_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := hr_dei_bus.g_legislation_code;
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
    hr_dei_bus.g_document_extra_info_id      := p_document_extra_info_id;
    hr_dei_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
--
Function return_leg_code_perid
  (p_person_id               in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , per_all_people_f ppf
     where ppf.person_id = p_person_id
       and pbg.business_group_id = ppf.business_group_id;
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
    ,p_argument           => 'person_id'
    ,p_argument_value     => p_person_id
    );
  --
  if ( nvl(hr_dei_bus.g_person_id, hr_api.g_number)
       = p_person_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := hr_dei_bus.g_legislation_code;
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
    hr_dei_bus.g_person_id      := p_person_id;
    hr_dei_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_leg_code_perid;
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
  (p_rec in hr_dei_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.document_extra_info_id is not null)  and (
    nvl(hr_dei_shd.g_old_rec.dei_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information_category, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_information1, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information1, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_information2, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information2, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_information3, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information3, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_information4, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information4, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_information5, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information5, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_information6, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information6, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_information7, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information7, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_information8, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information8, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_information9, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information9, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_information10, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information10, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_information11, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information11, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_information12, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information12, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_information13, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information13, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_information14, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information14, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_information15, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information15, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_information16, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information16, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_information17, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information17, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_information18, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information18, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_information19, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information19, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_information20, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information20, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_information21, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information21, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_information22, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information22, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_information23, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information23, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_information24, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information24, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_information25, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information25, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_information26, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information26, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_information27, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information27, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_information28, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information28, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_information29, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information29, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_information30, hr_api.g_varchar2) <>
    nvl(p_rec.dei_information30, hr_api.g_varchar2) ))
    or (p_rec.document_extra_info_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'HR'
      ,p_descflex_name                   => 'Extra Document Info DDF'
      ,p_attribute_category              => p_rec.dei_information_category
      ,p_attribute1_name                 => 'DEI_INFORMATION1'
      ,p_attribute1_value                => p_rec.dei_information1
      ,p_attribute2_name                 => 'DEI_INFORMATION2'
      ,p_attribute2_value                => p_rec.dei_information2
      ,p_attribute3_name                 => 'DEI_INFORMATION3'
      ,p_attribute3_value                => p_rec.dei_information3
      ,p_attribute4_name                 => 'DEI_INFORMATION4'
      ,p_attribute4_value                => p_rec.dei_information4
      ,p_attribute5_name                 => 'DEI_INFORMATION5'
      ,p_attribute5_value                => p_rec.dei_information5
      ,p_attribute6_name                 => 'DEI_INFORMATION6'
      ,p_attribute6_value                => p_rec.dei_information6
      ,p_attribute7_name                 => 'DEI_INFORMATION7'
      ,p_attribute7_value                => p_rec.dei_information7
      ,p_attribute8_name                 => 'DEI_INFORMATION8'
      ,p_attribute8_value                => p_rec.dei_information8
      ,p_attribute9_name                 => 'DEI_INFORMATION9'
      ,p_attribute9_value                => p_rec.dei_information9
      ,p_attribute10_name                => 'DEI_INFORMATION10'
      ,p_attribute10_value               => p_rec.dei_information10
      ,p_attribute11_name                => 'DEI_INFORMATION11'
      ,p_attribute11_value               => p_rec.dei_information11
      ,p_attribute12_name                => 'DEI_INFORMATION12'
      ,p_attribute12_value               => p_rec.dei_information12
      ,p_attribute13_name                => 'DEI_INFORMATION13'
      ,p_attribute13_value               => p_rec.dei_information13
      ,p_attribute14_name                => 'DEI_INFORMATION14'
      ,p_attribute14_value               => p_rec.dei_information14
      ,p_attribute15_name                => 'DEI_INFORMATION15'
      ,p_attribute15_value               => p_rec.dei_information15
      ,p_attribute16_name                => 'DEI_INFORMATION16'
      ,p_attribute16_value               => p_rec.dei_information16
      ,p_attribute17_name                => 'DEI_INFORMATION17'
      ,p_attribute17_value               => p_rec.dei_information17
      ,p_attribute18_name                => 'DEI_INFORMATION18'
      ,p_attribute18_value               => p_rec.dei_information18
      ,p_attribute19_name                => 'DEI_INFORMATION19'
      ,p_attribute19_value               => p_rec.dei_information19
      ,p_attribute20_name                => 'DEI_INFORMATION20'
      ,p_attribute20_value               => p_rec.dei_information20
      ,p_attribute21_name                => 'DEI_INFORMATION21'
      ,p_attribute21_value               => p_rec.dei_information21
      ,p_attribute22_name                => 'DEI_INFORMATION22'
      ,p_attribute22_value               => p_rec.dei_information22
      ,p_attribute23_name                => 'DEI_INFORMATION23'
      ,p_attribute23_value               => p_rec.dei_information23
      ,p_attribute24_name                => 'DEI_INFORMATION24'
      ,p_attribute24_value               => p_rec.dei_information24
      ,p_attribute25_name                => 'DEI_INFORMATION25'
      ,p_attribute25_value               => p_rec.dei_information25
      ,p_attribute26_name                => 'DEI_INFORMATION26'
      ,p_attribute26_value               => p_rec.dei_information26
      ,p_attribute27_name                => 'DEI_INFORMATION27'
      ,p_attribute27_value               => p_rec.dei_information27
      ,p_attribute28_name                => 'DEI_INFORMATION28'
      ,p_attribute28_value               => p_rec.dei_information28
      ,p_attribute29_name                => 'DEI_INFORMATION29'
      ,p_attribute29_value               => p_rec.dei_information29
      ,p_attribute30_name                => 'DEI_INFORMATION30'
      ,p_attribute30_value               => p_rec.dei_information30
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
  (p_rec in hr_dei_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.document_extra_info_id is not null)  and (
    nvl(hr_dei_shd.g_old_rec.dei_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute_category, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute1, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute2, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute3, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute4, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute5, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute6, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute7, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute8, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute9, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute10, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute11, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute12, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute13, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute14, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute15, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute16, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute17, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute18, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute19, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute20, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute21, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute22, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute23, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute24, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute25, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute26, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute27, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute28, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute29, hr_api.g_varchar2)  or
    nvl(hr_dei_shd.g_old_rec.dei_attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.dei_attribute30, hr_api.g_varchar2) ))
    or (p_rec.document_extra_info_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'HR'
      ,p_descflex_name                   => 'HR_DOCUMENT_EXTRA_INFO'
      ,p_attribute_category              => p_rec.dei_attribute_category
      ,p_attribute1_name                 => 'DEI_ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.dei_attribute1
      ,p_attribute2_name                 => 'DEI_ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.dei_attribute2
      ,p_attribute3_name                 => 'DEI_ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.dei_attribute3
      ,p_attribute4_name                 => 'DEI_ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.dei_attribute4
      ,p_attribute5_name                 => 'DEI_ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.dei_attribute5
      ,p_attribute6_name                 => 'DEI_ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.dei_attribute6
      ,p_attribute7_name                 => 'DEI_ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.dei_attribute7
      ,p_attribute8_name                 => 'DEI_ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.dei_attribute8
      ,p_attribute9_name                 => 'DEI_ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.dei_attribute9
      ,p_attribute10_name                => 'DEI_ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.dei_attribute10
      ,p_attribute11_name                => 'DEI_ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.dei_attribute11
      ,p_attribute12_name                => 'DEI_ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.dei_attribute12
      ,p_attribute13_name                => 'DEI_ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.dei_attribute13
      ,p_attribute14_name                => 'DEI_ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.dei_attribute14
      ,p_attribute15_name                => 'DEI_ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.dei_attribute15
      ,p_attribute16_name                => 'DEI_ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.dei_attribute16
      ,p_attribute17_name                => 'DEI_ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.dei_attribute17
      ,p_attribute18_name                => 'DEI_ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.dei_attribute18
      ,p_attribute19_name                => 'DEI_ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.dei_attribute19
      ,p_attribute20_name                => 'DEI_ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.dei_attribute20
      ,p_attribute21_name                => 'DEI_ATTRIBUTE21'
      ,p_attribute21_value               => p_rec.dei_attribute21
      ,p_attribute22_name                => 'DEI_ATTRIBUTE22'
      ,p_attribute22_value               => p_rec.dei_attribute22
      ,p_attribute23_name                => 'DEI_ATTRIBUTE23'
      ,p_attribute23_value               => p_rec.dei_attribute23
      ,p_attribute24_name                => 'DEI_ATTRIBUTE24'
      ,p_attribute24_value               => p_rec.dei_attribute24
      ,p_attribute25_name                => 'DEI_ATTRIBUTE25'
      ,p_attribute25_value               => p_rec.dei_attribute25
      ,p_attribute26_name                => 'DEI_ATTRIBUTE26'
      ,p_attribute26_value               => p_rec.dei_attribute26
      ,p_attribute27_name                => 'DEI_ATTRIBUTE27'
      ,p_attribute27_value               => p_rec.dei_attribute27
      ,p_attribute28_name                => 'DEI_ATTRIBUTE28'
      ,p_attribute28_value               => p_rec.dei_attribute28
      ,p_attribute29_name                => 'DEI_ATTRIBUTE29'
      ,p_attribute29_value               => p_rec.dei_attribute29
      ,p_attribute30_name                => 'DEI_ATTRIBUTE30'
      ,p_attribute30_value               => p_rec.dei_attribute30
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
  (p_rec in hr_dei_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT hr_dei_shd.api_updating
      (p_document_extra_info_id            => p_rec.document_extra_info_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --

  --Check for Non- updation of person_id
  --
  --
  if nvl(p_rec.person_id, hr_api.g_number) <>
     hr_dei_shd.g_old_rec.person_id then

    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'PERSON_ID'
    ,p_base_table => hr_dei_shd.g_tab_nam
    );

  end if;

    --Check for Non- updation of DOCUMENT_TYPE_ID
    --
    --
    if nvl(p_rec.document_type_id, hr_api.g_number) <>
       hr_dei_shd.g_old_rec.document_type_id then

      hr_api.argument_changed_error
      (p_api_name   => l_proc
      ,p_argument   => 'DOCUMENT_TYPE_ID'
      ,p_base_table => hr_dei_shd.g_tab_nam
      );

  end if;
  --
  --Check for Non- updation of document extra info id
  --
  --
  hr_utility.set_location(l_proc, 8);
if nvl(p_rec.document_extra_info_id, hr_api.g_number) <>
     hr_dei_shd.g_old_rec.document_extra_info_id then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'DOCUMENT_EXTRA_INFO_ID'
    ,p_base_table => hr_dei_shd.g_tab_nam
    );
  end if;
  --
End chk_non_updateable_args;
--
--  ---------------------------------------------------------------------------
--  |------------------------<  chk_date_from >-------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that date from is less than or equal to date to .
--
--  Pre-conditions:
--    Format of p_date_from and p_date_to must be correct.
--
--  In Arguments:
--    p_document_extra_info_id
--    p_date_from
--    p_date_to
--    p_object_version_number
--
--  Post Success:
--    If a given date from is less than or equal to a given date to then
--    processing continues.
--
--  Post Failure:
--    If a given date from is not less than or equal to a given date to then
--    an application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_date_from
  (p_document_extra_info_id in hr_document_extra_info.document_extra_info_id%type
  ,p_date_from              in hr_document_extra_info.date_from%TYPE
  ,p_date_to                in hr_document_extra_info.date_to%TYPE
  ,p_object_version_number  in hr_document_extra_info.object_version_number%TYPE)
   is
--
   l_exists           varchar2(1);
   l_proc             varchar2(72)  :=  g_package||'chk_date_from';
   l_api_updating     boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'date_from'
    ,p_argument_value => p_date_from
    );
  --
    --
    -- Check that the date_from values is less than
    -- or equal to the date_to value for the current
    -- record
    --
    if p_date_from > nvl(p_date_to, hr_api.g_eot) then

      hr_utility.set_message(801, 'HR_7303_ADD_DATE_FROM_EARLIER');
      hr_utility.raise_error;
    end if;
    --

  --
  hr_utility.set_location(' Leaving:'|| l_proc, 2);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'HR_DOCUMENT_EXTRA_INFO.DATE_FROM'
    ,p_associated_column2 =>  'HR_DOCUMENT_EXTRA_INFO.DATE_TO'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc,3);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,4);
--
end chk_date_from;
--
--  ---------------------------------------------------------------------------
--  |------------------------<  chk_date_to >--------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that date to  is greater than or equal to date
--    from.
--
--  Pre-conditions:
--    Format of p_date_from and p_date_to must be correct.
--
--  In Arguments:
--    p_document_extra_info_id
--    p_date_from
--    p_date_to
--    p_object_version_number
--
--  Post Success:
--    If a given date to is greater than or equal to a given date from then
--    processing continues.
--
--  Post Failure:
--    If a given date to is not greater than or equal to a given date from then
--    an application error will be raised and processing is terminated.
--
--  Access status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_date_to
  (p_document_extra_info_id in hr_document_extra_info.document_extra_info_id%TYPE
  ,p_date_from              in hr_document_extra_info.date_from%TYPE
  ,p_date_to                in hr_document_extra_info.date_to%TYPE
  ,p_object_version_number  in hr_document_extra_info.object_version_number%TYPE)
   is
--
   l_exists           varchar2(1);
   l_proc             varchar2(72)  :=  g_package||'chk_date_to';
   l_date_to          date;
   l_api_updating     boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'date_from'
    ,p_argument_value => p_date_from
    );

   /* hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'date_to'
    ,p_argument_value => p_date_to
    );*/ -- for bug 9718560

      -- Checks that the value for date_to is greater than or
      -- equal to the corresponding value for date_from for the
      -- same record
      --
      if nvl(p_date_to, hr_api.g_eot) < p_date_from then

        hr_utility.set_message(801, 'HR_7301_ADD_DATE_TO_LATER');
        hr_utility.raise_error;
      end if;
      --

  hr_utility.set_location(' Leaving:'|| l_proc, 3);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_same_associated_columns =>  'Y'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc,4);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,5);
--
end chk_date_to;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_document_type_id >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that document_type_id value is valid.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_document_type_id
--  p_document_extra_info_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if document_type_id is valid and if updating,
--   old_rec.document_type_id is null
--
-- Post Failure:
--   An application error is raised
--   if updating and old_rec.business_group_id is not null, or
--   business_group_id is not valid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_document_type_id
  (
   p_document_type_id     in     hr_document_extra_info.document_type_id%TYPE
  )
      is
  --

  --
  l_proc          varchar2(72) := g_package||'chk_document_type_id';
  l_api_updating  boolean;
  l_doc_type_id number;

 -- Cursor for Validating Document Type Id

    cursor csr_valid_doc_id is
    select document_type_id
    from hr_document_types hdt,
	     hr_lookups hrl
    where hrl.lookup_code = hdt.category_code
	and   hrl.lookup_type = 'DOCUMENT_CATEGORY'
	and   hdt.document_type_id = p_document_type_id;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 5);

    --
    -- Check that the Document Type Id is linked to a
    -- valid document type id on hr_document_types
    --


    open csr_valid_doc_id;
    fetch csr_valid_doc_id into l_doc_type_id;
    if csr_valid_doc_id%notfound then

      --
      close csr_valid_doc_id;
       hr_utility.set_message(800, 'HR_449710_DOR_INVL_VAL');
       hr_utility.set_message_token('OBJECT', 'DOCUMENT_TYPE_ID');
       hr_utility.set_message_token('TABLE', 'HR_DOCUMENT_TYPES');
       hr_utility.raise_error;
      --
   else
   close csr_valid_doc_id;

   end if;
    hr_utility.set_location(l_proc, 20);
    --

    --



  hr_utility.set_location('Leaving:'||l_proc, 30);

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1  => 'hr_document_types.document_type_id'
      ) then
      hr_utility.set_location('Leaving:'||l_proc, 50);
      raise;
    end if;
    hr_utility.set_location('Leaving:'||l_proc,60);
end chk_document_type_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_person_id >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that a person id exists in table per_people_f.
--    - Validates that the business group of the address matches
--      the business group of the person.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_person_id
--
--
--  Post Success:
--    If a row does exist in per_people_f for the given person id then
--    processing continues.
--
--  Post Failure:
--    If a row does not exist in per_people_f for the given person id then
--    an application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_person_id
  (p_document_extra_info_id in hr_document_extra_info.document_extra_info_id%TYPE
  ,p_object_version_number  in     hr_document_extra_info.object_version_number%TYPE
  ,p_person_id              in     hr_document_extra_info.person_id%TYPE
  )
is
  --
  l_proc              varchar2(72)  :=  g_package||'chk_person_id';
  --
  l_api_updating      boolean;
  l_person_id number;
  --
  cursor csr_valid_pers is
    select person_id
    from per_people_f ppf
    where ppf.person_id = p_person_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'person_id'
    ,p_argument_value => p_person_id
    );
  --
    --
    -- Check that the Person ID is linked to a
    -- valid person on PER_PEOPLE_F
    --
    open csr_valid_pers;
    fetch csr_valid_pers into l_person_id;
    if csr_valid_pers%notfound then

      --
      close csr_valid_pers;
      hr_utility.set_message(801, 'HR_7298_ADD_PERSON_INVALID');
      hr_utility.raise_error;
      --
    else
      close csr_valid_pers;
      hr_utility.set_location(l_proc, 20);
      --


    end if;

  --
  hr_utility.set_location(' Leaving:'|| l_proc, 30);

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'HR_DOCUMENT_EXTRA_INFO.PERSON_ID'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
end chk_person_id;
--

--

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in hr_dei_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  per_per_bus.set_security_group_id(p_person_id => p_rec.person_id);

  --
  -- Validate Dependent Attributes
  --
  -- Validate date from
  --
  chk_date_from
    (p_document_extra_info_id => p_rec.document_extra_info_id
    ,p_date_from              => p_rec.date_from
    ,p_date_to                => p_rec.date_to
    ,p_object_version_number  => p_rec.object_version_number
    );
  -- Validate Date To
  chk_date_to
  (p_document_extra_info_id => p_rec.document_extra_info_id
  ,p_date_from              => p_rec.date_from
  ,p_date_to                => p_rec.date_to
  ,p_object_version_number  => p_rec.object_version_number
  );
  -- Validate Document type ID
  chk_document_type_id
  (p_document_type_id      => p_rec.document_type_id
  );
  -- Validate Person ID
  chk_person_id
  (p_document_extra_info_id => p_rec.document_extra_info_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_person_id              => p_rec.person_id
  );


  hr_utility.set_location(l_proc, 10);
  --
--  hr_dei_bus.chk_ddf(p_rec);
  --
--  hr_dei_bus.chk_df(p_rec);
  --
 -- hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--



-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in hr_dei_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  per_per_bus.set_security_group_id(p_person_id => p_rec.person_id);
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args(p_rec => p_rec);
  --
  --
  -- Validate date from
  --
  chk_date_from
    (p_document_extra_info_id => p_rec.document_extra_info_id
    ,p_date_from              => p_rec.date_from
    ,p_date_to                => p_rec.date_to
    ,p_object_version_number  => p_rec.object_version_number
    );
  -- Validate Date To
 chk_date_to
  (p_document_extra_info_id => p_rec.document_extra_info_id
  ,p_date_from              => p_rec.date_from
  ,p_date_to                => p_rec.date_to
  ,p_object_version_number  => p_rec.object_version_number
  );
  -- Validate Document type ID
  chk_document_type_id
  (p_document_type_id      => p_rec.document_type_id
  );


--  hr_dei_bus.chk_ddf(p_rec);
  --
--  hr_dei_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hr_dei_shd.g_rec_type
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
end hr_dei_bus;

/
