--------------------------------------------------------
--  DDL for Package Body PER_PGV_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PGV_BUS" as
/* $Header: pepgvrhi.pkb 115.11 2004/06/10 23:41:52 vissingh noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_pgv_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_hierarchy_version_id        number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_hierarchy_version_id                 in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups_perf  pbg
         , per_gen_hierarchy_versions pgv
     where pgv.hierarchy_version_id = p_hierarchy_version_id
       and pbg.business_group_id (+) = pgv.business_group_id;
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
    ,p_argument           => 'hierarchy_version_id'
    ,p_argument_value     => p_hierarchy_version_id
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
  (p_hierarchy_version_id                 in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf  pbg
         , per_gen_hierarchy_versions pgv
     where pgv.hierarchy_version_id = p_hierarchy_version_id
       and pbg.business_group_id (+) = pgv.business_group_id;
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
    ,p_argument           => 'hierarchy_version_id'
    ,p_argument_value     => p_hierarchy_version_id
    );
  --
  if ( nvl(per_pgv_bus.g_hierarchy_version_id, hr_api.g_number)
       = p_hierarchy_version_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_pgv_bus.g_legislation_code;
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
    per_pgv_bus.g_hierarchy_version_id := p_hierarchy_version_id;
    per_pgv_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in per_pgv_shd.g_rec_type) is
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
  if (p_rec.hierarchy_version_id is null)
    or ((p_rec.hierarchy_version_id is not null)
    and
    nvl(per_pgv_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.information_category, hr_api.g_varchar2) or
    nvl(per_pgv_shd.g_old_rec.information1, hr_api.g_varchar2) <>
    nvl(p_rec.information1, hr_api.g_varchar2) or
    nvl(per_pgv_shd.g_old_rec.information2, hr_api.g_varchar2) <>
    nvl(p_rec.information2, hr_api.g_varchar2) or
    nvl(per_pgv_shd.g_old_rec.information3, hr_api.g_varchar2) <>
    nvl(p_rec.information3, hr_api.g_varchar2) or
    nvl(per_pgv_shd.g_old_rec.information4, hr_api.g_varchar2) <>
    nvl(p_rec.information4, hr_api.g_varchar2) or
    nvl(per_pgv_shd.g_old_rec.information5, hr_api.g_varchar2) <>
    nvl(p_rec.information5, hr_api.g_varchar2) or
    nvl(per_pgv_shd.g_old_rec.information6, hr_api.g_varchar2) <>
    nvl(p_rec.information6, hr_api.g_varchar2) or
    nvl(per_pgv_shd.g_old_rec.information7, hr_api.g_varchar2) <>
    nvl(p_rec.information7, hr_api.g_varchar2) or
    nvl(per_pgv_shd.g_old_rec.information8, hr_api.g_varchar2) <>
    nvl(p_rec.information8, hr_api.g_varchar2) or
    nvl(per_pgv_shd.g_old_rec.information9, hr_api.g_varchar2) <>
    nvl(p_rec.information9, hr_api.g_varchar2) or
    nvl(per_pgv_shd.g_old_rec.information10, hr_api.g_varchar2) <>
    nvl(p_rec.information10, hr_api.g_varchar2) or
    nvl(per_pgv_shd.g_old_rec.information11, hr_api.g_varchar2) <>
    nvl(p_rec.information11, hr_api.g_varchar2) or
    nvl(per_pgv_shd.g_old_rec.information12, hr_api.g_varchar2) <>
    nvl(p_rec.information12, hr_api.g_varchar2) or
    nvl(per_pgv_shd.g_old_rec.information13, hr_api.g_varchar2) <>
    nvl(p_rec.information13, hr_api.g_varchar2) or
    nvl(per_pgv_shd.g_old_rec.information14, hr_api.g_varchar2) <>
    nvl(p_rec.information14, hr_api.g_varchar2) or
    nvl(per_pgv_shd.g_old_rec.information15, hr_api.g_varchar2) <>
    nvl(p_rec.information15, hr_api.g_varchar2) or
    nvl(per_pgv_shd.g_old_rec.information16, hr_api.g_varchar2) <>
    nvl(p_rec.information16, hr_api.g_varchar2) or
    nvl(per_pgv_shd.g_old_rec.information17, hr_api.g_varchar2) <>
    nvl(p_rec.information17, hr_api.g_varchar2) or
    nvl(per_pgv_shd.g_old_rec.information18, hr_api.g_varchar2) <>
    nvl(p_rec.information18, hr_api.g_varchar2) or
    nvl(per_pgv_shd.g_old_rec.information19, hr_api.g_varchar2) <>
    nvl(p_rec.information19, hr_api.g_varchar2) or
    nvl(per_pgv_shd.g_old_rec.information20, hr_api.g_varchar2) <>
    nvl(p_rec.information20, hr_api.g_varchar2) or
    nvl(per_pgv_shd.g_old_rec.information21, hr_api.g_varchar2) <>
    nvl(p_rec.information21, hr_api.g_varchar2) or
    nvl(per_pgv_shd.g_old_rec.information22, hr_api.g_varchar2) <>
    nvl(p_rec.information22, hr_api.g_varchar2) or
    nvl(per_pgv_shd.g_old_rec.information23, hr_api.g_varchar2) <>
    nvl(p_rec.information23, hr_api.g_varchar2) or
    nvl(per_pgv_shd.g_old_rec.information24, hr_api.g_varchar2) <>
    nvl(p_rec.information24, hr_api.g_varchar2) or
    nvl(per_pgv_shd.g_old_rec.information25, hr_api.g_varchar2) <>
    nvl(p_rec.information25, hr_api.g_varchar2) or
    nvl(per_pgv_shd.g_old_rec.information26, hr_api.g_varchar2) <>
    nvl(p_rec.information26, hr_api.g_varchar2) or
    nvl(per_pgv_shd.g_old_rec.information27, hr_api.g_varchar2) <>
    nvl(p_rec.information27, hr_api.g_varchar2) or
    nvl(per_pgv_shd.g_old_rec.information28, hr_api.g_varchar2) <>
    nvl(p_rec.information28, hr_api.g_varchar2) or
    nvl(per_pgv_shd.g_old_rec.information29, hr_api.g_varchar2) <>
    nvl(p_rec.information29, hr_api.g_varchar2) or
    nvl(per_pgv_shd.g_old_rec.information30, hr_api.g_varchar2) <>
    nvl(p_rec.information30, hr_api.g_varchar2))
  then
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'PER_GEN_HIERARCHY_VERSIONS_DDF'
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
  (p_rec in per_pgv_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.hierarchy_version_id is not null)  and (
    nvl(per_pgv_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(per_pgv_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(per_pgv_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(per_pgv_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(per_pgv_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(per_pgv_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(per_pgv_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(per_pgv_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(per_pgv_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(per_pgv_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(per_pgv_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(per_pgv_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(per_pgv_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(per_pgv_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(per_pgv_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(per_pgv_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(per_pgv_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(per_pgv_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(per_pgv_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(per_pgv_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(per_pgv_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(per_pgv_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(per_pgv_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(per_pgv_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(per_pgv_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(per_pgv_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(per_pgv_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(per_pgv_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(per_pgv_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(per_pgv_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(per_pgv_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    or (p_rec.hierarchy_version_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_GEN_HIERARCHY_VERSIONS'
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
  (p_effective_date    in date
  ,p_rec in per_pgv_shd.g_rec_type
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
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  IF NOT per_pgv_shd.api_updating
      (p_hierarchy_version_id                 => p_rec.hierarchy_version_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- EDIT_HERE: Add checks to ensure non-updateable args have
  --            not been updated
  --
  hr_utility.set_location(l_proc, 15);
  IF nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(per_pgv_shd.g_old_rec.business_group_id, hr_api.g_number) THEN
     l_argument := 'business_group_id';
     RAISE l_error;
  END IF;
--
--
  hr_utility.set_location(l_proc, 20);
--
  IF nvl(p_rec.hierarchy_id, hr_api.g_number) <>
     nvl(per_pgv_shd.g_old_rec.hierarchy_id, hr_api.g_number) THEN
     l_argument := 'Hierarchy_Id';
     RAISE l_error;
  END IF;
  hr_utility.set_location('Exiting:'|| l_proc, 30);
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
--    Validates that HIERARCHY_ID exists.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_hierarchy_id
--    p_business_group_id
--
--  Post Success:
--    If the hierarchy_id exists then normal processing continues
--
--  Post Failure:
--    If the hierarchy_id does not exist then an application
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
  ( p_hierarchy_id            IN     per_gen_hierarchy.hierarchy_id%TYPE,
    p_business_group_id       IN     per_gen_hierarchy.business_group_id%TYPE)
IS
   l_proc           VARCHAR2(72)  :=  g_package||'chk_hierarchy_id';
   l_exists         VARCHAR2(1) := 'N';
--
   cursor csr_hierarchy_id IS
     SELECT 'Y'
        FROM  per_gen_hierarchy
        WHERE ( (p_business_group_id is not null and business_group_id = p_business_group_id)
                or p_business_group_id is null )
          AND hierarchy_id = p_hierarchy_id;
--
BEGIN
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
--
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'hierarchy_id'
    ,p_argument_value     => p_hierarchy_id
    );
--
--
-- Check hierarchy_id existence
--
   OPEN csr_hierarchy_id;
   FETCH csr_hierarchy_id INTO l_exists;
--
   hr_utility.set_location(l_proc, 20);
--
   IF csr_hierarchy_id%notfound THEN
     fnd_message.set_name('PER', 'HR_289071_PGV_HIER_NOT_EXIST');
     fnd_message.raise_error;
            CLOSE csr_hierarchy_id;
   ELSE
     CLOSE csr_hierarchy_id;
   END IF;
--
--
  hr_utility.set_location('Leaving:'||l_proc, 30);
--
END chk_hierarchy_id;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_multiple_versions >------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates allow multiple version flag for the hierarchy type when the
--    version is not the first version for the hierarchy.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_hierarchy_id
--
--  Post Success:
--    If the version attemtped is the initial version for the hierarchy or
--    if allow multiple versions flag is 'Y' or null for the hierarchy type,
--    normal processing continues.
--
--  Post Failure:
--    If the version tried to be created is not the first version for the
--    hierarchy and allow multiple versions flag is 'N' for the hierarchy
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

PROCEDURE chk_multiple_versions
   (p_hierarchy_id IN Number
   )
IS
--
CURSOR csr_multiple_version_flag IS
SELECT  nvl(Information2, 'Y')
FROM    per_shared_types
WHERE   lookup_type = 'HIERARCHY_TYPE'
AND     system_type_cd = (SELECT Type
                          FROM   Per_Gen_Hierarchy
                          WHERE  hierarchy_id = p_hierarchy_id)
AND     system_type_cd = shared_type_code;
--
CURSOR csr_version_exists IS
SELECT 'Y'
FROM   Per_Gen_Hierarchy_Versions
WHERE  Hierarchy_Id = p_hierarchy_id;
--
--
l_multiple_versions    Varchar2(1) := 'Y';
l_version_exists       Varchar2(1);
l_proc                 Varchar2(72):= 'chk_multiple_versions';
--
BEGIN
--
hr_utility.set_location('Entering:'||l_proc, 10);
--
Open  csr_multiple_version_flag;
Fetch csr_multiple_version_flag into l_multiple_versions;
Close csr_multiple_version_flag;
--
hr_utility.set_location(l_proc, 20);
--
Open  csr_version_exists;
Fetch csr_version_exists into l_version_exists;
 If csr_version_exists%found and l_multiple_versions = 'N'
 then
  hr_utility.set_location(l_proc, 30);
  Close csr_version_exists;
  fnd_message.set_name('PER','HR_449061_PGV_MULTIPLE_VERSION');
  fnd_message.raise_error;
 else
  Close csr_version_exists;
 End if;
--
hr_utility.set_location('Leaving:'||l_proc, 40);
--
end chk_multiple_versions;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_version_number >----------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that VERSION_NUMBER is a positive number.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_version_number
--
--  Post Success:
--    If the version_number is positive (or zero) then normal processing continues
--
--  Post Failure:
--    If the hierarchy_id does not exist then an application
--    error will be raised and processing is terminated.
--
--  Developer/Implementation Notes:
--  None.
--
--  Access Status:
--    Internal Row Table Handler Use Only.
--
-- {End Of Comments}
--
PROCEDURE chk_version_number
  ( p_version_number        IN     per_gen_hierarchy_versions.version_number%TYPE
  , p_hierarchy_version_id  IN     per_gen_hierarchy_versions.hierarchy_version_id%TYPE
  , p_object_version_number IN     per_gen_hierarchy_versions.object_version_number%TYPE
  )
IS
   l_proc           VARCHAR2(72)  :=  g_package||'chk_version_number';
   l_api_updating   boolean;
--
BEGIN
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
   hr_utility.set_location(l_proc, 20);
   hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'version_number'
    ,p_argument_value     => p_version_number
    );
--
   hr_utility.set_location(l_proc, 30);
   l_api_updating := per_pgv_shd.api_updating
         (p_hierarchy_version_id  =>  p_hierarchy_version_id
         ,p_object_version_number =>  p_object_version_number);
--
   hr_utility.set_location(l_proc, 40);
   if ((l_api_updating and
        nvl(per_pgv_shd.g_old_rec.version_number, hr_api.g_number) <>
        nvl(p_version_number, hr_api.g_number))
     or
        NOT l_api_updating) then
--
      hr_utility.set_location(l_proc, 50);
--
      if p_version_number < 0 then
        fnd_message.set_name('PER', 'HR_289078_PGV_VERSION_IS_NEG');
        fnd_message.raise_error;
      end if;
--
   end if;
--
   hr_utility.set_location('Leaving:'||l_proc, 60);
--
END chk_version_number;
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_duplicate_version >--------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that VERSION_NUMBER is unique for a hierarchy.
--    Called only from insert_validate.
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_version_number
--    p_hierarchy_id
--
--  Post Success:
--    If the version_number is unique then normal processing continues.
--
--  Post Failure:
--    If the version_number is already used for the hierarchy
--    error will be raised and processing is terminated.
--
--  Developer/Implementation Notes:
--  None.
--
--  Access Status:
--    Internal Row Table Handler Use Only.
--
-- {End Of Comments}
--
PROCEDURE chk_duplicate_version
  ( p_version_number        IN     per_gen_hierarchy_versions.version_number%TYPE
  , p_hierarchy_id          IN     per_gen_hierarchy_versions.hierarchy_id%TYPE
  )
IS
   l_proc           VARCHAR2(72)  :=  g_package||'chk_duplicate_version';
   l_exists	    VARCHAR2(1);

CURSOR csr_dup_version IS
SELECT '1'
FROM per_gen_hierarchy_versions
WHERE hierarchy_id = p_hierarchy_id
and
version_number = p_version_number;
--
BEGIN
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
   hr_utility.set_location(l_proc, 20);
   hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'hierarchy_id'
    ,p_argument_value     => p_hierarchy_id
    );
--
   hr_utility.set_location(l_proc, 30);
   hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'version_number'
    ,p_argument_value     => p_version_number
    );

--
   hr_utility.set_location(l_proc, 40);
--
      OPEN csr_dup_version;
      FETCH csr_dup_version INTO l_exists;
--
      if csr_dup_version%FOUND then
        CLOSE csr_dup_version;
        fnd_message.set_name('PER', 'HR_449051_PGV_VERSION_DUP');
        fnd_message.raise_error;
      else
	CLOSE csr_dup_version;
      end if;
--
--
   hr_utility.set_location('Leaving:'||l_proc, 50);
--
END chk_duplicate_version;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_date_from >-------------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that date_from of the hierarchy version is between date_from
--    and date_to of the business group, if business_group is not null.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_date_from
--    p_effective_date
--    p_business_group_id
--
--  Post Success:
--    If date_from of hierarchy version is between date_from and date_to
--    of the relevant business group then normal processing continues
--
--  Post Failure:
--    If the date_from of the hierarchy version is not between the date_from
--    and date_to of the relevant business group then an application
--    error will be raised and processing is terminated.
--
--  Developer/Implementation Notes:
--    Duplicate validation exists on form, so any changes made here
--    or on form must be dual-maintained
--
--  Access Status:
--    Internal Row Handler Use Only
--
-- {End Of Comments}
--
PROCEDURE chk_date_from
  (p_date_from              IN     per_gen_hierarchy_versions.date_from%TYPE
  , p_date_to               IN     per_gen_hierarchy_versions.date_to%TYPE
  , p_hierarchy_version_id  IN     per_gen_hierarchy_versions.hierarchy_version_id%TYPE
  , p_hierarchy_id          IN     per_gen_hierarchy_versions.hierarchy_id%TYPE
  , p_business_group_id     IN     hr_all_organization_units.business_group_id%TYPE
  , p_object_version_number IN     per_gen_hierarchy_versions.object_version_number%TYPE
  ) IS
--
   l_proc  VARCHAR2(72) := g_package||'chk_date_from';
   l_date_between varchar2(1) := 'N';
   l_api_updating   boolean;
--
   CURSOR csr_date_between IS
   SELECT 'Y'
   FROM hr_all_organization_units
   WHERE p_date_from >= date_from
     AND (p_date_from <= date_to
      OR date_to is null)
     AND (business_group_id = p_business_group_id);
--
--
   CURSOR csr_other_open_ended_vers IS
   SELECT 'Y'
   FROM per_gen_hierarchy_versions
   WHERE p_date_from > date_from
     AND date_to is null
     AND hierarchy_version_id <> nvl(p_hierarchy_version_id,-1)
     AND hierarchy_id = p_hierarchy_id;
--
--
   CURSOR csr_other_vers IS
   SELECT 'Y'
   FROM per_gen_hierarchy_versions
   WHERE p_date_from >= date_from
     AND (p_date_from <= date_to
      OR date_to is null)
     AND hierarchy_version_id <> nvl(p_hierarchy_version_id,-1)
     AND hierarchy_id = p_hierarchy_id;
--
BEGIN
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
   hr_utility.set_location(l_proc, 20);
   hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'Date_From'
    ,p_argument_value     => p_date_from
    );
--
   hr_utility.set_location(l_proc, 40);
   l_api_updating := per_pgv_shd.api_updating
         (p_hierarchy_version_id  =>  p_hierarchy_version_id
         ,p_object_version_number =>  p_object_version_number);
--
   hr_utility.set_location(l_proc, 50);
   if ((l_api_updating and
        nvl(per_pgv_shd.g_old_rec.date_from, hr_api.g_date) <>
        nvl(p_date_from, hr_api.g_date))
     or
        NOT l_api_updating) then
--
   hr_utility.set_location(l_proc, 60);
   --
   -- Check date_from is between date_from and date_to for the business group
   --
   if p_business_group_id is not null then
     OPEN csr_date_between;
     FETCH csr_date_between INTO l_date_between;
     IF csr_date_between%notfound THEN
         CLOSE csr_date_between;
       fnd_message.set_name('PER', 'HR_289072_PGV_INV_DATE_FROM');
       fnd_message.raise_error;
     END IF;
     CLOSE csr_date_between;
   end if;
   --
   -- Check if the DATE_FROM is before DATE_TO
   --
   hr_utility.set_location(l_proc, 70);
   if not p_date_from <= nvl(p_date_to,p_date_from) then
     fnd_message.set_name('PER', 'HR_289073_PGV_DATE_FROM_BEFORE');
     fnd_message.raise_error;
   end if;
   --
   -- Check if the DATE_FROM is not after the DATE_FROM of an existing version that is open ended
   --
   hr_utility.set_location(l_proc, 75);
   --
   --
   OPEN csr_other_open_ended_vers;
   FETCH csr_other_open_ended_vers INTO l_date_between;
   IF csr_other_open_ended_vers%found THEN
     CLOSE csr_other_open_ended_vers;
     fnd_message.set_name('PER', 'HR_449052_PGV_OPEN_END_OVERLAP');
     fnd_message.raise_error;
   END IF;
   CLOSE csr_other_open_ended_vers;
   --
   -- Check if the DATE_FROM is not overlaped by dates of another version.
   --
   hr_utility.set_location(l_proc, 80);
   --
   OPEN csr_other_vers;
   FETCH csr_other_vers INTO l_date_between;
   IF csr_other_vers%found THEN
     CLOSE csr_other_vers;
     fnd_message.set_name('PER', 'HR_289074_PGV_INV_DATE_OVERLAP');
     fnd_message.raise_error;
   END IF;
   CLOSE csr_other_vers;
   --
  end if;
   hr_utility.set_location('Leaving:'||l_proc, 90);
--
END chk_date_from;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_date_to >---------------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that date_to of the hierarchy version is between date_from
--    and date_to of the business group, if business_group is not null.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_date_to
--    p_effective_date
--    p_business_group_id
--
--  Post Success:
--    If date_to of hierarchy version is between date_from and date_to
--    of the relevant business group then normal processing continues
--
--  Post Failure:
--    If the date_to of the hierarchy version is not between the date_from
--    and date_to of the relevant business group then an application
--    error will be raised and processing is terminated.
--
--  Developer/Implementation Notes:
--    Duplicate validation exists on form, so any changes made here
--    or on form must be dual-maintained
--
--  Access Status:
--    Internal Row Handler Use Only
--
-- {End Of Comments}
--
PROCEDURE chk_date_to
  (p_date_to                IN     per_gen_hierarchy_versions.date_to%TYPE
  , p_date_from             IN     per_gen_hierarchy_versions.date_from%TYPE
  , p_hierarchy_version_id  IN     per_gen_hierarchy_versions.hierarchy_version_id%TYPE
  , p_hierarchy_id          IN     per_gen_hierarchy_versions.hierarchy_id%TYPE
  , p_version_number        IN     number
  , p_business_group_id     IN     hr_all_organization_units.business_group_id%TYPE
  , p_object_version_number IN     per_gen_hierarchy_versions.object_version_number%TYPE
  ) IS
--
   l_proc  VARCHAR2(72) := g_package||'chk_date_to';
   l_date_between varchar2(1) := 'N';
   l_api_updating   boolean;
   l_date_to  date;
--
   CURSOR csr_date_between IS
   SELECT 'Y'
   FROM hr_all_organization_units
   WHERE l_date_to >= date_from
     AND (l_date_to <= date_to
      OR date_to is null)
     AND (organization_id = p_business_group_id);
--
--
   CURSOR csr_other_vers IS
   SELECT 'Y'
   FROM per_gen_hierarchy_versions
   WHERE l_date_to
         between date_from
         and     nvl(date_to,l_date_to)
     AND hierarchy_version_id <> nvl(p_hierarchy_version_id,-1)
     AND hierarchy_id = p_hierarchy_id;
--
BEGIN
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
   l_date_to := nvl(p_date_to, hr_api.g_eot);
--
   hr_utility.set_location(l_proc, 20);
--
   hr_utility.set_location(l_proc, 30);
   l_api_updating := per_pgv_shd.api_updating
         (p_hierarchy_version_id  =>  p_hierarchy_version_id
         ,p_object_version_number =>  p_object_version_number);
--
   hr_utility.set_location(l_proc, 40);
   if ((l_api_updating and
        nvl(per_pgv_shd.g_old_rec.date_to, hr_api.g_date) <>
        nvl(p_date_to, hr_api.g_date))
     or
        NOT l_api_updating) then
--
   hr_utility.set_location(l_proc, 50);
   --
   -- Check date_to is between date_from and date_to for the business group
   --
   if p_business_group_id is not null then
     OPEN csr_date_between;
     FETCH csr_date_between INTO l_date_between;
     IF csr_date_between%notfound THEN
       CLOSE csr_date_between;
       fnd_message.set_name('PER', 'HR_289072_PGV_INV_DATE_FROM');
       fnd_message.raise_error;
     END IF;
     CLOSE csr_date_between;
   end if;
   --
   -- Check if the DATE_TO is after DATE_FROM
   --
   hr_utility.set_location(l_proc, 60);
   if not l_date_to >= p_date_from then
     fnd_message.set_name('PER', 'HR_289073_PGV_DATE_FROM_BEFORE');
     fnd_message.raise_error;
   end if;
   --
   -- Check if the DATE_TO is not overlaped by dates of another version.
   --
   hr_utility.set_location(l_proc, 70);
   --
   OPEN csr_other_vers;
   FETCH csr_other_vers INTO l_date_between;
   IF csr_other_vers%found THEN
     CLOSE csr_other_vers;
     fnd_message.set_name('PER', 'HR_289074_PGV_INV_DATE_OVERLAP');
     fnd_message.raise_error;
   END IF;
   CLOSE csr_other_vers;
   --
   hr_utility.set_location('Leaving:'||l_proc, 80);
  end if;
--
--
END chk_date_to;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_status >----------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_status
  (p_status                 in     per_gen_hierarchy_versions.status%TYPE
  , p_effective_date        in     date
  , p_hierarchy_version_id  in     per_gen_hierarchy_versions.hierarchy_version_id%TYPE
  , p_object_version_number in     per_gen_hierarchy_versions.object_version_number%TYPE
  )
  is
--
-- Declare local variables
--
  l_proc      varchar2(72) := g_package||'chk_status';
  l_api_updating   boolean;
--
Begin
--
  hr_utility.set_location('Entering: '||l_proc, 10);
--
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'effective_date'
    ,p_argument_value     => p_effective_date
    );
--
  hr_utility.set_location(l_proc, 20);
--
   l_api_updating := per_pgv_shd.api_updating
         (p_hierarchy_version_id  =>  p_hierarchy_version_id
         ,p_object_version_number =>  p_object_version_number);
--
   hr_utility.set_location(l_proc, 30);
   if ((l_api_updating and
        nvl(per_pgv_shd.g_old_rec.status, hr_api.g_varchar2) <>
        nvl(p_status, hr_api.g_varchar2))
     or
        NOT l_api_updating) then
--
    if hr_api.NOT_EXISTS_IN_HRSTANLOOKUPS
       (p_effective_date  => p_effective_date
       ,p_lookup_type     => 'ACTIVE_INACTIVE'
       ,p_lookup_code     => p_status
       ) then
      -- Error Invalid Status
      fnd_message.set_name('PER', 'HR_289075_PGV_INV_STATUS');
      fnd_message.raise_error;
    end if;
--
  hr_utility.set_location(l_proc, 40);
--
  end if;
--
  hr_utility.set_location('Leaving: '||l_proc, 50);
--
end chk_status;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_validate_flag >---------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_validate_flag
  (p_validate_flag          in     per_gen_hierarchy_versions.validate_flag%TYPE
  , p_effective_date        in     date
  , p_hierarchy_version_id  in     per_gen_hierarchy_versions.hierarchy_version_id%TYPE
  , p_object_version_number in     per_gen_hierarchy_versions.object_version_number%TYPE
  )
  is
--
-- Declare local variables
--
  l_proc           varchar2(72) := g_package||'chk_validate_flag';
  l_api_updating   boolean;
--
Begin
--
  hr_utility.set_location('Entering: '||l_proc, 10);
--
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'effective_date'
    ,p_argument_value     => p_effective_date
    );
--
  hr_utility.set_location(l_proc, 20);
--
   l_api_updating := per_pgv_shd.api_updating
         (p_hierarchy_version_id  =>  p_hierarchy_version_id
         ,p_object_version_number =>  p_object_version_number);
--
   hr_utility.set_location(l_proc, 30);
   if ((l_api_updating and
        nvl(per_pgv_shd.g_old_rec.validate_flag, hr_api.g_varchar2) <>
        nvl(p_validate_flag, hr_api.g_varchar2))
     or
        NOT l_api_updating) then
--
    if hr_api.NOT_EXISTS_IN_HRSTANLOOKUPS
       (p_effective_date  => p_effective_date
       ,p_lookup_type     => 'YES_NO'
       ,p_lookup_code     => p_validate_flag
       ) then
      -- Error Invalid Validate Flag
      fnd_message.set_name('PER', 'HR_289076_PGV_INV_VALIDATE');
      fnd_message.raise_error;
    end if;
--
  hr_utility.set_location(l_proc, 40);
--
  end if;
--
  hr_utility.set_location('Leaving: '||l_proc, 50);
--
end chk_validate_flag;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_delete >---------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (p_hierarchy_version_id  in per_gen_hierarchy_versions.hierarchy_version_id%TYPE
  ) is
--
-- Declare local variables
--
   l_exists      varchar2(1)  := 'Y';
   l_proc        varchar2(72) := g_package||'chk_delete';
--
   cursor csr_node_exists is
     select  'Y'
       from  per_gen_hierarchy_nodes
      where  hierarchy_version_id = p_hierarchy_version_id;
--
Begin
--
  hr_utility.set_location('Entering: '||l_proc, 5);
--
  hr_utility.set_location(l_proc, 10);
   hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'hierarchy_version_id'
     ,p_argument_value => p_hierarchy_version_id
     );
--
-- Check if nodes of the hierarchy version exist
--
  hr_utility.set_location(l_proc, 20);
--
   open csr_node_exists;
   fetch csr_node_exists into l_exists;
   if csr_node_exists%notfound then
      close csr_node_exists;
   else
      close csr_node_exists;
      fnd_message.set_name('PER', 'HR_289077_PGV_DEL_HIER_VERS');
      fnd_message.raise_error;
   end if;
--
  hr_utility.set_location('Leaving :'||l_proc, 30);
--
end chk_delete;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date         in  date
  ,p_rec                    in per_pgv_shd.g_rec_type
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
  hr_utility.set_location(l_proc, 10);
  --
  -- Validate hierarchy_id
  -- ======================
  chk_hierarchy_id
    (p_hierarchy_id               =>    p_rec.hierarchy_id
    ,p_business_group_id          =>    p_rec.business_group_id
    );
  --
  hr_utility.set_location(l_proc, 20);
--
  --
  -- Validate Allow Multiple Version flag
  -- =====================================
  chk_multiple_versions
   (p_hierarchy_id                =>   p_rec.hierarchy_id
   );
  --
 -- Validate version_number
  -- ======================
  chk_version_number
    (p_version_number             =>    p_rec.version_number
    ,p_hierarchy_version_id       =>    p_rec.hierarchy_version_id
    ,p_object_version_number      =>    p_rec.object_version_number
    );
--
  hr_utility.set_location(l_proc, 30);
  --
 -- Validate version_number is unique
  -- ================================
  chk_duplicate_version
    (p_version_number		  => 	p_rec.version_number
    ,p_hierarchy_id		  =>    p_rec.hierarchy_id
    );
 --
  hr_utility.set_location(l_proc, 35);
  --
 -- Validate date_from
  -- ======================
  chk_date_from
    (p_date_from                  =>    p_rec.date_from
    ,p_date_to                    =>    p_rec.date_to
    ,p_hierarchy_version_id       =>    p_rec.hierarchy_version_id
    ,p_hierarchy_id               =>    p_rec.hierarchy_id
    ,p_business_group_id          =>    p_rec.business_group_id
    ,p_object_version_number      =>    p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Validate date_to
  -- ======================
  chk_date_to
    (p_date_to                    =>    p_rec.date_to
    ,p_date_from                  =>    p_rec.date_from
    ,p_hierarchy_version_id       =>    p_rec.hierarchy_version_id
    ,p_hierarchy_id               =>    p_rec.hierarchy_id
    ,p_version_number             =>    p_rec.version_number
    ,p_business_group_id          =>    p_rec.business_group_id
    ,p_object_version_number      =>    p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Validate Status
  -- ======================
  chk_status
    (p_status                     =>    p_rec.status
    ,p_effective_date             =>    p_effective_date
    ,p_hierarchy_version_id       =>    p_rec.hierarchy_version_id
    ,p_object_version_number      =>    p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- Validate Validate Flag
  -- ======================
  chk_validate_flag
    (p_validate_flag              =>    p_rec.validate_flag
    ,p_effective_date             =>    p_effective_date
    ,p_hierarchy_version_id       =>    p_rec.hierarchy_version_id
    ,p_object_version_number      =>    p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 70);
  --
  per_pgv_bus.chk_ddf(p_rec);

  per_pgv_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_pgv_shd.g_rec_type
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
 chk_non_updateable_args
    (p_effective_date      =>   p_effective_date
    ,p_rec              => p_rec
    );
  --
  hr_utility.set_location(l_proc, 10);
  --
 -- Validate version_number
  -- ======================
  chk_version_number
    (p_version_number             =>    p_rec.version_number
    ,p_hierarchy_version_id       =>    p_rec.hierarchy_version_id
    ,p_object_version_number      =>    p_rec.object_version_number
    );
  --
--
  hr_utility.set_location(l_proc, 20);
  --
  -- Validate date_from
  -- ======================
  chk_date_from
    (p_date_from                  =>    p_rec.date_from
    ,p_date_to                    =>    p_rec.date_to
    ,p_hierarchy_version_id       =>    p_rec.hierarchy_version_id
    ,p_hierarchy_id               =>    p_rec.hierarchy_id
    ,p_business_group_id          =>    p_rec.business_group_id
    ,p_object_version_number      =>    p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Validate date_to
  -- ======================
  chk_date_to
    (p_date_to                    =>    p_rec.date_to
    ,p_date_from                  =>    p_rec.date_from
    ,p_hierarchy_version_id       =>    p_rec.hierarchy_version_id
    ,p_hierarchy_id               =>    p_rec.hierarchy_id
    ,p_version_number             =>    p_rec.version_number
    ,p_business_group_id          =>    p_rec.business_group_id
    ,p_object_version_number      =>    p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Validate Status
  -- ======================
  chk_status
    (p_status                     =>    p_rec.status
    ,p_effective_date             =>    p_effective_date
    ,p_hierarchy_version_id       =>    p_rec.hierarchy_version_id
    ,p_object_version_number      =>    p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Validate Validate Flag
  -- ======================
  chk_validate_flag
    (p_validate_flag              =>    p_rec.validate_flag
    ,p_effective_date             =>    p_effective_date
    ,p_hierarchy_version_id       =>    p_rec.hierarchy_version_id
    ,p_object_version_number      =>    p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 60);
  --
  per_pgv_bus.chk_ddf(p_rec);
  per_pgv_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
End update_validate;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_pgv_shd.g_rec_type
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
    (p_hierarchy_version_id   => p_rec.hierarchy_version_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End delete_validate;
--
end per_pgv_bus;

/
