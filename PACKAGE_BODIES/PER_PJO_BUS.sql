--------------------------------------------------------
--  DDL for Package Body PER_PJO_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PJO_BUS" as
/* $Header: pepjorhi.pkb 120.0.12010000.2 2008/08/06 09:28:19 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pjo_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_previous_job_id             number         default null;
g_previous_employer_id        number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_previous_job_id                      in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_previous_jobs pjo
         , per_all_people_f ppf
         , per_previous_employers pem
     where pjo.previous_job_id = p_previous_job_id
     and   pbg.business_group_id = ppf.business_group_id
     and   pem.person_id = ppf.person_id
     and   pem.previous_employer_id = pjo.previous_employer_id;
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
    ,p_argument           => 'previous_job_id'
    ,p_argument_value     => p_previous_job_id
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
        => nvl(p_associated_column1,'PREVIOUS_JOB_ID')
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
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_previous_job_id                      in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
     select pbg.legislation_code
     from  per_business_groups     pbg
         , per_previous_jobs       pjo
         , per_all_people_f        ppf
         , per_previous_employers  pem
     where pjo.previous_job_id      = p_previous_job_id
     and   ppf.business_group_id    = pbg.business_group_id(+)
     and   pem.person_id            = ppf.person_id(+)
     and   pjo.previous_employer_id = pem.previous_employer_id;
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
    ,p_argument           => 'previous_job_id'
    ,p_argument_value     => p_previous_job_id
    );
  --
  if ( nvl(per_pjo_bus.g_previous_job_id, hr_api.g_number)
       = p_previous_job_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_pjo_bus.g_legislation_code;
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
    per_pjo_bus.g_previous_job_id             := p_previous_job_id;
    per_pjo_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in per_pjo_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.previous_job_id is not null)  and (
    nvl(per_pjo_shd.g_old_rec.pjo_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information_category, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_information1, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information1, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_information2, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information2, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_information3, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information3, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_information4, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information4, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_information5, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information5, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_information6, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information6, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_information7, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information7, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_information8, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information8, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_information9, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information9, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_information10, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information10, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_information11, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information11, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_information12, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information12, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_information13, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information13, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_information14, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information14, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_information15, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information15, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_information16, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information16, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_information17, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information17, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_information18, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information18, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_information19, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information19, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_information20, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information20, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_information21, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information21, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_information22, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information22, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_information23, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information23, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_information24, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information24, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_information25, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information25, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_information26, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information26, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_information27, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information27, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_information28, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information28, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_information29, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information29, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_information30, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_information30, hr_api.g_varchar2) ))
    or (p_rec.previous_job_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'Previous Job Developer DF'
      ,p_attribute_category              => p_rec.pjo_information_category
      ,p_attribute1_name                 => 'PJO_INFORMATION1'
      ,p_attribute1_value                => p_rec.pjo_information1
      ,p_attribute2_name                 => 'PJO_INFORMATION2'
      ,p_attribute2_value                => p_rec.pjo_information2
      ,p_attribute3_name                 => 'PJO_INFORMATION3'
      ,p_attribute3_value                => p_rec.pjo_information3
      ,p_attribute4_name                 => 'PJO_INFORMATION4'
      ,p_attribute4_value                => p_rec.pjo_information4
      ,p_attribute5_name                 => 'PJO_INFORMATION5'
      ,p_attribute5_value                => p_rec.pjo_information5
      ,p_attribute6_name                 => 'PJO_INFORMATION6'
      ,p_attribute6_value                => p_rec.pjo_information6
      ,p_attribute7_name                 => 'PJO_INFORMATION7'
      ,p_attribute7_value                => p_rec.pjo_information7
      ,p_attribute8_name                 => 'PJO_INFORMATION8'
      ,p_attribute8_value                => p_rec.pjo_information8
      ,p_attribute9_name                 => 'PJO_INFORMATION9'
      ,p_attribute9_value                => p_rec.pjo_information9
      ,p_attribute10_name                => 'PJO_INFORMATION10'
      ,p_attribute10_value               => p_rec.pjo_information10
      ,p_attribute11_name                => 'PJO_INFORMATION11'
      ,p_attribute11_value               => p_rec.pjo_information11
      ,p_attribute12_name                => 'PJO_INFORMATION12'
      ,p_attribute12_value               => p_rec.pjo_information12
      ,p_attribute13_name                => 'PJO_INFORMATION13'
      ,p_attribute13_value               => p_rec.pjo_information13
      ,p_attribute14_name                => 'PJO_INFORMATION14'
      ,p_attribute14_value               => p_rec.pjo_information14
      ,p_attribute15_name                => 'PJO_INFORMATION15'
      ,p_attribute15_value               => p_rec.pjo_information15
      ,p_attribute16_name                => 'PJO_INFORMATION16'
      ,p_attribute16_value               => p_rec.pjo_information16
      ,p_attribute17_name                => 'PJO_INFORMATION17'
      ,p_attribute17_value               => p_rec.pjo_information17
      ,p_attribute18_name                => 'PJO_INFORMATION18'
      ,p_attribute18_value               => p_rec.pjo_information18
      ,p_attribute19_name                => 'PJO_INFORMATION19'
      ,p_attribute19_value               => p_rec.pjo_information19
      ,p_attribute20_name                => 'PJO_INFORMATION20'
      ,p_attribute20_value               => p_rec.pjo_information20
      ,p_attribute21_name                => 'PJO_INFORMATION21'
      ,p_attribute21_value               => p_rec.pjo_information21
      ,p_attribute22_name                => 'PJO_INFORMATION22'
      ,p_attribute22_value               => p_rec.pjo_information22
      ,p_attribute23_name                => 'PJO_INFORMATION23'
      ,p_attribute23_value               => p_rec.pjo_information23
      ,p_attribute24_name                => 'PJO_INFORMATION24'
      ,p_attribute24_value               => p_rec.pjo_information24
      ,p_attribute25_name                => 'PJO_INFORMATION25'
      ,p_attribute25_value               => p_rec.pjo_information25
      ,p_attribute26_name                => 'PJO_INFORMATION26'
      ,p_attribute26_value               => p_rec.pjo_information26
      ,p_attribute27_name                => 'PJO_INFORMATION27'
      ,p_attribute27_value               => p_rec.pjo_information27
      ,p_attribute28_name                => 'PJO_INFORMATION28'
      ,p_attribute28_value               => p_rec.pjo_information28
      ,p_attribute29_name                => 'PJO_INFORMATION29'
      ,p_attribute29_value               => p_rec.pjo_information29
      ,p_attribute30_name                => 'PJO_INFORMATION30'
      ,p_attribute30_value               => p_rec.pjo_information30
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
  (p_rec in per_pjo_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.previous_job_id is not null)  and (
    nvl(per_pjo_shd.g_old_rec.pjo_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute_category, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute1, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute2, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute3, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute4, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute5, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute6, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute7, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute8, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute9, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute10, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute11, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute12, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute13, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute14, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute15, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute16, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute17, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute18, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute19, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute20, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute21, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute22, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute23, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute24, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute25, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute26, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute27, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute28, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute29, hr_api.g_varchar2)  or
    nvl(per_pjo_shd.g_old_rec.pjo_attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.pjo_attribute30, hr_api.g_varchar2) ))
    or (p_rec.previous_job_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_PREVIOUS_JOBS'
      ,p_attribute_category              => p_rec.pjo_attribute_category
      ,p_attribute1_name                 => 'PJO_ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.pjo_attribute1
      ,p_attribute2_name                 => 'PJO_ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.pjo_attribute2
      ,p_attribute3_name                 => 'PJO_ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.pjo_attribute3
      ,p_attribute4_name                 => 'PJO_ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.pjo_attribute4
      ,p_attribute5_name                 => 'PJO_ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.pjo_attribute5
      ,p_attribute6_name                 => 'PJO_ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.pjo_attribute6
      ,p_attribute7_name                 => 'PJO_ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.pjo_attribute7
      ,p_attribute8_name                 => 'PJO_ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.pjo_attribute8
      ,p_attribute9_name                 => 'PJO_ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.pjo_attribute9
      ,p_attribute10_name                => 'PJO_ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.pjo_attribute10
      ,p_attribute11_name                => 'PJO_ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.pjo_attribute11
      ,p_attribute12_name                => 'PJO_ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.pjo_attribute12
      ,p_attribute13_name                => 'PJO_ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.pjo_attribute13
      ,p_attribute14_name                => 'PJO_ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.pjo_attribute14
      ,p_attribute15_name                => 'PJO_ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.pjo_attribute15
      ,p_attribute16_name                => 'PJO_ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.pjo_attribute16
      ,p_attribute17_name                => 'PJO_ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.pjo_attribute17
      ,p_attribute18_name                => 'PJO_ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.pjo_attribute18
      ,p_attribute19_name                => 'PJO_ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.pjo_attribute19
      ,p_attribute20_name                => 'PJO_ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.pjo_attribute20
      ,p_attribute21_name                => 'PJO_ATTRIBUTE21'
      ,p_attribute21_value               => p_rec.pjo_attribute21
      ,p_attribute22_name                => 'PJO_ATTRIBUTE22'
      ,p_attribute22_value               => p_rec.pjo_attribute22
      ,p_attribute23_name                => 'PJO_ATTRIBUTE23'
      ,p_attribute23_value               => p_rec.pjo_attribute23
      ,p_attribute24_name                => 'PJO_ATTRIBUTE24'
      ,p_attribute24_value               => p_rec.pjo_attribute24
      ,p_attribute25_name                => 'PJO_ATTRIBUTE25'
      ,p_attribute25_value               => p_rec.pjo_attribute25
      ,p_attribute26_name                => 'PJO_ATTRIBUTE26'
      ,p_attribute26_value               => p_rec.pjo_attribute26
      ,p_attribute27_name                => 'PJO_ATTRIBUTE27'
      ,p_attribute27_value               => p_rec.pjo_attribute27
      ,p_attribute28_name                => 'PJO_ATTRIBUTE28'
      ,p_attribute28_value               => p_rec.pjo_attribute28
      ,p_attribute29_name                => 'PJO_ATTRIBUTE29'
      ,p_attribute29_value               => p_rec.pjo_attribute29
      ,p_attribute30_name                => 'PJO_ATTRIBUTE30'
      ,p_attribute30_value               => p_rec.pjo_attribute30
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
  (p_effective_date               in date
  ,p_rec in per_pjo_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_pjo_shd.api_updating
      (p_previous_job_id                      => p_rec.previous_job_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- Add checks to ensure non-updateable args have
  -- not been updated.
  if per_pjo_shd.g_old_rec.previous_job_id <> p_rec.previous_job_id
     then
     hr_api.argument_changed_error
       (p_api_name   =>  l_proc
       ,p_argument   =>  'previous_job_id'
       ,p_base_table =>  per_pjo_shd.g_tab_nam
       );
  end if;
  --
  hr_utility.set_location(l_proc,15);
  if per_pjo_shd.g_old_rec.previous_employer_id <> p_rec.previous_employer_id
     then
     hr_api.argument_changed_error
       (p_api_name    => l_proc
       ,p_argument    => 'previous_employer_id'
       ,p_base_table  =>  per_pjo_shd.g_tab_nam
       );
  end if;
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_previous_employer_id >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that previous_employer_id is unique
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
-- p_previous_employer_id
--
-- Post Success:
--   Processing continues if previous_employer_id is valid.
--
-- Post Failure:
--   An application error is raised previous_employer_id is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_previous_employer_id
          (p_previous_employer_id
           in  per_previous_jobs.previous_employer_id%type
          ,p_previous_job_id
           in  per_previous_jobs.previous_job_id%type
          ,p_object_version_number
           in  per_previous_jobs.object_version_number%type) is
  cursor csr_previous_employer_id is
    select previous_employer_id
    from   per_previous_employers
    where  previous_employer_id = p_previous_employer_id;
  l_previous_employer_id  per_previous_employers.previous_employer_id%type;
  --
  l_proc          varchar2(72) := g_package||'chk_previous_employer_id';
  l_api_updating  boolean;
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_previous_employer_id is not null then
    hr_utility.set_location(l_proc, 10);
    l_api_updating := per_pjo_shd.api_updating(p_previous_job_id
                                            =>  p_previous_job_id
                                            ,p_object_version_number
                                            =>  p_object_version_number);
    if (l_api_updating and
       (nvl(p_previous_employer_id,hr_api.g_number)
        <> nvl(per_pjo_shd.g_old_rec.previous_employer_id,hr_api.g_number))
       ) or
       (not l_api_updating) then
        hr_utility.set_location(l_proc, 15);
        open  csr_previous_employer_id;
        fetch csr_previous_employer_id into l_previous_employer_id;
        if csr_previous_employer_id%notfound then
          hr_utility.set_location(l_proc, 20);
          close csr_previous_employer_id;
          fnd_message.set_name('PER','HR_289537_PJO_VALID_PR_EMPR_ID');
          fnd_message.raise_error;
        end if;
        if csr_previous_employer_id%isopen then
          close csr_previous_employer_id;
        end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 25);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1   => 'PER_PREVIOUS_JOBS.PREVIOUS_EMPLOYER_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 35);
end chk_previous_employer_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_start_end_dates >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that start_date is earlier than end_date.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_previous_job_id
--  p_object_version_number
--  p_start_date
--  p_end_date
--
-- Post Success:
--   Processing continues if end_date is greater than start_date is valid.
--
-- Post Failure:
--   An application error is raised previous_employer_id is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_start_end_dates
          (p_previous_job_id
          in  per_previous_jobs.previous_job_id%type
          ,p_object_version_number
          in  per_previous_jobs.object_version_number%type
          ,p_start_date
          in  per_previous_jobs.start_date%type
          ,p_end_date
          in  per_previous_jobs.end_date%type) is
  l_proc            varchar2(72) := g_package||'chk_start_end_dates';
  l_api_updating    boolean;
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_start_date is not null and p_end_date is not null then
    hr_utility.set_location(l_proc, 10);
    l_api_updating := per_pjo_shd.api_updating(p_previous_job_id
                                            =>  p_previous_job_id
                                            ,p_object_version_number
                                            =>  p_object_version_number);
    if (l_api_updating and
       (nvl(p_start_date,hr_api.g_sot)
        <> nvl(per_pjo_shd.g_old_rec.start_date,hr_api.g_sot)
        or
        nvl(p_end_date,hr_api.g_eot)
        <> nvl(per_pjo_shd.g_old_rec.end_date,hr_api.g_eot))
       ) or
       (not l_api_updating) then
        hr_utility.set_location(l_proc, 15);
        if p_start_date > p_end_date then
           hr_utility.set_location(l_proc, 20);
           fnd_message.set_name('PER','HR_289530_PEM_STRT_END_DATES');
           fnd_message.set_token('START_DATE',TO_CHAR(p_start_date,'DD-MON-YYYY'),TRUE);
           fnd_message.set_token('END_DATE',TO_CHAR(p_end_date,'DD-MON-YYYY'),TRUE);
           fnd_message.raise_error;
        end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 25);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_PREVIOUS_JOBS.START_DATE'
	 ,p_associated_column2      => 'PER_PREVIOUS_JOBS.END_DATE'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 50);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_start_end_dates;
--
-- -----------------------------------------------------------------------
-- |---------------------------< chk_employment_category >---------------|
-- -----------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that employment_category has valid lookup
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_previous_job_id
--  p_object_version_number
--  p_employment_category
--  p_effective_date
--
-- Post Success:
--   Processing continues if employment_category has valid lookup.
--
-- Post Failure:
--   An application error is raised previous_employer_id is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_employment_category
          (p_previous_job_id
          in  per_previous_jobs.previous_job_id%type
          ,p_object_version_number
          in  per_previous_jobs.object_version_number%type
          ,p_employment_category
          in  per_previous_jobs.employment_category%type
          ,p_effective_date  in date) is
  l_proc            varchar2(72) := g_package||'chk_employment_category';
  l_no_lookup       boolean;
  l_effective_date  date := p_effective_date;
  l_lookup_type     fnd_lookups.lookup_type%type := 'EMPLOYEE_CATG';
  l_lookup_code     per_previous_jobs.employment_category%type
                    := p_employment_category;
  l_api_updating    boolean;
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_employment_category is not null then
    hr_utility.set_location(l_proc, 10);
    l_api_updating := per_pjo_shd.api_updating(p_previous_job_id
                                            =>  p_previous_job_id
                                            ,p_object_version_number
                                            =>  p_object_version_number);
    if ((l_api_updating and
        (   nvl(p_employment_category,hr_api.g_varchar2)
            <> nvl(per_pjo_shd.g_old_rec.employment_category,hr_api.g_varchar2)
        )
       ) or
       (not l_api_updating)) then
        hr_utility.set_location(l_proc, 15);
        l_no_lookup := hr_api.not_exists_in_leg_lookups
                  (p_effective_date =>  l_effective_date
                  ,p_lookup_type    =>  l_lookup_type
                  ,p_lookup_code    =>  l_lookup_code
                  );
        hr_utility.set_location(l_proc, 20);
        if l_no_lookup = true then
           hr_utility.set_location(l_proc, 25);
           fnd_message.set_name('PER','HR_289538_PJO_EMPT_CAT');
           fnd_message.raise_error;
        end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 30);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_PREVIOUS_JOBS.EMPLOYMENT_CATEGORY'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 50);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_employment_category;
--
-- -----------------------------------------------------------------------
-- |---------------------------< chk_period_years >----------------------|
-- -----------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that period_years value is between 0 and 99
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_period_years
--  p_previous_job_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if period_years is between 0 and 99
--
-- Post Failure:
--   An application error is raised period_years is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_period_years
          (p_period_years
           in  per_previous_jobs.period_years%type
          ,p_previous_job_id
           in  per_previous_jobs.previous_job_id%type
          ,p_object_version_number
           in  per_previous_jobs.object_version_number%type) is
  l_proc          varchar2(72) := g_package||'chk_period_years';
  l_api_updating  boolean;
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_period_years is not null then
    hr_utility.set_location(l_proc, 10);
    l_api_updating := per_pjo_shd.api_updating(p_previous_job_id
                                            =>  p_previous_job_id
                                            ,p_object_version_number
                                            =>  p_object_version_number);
    hr_utility.set_location(l_proc, 15);
    if ((l_api_updating and
        (   nvl(p_period_years,hr_api.g_number)
            <> nvl(per_pjo_shd.g_old_rec.period_years,hr_api.g_number)
        )
       ) or
       (not l_api_updating)) then
      hr_utility.set_location(l_proc, 20);
      if p_period_years not between 0 and 99 then
        hr_utility.set_location(l_proc, 25);
        fnd_message.set_name('PER','HR_289534_PEM_VALID_PRD_RANGE');
        fnd_message.set_token('RANGE_START','0',true);
        fnd_message.set_token('RANGE_END','99',true);
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 30);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_PREVIOUS_JOBS.PERIOD_YEARS'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_period_years;
--
-- -----------------------------------------------------------------------
-- |---------------------------< chk_period_months >---------------------|
-- -----------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that period_months value is between 0 and 11
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_period_months
--  p_previous_job_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if period_months is between 0 and 11
--
-- Post Failure:
--   An application error is raised period_months is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_period_months
          (p_period_months
           in  per_previous_jobs.period_months%type
          ,p_previous_job_id
           in  per_previous_jobs.previous_job_id%type
          ,p_object_version_number
           in  per_previous_jobs.object_version_number%type) is
  l_proc          varchar2(72) := g_package||'chk_period_months';
  l_api_updating  boolean;
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_period_months is not null then
    hr_utility.set_location(l_proc, 10);
    l_api_updating := per_pjo_shd.api_updating(p_previous_job_id
                                            =>  p_previous_job_id
                                            ,p_object_version_number
                                            =>  p_object_version_number);
    hr_utility.set_location(l_proc, 15);
    if ((l_api_updating and
        (   nvl(p_period_months,hr_api.g_number)
            <> nvl(per_pjo_shd.g_old_rec.period_months,hr_api.g_number)
        )
       ) or
       (not l_api_updating)) then
      hr_utility.set_location(l_proc, 20);
      if p_period_months not between 0 and 11 then
        hr_utility.set_location(l_proc, 25);
        fnd_message.set_name('PER','HR_289534_PEM_VALID_PRD_RANGE');
        fnd_message.set_token('RANGE_START','0',true);
        fnd_message.set_token('RANGE_END','11',true);
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 30);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_PREVIOUS_JOBS.PERIOD_MONTHS'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_period_months;
--
-- -----------------------------------------------------------------------
-- |---------------------------< chk_period_days >-----------------------|
-- -----------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that period_days value is between 0 and 365
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_period_days
--  p_previous_job_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if period_years is between 0 and 365
--
-- Post Failure:
--   An application error is raised period_days is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_period_days
          (p_period_days
           in  per_previous_jobs.period_days%type
          ,p_previous_job_id
           in  per_previous_jobs.previous_job_id%type
          ,p_object_version_number
           in  per_previous_jobs.object_version_number%type) is
  l_proc            varchar2(72) := g_package||'chk_period_days';
  l_api_updating    boolean;
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_period_days is not null then
    hr_utility.set_location(l_proc, 10);
    l_api_updating := per_pjo_shd.api_updating(p_previous_job_id
                                            =>  p_previous_job_id
                                            ,p_object_version_number
                                            =>  p_object_version_number);
    hr_utility.set_location(l_proc, 15);
    if ((l_api_updating and
        (   nvl(p_period_days,hr_api.g_number)
            <> nvl(per_pjo_shd.g_old_rec.period_days,hr_api.g_number)
        )
       ) or
       (not l_api_updating)) then
      hr_utility.set_location(l_proc, 20);
      if p_period_days not between 0 and 365 then
        hr_utility.set_location(l_proc, 25);
        fnd_message.set_name('PER','HR_289534_PEM_VALID_PRD_RANGE');
        fnd_message.set_token('RANGE_START','0',true);
        fnd_message.set_token('RANGE_END','365',true);
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 30);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_PREVIOUS_JOBS.PERIOD_DAYS'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_period_days;
--
-- -----------------------------------------------------------------------
-- |---------------------------< chk_pjo_start_end_dates >---------------|
-- -----------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that start_date and end_date of
--   previous job are between start_date and end_date of the previous
--   employer assiciated with.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_previous_job_id
--  p_previous_employer_id
--  p_object_version_number
--  p_start_date
--  p_end_date
--
-- Post Success:
--   Processing continues if start_date and end_date are between
--   start_date and end_date of the previous_employer associated with
--
-- Post Failure:
--   An application error is raised if start_date or end_date are
--   beyond the range of the start_date and end_date of previous employer
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_pjo_start_end_dates
          (p_previous_job_id
           in  per_previous_jobs.previous_job_id%type
          ,p_previous_employer_id
           in  per_previous_jobs.previous_employer_id%type
          ,p_object_version_number
           in  per_previous_jobs.object_version_number%type
          ,p_start_date
           in  per_previous_jobs.start_date%type
          ,p_end_date
           in  per_previous_jobs.end_date%TYPE
	   ,p_effective_date
	   IN  per_previous_jobs.start_date%type) is
  cursor csr_pem_start_end_dates is
    select  previous_employer_id
    from    per_previous_employers
    where   previous_employer_id = p_previous_employer_id
    and     (p_start_date not between nvl(start_date,hr_api.g_sot)
                              and     nvl(end_date,hr_api.g_eot)
             or p_end_date not between nvl(start_date,hr_api.g_sot)
                               and     nvl(end_date,hr_api.g_eot));
  l_previous_employer_id  per_previous_employers.previous_employer_id%type;
  --
  l_proc            varchar2(72) := g_package||'chk_pjo_start_end_dates';
  l_api_updating    boolean;
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if hr_multi_message.no_all_inclusive_error
       (p_check_column1      => 'PER_PREVIOUS_JOBS.START_DATE'
       ,p_check_column2      => 'PER_PREVIOUS_JOBS.END_DATE'
       ,p_check_column3      => 'PER_PREVIOUS_JOBS.PREVIOUS_EMPLOYER_ID'
       ) THEN
      hr_utility.set_location('Entering:'||l_proc, 6);
    -- This if condition added for bug 7112425
    IF p_start_date is not null  AND p_start_date > p_effective_date THEN
          fnd_message.set_name('PER','HR_INVAL_ST_DT_PJO');
          fnd_message.raise_error;
    END IF ;
    hr_utility.set_location('Entering:'||l_proc, 7);

    if p_start_date is not null or p_end_date is not null then
      hr_utility.set_location(l_proc, 10);
      l_api_updating := per_pjo_shd.api_updating(p_previous_job_id
                                                =>  p_previous_job_id
                                                ,p_object_version_number
                                                =>  p_object_version_number);
      if ((l_api_updating or
         (nvl(p_start_date,hr_api.g_sot)
          <> nvl(per_pjo_shd.g_old_rec.start_date,hr_api.g_sot)
          or
          nvl(p_end_date,hr_api.g_eot)
          <> nvl(per_pjo_shd.g_old_rec.end_date,hr_api.g_eot))
         ) or
         (not l_api_updating)) then
            hr_utility.set_location(l_proc, 15);
            open  csr_pem_start_end_dates;
            fetch csr_pem_start_end_dates into l_previous_employer_id;
            if csr_pem_start_end_dates%found then
              hr_utility.set_location(l_proc, 20);
              close csr_pem_start_end_dates;
              fnd_message.set_name('PER','HR_289542_PJO_START_END_DATES');
              fnd_message.raise_error;
            end if;
            if csr_pem_start_end_dates%isopen then
              close csr_pem_start_end_dates;
            end if;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 25);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_PREVIOUS_JOBS.START_DATE'
         ,p_associated_column2      => 'PER_PREVIOUS_JOBS.END_DATE'
	 ,p_associated_column3      => 'PER_PREVIOUS_JOBS.PREVIOUS_EMPLOYER_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 35);
end chk_pjo_start_end_dates;
--
-- -----------------------------------------------------------------------
-- |---------------------------< chk_all_assignments >-------------------|
-- -----------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that all_assignments value is valid
--   and also checks if there are any assignment usages assiciated with
--   this previous job.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_previous_job_id
--  p_object_version_number
--  p_all_assignments
--
-- Post Success:
--   Processing continues if all_assignments value is valid and
--   there are no assignments mappped to this previous job.
--
-- Post Failure:
--   An application error is raised if all_assignments value is not valid
--   or if there are any assignment mappings for this previous job.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_all_assignments
          (p_previous_job_id
          in  per_previous_jobs.previous_job_id%type
          ,p_object_version_number
          in  per_previous_jobs.object_version_number%type
          ,p_all_assignments
          in  per_previous_jobs.all_assignments%type) is
  cursor csr_pjo_assignments is
       select previous_job_usage_id
       from   per_previous_job_usages
       where  previous_job_id = p_previous_job_id;
  l_previous_job_usage_id   per_previous_job_usages.previous_job_usage_id%type;
  --
  l_proc            varchar2(72) := g_package||'chk_all_assignments';
  l_api_updating    boolean;
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
 if hr_multi_message.no_exclusive_error
       (p_check_column1      => 'PER_PREVIOUS_JOBS.PREVIOUS_JOB_ID'
       ) then
   if p_all_assignments is not null then
       hr_utility.set_location(l_proc, 10);
      l_api_updating := per_pjo_shd.api_updating(p_previous_job_id
                                                =>  p_previous_job_id
                                                ,p_object_version_number
                                                =>  p_object_version_number);
      if ((l_api_updating and
           nvl(p_all_assignments,hr_api.g_varchar2)
           <> nvl(per_pjo_shd.g_old_rec.all_assignments,hr_api.g_varchar2)
          ) or
         (not l_api_updating)) then
            hr_utility.set_location(l_proc, 15);
            if p_all_assignments = 'Y' or p_all_assignments = 'N' then
              hr_utility.set_location(l_proc, 20);
              if p_all_assignments = 'Y' then
                hr_utility.set_location(l_proc, 25);
                open    csr_pjo_assignments;
                fetch   csr_pjo_assignments into l_previous_job_usage_id;
                if csr_pjo_assignments%found then
                  hr_utility.set_location(l_proc, 30);
                  close   csr_pjo_assignments;
                  fnd_message.set_name('PER','HR_289546_PEM_ALL_ASG_MOD_NA');
                  hr_multi_message.add
                    (p_associated_column1 => 'PER_PREVIOUS_JOBS.
		                              PREVIOUS_JOB_ID'
	            );
                end if;
                if  csr_pjo_assignments%isopen then
                  close csr_pjo_assignments;
                end if;
              end if;
            else
              hr_utility.set_location(l_proc, 35);
              fnd_message.set_name('PER','HR_289545_PEM_VALID_ASGMT_FLAG');
              hr_multi_message.add
                (p_associated_column1 => 'PER_PREVIOUS_JOBS.PREVIOUS_JOB_ID'
	        ,p_associated_column2 => 'PER_PREVIOUS_JOBS.ALL_ASSIGNMENTS'
		);
            end if;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 40);
end chk_all_assignments;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_pjo_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
 -- Call all supporting business operations
    hr_utility.set_location(l_proc, 10);
    hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'EFFECTIVE_DATE'
    ,p_argument_value     => p_effective_date
    );
--
  hr_utility.set_location(l_proc, 15);
  chk_previous_employer_id(p_previous_employer_id
                           =>  p_rec.previous_employer_id
                          ,p_previous_job_id
                           =>  p_rec.previous_job_id
                          ,p_object_version_number
                           =>  p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 20);
  chk_start_end_dates(p_previous_job_id
                      =>  p_rec.previous_job_id
                     ,p_object_version_number
                      =>  p_rec.object_version_number
                     ,p_start_date
                      =>  p_rec.start_date
                     ,p_end_date
                      =>  p_rec.end_date);
  --
  hr_utility.set_location(l_proc, 25);
  chk_pjo_start_end_dates(p_previous_job_id
                          =>  p_rec.previous_job_id
                         ,p_previous_employer_id
                          =>  p_rec.previous_employer_id
                         ,p_object_version_number
                          =>  p_rec.object_version_number
                         ,p_start_date
                          =>  p_rec.start_date
                         ,p_end_date
                          =>  p_rec.end_date
			  ,p_effective_date
			  => p_effective_date);      -- bug 7112425
  --
  hr_utility.set_location(l_proc, 30);
  chk_employment_category(p_previous_job_id
                          =>  p_rec.previous_job_id
                         ,p_object_version_number
                          =>  p_rec.object_version_number
                         ,p_employment_category
                          =>  p_rec.employment_category
                         ,p_effective_date
                          =>  p_effective_date);
  --
  hr_utility.set_location(l_proc, 35);
  chk_period_years(p_period_years
                   =>  p_rec.period_years
                  ,p_previous_job_id
                   =>  p_rec.previous_job_id
                  ,p_object_version_number
                   =>  p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 40);
  chk_period_months(p_period_months
                    =>  p_rec.period_months
                   ,p_previous_job_id
                    =>  p_rec.previous_job_id
                   ,p_object_version_number
                    =>  p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 45);
  chk_period_days(p_period_days
                  =>  p_rec.period_days
                 ,p_previous_job_id
                  =>  p_rec.previous_job_id
                 ,p_object_version_number
                  =>  p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 50);
  chk_all_assignments(p_previous_job_id
                      =>  p_rec.previous_job_id
                     ,p_object_version_number
                      =>  p_rec.object_version_number
                     ,p_all_assignments
                      =>  p_rec.all_assignments);
  --
  hr_utility.set_location(l_proc, 55);
  per_pjo_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(l_proc, 60);
  per_pjo_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 65);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_pjo_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
    hr_utility.set_location(l_proc, 10);
    hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'EFFECTIVE_DATE'
    ,p_argument_value     => p_effective_date
    );
    --
    chk_non_updateable_args
    (p_effective_date   => p_effective_date
    ,p_rec              => p_rec
    );
    --
    hr_utility.set_location(l_proc, 20);
    chk_start_end_dates(p_previous_job_id       => p_rec.previous_job_id
                       ,p_object_version_number => p_rec.object_version_number
                       ,p_start_date            => p_rec.start_date
                       ,p_end_date              => p_rec.end_date);
    --
    hr_utility.set_location(l_proc, 25);
    chk_employment_category(p_previous_job_id
                            => p_rec.previous_job_id
                           ,p_object_version_number
                           => p_rec.object_version_number
                           ,p_employment_category
                           => p_rec.employment_category
                           ,p_effective_date
                           => p_effective_date);
    --
    hr_utility.set_location(l_proc, 30);
    chk_period_years(p_period_years
                     =>  p_rec.period_years
                    ,p_previous_job_id
                     =>  p_rec.previous_job_id
                    ,p_object_version_number
                     =>  p_rec.object_version_number);
    --
    hr_utility.set_location(l_proc, 35);
    chk_period_months(p_period_months
                      =>  p_rec.period_months
                     ,p_previous_job_id
                      =>  p_rec.previous_job_id
                     ,p_object_version_number
                      =>  p_rec.object_version_number);
    --
    hr_utility.set_location(l_proc, 40);
    chk_period_days(p_period_days
                    =>  p_rec.period_days
                   ,p_previous_job_id
                    =>  p_rec.previous_job_id
                   ,p_object_version_number
                    =>  p_rec.object_version_number);
    --
    hr_utility.set_location(l_proc, 45);
    chk_pjo_start_end_dates(p_previous_job_id
                            =>  p_rec.previous_job_id
                           ,p_previous_employer_id
                            =>  p_rec.previous_employer_id
                           ,p_object_version_number
                            =>  p_rec.object_version_number
                           ,p_start_date
                            =>  p_rec.start_date
                           ,p_end_date
                            =>  p_rec.end_date
			    ,p_effective_date
			    => p_effective_date);      -- bug 7112425
    --
    hr_utility.set_location(l_proc, 50);
    chk_all_assignments(p_previous_job_id       => p_rec.previous_job_id
                       ,p_object_version_number => p_rec.object_version_number
                       ,p_all_assignments       => p_rec.all_assignments);
    --
    hr_utility.set_location(l_proc, 55);
    per_pjo_bus.chk_ddf(p_rec);
    --
    hr_utility.set_location(l_proc, 60);
    per_pjo_bus.chk_df(p_rec);
    --
    hr_utility.set_location(l_proc, 65);
  hr_utility.set_location(' Leaving:'||l_proc, 70);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_pjo_shd.g_rec_type
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
--  ---------------------------------------------------------------------------
--  |--------------------------< return_leg_code >----------------------------|
--  ---------------------------------------------------------------------------
--
Function return_leg_code(
         p_previous_employer_id      in number
         ) return varchar2 is
   --
   -- Declare cursor
   cursor csr_leg_code is
          select pbg.legislation_code
            from per_business_groups pbg,
                 per_all_people_f ppf,
                 per_previous_employers pem
           where pem.previous_employer_id = p_previous_employer_id
             and ppf.business_group_id    = pbg.business_group_id(+)
             and pem.person_id            = ppf.person_id(+);
   --
   -- Declare local variables
   l_legislation_code  varchar2(150);
   l_proc              varchar2(72)  :=  g_package||'return_leg_code';
   --
Begin
   --
   hr_utility.set_location('Entering:'|| l_proc, 10);
   --
   -- Ensure that all the mandatory parameter are not null
   hr_api.mandatory_arg_error
      (p_api_name           => l_proc
      ,p_argument           => 'p_previous_employer_id'
      ,p_argument_value     => p_previous_employer_id);
   --
   if(nvl(per_pjo_bus.g_previous_employer_id, hr_api.g_number) =
      p_previous_employer_id) then
      --
      -- The legislation code has already been found with a previous
      -- call to this function. Just return the value in the global variable.
      l_legislation_code := per_pjo_bus.g_legislation_code;
      hr_utility.set_location(l_proc, 20);
      --
   else
      --
      -- The ID is different to the last call to this function
      -- or this is the first call to this function.
      open csr_leg_code;
      fetch csr_leg_code into l_legislation_code;
      --
      if csr_leg_code%notfound then
         --
         -- The primary key is invalid therefore we must error
         close csr_leg_code;
         hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
         hr_utility.raise_error;
         --
      end if;
      --
      hr_utility.set_location(l_proc,30);
      --
      -- Set the global variables so the values are
      -- available for the next call to this function.
      close csr_leg_code;
      per_pjo_bus.g_previous_employer_id := p_previous_employer_id;
      per_pjo_bus.g_legislation_code     := l_legislation_code;
      --
   end if;
   --
   hr_utility.set_location(' Leaving:'|| l_proc, 40);
   --
   return l_legislation_code;
   --
end return_leg_code;
--
end per_pjo_bus;

/
