--------------------------------------------------------
--  DDL for Package Body PER_PGH_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PGH_BUS" as
/* $Header: pepghrhi.pkb 120.0 2005/05/31 14:05:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_pgh_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_hierarchy_id                number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_hierarchy_id                         in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups_perf  pbg
         , per_gen_hierarchy pgh
     where pgh.hierarchy_id = p_hierarchy_id
       and pbg.business_group_id (+) = pgh.business_group_id;
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
    ,p_argument           => 'hierarchy_id'
    ,p_argument_value     => p_hierarchy_id
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
  (p_hierarchy_id                         in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf  pbg
         , per_gen_hierarchy pgh
     where pgh.hierarchy_id = p_hierarchy_id
       and pbg.business_group_id (+) = pgh.business_group_id;
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
    ,p_argument           => 'hierarchy_id'
    ,p_argument_value     => p_hierarchy_id
    );
  --
  if ( nvl(per_pgh_bus.g_hierarchy_id, hr_api.g_number)
       = p_hierarchy_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_pgh_bus.g_legislation_code;
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
    per_pgh_bus.g_hierarchy_id      := p_hierarchy_id;
    per_pgh_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--

-- -----------------------------------------------------------------------------
-- |-------------------------------< chk_ddf >---------------------------------|
-- -----------------------------------------------------------------------------
--
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
--   If the Developer Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
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
  (p_rec in per_pgh_shd.g_rec_type) is
--
  l_proc       varchar2(72) := g_package||'chk_ddf';
  l_error      exception;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check if the row is being inserted or updated and a
  -- value has changed
  --
  if (p_rec.hierarchy_id is null)
    or ((p_rec.hierarchy_id is not null)
    and
    nvl(per_pgh_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.information_category, hr_api.g_varchar2) or
    nvl(per_pgh_shd.g_old_rec.information1, hr_api.g_varchar2) <>
    nvl(p_rec.information1, hr_api.g_varchar2) or
    nvl(per_pgh_shd.g_old_rec.information2, hr_api.g_varchar2) <>
    nvl(p_rec.information2, hr_api.g_varchar2) or
    nvl(per_pgh_shd.g_old_rec.information3, hr_api.g_varchar2) <>
    nvl(p_rec.information3, hr_api.g_varchar2) or
    nvl(per_pgh_shd.g_old_rec.information4, hr_api.g_varchar2) <>
    nvl(p_rec.information4, hr_api.g_varchar2) or
    nvl(per_pgh_shd.g_old_rec.information5, hr_api.g_varchar2) <>
    nvl(p_rec.information5, hr_api.g_varchar2) or
    nvl(per_pgh_shd.g_old_rec.information6, hr_api.g_varchar2) <>
    nvl(p_rec.information6, hr_api.g_varchar2) or
    nvl(per_pgh_shd.g_old_rec.information7, hr_api.g_varchar2) <>
    nvl(p_rec.information7, hr_api.g_varchar2) or
    nvl(per_pgh_shd.g_old_rec.information8, hr_api.g_varchar2) <>
    nvl(p_rec.information8, hr_api.g_varchar2) or
    nvl(per_pgh_shd.g_old_rec.information9, hr_api.g_varchar2) <>
    nvl(p_rec.information9, hr_api.g_varchar2) or
    nvl(per_pgh_shd.g_old_rec.information10, hr_api.g_varchar2) <>
    nvl(p_rec.information10, hr_api.g_varchar2) or
    nvl(per_pgh_shd.g_old_rec.information11, hr_api.g_varchar2) <>
    nvl(p_rec.information11, hr_api.g_varchar2) or
    nvl(per_pgh_shd.g_old_rec.information12, hr_api.g_varchar2) <>
    nvl(p_rec.information12, hr_api.g_varchar2) or
    nvl(per_pgh_shd.g_old_rec.information13, hr_api.g_varchar2) <>
    nvl(p_rec.information13, hr_api.g_varchar2) or
    nvl(per_pgh_shd.g_old_rec.information14, hr_api.g_varchar2) <>
    nvl(p_rec.information14, hr_api.g_varchar2) or
    nvl(per_pgh_shd.g_old_rec.information15, hr_api.g_varchar2) <>
    nvl(p_rec.information15, hr_api.g_varchar2) or
    nvl(per_pgh_shd.g_old_rec.information16, hr_api.g_varchar2) <>
    nvl(p_rec.information16, hr_api.g_varchar2) or
    nvl(per_pgh_shd.g_old_rec.information17, hr_api.g_varchar2) <>
    nvl(p_rec.information17, hr_api.g_varchar2) or
    nvl(per_pgh_shd.g_old_rec.information18, hr_api.g_varchar2) <>
    nvl(p_rec.information18, hr_api.g_varchar2) or
    nvl(per_pgh_shd.g_old_rec.information19, hr_api.g_varchar2) <>
    nvl(p_rec.information19, hr_api.g_varchar2) or
    nvl(per_pgh_shd.g_old_rec.information20, hr_api.g_varchar2) <>
    nvl(p_rec.information20, hr_api.g_varchar2) or
    nvl(per_pgh_shd.g_old_rec.information21, hr_api.g_varchar2) <>
    nvl(p_rec.information21, hr_api.g_varchar2) or
    nvl(per_pgh_shd.g_old_rec.information22, hr_api.g_varchar2) <>
    nvl(p_rec.information22, hr_api.g_varchar2) or
    nvl(per_pgh_shd.g_old_rec.information23, hr_api.g_varchar2) <>
    nvl(p_rec.information23, hr_api.g_varchar2) or
    nvl(per_pgh_shd.g_old_rec.information24, hr_api.g_varchar2) <>
    nvl(p_rec.information24, hr_api.g_varchar2) or
    nvl(per_pgh_shd.g_old_rec.information25, hr_api.g_varchar2) <>
    nvl(p_rec.information25, hr_api.g_varchar2) or
    nvl(per_pgh_shd.g_old_rec.information26, hr_api.g_varchar2) <>
    nvl(p_rec.information26, hr_api.g_varchar2) or
    nvl(per_pgh_shd.g_old_rec.information27, hr_api.g_varchar2) <>
    nvl(p_rec.information27, hr_api.g_varchar2) or
    nvl(per_pgh_shd.g_old_rec.information28, hr_api.g_varchar2) <>
    nvl(p_rec.information28, hr_api.g_varchar2) or
    nvl(per_pgh_shd.g_old_rec.information29, hr_api.g_varchar2) <>
    nvl(p_rec.information29, hr_api.g_varchar2) or
    nvl(per_pgh_shd.g_old_rec.information30, hr_api.g_varchar2) <>
    nvl(p_rec.information30, hr_api.g_varchar2))
  then
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'Hierarchy Type Developer DF'
      ,p_attribute_category => p_rec.information_category
      ,p_attribute1_name    => 'INFORMATION1'
      ,p_attribute1_value   => p_rec.information1
      ,p_attribute2_name    => 'INFORMATION2'
      ,p_attribute2_value   => p_rec.information2
      ,p_attribute3_name    => 'INFORMATION3'
      ,p_attribute3_value   => p_rec.information3
      ,p_attribute4_name    => 'INFORMATION4'
      ,p_attribute4_value   => p_rec.information4
      ,p_attribute5_name    => 'INFORMATION5'
      ,p_attribute5_value   => p_rec.information5
      ,p_attribute6_name    => 'INFORMATION6'
      ,p_attribute6_value   => p_rec.information6
      ,p_attribute7_name    => 'INFORMATION7'
      ,p_attribute7_value   => p_rec.information7
      ,p_attribute8_name    => 'INFORMATION8'
      ,p_attribute8_value   => p_rec.information8
      ,p_attribute9_name    => 'INFORMATION9'
      ,p_attribute9_value   => p_rec.information9
      ,p_attribute10_name   => 'INFORMATION10'
      ,p_attribute10_value  => p_rec.information10
      ,p_attribute11_name   => 'INFORMATION11'
      ,p_attribute11_value  => p_rec.information11
      ,p_attribute12_name   => 'INFORMATION12'
      ,p_attribute12_value  => p_rec.information12
      ,p_attribute13_name   => 'INFORMATION13'
      ,p_attribute13_value  => p_rec.information13
      ,p_attribute14_name   => 'INFORMATION14'
      ,p_attribute14_value  => p_rec.information14
      ,p_attribute15_name   => 'INFORMATION15'
      ,p_attribute15_value  => p_rec.information15
      ,p_attribute16_name   => 'INFORMATION16'
      ,p_attribute16_value  => p_rec.information16
      ,p_attribute17_name   => 'INFORMATION17'
      ,p_attribute17_value  => p_rec.information17
      ,p_attribute18_name   => 'INFORMATION18'
      ,p_attribute18_value  => p_rec.information18
      ,p_attribute19_name   => 'INFORMATION19'
      ,p_attribute19_value  => p_rec.information19
      ,p_attribute20_name   => 'INFORMATION20'
      ,p_attribute20_value  => p_rec.information20
      ,p_attribute21_name   => 'INFORMATION21'
      ,p_attribute21_value  => p_rec.information21
      ,p_attribute22_name   => 'INFORMATION22'
      ,p_attribute22_value  => p_rec.information22
      ,p_attribute23_name   => 'INFORMATION23'
      ,p_attribute23_value  => p_rec.information23
      ,p_attribute24_name   => 'INFORMATION24'
      ,p_attribute24_value  => p_rec.information24
      ,p_attribute25_name   => 'INFORMATION25'
      ,p_attribute25_value  => p_rec.information25
      ,p_attribute26_name   => 'INFORMATION26'
      ,p_attribute26_value  => p_rec.information26
      ,p_attribute27_name   => 'INFORMATION27'
      ,p_attribute27_value  => p_rec.information27
      ,p_attribute28_name   => 'INFORMATION28'
      ,p_attribute28_value  => p_rec.information28
      ,p_attribute29_name   => 'INFORMATION29'
      ,p_attribute29_value  => p_rec.information29
      ,p_attribute30_name   => 'INFORMATION30'
      ,p_attribute30_value  => p_rec.information30
      );
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end chk_ddf;
--
--
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
  (p_rec in per_pgh_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.hierarchy_id is not null)  and (
    nvl(per_pgh_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(per_pgh_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(per_pgh_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(per_pgh_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(per_pgh_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(per_pgh_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(per_pgh_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(per_pgh_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(per_pgh_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(per_pgh_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(per_pgh_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(per_pgh_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(per_pgh_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(per_pgh_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(per_pgh_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(per_pgh_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(per_pgh_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(per_pgh_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(per_pgh_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(per_pgh_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(per_pgh_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(per_pgh_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(per_pgh_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(per_pgh_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(per_pgh_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(per_pgh_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(per_pgh_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(per_pgh_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(per_pgh_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(per_pgh_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(per_pgh_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    or (p_rec.hierarchy_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    null;
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_GEN_HIERARCHY'
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
  ,p_rec in per_pgh_shd.g_rec_type
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
  IF NOT per_pgh_shd.api_updating
      (p_hierarchy_id                         => p_rec.hierarchy_id
      ,p_object_version_number                => p_rec.object_version_number
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
  IF nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(per_pgh_shd.g_old_rec.business_group_id, hr_api.g_number) THEN
     l_argument := 'business_group_id';
     RAISE l_error;
  END IF;
--
  --
  IF nvl(p_rec.type, hr_api.g_varchar2) <>
     nvl(per_pgh_shd.g_old_rec.type, hr_api.g_varchar2) THEN
     l_argument := 'TYPE';
     RAISE l_error;
  END IF;
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
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_hierarchy_id >-----------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that the hierarchy id parameter is null on insert.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_hierarchy_id
--
--  Post Success:
--    If the hierarchy_id parameter is NULL then
--    normal processing continues
--
--  Post Failure:
--    If the hierarchy_id is not null as an insert parameter  an application
--    error will be raised and processing is terminated.
--
--  Developer/Implementation Notes:
--    Duplicate validation exists on form, so any changes made here
--    or on form must be dual-maintained.
--
--  Access Status:
--    Internal Row Table Handler Use Only.
--
-- {End Of Comments}
--
PROCEDURE chk_hierarchy_id
  (p_hierarchy_id IN number) is
  --
  l_proc           VARCHAR2(72)  :=  g_package||'chk_hierarchy_id';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if p_hierarchy_id is not null then
    --
    fnd_message.set_name('PER', 'HR_289056_PGH_PK_NOT_NULL');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 30);
  --
END chk_hierarchy_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_name >-------------------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that NAME of the hierarchy is UNIQUE within the
--    business group, if business group is set, or unique across
--    all business groups if global generic hierarchy (calendar).
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_name
--    p_effective_date
--    p_business_group_id
--
--  Post Success:
--    If the name attribute is UNIQUE then
--    normal processing continues
--
--  Post Failure:
--    If the name attribute is already present then an application
--    error will be raised and processing is terminated.
--
--  Developer/Implementation Notes:
--    Duplicate validation exists on form, so any changes made here
--    or on form must be dual-maintained.
--
--  Access Status:
--    Internal Row Table Handler Use Only.
--
-- {End Of Comments}
--
PROCEDURE chk_name
  (p_name                    in varchar2
  ,p_hierarchy_id            in number
  ,p_business_group_id       in number
  ,p_object_version_number   in number) IS
  --
  l_proc           VARCHAR2(72)  :=  g_package||'chk_name';
  l_exists         VARCHAR2(1) := 'N';
  l_api_updating   BOOLEAN;
  --
  -- Cursor to check uniqueness.
  --
  cursor csr_unique_name IS
    SELECT 'Y'
    FROM   per_gen_hierarchy
    WHERE  (business_group_id = p_business_group_id or p_business_group_id is null)
    AND    hierarchy_id <> nvl(p_hierarchy_id,-1)
    AND    name = p_name;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'NAME'
    ,p_argument_value     => p_name);
  --
  l_api_updating := per_pgh_shd.api_updating
    (p_hierarchy_id          =>  p_hierarchy_id
    ,p_object_version_number =>  p_object_version_number);
  --
  -- Check name uniqueness
  --
  if ((l_api_updating and
       nvl(per_pgh_shd.g_old_rec.name, hr_api.g_varchar2) <>
       nvl(p_name, hr_api.g_varchar2))
     or NOT l_api_updating) then
    --
    OPEN csr_unique_name;
      --
      FETCH csr_unique_name INTO l_exists;
      --
      hr_utility.set_location(l_proc, 20);
      --
      IF csr_unique_name%notfound THEN
        --
        CLOSE csr_unique_name;
        --
      ELSE
        --
        CLOSE csr_unique_name;
        fnd_message.set_name('PER', 'HR_289057_PGH_DUP_HIER_NAME');
        fnd_message.raise_error;
        --
      END IF;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 30);
  --
END chk_name;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_type >-------------------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that type of hierarchy is present in
--     HR_STANDARD_LOOKUPS for 'HIERARCHY_TYPE' lookup code.
--     Also checks that hr_cross_business_group profile = 'Y' if inserting
--     a custom or georgraphical calendar coverage hierarchy that is global,
--     otherwise raise an error.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_type
--    p_effective_date
--    p_business_group_id
--
--  Post Success:
--    If the type attribute is present and valid then
--    normal processing continues
--
--  Post Failure:
--    If the type attribute is present and invalid then an application
--    error will be raised and processing is terminated.
--
--  Development Notes:
--    Duplicate validation exists on form, so any changes made here
--    or on form must be dual-maintained.
--
--  Access Status:
--    Internal Row Table Handler Use Only.
--
-- {End Of Comments}
--
PROCEDURE chk_type
  (p_type           IN varchar2,
   p_effective_date IN DATE,
   p_business_group_id IN number) IS
  --
  l_proc           VARCHAR2(72)  :=  g_package||'chk_type';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'effective_date'
    ,p_argument_value     => p_effective_date);
  --
  -- Check if type exists in hr_lookups
  --
  if hr_api.NOT_EXISTS_IN_HRSTANLOOKUPS
      (p_effective_date => p_effective_date
      ,p_lookup_type    => 'HIERARCHY_TYPE'
      ,p_lookup_code    => p_type) then
    --
      fnd_message.set_name('PER', 'HR_289058_PGH_INV_HIER_TYPE');
      fnd_message.raise_error;
    --
  end if;

  -- Validate that for a custom calendar hierarchy  or a geographical hierarchy, the hierarchy
  -- cannot be global unless the HR_CROSS_BUSINESS_GROUP profile is set appropriately.
  if p_business_group_id is NULL then
     if substr(p_type,0,7) = 'PER_CAL' then
       if nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')  <> 'Y' then
        -- raise error
        fnd_message.set_name('PER', 'PER_289185_CAL_GLB_INV');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
END chk_type;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_duplicate_name >--------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates allow duplicate name flag for the hierarchy type that
--    determines if the hierarchy type can be used to build multiple
--    hierarchies.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_type
--
--  Post Success:
--    If there are no hierarchies existing of the hierarchy type or
--    if allow duplicate name flag is 'Y' or null for the hierarchy type,
--    normal processing continues.
--
--  Post Failure:
--    If the hierarchy tried to be created is not the first for the
--    hierarchy type and allow multiple versions flag is 'N' for the hierarchy
--    type, error will be raised.
--
--
--  Developer/Implementation Notes:
--  None
--
--  Access Status:
--    Internal Row Table Handler Use Only.
--
-- {End Of Comments}
--

PROCEDURE chk_duplicate_name
   (p_type IN Varchar2
   )
IS
--
CURSOR csr_duplicate_name_flag IS
SELECT  nvl(Information3, 'Y')
FROM    per_shared_types
WHERE   lookup_type = 'HIERARCHY_TYPE'
AND     system_type_cd = p_type
AND     system_type_cd = shared_type_code;
--
CURSOR csr_hierarchy_exists IS
SELECT 'Y'
FROM   Per_Gen_Hierarchy
WHERE  type = p_type;
--
--
l_duplicate_name       Varchar2(1) := 'Y';
l_hierarchy_exists     Varchar2(1);
l_proc                 Varchar2(72):= 'chk_duplicate_name';
--
BEGIN
--
hr_utility.set_location('Entering:'||l_proc, 10);
--
Open  csr_duplicate_name_flag;
Fetch csr_duplicate_name_flag into l_duplicate_name;
Close csr_duplicate_name_flag;
--
hr_utility.set_location(l_proc, 20);
--
Open  csr_hierarchy_exists;
Fetch csr_hierarchy_exists into l_hierarchy_exists;
 If csr_hierarchy_exists%found and l_duplicate_name = 'N'
 then
  hr_utility.set_location(l_proc, 30);
  Close csr_hierarchy_exists;
  fnd_message.set_name('PER','HR_449062_PGH_DUPLICATE_NAME');
  fnd_message.raise_error;
 else
  Close csr_hierarchy_exists;
 End if;
--
hr_utility.set_location('Leaving:'||l_proc, 40);
--
end chk_duplicate_name;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_delete >---------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (p_hierarchy_id  in number) is
  --
  -- Declare local variables
  --
  l_exists      varchar2(1)  := 'N';
  l_proc        varchar2(72) := g_package||'chk_delete';
  --
  cursor csr_vers_exists is
    select  'Y'
    from    per_gen_hierarchy_versions
    where   hierarchy_id = p_hierarchy_id;
  --
   cursor csr_ev is
    select 'X'
    from per_calendar_entries
    where hierarchy_id = p_hierarchy_id;
  --
Begin
  --
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'hierarchy_id'
    ,p_argument_value => p_hierarchy_id);
  --
  -- Check if versions of the hierarchy exist
  --
  hr_utility.set_location(l_proc, 20);
  --
  open csr_vers_exists;
    --
    fetch csr_vers_exists into l_exists;
    --
    if csr_vers_exists%notfound then
      --
      close csr_vers_exists;
      --
    else
      --
      close csr_vers_exists;
      fnd_message.set_name('PER', 'HR_289059_PGH_DEL_HIERARCHY');
      fnd_message.raise_error;
      --
    end if;

  -- prevent delete if Calendar Hierarchy child record exists
  open csr_ev;
   fetch csr_ev into l_exists;
   if csr_ev%notfound then
      close csr_ev;
   else
      close csr_ev;
      fnd_message.set_name('PER', 'HR_449078_CAL_ENTRY_VAL_EXISTS');
      fnd_message.raise_error;
   end if;

  --
  hr_utility.set_location('Leaving :'||l_proc, 30);
  --
end chk_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_pgh_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  if p_rec.business_group_id is not null then
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  --
  --
  -- Call developer descriptive flexfield validation routines
  per_pgh_bus.chk_ddf(p_rec);
  --
  per_pgh_bus.chk_df(p_rec);
  --
  --
  -- Validate hierarchy_id
  -- =====================
  --
  hr_utility.set_location(l_proc, 10);
  --
  chk_hierarchy_id
    (p_hierarchy_id            =>    p_rec.hierarchy_id);
  --
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- Validate name
  -- =================
  --
  chk_name
    (p_name                     =>    p_rec.name
    , p_hierarchy_id            =>    p_rec.hierarchy_id
    , p_business_group_id       =>    p_rec.business_group_id
    , p_object_version_number   =>    p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 30);
  --
  --
  -- Validate type
  -- ======================
  chk_type
    (p_type                       =>    p_rec.type
    ,p_effective_date             =>    p_effective_date
    ,p_business_group_id          =>    p_rec.business_group_id);
  --
  --
  -- Validate Allow Duplicate Name Flag
  -- ==================================
  chk_duplicate_name
   (p_type                        =>    p_rec.type
    );
--
  hr_utility.set_location('Leaving: '||l_proc, 40);
--
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_pgh_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  if p_rec.business_group_id is not null then
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  --
  hr_utility.set_location(l_proc, 10);
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Validate name
  -- =================
  --
  chk_name
    (p_name                     =>    p_rec.name
    , p_hierarchy_id            =>    p_rec.hierarchy_id
    , p_business_group_id       =>    p_rec.business_group_id
    , p_object_version_number   =>    p_rec.object_version_number
    );
--
  hr_utility.set_location(l_proc, 30);
  --
  -- Call developer descriptive flexfield validation routines
  --
  per_pgh_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(l_proc, 40);
  --
  --
  per_pgh_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_pgh_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(l_proc, 10);
  --
  chk_delete
    (p_hierarchy_id   => p_rec.hierarchy_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End delete_validate;
--
end per_pgh_bus;

/
