--------------------------------------------------------
--  DDL for Package Body PER_INC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_INC_BUS" as
/* $Header: peincrhi.pkb 115.29 2003/08/31 00:49:48 kjagadee noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_inc_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_incident_id                 number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_incident_id                          in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
      select null
       from per_work_incidents inc
            ,per_people_f per
            ,hr_organization_information hoi
      where inc.incident_id = p_incident_id
        and per.person_id = inc.person_id
        and hoi.organization_id = per.business_group_id
        and hoi.org_information_context||'' = 'Business Group Information';
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
    ,p_argument           => 'incident_id'
    ,p_argument_value     => p_incident_id
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
  (p_incident_id                          in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_work_incidents inc,
      per_people_f per,
      per_business_groups pbg
     where inc.incident_id = p_incident_id
       and inc.person_id = per.person_id
       and per.business_group_id = pbg.business_group_id;
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
    ,p_argument           => 'incident_id'
    ,p_argument_value     => p_incident_id
    );
  --
  if ( nvl(per_inc_bus.g_incident_id, hr_api.g_number) = p_incident_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_inc_bus.g_legislation_code;
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
    per_inc_bus.g_incident_id       := p_incident_id;
    per_inc_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in per_inc_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.incident_id is not null)  and (
    nvl(per_inc_shd.g_old_rec.inc_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information_category, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.inc_information1, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information1, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.inc_information2, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information2, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.inc_information3, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information3, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.inc_information4, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information4, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.inc_information5, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information5, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.inc_information6, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information6, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.inc_information7, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information7, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.inc_information8, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information8, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.inc_information9, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information9, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.inc_information10, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information10, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.inc_information11, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information11, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.inc_information12, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information12, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.inc_information13, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information13, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.inc_information14, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information14, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.inc_information15, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information15, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.inc_information16, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information16, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.inc_information17, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information17, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.inc_information18, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information18, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.inc_information19, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information19, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.inc_information20, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information20, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.inc_information21, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information21, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.inc_information22, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information22, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.inc_information23, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information23, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.inc_information24, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information24, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.inc_information25, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information25, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.inc_information26, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information26, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.inc_information27, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information27, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.inc_information28, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information28, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.inc_information29, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information29, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.inc_information30, hr_api.g_varchar2) <>
    nvl(p_rec.inc_information30, hr_api.g_varchar2) ))
    or (p_rec.incident_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
  hr_utility.set_location(' INC Cat:'||p_rec.inc_information_category,20);
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'Work Incident Developer DF'
      ,p_attribute_category              => p_rec.INC_INFORMATION_CATEGORY
      ,p_attribute1_name                 => 'INC_INFORMATION1'
      ,p_attribute1_value                => p_rec.inc_information1
      ,p_attribute2_name                 => 'INC_INFORMATION2'
      ,p_attribute2_value                => p_rec.inc_information2
      ,p_attribute3_name                 => 'INC_INFORMATION3'
      ,p_attribute3_value                => p_rec.inc_information3
      ,p_attribute4_name                 => 'INC_INFORMATION4'
      ,p_attribute4_value                => p_rec.inc_information4
      ,p_attribute5_name                 => 'INC_INFORMATION5'
      ,p_attribute5_value                => p_rec.inc_information5
      ,p_attribute6_name                 => 'INC_INFORMATION6'
      ,p_attribute6_value                => p_rec.inc_information6
      ,p_attribute7_name                 => 'INC_INFORMATION7'
      ,p_attribute7_value                => p_rec.inc_information7
      ,p_attribute8_name                 => 'INC_INFORMATION8'
      ,p_attribute8_value                => p_rec.inc_information8
      ,p_attribute9_name                 => 'INC_INFORMATION9'
      ,p_attribute9_value                => p_rec.inc_information9
      ,p_attribute10_name                => 'INC_INFORMATION10'
      ,p_attribute10_value               => p_rec.inc_information10
      ,p_attribute11_name                => 'INC_INFORMATION11'
      ,p_attribute11_value               => p_rec.inc_information11
      ,p_attribute12_name                => 'INC_INFORMATION12'
      ,p_attribute12_value               => p_rec.inc_information12
      ,p_attribute13_name                => 'INC_INFORMATION13'
      ,p_attribute13_value               => p_rec.inc_information13
      ,p_attribute14_name                => 'INC_INFORMATION14'
      ,p_attribute14_value               => p_rec.inc_information14
      ,p_attribute15_name                => 'INC_INFORMATION15'
      ,p_attribute15_value               => p_rec.inc_information15
      ,p_attribute16_name                => 'INC_INFORMATION16'
      ,p_attribute16_value               => p_rec.inc_information16
      ,p_attribute17_name                => 'INC_INFORMATION17'
      ,p_attribute17_value               => p_rec.inc_information17
      ,p_attribute18_name                => 'INC_INFORMATION18'
      ,p_attribute18_value               => p_rec.inc_information18
      ,p_attribute19_name                => 'INC_INFORMATION19'
      ,p_attribute19_value               => p_rec.inc_information19
      ,p_attribute20_name                => 'INC_INFORMATION20'
      ,p_attribute20_value               => p_rec.inc_information20
      ,p_attribute21_name                => 'INC_INFORMATION21'
      ,p_attribute21_value               => p_rec.inc_information21
      ,p_attribute22_name                => 'INC_INFORMATION22'
      ,p_attribute22_value               => p_rec.inc_information22
      ,p_attribute23_name                => 'INC_INFORMATION23'
      ,p_attribute23_value               => p_rec.inc_information23
      ,p_attribute24_name                => 'INC_INFORMATION24'
      ,p_attribute24_value               => p_rec.inc_information24
      ,p_attribute25_name                => 'INC_INFORMATION25'
      ,p_attribute25_value               => p_rec.inc_information25
      ,p_attribute26_name                => 'INC_INFORMATION26'
      ,p_attribute26_value               => p_rec.inc_information26
      ,p_attribute27_name                => 'INC_INFORMATION27'
      ,p_attribute27_value               => p_rec.inc_information27
      ,p_attribute28_name                => 'INC_INFORMATION28'
      ,p_attribute28_value               => p_rec.inc_information28
      ,p_attribute29_name                => 'INC_INFORMATION29'
      ,p_attribute29_value               => p_rec.inc_information29
      ,p_attribute30_name                => 'INC_INFORMATION30'
      ,p_attribute30_value               => p_rec.inc_information30
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
  (p_rec in per_inc_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.incident_id is not null)  and (
    nvl(per_inc_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(per_inc_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    or (p_rec.incident_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_WORK_INCIDENTS'
      ,p_attribute_category              => p_rec.ATTRIBUTE_CATEGORY
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
  (p_effective_date               in date
  ,p_rec in per_inc_shd.g_rec_type ) IS
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
  IF NOT per_inc_shd.api_updating
      (p_incident_id                          => p_rec.incident_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  hr_utility.set_location(l_proc, 30);
  --
  if nvl(p_rec.person_id, hr_api.g_number) <>
     nvl(per_inc_shd.g_old_rec.person_id
        ,hr_api.g_number) then
     l_argument := 'person_id';
     raise l_error;
  end if;
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
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_person_id >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that on insert PERSON_ID is not null and that
--    it exists in per_all_people_f on the effective_date.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_incident_id
--    p_person_id
--    p_effective_date
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_person_id
  (p_incident_id         in    per_work_incidents.incident_id%TYPE,
   p_person_id           in    per_work_incidents.person_id%TYPE,
   p_effective_date      in    date
   ) is
--
 l_proc  varchar2(72) := g_package||'chk_person_id';
 l_dummy number;
--
 cursor csr_person_id is
    select null
    from per_people_f per
    where per.person_id = p_person_id
    and p_effective_date between per.effective_start_date
                         and per.effective_end_date;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- 	Check mandatory person_id is set
  --
  if p_person_id is null then
          hr_utility.set_message(800, 'HR_52891_INC_PERSON_ID_NULL');
          hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 5);
  --
  --
  --
  -- Only proceed with validation if :
  -- a) on insert (non-updateable param)
  --
  if (p_incident_id is null) then
     --
     hr_utility.set_location(l_proc, 10);
     --
     -- Check that the person_id is in the per_people_f view on the effective_date.
     --
       open csr_person_id;
       fetch csr_person_id into l_dummy;
       if csr_person_id%notfound then
          close csr_person_id;
          hr_utility.set_message(800, 'HR_52896_INC_FK_NOT_FOUND');
          hr_utility.raise_error;
       end if;
       close csr_person_id;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
  --
end chk_person_id;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_incident_date >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description :
--
--    Validate that INCIDENT_DATE is not null
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_incident_date
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_incident_date
  (p_incident_date       in    per_work_incidents.incident_date%TYPE
   ) is
--
 l_proc  varchar2(72) := g_package||'chk_incident_date';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- 	Check mandatory incident_date is set
  --
  if p_incident_date is null then
          hr_utility.set_message(800, 'HR_52895_INC_INC_DATE_NULL');
          hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 5);
  --
end chk_incident_date;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_incident_time >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that INCIDENT_TIME is valid time in 24HH:MI.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_incident_time
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_incident_time
  (p_incident_time       in    per_work_incidents.incident_time%TYPE
   ) is
--
 l_proc   varchar2(72) := g_package||'chk_incident_time';
 l_value  varchar2(60) := p_incident_time;
 l_output varchar2(60) := p_incident_time;
 l_rgeflg varchar2(1);
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- 	Check incident_time is in HH24:MI format
  --
  if p_incident_time is not null then
    begin

      hr_chkfmt.checkformat(l_value, 'TIMES', l_output, NULL, NULL, 'Y', l_rgeflg, NULL);

      if p_incident_time <> l_output then
        hr_utility.set_message(800, 'HR_289019_INC_INV_ITIME');
        hr_utility.raise_error;
      end if;

     exception
       when others then
         hr_utility.set_message(801,'HR_7916_CHECK_FMT_HHMM');
         hr_utility.set_message_token('ARG_NAME', 'incident_time');
	    hr_utility.set_message_token('ARG_VALUE', p_incident_time);
         hr_utility.raise_error;
    end;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 5);
  --
end chk_incident_time;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------< get_osha_case_number >---------------------------|
--  ---------------------------------------------------------------------------
--
Function get_osha_case_number
  (p_date          in   date
  ,p_bg_id         in   number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_num(p_year number,p_bg_id number) is
    SELECT next_value
      FROM per_us_osha_numbers
      WHERE case_year       = p_year
      AND business_group_id = p_bg_id
      FOR UPDATE OF next_value NOWAIT;
  --
  -- Declare local variables
  --
  l_case_num per_work_incidents.incident_reference%type;
  l_next_num per_us_osha_numbers.next_value%type;
  p_year              number;
  l_proc              varchar2(72)  :=  g_package||'get_osha_case_number';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  p_year :=to_number(to_char(p_date,'YYYY'));
  hr_utility.set_location('Year '||p_year||'-'|| l_proc, 11);
  hr_utility.set_location('BGID '||p_bg_id||'-'|| l_proc, 12);
  --
  -- Get the next case number from cursor
  --
  open csr_num(p_year,p_bg_id);
  fetch csr_num into l_next_num;
  --
  if csr_num%notfound then
  --
     close csr_num;
     hr_utility.set_location(l_proc, 20);
     fnd_message.set_name('PER','HR_289811_INC_RUN_CONC_OSHA');
     fnd_message.raise_error;
  --
  else
  --
    UPDATE per_us_osha_numbers
      SET next_value = next_value+1
      WHERE CURRENT OF csr_num;
    --
    close csr_num;
    --
    l_case_num := substr(to_char(p_year),3,2)||'-'||l_next_num;
    hr_utility.set_location('Case num '||l_case_num, 25);
    hr_utility.set_location(' Leaving:'|| l_proc, 30);
    return l_case_num;
  --
  end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 30);
  --
end get_osha_case_number;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_incident_reference >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that value for mandatory INCIDENT_REFERENCE has been supplied
--    and that it is unique (case insensitive).
--
--  Pre-conditions :
--    Format mask must be supplied.
--
--  In Arguments :
--    p_incident_reference
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Public Access.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_incident_reference
  (p_incident_id           in    per_work_incidents.incident_id%TYPE
  ,p_incident_reference    in    per_work_incidents.incident_reference%TYPE
  ,p_object_version_number in    per_work_incidents.object_version_number%TYPE) is
--
 cursor csr_ref_unique is
 select null
 from per_work_incidents pwi
 where upper(pwi.incident_reference) = upper(p_incident_reference);
--
 l_proc  varchar2(72) := g_package||'chk_incident_reference';
 l_dummy  varchar2(30);
 l_api_updating      boolean;

--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  --
  if p_incident_reference is not null then

    -- This condition added to avoid : unique reference for US OSHA
    --
    IF (hr_api.get_legislation_context) <> 'US' then
    --

      l_api_updating := per_inc_shd.api_updating
          (p_incident_id            => p_incident_id
          ,p_object_version_number  => p_object_version_number);
      hr_utility.set_location(l_proc, 30);
      --
      -- Check if the incident is being inserted or updated.
      --
      if ((l_api_updating and
         nvl(per_inc_shd.g_old_rec.incident_reference, hr_api.g_varchar2)
         <> nvl(p_incident_reference, hr_api.g_varchar2))
        or (NOT l_api_updating))
      then
        --
        hr_utility.set_location(l_proc, 10);
        --
        -- validate unique reference.#1296633
        --
        open csr_ref_unique;
        fetch csr_ref_unique into l_dummy;
        if csr_ref_unique%found then
          close csr_ref_unique;
          hr_utility.set_message(800, 'HR_52889_INC_REF_NOT_UNIQUE');
          hr_utility.raise_error;
        end if;
        close csr_ref_unique;
      end if;
    --
    END IF ;
    --
  else
    hr_utility.set_message(800, 'HR_52890_INC_REF_NOT_NULL');
    hr_utility.raise_error;
  end if;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 3);
  --
end chk_incident_reference;
--
--
--  ---------------------------------------------------------------------------
--  |-------------------------<  chk_incident_type >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that an incident type exists in view hr_leg_lookups
--    where lookup_type is 'INCIDENT_TYPE' and enabled_flag is 'Y' and
--    effective_date is between the active dates (if they are not null).
--    Incident type is mandatory.
--
--  Pre-conditions:
--    Effective_date must be valid.
--
--  In Arguments:
--    p_incident_id
--    p_incident_type
--    p_effective_date
--
--  Post Success:
--    If a row does exist in hr_leg_lookups for the given incident then
--    processing continues.
--
--  Post Failure:
--    If a row does not exist in hr_leg_lookups for the given incident code then
--    an application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_incident_type
  (p_incident_id            in per_work_incidents.incident_id%TYPE,
  p_incident_type          in per_work_incidents.incident_type%TYPE,
  p_effective_date         in date) is
  --
   l_proc           varchar2(72)  :=  g_package||'chk_incident_type';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  --
  if p_incident_type is not null then
    --
    hr_utility.set_location(l_proc, 5);
    --
    -- Only proceed with validation if :
    -- a) Inserting or
    -- b) The value for incident type has changed
    --
    if ((p_incident_id is null) or
       ((p_incident_id is not null) and
         (per_inc_shd.g_old_rec.incident_type <> p_incident_type))) then
      --
      -- This condition is added for US OSHA specific
      --
      IF (hr_api.get_legislation_context) = 'US' then
      --
        if hr_api.not_exists_in_leg_lookups
          (p_effective_date        => p_effective_date
          ,p_lookup_type           => 'US_OSHA_CATEGORY'
          ,p_lookup_code           => p_incident_type
          )
        then
        --
          hr_utility.set_message(800, 'HR_52897_INC_INC_TYPE_INV');
          hr_utility.raise_error;
        --
        end if;
      END IF;
      --
      -- This condition is for non US legislations
      --
      --
      IF (hr_api.get_legislation_context) <> 'US' then
      --
        if hr_api.not_exists_in_leg_lookups
          (p_effective_date        => p_effective_date
          ,p_lookup_type           => 'INCIDENT_TYPE'
          ,p_lookup_code           => p_incident_type
          )
        then
        --
          hr_utility.set_message(800, 'HR_52897_INC_INC_TYPE_INV');
          hr_utility.raise_error;
        --
        end if;
        --
      END IF;
      --
    end if;
  --
  else
          hr_utility.set_location(l_proc, 15);
          hr_utility.set_message(800, 'HR_52898_INC_INC_TYPE_NULL');
          hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end chk_incident_type;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_related_incident_id >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates related incident is for the current person and the incident selected
--    has an incident date on or before the current incident date. The related incident
--    must be different to the current incident record.
--
--  Pre-conditions :
--    Format mask must be supplied.
--
--  In Arguments :
--    p_incident_id
--    p_related_incident_id
--    p_person_id
--    p_incident_date
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Public Access.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_related_incident_id
  (p_incident_id           in    per_work_incidents.incident_id%TYPE
  ,p_related_incident_id   in    per_work_incidents.related_incident_id%TYPE
  ,p_person_id             in    per_work_incidents.person_id%TYPE
  ,p_incident_date         in    per_work_incidents.incident_date%TYPE) is
--
 cursor csr_rel_inc is
 select null
 from per_work_incidents pwi
 where pwi.incident_id = p_related_incident_id
 and pwi.person_id = p_person_id
 and pwi.incident_date <= p_incident_date;
--
 l_proc  varchar2(72) := g_package||'chk_related_incident_id';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  --
  if ((p_incident_id is null) or
       ((p_incident_id is not null) and
         (per_inc_shd.g_old_rec.related_incident_id <> p_related_incident_id))) then
    --
    -- related inc cannot be current record
    if p_incident_id = p_related_incident_id then
      hr_utility.set_message(800, 'HR_289020_INC_INV_RELINC');
      hr_utility.raise_error;
    end if;
    --
    hr_utility.set_location(l_proc, 20);
    --
    open csr_rel_inc;
    if csr_rel_inc%notfound then
      close csr_rel_inc;
        -- related inc not found for the person
        -- before the current record's incident date.
      hr_utility.set_message(800, 'HR_289020_INC_INV_RELINC');
      hr_utility.raise_error;
    end if;
    close csr_rel_inc;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 3);
  --
end chk_related_incident_id;
--
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_org_notified_date >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that NOTIFIED_ORG_DATE does not pre-date INCIDENT_DATE.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_org_notified_date
--    p_incident_date
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_org_notified_date
  (p_org_notified_date       in    per_work_incidents.org_notified_date%TYPE
  ,p_incident_date           in    per_work_incidents.incident_date%TYPE
   ) is
--
 l_proc  varchar2(72) := g_package||'chk_org_notified_date';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  if p_org_notified_date is not null then
    if p_org_notified_date < p_incident_date then
          hr_utility.set_message(800, 'HR_289021_INC_INV_NODATE');
          hr_utility.raise_error;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 5);
  --
end chk_org_notified_date;
--
--
--  ---------------------------------------------------------------------------
--  |------------------------<  chk_over_time_flag >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that OVER_TIME_FLAG is NULL or 'Y' or 'N'.
--
--  Pre-conditions:
--
--  In Arguments:
--    p_over_time_flag
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_over_time_flag
  (p_over_time_flag        in per_work_incidents.over_time_flag%TYPE) is
  --
   l_proc           varchar2(72)  :=  g_package||'chk_over_time_flag';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  if p_over_time_flag is not null then
    if p_over_time_flag not in ('Y','N') then
      hr_utility.set_message(800, 'HR_289028_INC_INV_OTF');
      hr_utility.raise_error;
    end if;
  end if;
    --
  hr_utility.set_location('Leaving:'|| l_proc, 5);
--
end chk_over_time_flag;
--  ---------------------------------------------------------------------------
--  |-------------------------<  chk_at_work_flag >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that mandatory an at_work_flag is set, and exists in hr_leg_lookups
--    for the lookup_type 'AT_WORK_FLAG'.
--
--  Pre-conditions:
--
--  In Arguments:
--    p_incident_id
--    p_at_work_flag
--    p_effective_date
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_at_work_flag
  (p_incident_id            in per_work_incidents.incident_id%TYPE,
   p_at_work_flag          in per_work_incidents.at_work_flag%TYPE,
   p_effective_date         in date) is
  --
   l_proc           varchar2(72)  :=  g_package||'chk_at_work_flag';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
--
--  The following IF conditon added to eliminate this check for US OSHA.
--
IF hr_api.get_legislation_context <> 'US' then
--
  if p_at_work_flag is not null then
    --
    hr_utility.set_location(l_proc, 5);
    --
    -- Only proceed with validation if :
    -- a) Inserting or
    -- b) The value for at_work_flag has changed
    --
    if ((p_incident_id is null) or
       ((p_incident_id is not null) and
         (per_inc_shd.g_old_rec.at_work_flag <> p_at_work_flag))) then
       --
      if hr_api.not_exists_in_leg_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'AT_WORK_FLAG'
        ,p_lookup_code           => p_at_work_flag
        )
      then
      --
        hr_utility.set_message(800, 'HR_52899_INC_AWF_INV');
        hr_utility.raise_error;
      --
      end if;
    end if;
  else
    hr_utility.set_message(800, 'HR_52899_INC_AWF_INV');
    hr_utility.raise_error;
  end if;
--
END IF;
--
--
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
--
end chk_at_work_flag;
--
--
--  ---------------------------------------------------------------------------
--  |--------------------------<  chk_hazard_type >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that value for HAZARD_TYPE exists in hr_leg_lookups for the
--    lookup_type of 'HAZARD_TYPE'.
--
--  Pre-conditions:
--
--  In Arguments:
--    p_incident_id
--    p_hazard_type
--    p_effective_date
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_hazard_type
  (p_incident_id            in per_work_incidents.incident_id%TYPE,
   p_hazard_type            in per_work_incidents.at_work_flag%TYPE,
   p_effective_date         in date) is
  --
   l_proc           varchar2(72)  :=  g_package||'chk_hazard_type';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  if p_hazard_type is not null then
    --
    hr_utility.set_location(l_proc, 5);
    --
    -- Only proceed with validation if :
    -- a) Inserting or
    -- b) The value for hazard_type has changed
    --
    if ((p_incident_id is null) or
       ((p_incident_id is not null) and
         (per_inc_shd.g_old_rec.hazard_type <> p_hazard_type))) then
       --
      if hr_api.not_exists_in_leg_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'HAZARD_TYPE'
        ,p_lookup_code           => p_hazard_type
        )
      then
      --
        hr_utility.set_message(800, 'HR_289022_INC_HAZ_TYPE_INV');
        hr_utility.raise_error;
      --
      end if;
    end if;
  end if;
--
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
--
end chk_hazard_type;
--
--
--  ---------------------------------------------------------------------------
--  |--------------------------<  chk_injury_type >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that value for INJURY_TYPE exists in hr_leg_lookups for the
--    lookup_type of 'INJURY_TYPE'.
--
--  Pre-conditions:
--
--  In Arguments:
--    p_incident_id
--    p_injury_type
--    p_effective_date
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_injury_type
  (p_incident_id            in per_work_incidents.incident_id%TYPE,
   p_injury_type            in per_work_incidents.at_work_flag%TYPE,
   p_effective_date         in date) is
  --
   l_proc           varchar2(72)  :=  g_package||'chk_injury_type';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  if p_injury_type is not null then
    --
    hr_utility.set_location(l_proc, 5);
    --
    -- Only proceed with validation if :
    -- a) Inserting or
    -- b) The value for injury_type has changed
    --
    if ((p_incident_id is null) or
       ((p_incident_id is not null) and
         (per_inc_shd.g_old_rec.injury_type <> p_injury_type))) then
       --
      if hr_api.not_exists_in_leg_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'INJURY_TYPE'
        ,p_lookup_code           => p_injury_type
        )
      then
      --
        hr_utility.set_message(800, 'HR_289023_INC_INJ_TYPE_INV');
        hr_utility.raise_error;
      --
      end if;
    end if;
  end if;
--
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
--
end chk_injury_type;
--
--
--  ---------------------------------------------------------------------------
--  |--------------------------<  chk_diease_type >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that value for DISEASE_TYPE exists in hr_leg_lookups for the
--    lookup_type of 'DISEASE_TYPE'.
--
--  Pre-conditions:
--
--  In Arguments:
--    p_incident_id
--    p_disease_type
--    p_effective_date
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_disease_type
  (p_incident_id            in per_work_incidents.incident_id%TYPE,
   p_disease_type            in per_work_incidents.at_work_flag%TYPE,
   p_effective_date         in date) is
  --
   l_proc           varchar2(72)  :=  g_package||'chk_disease_type';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  if p_disease_type is not null then
    --
    hr_utility.set_location(l_proc, 5);
    --
    -- Only proceed with validation if :
    -- a) Inserting or
    -- b) The value for disease_type has changed
    --
    if ((p_incident_id is null) or
       ((p_incident_id is not null) and
         (per_inc_shd.g_old_rec.disease_type <> p_disease_type))) then
       --
      if hr_api.not_exists_in_leg_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'DISEASE_TYPE'
        ,p_lookup_code           => p_disease_type
        )
      then
      --
        hr_utility.set_message(800, 'HR_289024_INC_DIS_TYPE_INV');
        hr_utility.raise_error;
      --
      end if;
    end if;
  end if;
--
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
--
end chk_disease_type;
--
--
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_work_start_time >------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that WORK_START_TIME is valid time in 24HH:MI.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_work_start_time
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_work_start_time
  (p_work_start_time     in    per_work_incidents.work_start_time%TYPE
   ) is
--
 l_proc   varchar2(72) := g_package||'chk_work_start_time';
 l_value  varchar2(60) := p_work_start_time;
 l_output varchar2(60) := p_work_start_time;
 l_rgeflg varchar2(1);
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- 	Check work_start_time is in HH24:MI format
  --
  if p_work_start_time is not null then
    begin

      hr_chkfmt.checkformat(l_value, 'TIMES', l_output, NULL, NULL, 'Y', l_rgeflg, NULL);

      if p_work_start_time <> l_output then
        hr_utility.set_message(800, 'HR_289810_INC_INV_WKST_TIME');
        hr_utility.raise_error;
      end if;

     exception
       when others then
         hr_utility.set_message(801,'HR_7916_CHECK_FMT_HHMM');
         hr_utility.set_message_token('ARG_NAME', 'work_start_time');
	    hr_utility.set_message_token('ARG_VALUE', p_work_start_time);
         hr_utility.raise_error;
    end;

  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 5);
  --
end chk_work_start_time;
--
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_date_of_death >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that date_of_death does not pre-date incident_date.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_incident_date
--    p_date_of_death
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Externalised for public access.
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_date_of_death
  (p_incident_date         in   per_work_incidents.incident_date%TYPE
  ,p_date_of_death         in   per_work_incidents.date_of_death%TYPE
   ) is
--
l_proc   varchar2(72) := g_package||'chk_date_of_death';
l_dummy  varchar2(1);
l_api_updating boolean;
--
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- date_of_death cannot pre-date incident_date.
  --
  if nvl(p_date_of_death, p_incident_date) < p_incident_date then
     hr_utility.set_message(800, 'HR_289809_INC_INV_DEATH_DATE');
     hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 5);
  --
end chk_date_of_death;
--
--
--  ---------------------------------------------------------------------------
--  |-----------------------<  chk_hospitalized_flag >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that HOSPITALIZED_FLAG is NULL or 'Y' or 'N'.
--
--  Pre-conditions:
--
--  In Arguments:
--    p_hospitalized_flag
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_hospitalized_flag
  (p_hospitalized_flag        in per_work_incidents.hospitalized_flag%TYPE) is
  --
   l_proc           varchar2(72)  :=  g_package||'chk_hospitalized_flag';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  if p_hospitalized_flag is not null then
    if p_hospitalized_flag not in ('Y','N') then
      hr_utility.set_message(800, 'HR_289805_INC_INV_HOSP_FLAG');
      hr_utility.raise_error;
    end if;
  end if;
    --
  hr_utility.set_location('Leaving:'|| l_proc, 5);
--
end chk_hospitalized_flag;
--
--
--  ---------------------------------------------------------------------------
--  |-------------------------<  chk_privacy_issue >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that PRIVACY_ISSUE is NULL or 'Y' or 'N'.
--
--  Pre-conditions:
--
--  In Arguments:
--    p_privacy_issue
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_privacy_issue
  (p_privacy_issue        in per_work_incidents.privacy_issue%TYPE) is
  --
   l_proc           varchar2(72)  :=  g_package||'chk_privacy_issue';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  if p_privacy_issue is not null then
    if p_privacy_issue not in ('Y','N') then
      hr_utility.set_message(800, 'HR_289806_INC_INV_PRIV_ISSUE');
      hr_utility.raise_error;
    end if;
  end if;
    --
  hr_utility.set_location('Leaving:'|| l_proc, 5);
--
end chk_privacy_issue;
--
--
--  ---------------------------------------------------------------------------
--  |-------------------------<  chk_emergency_code >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that EMERGENCY_CODE is NULL or 'Y' or 'N'.
--
--  Pre-conditions:
--
--  In Arguments:
--    p_emergency_code
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_emergency_code
  (p_emergency_code        in per_work_incidents.emergency_code%TYPE) is
  --
   l_proc           varchar2(72)  :=  g_package||'chk_emergency_code';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  if p_emergency_code is not null then
    if p_emergency_code not in ('Y','N') then
      hr_utility.set_message(800, 'HR_289807_INC_INV_EMERG_CODE');
      hr_utility.raise_error;
    end if;
  end if;
    --
  hr_utility.set_location('Leaving:'|| l_proc, 5);
--
end chk_emergency_code;
--
--
--  ---------------------------------------------------------------------------
--  |--------------------< chk_person_reported_date_time >--------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that report_date does not pre-date incident_date and that
--    person_reported_by exists in per_all_people_f on the report_date.
--    Error if incident date and report date are the same
--    and report time is earlier than incident time.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_incident_id
--    p_incident_date
--    p_incident_time
--    p_person_reported_by
--    p_report_date
--    p_report_time
--    p_business_group_id
--    p_object_version_number
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Externalised for public access.
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_person_reported_date_time
  (p_incident_id           in   per_work_incidents.incident_id%TYPE
  ,p_incident_date         in   per_work_incidents.incident_date%TYPE
  ,p_incident_time         in   per_work_incidents.incident_time%TYPE
  ,p_person_reported_by    in   per_work_incidents.person_reported_by%TYPE
  ,p_report_date           in   per_work_incidents.report_date%TYPE
  ,p_report_time           in   per_work_incidents.report_time%TYPE
  ,p_business_group_id     in   per_all_people_f.business_group_id%TYPE
  ,p_object_version_number in   per_work_incidents.object_version_number%TYPE
   ) is
--
cursor c_person is
  select null
  from per_all_people_f paf
  where paf.person_id = p_person_reported_by
  and paf.business_group_id = p_business_group_id
  and nvl(p_report_date, paf.effective_start_date)
     between paf.effective_start_date and paf.effective_end_date;

--
l_proc   varchar2(72) := g_package||'chk_person_reported_date_time';
l_dummy  varchar2(1);
l_api_updating boolean;
--
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- report_date cannot pre-date incident_date.
  --
  if nvl(p_report_date, p_incident_date) < p_incident_date then
     hr_utility.set_message(800, 'HR_289030_INC_INV_RDATE');
     hr_utility.raise_error;
  end if;
  --
  -- Error if incident date and report date are the same
  -- and report time is earlier than incident time.
  --
  if p_report_date = p_incident_date then
    if p_report_time is not null and p_incident_time is not null then
      if to_date(p_report_time,'HH24:MI') < to_date(p_incident_time,'HH24:MI') then
        hr_utility.set_message(800, 'HR_289032_INC_INV_IRTIME');
        hr_utility.raise_error;
      end if;
    end if;
  end if;
  --
  --
  hr_utility.set_location(l_proc, 3);
  --
  l_api_updating := per_inc_shd.api_updating
      (p_incident_id            => p_incident_id
      ,p_object_version_number  => p_object_version_number);
  --
  if p_person_reported_by is not null then
    if ((l_api_updating and
       (nvl(per_inc_shd.g_old_rec.person_reported_by, hr_api.g_number)
       <> nvl(p_person_reported_by, hr_api.g_number)
       or nvl(per_inc_shd.g_old_rec.report_date, hr_api.g_date)
       <> nvl(p_report_date, hr_api.g_date)))
       or (NOT l_api_updating))
    then
       --
       open c_person;
       fetch c_person into l_dummy;
       if c_person%notfound then
         close c_person;
         -- Person reported by does not exist on the report date
         hr_utility.set_message(800, 'HR_289029_INC_INV_PREPBY');
         hr_utility.raise_error;
       end if;
       close c_person;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 5);
  --
end chk_person_reported_date_time;
--
--
--  ---------------------------------------------------------------------------
--  |--------------------------<  chk_report_method >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that REPORT_METHOD value exists in hr_lookups for the
--    lookup_type of 'PER_CM_MTHD'.
--
--  Pre-conditions:
--
--  In Arguments:
--    p_incident_id
--    p_report_method
--    p_effective_date
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_report_method
  (p_incident_id            in per_work_incidents.incident_id%TYPE,
   p_report_method          in per_work_incidents.report_method%TYPE,
   p_effective_date         in date) is
  --
   l_proc           varchar2(72)  :=  g_package||'chk_report_method';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  if p_report_method is not null then
    --
    hr_utility.set_location(l_proc, 5);
    --
    -- Only proceed with validation if :
    -- a) Inserting or
    -- b) The value for report_method has changed
    --
    if ((p_incident_id is null) or
       ((p_incident_id is not null) and
         (per_inc_shd.g_old_rec.report_method <> p_report_method))) then
       --
      if hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'PER_CM_MTHD'
        ,p_lookup_code           => p_report_method
        )
      then
      --
        hr_utility.set_message(800, 'HR_52391_PDM_INV_DLVRY_METHOD');
        hr_utility.raise_error;
      --
      end if;
    end if;
  end if;
--
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
--
end chk_report_method;
--
--  ---------------------------------------------------------------------------
--  |--------------------< chk_notified_hsrep_and_date >--------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that NOTIFIED_HSREP_DATE does not pre-date INCIDENT_DATE and that
--    NOTIFIED_HSREP_ID exists in PER_ALL_PEOPLE_F.PERSON_ID on the NOTIFIED_HSREP_DATE
--    and business group of the person with the incident.
--    Ensure the NOTIFIED_HSREP_DATE is null if NOTIFIED_HSREP_ID is null.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_incident_id
--    p_incident_date
--    p_notified_hsrep_id
--    p_notified_hsrep_date
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Externalised for public access.
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_notified_hsrep_and_date
  (p_incident_id           in    per_work_incidents.incident_id%TYPE
  ,p_incident_date         in    per_work_incidents.incident_date%TYPE
  ,p_notified_hsrep_id     in    per_work_incidents.notified_hsrep_id%TYPE
  ,p_notified_hsrep_date   in    per_work_incidents.notified_hsrep_date%TYPE
  ,p_business_group_id     in    per_all_people_f.business_group_id%TYPE
  ,p_object_version_number in    per_work_incidents.object_version_number%TYPE
   ) is
--
cursor c_person is
  select null
  from per_all_people_f paf
  where paf.person_id = p_notified_hsrep_id
  and paf.business_group_id = p_business_group_id
  and nvl(p_notified_hsrep_date, paf.effective_start_date)
     between paf.effective_start_date and paf.effective_end_date;

--
l_proc   varchar2(72) := g_package||'chk_notified_hsrep_and_date';
l_dummy  varchar2(1);
l_api_updating boolean;
--
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'incident_date'
    ,p_argument_value   => p_incident_date
    );
  --
  -- hsrep_date cannot pre-date incident_date.
  --
  if nvl(p_notified_hsrep_date, p_incident_date) < p_incident_date then
     hr_utility.set_message(800, 'HR_289033_INC_INV_HSDATE');
     hr_utility.raise_error;
  end if;
  --
  l_api_updating := per_inc_shd.api_updating
       (p_incident_id            => p_incident_id
       ,p_object_version_number  => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 5);

  if p_notified_hsrep_id is not null then
       --
    if ((l_api_updating and
       (nvl(per_inc_shd.g_old_rec.notified_hsrep_id, hr_api.g_number)
       <> nvl(p_notified_hsrep_id, hr_api.g_number)
       or nvl(per_inc_shd.g_old_rec.notified_hsrep_date, hr_api.g_date)
       <> nvl(p_notified_hsrep_date, hr_api.g_date)))
       or (NOT l_api_updating))
    then
       open c_person;
       fetch c_person into l_dummy;
       if c_person%notfound then
         close c_person;
         -- hsrep by does not exist in papf on the report date
         hr_utility.set_message(800, 'HR_289034_INC_INV_HSREP');
         hr_utility.raise_error;
       end if;
       close c_person;
    end if;
  elsif p_notified_hsrep_date is not null then
    hr_utility.set_message(800, 'HR_289035_INC_HSDATE_NULL');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 5);
  --
end chk_notified_hsrep_and_date;
--
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_notified_rep_org_date >---------------------|
--  ---------------------------------------------------------------------------
--
--  Description :
--    Validate that NOTIFIED_REP_ORG_ID is valid external organization for the
--    org_class 'REPBODY' and business group on the NOTIFIED_HSREP_DATE.
--
--    Validate that NOTIFIED_HSREP_ID exists in PER_ALL_PEOPLE_F.PERSON_ID for
--    the business_group on the NOTIFIED_HSREP_DATE. The NOTIFIED_HSREP_ID
--    should have the role of representative body, for the NOTIFIED_REP_ORG_ID
--    representative body on the NOTIFIED_HSREP_DATE.
--
--    Validate that NOTIFIED_REP_DATE does not pre-date INCIDENT_DATE, that
--    NOTIFIED_REP_DATE is null if NOTIFIED_REP_ID is null and that
--    NOTIFIED_REP_ID is null if NOTIFIED_REP_ORG_ID is null.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_incident_id
--    p_incident_date
--    p_notified_rep_org_id
--    p_notified_rep_id
--    p_notified_rep_date
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_notified_rep_org_date
  (p_incident_id           in    per_work_incidents.incident_id%TYPE
  ,p_incident_date         in    per_work_incidents.incident_date%TYPE
  ,p_notified_rep_org_id   in    per_work_incidents.notified_rep_org_id%TYPE
  ,p_notified_rep_id       in    per_work_incidents.notified_rep_id%TYPE
  ,p_notified_rep_date     in    per_work_incidents.notified_rep_date%TYPE
  ,p_business_group_id     in    per_all_people_f.business_group_id%TYPE
  ,p_object_version_number in    per_work_incidents.object_version_number%TYPE
   ) is
--
-- get valid organizations with class of rep body.
--
cursor c_org is
  select null
  from hr_all_organization_units hou
  where  hou.organization_id = p_notified_rep_org_id
   and hou.internal_external_flag = 'EXT'
   and hou.business_group_id = p_business_group_id
   and nvl(p_notified_rep_date, hou.date_from) between hou.date_from
                      and nvl(hou.date_to,hr_general.end_of_time)
   and p_notified_rep_org_id in (select hoi.organization_id
                                 from hr_organization_information hoi
                                 where hoi.org_information_context = 'CLASS'
                                 and hoi.org_information1 = 'REPBODY'
                                 and hoi.org_information2 = 'Y');
--
-- get person with roles of rep_body representative
-- on the report date.
--
cursor c_person is
  select null
  from per_all_people_f paf, per_roles rol
  where paf.person_id = p_notified_rep_id
  and paf.business_group_id = p_business_group_id
  and paf.person_id = rol.person_id
  and rol.organization_id = p_notified_rep_org_id
  and nvl(p_notified_rep_date, paf.effective_start_date)
     between paf.effective_start_date and paf.effective_end_date
  and nvl(p_notified_rep_date, rol.start_date)
     between rol.start_date and nvl(rol.end_date,hr_general.end_of_time);
--
--
l_proc   varchar2(72) := g_package||'chk_notified_rep_org_date';
l_dummy  varchar2(1);
l_api_updating  boolean;
--
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'incident_date'
    ,p_argument_value   => p_incident_date
    );
  --
  if p_notified_rep_date is not null then
    --
    -- notified_rep_date cannot pre-date incident_date.
    --
    if p_notified_rep_date < p_incident_date then
      hr_utility.set_message(800, 'HR_289036_INC_INV_NRBDATE');
      hr_utility.raise_error;
    end if;
    --
    -- notified_rep_date must be null if notified_hsrep_id is null.
    --
    if p_notified_rep_id is null then
      hr_utility.set_message(800, 'HR_289037_INC_NRBDATE_NULL');
      hr_utility.raise_error;
    end if;
  end if;
  --
  if p_notified_rep_id is not null then
    --
    -- notified_rep_id must be null if notified_rep_org_id is null.
    --
    if p_notified_rep_org_id is null then
      hr_utility.set_message(800, 'HR_289038_INC_NREP_NULL');
      hr_utility.raise_error;
    end if;
  end if;
  --
  l_api_updating := per_inc_shd.api_updating
        (p_incident_id            => p_incident_id
        ,p_object_version_number  => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 5);
  --
  -- Validate the rep_body org supplied.
  --
  if p_notified_rep_org_id is not null then
    if ((l_api_updating and
       nvl(per_inc_shd.g_old_rec.notified_rep_org_id, hr_api.g_number)
       <> nvl(p_notified_rep_org_id, hr_api.g_number))
       or (NOT l_api_updating))
    then
      open c_org;
      fetch c_org into l_dummy;
      if c_org%notfound then
        close c_org;
        -- repbody org does not exist, so error.
        hr_utility.set_message(800, 'HR_289039_INC_INV_REPBODY');
        hr_utility.raise_error;
      end if;
      close c_org;
    end if;
  end if;
  --
  hr_utility.set_location(l_proc, 15);
  --
  -- Validate the representative exists for the rep body.
  --
  if p_notified_rep_id is not null then
    if ((l_api_updating and
      nvl(per_inc_shd.g_old_rec.notified_rep_id, hr_api.g_number)
      <> nvl(p_notified_rep_id, hr_api.g_number))
      or (NOT l_api_updating))
    then
      open c_person;
      fetch c_person into l_dummy;
      if c_person%notfound then
        close c_person;
        -- repbody org does not exist, so error.
        hr_utility.set_message(800, 'HR_289040_INC_INV_REP');
        hr_utility.raise_error;
      end if;
      close c_person;
    end if;
  end if;
  --
  --
  hr_utility.set_location(l_proc,25);
  --
end chk_notified_rep_org_date;
--
--
--  ---------------------------------------------------------------------------
--  |-------------------< chk_hospital_doctor_details >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description :
--
--    Validate that HOSPITAL_DETAILS and DOCTOR_NAME are null if
--    treatment_received_flag is null.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_treatment_received_flag
--    p_hospital_details
--    p_doctor_name
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_hospital_doctor_details
  (p_treatment_received_flag       in    per_work_incidents.treatment_received_flag%TYPE
  ,p_hospital_details              in    per_work_incidents.hospital_details%TYPE
  ,p_doctor_name                   in    per_work_incidents.doctor_name%TYPE
   ) is
--
 l_proc   varchar2(72) := g_package||'chk_hospital_doctor_details';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  if p_treatment_received_flag is not null and p_treatment_received_flag not in ('Y','N') then
    hr_utility.set_message(800, 'HR_289027_INC_TREATMENT_INV');
    hr_utility.raise_error;
  end if;
  --
  -- Following IF (..) <> 'US' condition is added for OSHA localization.
  --
  IF (hr_api.get_legislation_context) <> 'US' then
    if p_treatment_received_flag <> 'Y' then
      if p_hospital_details is not null then
         hr_utility.set_message(800, 'HR_289025_INC_HOSP_NULL');
         hr_utility.raise_error;
      elsif p_doctor_name is not null then
         hr_utility.set_message(800, 'HR_289026_INC_DOC_NULL');
         hr_utility.raise_error;
      end if;
    end if;
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 5);
  --
end chk_hospital_doctor_details;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_report_time >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that REPORT_TIME is valid time in 24HH:MI.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_incident_report
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_report_time
  (p_report_time       in    per_work_incidents.report_time%TYPE
   ) is
--
 l_proc   varchar2(72) := g_package||'chk_report_time';
 l_value  varchar2(60) := p_report_time;
 l_output varchar2(60) := p_report_time;
 l_rgeflg varchar2(1);
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- 	Check report_time is in HH24:MI format
  --
  if p_report_time is not null then
    begin

      hr_chkfmt.checkformat(l_value, 'TIMES', l_output, NULL, NULL, 'Y', l_rgeflg, NULL);

      if p_report_time <> l_output then
        hr_utility.set_message(800, 'HR_289031_INC_INV_RTIME');
        hr_utility.raise_error;
      end if;

     exception
       when others then
         hr_utility.set_message(801,'HR_7916_CHECK_FMT_HHMM');
         hr_utility.set_message_token('ARG_NAME', 'report_time');
	    hr_utility.set_message_token('ARG_VALUE', p_report_time);
         hr_utility.raise_error;
    end;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 5);
  --
end chk_report_time;
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_assignment_id >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description :
--
--    Validate that ASSIGNMENT_ID exsts for the person on the incident_date
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_incident_id
--    p_assignment_id
--    p_person_id
--    p_incident_date
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_assignment_id
  (p_incident_id         in    per_work_incidents.incident_id%TYPE,
   p_assignment_id       in    per_work_incidents.assignment_id%TYPE,
   p_person_id           in    per_work_incidents.person_id%TYPE,
   p_incident_date       in    per_work_incidents.incident_date%TYPE
   ) is
--
 l_proc  varchar2(72) := g_package||'chk_assignment_id';
 l_dummy number;
--
 cursor csr_asg is
    select null
    from per_all_assignments_f asg
    where asg.assignment_id = p_assignment_id
    and asg.person_id = p_person_id
    and p_incident_date between asg.effective_start_date
                         and asg.effective_end_date;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'person_id'
    ,p_argument_value => p_person_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'incident_date'
    ,p_argument_value => p_incident_date
    );
  --
  if p_assignment_id is not null then
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
  --
    if ((p_incident_id is null) or
       ((p_incident_id is not null) and
         ((per_inc_shd.g_old_rec.assignment_id <> p_assignment_id)
         or (per_inc_shd.g_old_rec.incident_date <> p_incident_date)))) then
     --
     -- Check that the assignment exists
     -- for the eprson on the incident_date.
     --
       open csr_asg;
       fetch csr_asg into l_dummy;
       if csr_asg%notfound then
          close csr_asg;
          hr_utility.set_message(800, 'HR_289041_INC_ASG_FK_NOT_FOUND');
          hr_utility.raise_error;
       end if;
       close csr_asg;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
  --
end chk_assignment_id;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_compensation_details  >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Description :
--
--    Validate that ASSIGNMENT_ID exsts for the person on the incident_date
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_incident_id
--    p_assignment_id
--    p_person_id
--    p_incident_date
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_compensation_details
  (p_incident_id                 in    per_work_incidents.incident_id%TYPE,
   p_compensation_currency       in    per_work_incidents.compensation_currency%TYPE,
   p_compensation_amount         in    per_work_incidents.compensation_amount%TYPE,
   p_compensation_date           in    per_work_incidents.compensation_date%TYPE,
   p_incident_date               in    per_work_incidents.incident_date%TYPE
   ) is
--
 l_proc  varchar2(72) := g_package||'chk_compensation_details';
 l_dummy number;
 l_output varchar2(60);
 l_value   varchar2(60);
 l_reg   varchar2(60);
--
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- ensure both currency and amount are not null
  -- if either is not null.
  if (p_compensation_currency is null and p_compensation_amount is not null)
     or (p_compensation_currency is not null and p_compensation_amount is null) then
    hr_utility.set_message(800, 'HR_289043_INC_CURR_NULL');
    hr_utility.raise_error;
  end if;
  --
  -- compensation_date cannot pre-date incident_date.
  --
  if p_compensation_date < p_incident_date then
    hr_utility.set_message(800, 'HR_289045_INC_INV_CDATE');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- check currency_code and currency_amount are is valid.
  --
  if ((p_incident_id is null) or
     ((p_incident_id is not null) and
       ((per_inc_shd.g_old_rec.compensation_currency <> p_compensation_currency)
       or (per_inc_shd.g_old_rec.compensation_amount <> p_compensation_amount)))) then
     --
    begin
      --
     l_value := to_char(p_compensation_amount);
     l_output := to_char(p_compensation_amount);
      --
     hr_chkfmt.checkformat(l_value, 'MONEY', l_output, NULL, NULL, 'Y', l_reg, p_compensation_currency);

     exception
       when others then
        hr_utility.set_message(801,'HR_7912_CHECK_FMT_MONEY');
        hr_utility.set_message_token('ARG_NAME', 'compensation amount');
        hr_utility.set_message_token('ARG_VALUE', l_value);
        hr_utility.raise_error;
    end;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
  --
end chk_compensation_details;
--
--
--  ---------------------------------------------------------------------------
--  |-------------------< chk_absence_exists >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description :
--
--    Validate that HOSPITAL_DETAILS and DOCTOR_NAME are null if
--    treatment_received_flag is null.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_treatment_received_flag
--    p_hospital_details
--    p_doctor_name
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_absence_exists_flag
  (p_absence_exists_flag       in    per_work_incidents.absence_exists_flag%TYPE
   ) is
--
 l_proc   varchar2(72) := g_package||'chk_absence_exists_flag';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  if p_absence_exists_flag is not null and p_absence_exists_flag not in ('Y','N') then
    hr_utility.set_message(800, 'HR_289042_INC_ABS_EXISTS_INV');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 5);
  --
end chk_absence_exists_flag;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_object_version_number >-----------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Checks that the OVN passed is not null on update and delete.
--
--  Pre-conditions :
--    None.
--
--  In Arguments :
--    p_object_version_number
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_object_version_number
  (
    p_object_version_number in  per_phones.object_version_number%TYPE
  )	is
--
 l_proc  varchar2(72) := g_package||'chk_object_version_number';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- 	Check mandatory parameters have been set
  --
   hr_api.mandatory_arg_error
    (p_api_name	        => l_proc
    ,p_argument	        => 'object_version_number'
    ,p_argument_value	  => p_object_version_number
    );
    --
  hr_utility.set_location(' Leaving:'||l_proc, 3);
  --
end chk_object_version_number;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_inc_shd.g_rec_type
  ) is
--
  cursor csr_bg is
    select business_group_id
    from per_all_people_f
    where person_id = p_rec.person_id;
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_bg_id per_all_people_f.business_group_id%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Call parent person table's set_security_group_id function
  per_per_bus.set_security_group_id(p_person_id => to_number(p_rec.person_id));
  --
  -- Validate person id
  --
  per_inc_bus.chk_person_id
       (p_incident_id    => p_rec.incident_id,
        p_person_id      => p_rec.person_id,
        p_effective_date => p_effective_date);
  --
  -- Validate incident date
  --
  per_inc_bus.chk_incident_date
        (p_incident_date  => p_rec.incident_date);
  --
  -- Validate incident time
  --
  per_inc_bus.chk_incident_time
        (p_incident_time  => p_rec.incident_time);
  --
  -- Start of changes for additional columns
  --
  -- Validate hospitalized flag
  --
  per_inc_bus.chk_hospitalized_flag
        (p_hospitalized_flag  => p_rec.hospitalized_flag);

  --
  -- Validate privacy issue
  --
  per_inc_bus.chk_privacy_issue
        (p_privacy_issue  => p_rec.privacy_issue);
  --
  -- Validate emergency_code
  --
  per_inc_bus.chk_emergency_code
        (p_emergency_code  => p_rec.emergency_code);
  --
  -- Validate date of death
  --
  per_inc_bus.chk_date_of_death
        (p_incident_date  => p_rec.incident_date
        ,p_date_of_death  => p_rec.date_of_death);
  --
  -- Validate work start time
  --
  per_inc_bus.chk_work_start_time
        (p_work_start_time  => p_rec.work_start_time);

  --
  -- End of changes for additional columns
  --
  -- Validate incident reference
  --
  per_inc_bus.chk_incident_reference(p_incident_id           => p_rec.incident_id,
                                     p_incident_reference    => p_rec.incident_reference,
                                     p_object_version_number => p_rec.object_version_number);
  --
  -- Validate incident type
  --
  per_inc_bus.chk_incident_type(p_incident_id        => p_rec.incident_id,
                                p_incident_type      => p_rec.incident_type,
                                p_effective_date     => p_effective_date);
  --
  -- Validate Over Time Flag
  --
  per_inc_bus.chk_over_time_flag
        (p_over_time_flag  => p_rec.over_time_flag);

  --
  -- Validate related incident
  --
  per_inc_bus.chk_related_incident_id(p_incident_id         => p_rec.incident_id,
                                      p_related_incident_id => p_rec.related_incident_id,
                                      p_person_id           => p_rec.person_id,
                                      p_incident_date       => p_rec.incident_date);
  --
  -- Validate Org Notified Date
  --
  per_inc_bus.chk_org_notified_date(p_org_notified_date     => p_rec.org_notified_date,
                                    p_incident_date         => p_rec.incident_date);
  --
  -- Validate At Work Flag
  --
   per_inc_bus.chk_at_work_flag(p_incident_id           => p_rec.incident_id,
                                p_at_work_flag          => p_rec.at_work_flag,
                                p_effective_date        => p_effective_date);
  --
  -- Validate Hazard Type
  --
  per_inc_bus.chk_hazard_type(p_incident_id        => p_rec.incident_id,
                              p_hazard_type      => p_rec.hazard_type,
                              p_effective_date     => p_effective_date);

  --
  -- Validate Injury Type
  --
  per_inc_bus.chk_injury_type(p_incident_id        => p_rec.incident_id,
                                p_injury_type      => p_rec.injury_type,
                                p_effective_date     => p_effective_date);

  --
  -- Validate Disease Type
  --
  per_inc_bus.chk_disease_type(p_incident_id        => p_rec.incident_id,
                                p_disease_type      => p_rec.disease_type,
                                p_effective_date     => p_effective_date);

  --
  -- Validate Hopsital Details and Doctor Name
  --
  per_inc_bus.chk_hospital_doctor_details
	  (p_treatment_received_flag  => p_rec.treatment_received_flag,
           p_hospital_details         => p_rec.hospital_details,
           p_doctor_name              => p_rec.doctor_name);
  --
  -- Validate report time
  --
  per_inc_bus.chk_report_time
        (p_report_time  => p_rec.report_time);
  --
  -- Validate person reported by, report date and time
  --
  open csr_bg;
  fetch csr_bg into l_bg_id;
  close csr_bg;
  per_inc_bus.chk_person_reported_date_time
        (p_incident_id        =>    p_rec.incident_id
        ,p_incident_date      =>    p_rec.incident_date
        ,p_incident_time      =>    p_rec.incident_time
        ,p_person_reported_by =>    p_rec.person_reported_by
        ,p_report_date        =>    p_rec.report_date
        ,p_report_time        =>    p_rec.report_time
        ,p_business_group_id  =>    l_bg_id
        ,p_object_version_number =>    p_rec.object_version_number);
  --
  -- Validate report method
  --
  per_inc_bus.chk_report_method(p_incident_id        => p_rec.incident_id,
                                p_report_method      => p_rec.report_method,
                                p_effective_date     => p_effective_date);
  --
  -- Validate notified_hsrep_id, notified_hsrep_date
  --
  per_inc_bus.chk_notified_hsrep_and_date
  (p_incident_id           =>    p_rec.incident_id
  ,p_incident_date         =>    p_rec.incident_date
  ,p_notified_hsrep_id     =>    p_rec.notified_hsrep_id
  ,p_notified_hsrep_date   =>    p_rec.notified_hsrep_date
  ,p_business_group_id     =>    l_bg_id
  ,p_object_version_number =>    p_rec.object_version_number);
  --
  -- Validate notified_rep_org, notified_rep_id, notified_rep_date
  --
  per_inc_bus.chk_notified_rep_org_date
  (p_incident_id           =>    p_rec.incident_id
  ,p_incident_date         =>    p_rec.incident_date
  ,p_notified_rep_org_id   =>    p_rec.notified_rep_org_id
  ,p_notified_rep_id       =>    p_rec.notified_rep_id
  ,p_notified_rep_date     =>    p_rec.notified_rep_date
  ,p_business_group_id     =>    l_bg_id
  ,p_object_version_number =>    p_rec.object_version_number);
 --
 -- Validate compensation details
 --
  per_inc_bus.chk_compensation_details
  (p_incident_id                 =>    p_rec.incident_id,
   p_compensation_currency       =>    p_rec.compensation_currency,
   p_compensation_amount         =>    p_rec.compensation_amount,
   p_compensation_date           =>    p_rec.compensation_date,
   p_incident_date               =>    p_rec.incident_date);
  --
  -- Validate assignment_id
  --
  per_inc_bus.chk_assignment_id(p_incident_id      =>    p_rec.incident_id
                               ,p_assignment_id    =>    p_rec.assignment_id
                               ,p_person_id        =>    p_rec.person_id
                               ,p_incident_date    =>    p_rec.incident_date);
  --
  -- Check absence exists flag
  --
  per_inc_bus.chk_absence_exists_flag
  (p_absence_exists_flag       =>    p_rec.absence_exists_flag);
  --
  -- Validate Developer Descriptive Flexfield
  --
  per_inc_bus.chk_ddf(p_rec);
  --
  -- Validate Descriptive Flexfield
  --
  per_inc_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_inc_shd.g_rec_type
  ) is
--
  cursor csr_bg is
    select business_group_id
    from per_all_people_f
    where person_id = p_rec.person_id;
--
  l_bg_id per_all_people_f.business_group_id%TYPE;
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  -- Call parent person table's set_security_group_id function
  per_per_bus.set_security_group_id(p_person_id => to_number(p_rec.person_id));
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
     ,p_rec                        => p_rec);
  --
  -- Validate person id
  --
  per_inc_bus.chk_person_id
       (p_incident_id    => p_rec.incident_id,
        p_person_id      => p_rec.person_id,
        p_effective_date => p_effective_date);
  --
  -- Validate incident date
  --
  per_inc_bus.chk_incident_date
        (p_incident_date  => p_rec.incident_date);
  --
  -- Validate incident time
  --
  per_inc_bus.chk_incident_time
        (p_incident_time  => p_rec.incident_time);
  --
  -- Validate incident reference
  --
  per_inc_bus.chk_incident_reference(p_incident_id           => p_rec.incident_id,
                                     p_incident_reference    => p_rec.incident_reference,
                                     p_object_version_number => p_rec.object_version_number);
  --
  -- Validate incident type
  --
  per_inc_bus.chk_incident_type
     (p_incident_id        => p_rec.incident_id,
      p_incident_type      => p_rec.incident_type,
      p_effective_date     => p_effective_date);

  --
  -- Validate Over Time Flag
  --
  per_inc_bus.chk_over_time_flag
        (p_over_time_flag  => p_rec.over_time_flag);

  --
  -- Validate related incident
  --
  per_inc_bus.chk_related_incident_id(p_incident_id         => p_rec.incident_id,
                                      p_related_incident_id => p_rec.related_incident_id,
                                      p_person_id           => p_rec.person_id,
                                      p_incident_date       => p_rec.incident_date);
  --
  -- Validate Org Notified Date
  --
  per_inc_bus.chk_org_notified_date(p_org_notified_date     => p_rec.org_notified_date,
                                    p_incident_date         => p_rec.incident_date);
  --
  -- Validate At Work flag
  --
  per_inc_bus.chk_at_work_flag(p_incident_id           => p_rec.incident_id,
                               p_at_work_flag          => p_rec.at_work_flag,
                               p_effective_date        => p_effective_date);
  --
  -- Validate Hazard Type
  --
  per_inc_bus.chk_hazard_type(p_incident_id        => p_rec.incident_id,
                              p_hazard_type      => p_rec.hazard_type,
                              p_effective_date     => p_effective_date);
  --
  -- Validate Injury Type
  --
  per_inc_bus.chk_injury_type(p_incident_id        => p_rec.incident_id,
                                p_injury_type      => p_rec.injury_type,
                                p_effective_date     => p_effective_date);
  --
  -- Validate Disease Type
  --
  per_inc_bus.chk_disease_type(p_incident_id        => p_rec.incident_id,
                                p_disease_type      => p_rec.disease_type,
                                p_effective_date     => p_effective_date);
  --
  -- Validate Hopsital Details and Doctor Name
  --
  per_inc_bus.chk_hospital_doctor_details
  	  (p_treatment_received_flag  => p_rec.treatment_received_flag,
           p_hospital_details         => p_rec.hospital_details,
           p_doctor_name              => p_rec.doctor_name);
  --
  -- Validate report time
  --
  per_inc_bus.chk_report_time
        (p_report_time  => p_rec.report_time);
  --
  -- Validate person reported by, report date and time
  --
  open csr_bg;
  fetch csr_bg into l_bg_id;
  close csr_bg;
  per_inc_bus.chk_person_reported_date_time
        (p_incident_id           =>    p_rec.incident_id
        ,p_incident_date         =>    p_rec.incident_date
        ,p_incident_time         =>    p_rec.incident_time
        ,p_person_reported_by    =>    p_rec.person_reported_by
        ,p_report_date           =>    p_rec.report_date
        ,p_report_time           =>    p_rec.report_time
        ,p_business_group_id     =>    l_bg_id
        ,p_object_version_number =>    p_rec.object_version_number);
  --
  -- Validate report method
  --
  per_inc_bus.chk_report_method(p_incident_id        => p_rec.incident_id,
                                p_report_method      => p_rec.report_method,
                                p_effective_date     => p_effective_date);
  --
  -- Validate notified_hsrep_id, notified_hsrep_date
  --
  per_inc_bus.chk_notified_hsrep_and_date
  (p_incident_id           =>    p_rec.incident_id
  ,p_incident_date         =>    p_rec.incident_date
  ,p_notified_hsrep_id     =>    p_rec.notified_hsrep_id
  ,p_notified_hsrep_date   =>    p_rec.notified_hsrep_date
  ,p_business_group_id     =>    l_bg_id
  ,p_object_version_number =>    p_rec.object_version_number);
  --
  --
  -- Validate notified_rep_org, notified_rep_id, notified_rep_date
  --
  per_inc_bus.chk_notified_rep_org_date
  (p_incident_id           =>    p_rec.incident_id
  ,p_incident_date         =>    p_rec.incident_date
  ,p_notified_rep_org_id   =>    p_rec.notified_rep_org_id
  ,p_notified_rep_id       =>    p_rec.notified_rep_id
  ,p_notified_rep_date     =>    p_rec.notified_rep_date
  ,p_business_group_id     =>    l_bg_id
  ,p_object_version_number =>    p_rec.object_version_number);
  --
 -- Validate compensation details
 --
  per_inc_bus.chk_compensation_details
  (p_incident_id                 =>    p_rec.incident_id,
   p_compensation_currency       =>    p_rec.compensation_currency,
   p_compensation_amount         =>    p_rec.compensation_amount,
   p_compensation_date           =>    p_rec.compensation_date,
   p_incident_date               =>    p_rec.incident_date);
  --
  -- Validate assignment_id
  --
  per_inc_bus.chk_assignment_id(p_incident_id      =>    p_rec.incident_id
                               ,p_assignment_id    =>    p_rec.assignment_id
                               ,p_person_id        =>    p_rec.person_id
                               ,p_incident_date    =>    p_rec.incident_date);
  --
  -- Check absence exists flag
  --
  per_inc_bus.chk_absence_exists_flag
  (p_absence_exists_flag       =>    p_rec.absence_exists_flag);
  --
  -- Validate Developer Descriptive Flexfield
  --
  per_inc_bus.chk_ddf(p_rec);
  --
  -- Validate Descriptive Flexfield
  --
  per_inc_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_inc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Validate Object Version Number
  --
  chk_object_version_number
     (p_object_version_number => p_rec.object_version_number);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
--
--******************************************************************************
--* Returns the reference for the supplied incident_id
--******************************************************************************
function GET_INCIDENT_REFERENCE (p_incident_id in number) return varchar2 is
--
cursor csr_incident is
        select incident_reference
        from    per_work_incidents pwi
        where   pwi.incident_id = p_incident_id;
--
v_reference   per_work_incidents.incident_reference%TYPE := null;
--
begin
--
-- Only open the cursor if the parameters are going to retrieve anything
--
if p_incident_id is not null then
  --
  open csr_incident;
  fetch csr_incident into v_reference;
  close csr_incident;
  --
end if;
--
return v_reference;
--
end GET_INCIDENT_REFERENCE;
--
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_osha_numbers >--------------------------|
-- ----------------------------------------------------------------------------
--
Procedure create_osha_numbers(p_number_of_workers in number default 1,
                              p_current_worker    in number default 1) is
--
--cursor selects all US business groups, which are not yet have rows in
--PER_US_OSHA_NUMBERS table.
--
  cursor csr_us_bg is
         select business_group_id
         from   hr_all_organization_units units
               ,hr_organization_information org
         where  units.organization_id = org.organization_id
         --and    units.type            = 'BG'
         and    mod(business_group_id,p_number_of_workers) = p_current_worker-1
         and    org.org_information_context = 'Business Group Information'
         and    org.org_information9 = 'US'
         and    not exists (select null from per_us_osha_numbers osha
                            where osha.business_group_id = units.business_group_id
                            and   osha.case_year         = 1900
                            );

--
  l_proc  varchar2(72) := g_package||'delete_validate';
--

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Loop for all the existing US business Groups
  --
  for i in csr_us_bg loop
    --
    -- Loop for all the years until End of Time (4712)
    --
    -- Changed to 2200 for now
    --
    for x in 1900 .. 2200 loop
      insert into per_us_osha_numbers(
                      case_year,
                      business_group_id,
                      next_value,
                      last_update_date,
                      last_updated_by,
                      last_update_login,
                      created_by,
                      creation_date)
              values (x,
                      i.business_group_id,
                      1,
                      trunc(sysdate),
                      -1,
                      0,
                      -1,
                      trunc(sysdate)
                      );
      --commented since inserting only 300 records.
      --if mod(x,600) = 0 then
      -- commit;
      --end if;
      --
    end loop;  -- End of Time Loop (changed until 2200 only)
    commit;
    --
  end loop;  -- Business Groups Loop
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End create_osha_numbers;
--
--

end per_inc_bus;

/
