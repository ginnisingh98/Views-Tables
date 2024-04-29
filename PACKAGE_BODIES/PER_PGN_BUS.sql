--------------------------------------------------------
--  DDL for Package Body PER_PGN_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PGN_BUS" as
/* $Header: pepgnrhi.pkb 120.0 2005/05/31 14:09:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_pgn_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_hierarchy_node_id           number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_hierarchy_node_id                    in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups_perf  pbg
         , per_gen_hierarchy_nodes pgn
     where pgn.hierarchy_node_id = p_hierarchy_node_id
      and  pbg.business_group_id  (+) = pgn.business_group_id;
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
    ,p_argument           => 'hierarchy_node_id'
    ,p_argument_value     => p_hierarchy_node_id
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
  (p_hierarchy_node_id                    in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf  pbg
         , per_gen_hierarchy_nodes pgn
     where pgn.hierarchy_node_id = p_hierarchy_node_id
       and pbg.business_group_id (+) = pgn.business_group_id;
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
    ,p_argument           => 'hierarchy_node_id'
    ,p_argument_value     => p_hierarchy_node_id
    );
  --
  if ( nvl(per_pgn_bus.g_hierarchy_node_id, hr_api.g_number)
       = p_hierarchy_node_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_pgn_bus.g_legislation_code;
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
    per_pgn_bus.g_hierarchy_node_id := p_hierarchy_node_id;
    per_pgn_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in per_pgn_shd.g_rec_type) is
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
  if (p_rec.hierarchy_node_id is null)
    or ((p_rec.hierarchy_node_id is not null)
    and
    nvl(per_pgn_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.information_category, hr_api.g_varchar2) or
    nvl(per_pgn_shd.g_old_rec.information1, hr_api.g_varchar2) <>
    nvl(p_rec.information1, hr_api.g_varchar2) or
    nvl(per_pgn_shd.g_old_rec.information2, hr_api.g_varchar2) <>
    nvl(p_rec.information2, hr_api.g_varchar2) or
    nvl(per_pgn_shd.g_old_rec.information3, hr_api.g_varchar2) <>
    nvl(p_rec.information3, hr_api.g_varchar2) or
    nvl(per_pgn_shd.g_old_rec.information4, hr_api.g_varchar2) <>
    nvl(p_rec.information4, hr_api.g_varchar2) or
    nvl(per_pgn_shd.g_old_rec.information5, hr_api.g_varchar2) <>
    nvl(p_rec.information5, hr_api.g_varchar2) or
    nvl(per_pgn_shd.g_old_rec.information6, hr_api.g_varchar2) <>
    nvl(p_rec.information6, hr_api.g_varchar2) or
    nvl(per_pgn_shd.g_old_rec.information7, hr_api.g_varchar2) <>
    nvl(p_rec.information7, hr_api.g_varchar2) or
    nvl(per_pgn_shd.g_old_rec.information8, hr_api.g_varchar2) <>
    nvl(p_rec.information8, hr_api.g_varchar2) or
    nvl(per_pgn_shd.g_old_rec.information9, hr_api.g_varchar2) <>
    nvl(p_rec.information9, hr_api.g_varchar2) or
    nvl(per_pgn_shd.g_old_rec.information10, hr_api.g_varchar2) <>
    nvl(p_rec.information10, hr_api.g_varchar2) or
    nvl(per_pgn_shd.g_old_rec.information11, hr_api.g_varchar2) <>
    nvl(p_rec.information11, hr_api.g_varchar2) or
    nvl(per_pgn_shd.g_old_rec.information12, hr_api.g_varchar2) <>
    nvl(p_rec.information12, hr_api.g_varchar2) or
    nvl(per_pgn_shd.g_old_rec.information13, hr_api.g_varchar2) <>
    nvl(p_rec.information13, hr_api.g_varchar2) or
    nvl(per_pgn_shd.g_old_rec.information14, hr_api.g_varchar2) <>
    nvl(p_rec.information14, hr_api.g_varchar2) or
    nvl(per_pgn_shd.g_old_rec.information15, hr_api.g_varchar2) <>
    nvl(p_rec.information15, hr_api.g_varchar2) or
    nvl(per_pgn_shd.g_old_rec.information16, hr_api.g_varchar2) <>
    nvl(p_rec.information16, hr_api.g_varchar2) or
    nvl(per_pgn_shd.g_old_rec.information17, hr_api.g_varchar2) <>
    nvl(p_rec.information17, hr_api.g_varchar2) or
    nvl(per_pgn_shd.g_old_rec.information18, hr_api.g_varchar2) <>
    nvl(p_rec.information18, hr_api.g_varchar2) or
    nvl(per_pgn_shd.g_old_rec.information19, hr_api.g_varchar2) <>
    nvl(p_rec.information19, hr_api.g_varchar2) or
    nvl(per_pgn_shd.g_old_rec.information20, hr_api.g_varchar2) <>
    nvl(p_rec.information20, hr_api.g_varchar2) or
    nvl(per_pgn_shd.g_old_rec.information21, hr_api.g_varchar2) <>
    nvl(p_rec.information21, hr_api.g_varchar2) or
    nvl(per_pgn_shd.g_old_rec.information22, hr_api.g_varchar2) <>
    nvl(p_rec.information22, hr_api.g_varchar2) or
    nvl(per_pgn_shd.g_old_rec.information23, hr_api.g_varchar2) <>
    nvl(p_rec.information23, hr_api.g_varchar2) or
    nvl(per_pgn_shd.g_old_rec.information24, hr_api.g_varchar2) <>
    nvl(p_rec.information24, hr_api.g_varchar2) or
    nvl(per_pgn_shd.g_old_rec.information25, hr_api.g_varchar2) <>
    nvl(p_rec.information25, hr_api.g_varchar2) or
    nvl(per_pgn_shd.g_old_rec.information26, hr_api.g_varchar2) <>
    nvl(p_rec.information26, hr_api.g_varchar2) or
    nvl(per_pgn_shd.g_old_rec.information27, hr_api.g_varchar2) <>
    nvl(p_rec.information27, hr_api.g_varchar2) or
    nvl(per_pgn_shd.g_old_rec.information28, hr_api.g_varchar2) <>
    nvl(p_rec.information28, hr_api.g_varchar2) or
    nvl(per_pgn_shd.g_old_rec.information29, hr_api.g_varchar2) <>
    nvl(p_rec.information29, hr_api.g_varchar2) or
    nvl(per_pgn_shd.g_old_rec.information30, hr_api.g_varchar2) <>
    nvl(p_rec.information30, hr_api.g_varchar2))
  then
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'PER_GEN_HIERARCHY_NODES_DDF'
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
  (p_rec in per_pgn_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,15);
  --
  if ((p_rec.hierarchy_node_id is not null)  and (
    nvl(per_pgn_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(per_pgn_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(per_pgn_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(per_pgn_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(per_pgn_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(per_pgn_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(per_pgn_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(per_pgn_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(per_pgn_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(per_pgn_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(per_pgn_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(per_pgn_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(per_pgn_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(per_pgn_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(per_pgn_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(per_pgn_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(per_pgn_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(per_pgn_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(per_pgn_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(per_pgn_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(per_pgn_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(per_pgn_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(per_pgn_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(per_pgn_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(per_pgn_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(per_pgn_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(per_pgn_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(per_pgn_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(per_pgn_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(per_pgn_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(per_pgn_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    or (p_rec.hierarchy_node_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_GEN_HIERARCHY_NODES'
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
  (p_effective_date               in date
  ,p_rec in per_pgn_shd.g_rec_type
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
  IF NOT per_pgn_shd.api_updating
      (p_hierarchy_node_id                    => p_rec.hierarchy_node_id
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
--
  IF nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(per_pgn_shd.g_old_rec.business_group_id, hr_api.g_number) THEN
     l_argument := 'business_group_id';
     RAISE l_error;
  END IF;
--
  IF nvl(p_rec.node_type, hr_api.g_varchar2) <>
    nvl(per_pgn_shd.g_old_rec.node_type, hr_api.g_varchar2) THEN
    l_argument := 'node_type';
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
-- |---------------------------< chk_entity_id >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_entity_id
  ( p_entity_id            in  per_gen_hierarchy_nodes.entity_id%TYPE
  , p_business_group_id    in  hr_all_organization_units.business_group_id%TYPE
  , p_node_type            in  per_gen_hierarchy_nodes.node_type%TYPE
  , p_hierarchy_version_id in  per_gen_hierarchy_versions.hierarchy_version_id%TYPE
  ) IS
--
  l_ent_exists varchar2(1) := 'Y';
--
  cursor csr_org_exists is
    select 'Y'
      from  hr_all_organization_units  hou
         ,  hr_organization_information hoi
         ,  per_gen_hierarchy_versions pgv
     where  hou.organization_id = p_entity_id
       and  (hou.business_group_id = p_business_group_id or p_business_group_id is null)
       and  pgv.hierarchy_version_id = p_hierarchy_version_id
       and  hou.organization_id = hoi.organization_id
       and  hoi.org_information_context = 'CLASS'
       and  hoi.org_information1 = 'PAR_ENT';
--
  cursor csr_loc_exists is
    select 'Y'
      from  hr_locations_all  loc
     where  loc.location_id = p_entity_id;
--
  cursor csr_loc_extra_exists is
    select 'Y'
      from  hr_locations_all  loc,
            hr_location_extra_info lei
     where  loc.location_id = p_entity_id
     and    loc.location_id = lei.location_id
     and    lei.information_type in ('Establishment Information',
                                     'VETS-100 Specific Information',
                                     'EEO-1 Specific Information',
                                      'Multi Work Site Information');
  --
  cursor csr_ent_exists is
    select 'Y'
    from   per_gen_hierarchy_nodes
    where  entity_id = p_entity_id
    and    hierarchy_version_id = p_hierarchy_version_id
    and    node_type = p_node_type;
--
  l_proc  varchar2(72) := g_package||'chk_entity_id';
--
Begin
--
  hr_utility.set_location('Entering:'||l_proc, 5);
--
-- Check mandatory parameters have been set
--
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument        =>  'entity_id'
    ,p_argument_value  =>  p_entity_id
    );
--
  hr_utility.set_location(l_proc, 10);
--
  if nvl(per_pgn_shd.g_old_rec.entity_id, hr_api.g_varchar2) <>
     nvl(p_entity_id, hr_api.g_varchar2) then
--
  if p_node_type = 'PAR' then
  --
     hr_utility.set_location(l_proc, 20);
  --
     open csr_org_exists;
       --
       fetch csr_org_exists into l_ent_exists;
       if csr_org_exists%notfound then
         close csr_org_exists;
         fnd_message.set_name('PER', 'HR_289060_PGN_INV_HIER_ORG');
         fnd_message.raise_error;
       end if;
       --
     close csr_org_exists;
  elsif p_node_type = 'LOC' then
     --
     hr_utility.set_location(l_proc, 30);
     --
     open csr_loc_exists;
     fetch csr_loc_exists into l_ent_exists;
     if csr_loc_exists%notfound then
        close csr_loc_exists;
        fnd_message.set_name('PER', 'HR_289061_PGN_INV_HIER_LOC');
        fnd_message.raise_error;
     else
        close csr_loc_exists;
     end if;
  elsif p_node_type = 'EST' then
     --
     hr_utility.set_location(l_proc, 30);
     --
     open csr_loc_extra_exists;
     fetch csr_loc_extra_exists into l_ent_exists;
     if csr_loc_extra_exists%notfound then
        close csr_loc_extra_exists;
        fnd_message.set_name('PER', 'HR_289062_PGN_INV_HIER_EST');
        fnd_message.raise_error;
     else
        close csr_loc_extra_exists;
     end if;
 --  else
     --
 --    hr_utility.set_location(l_proc, 50);
 --    fnd_message.set_name('PER', 'HR_289063_INV_NODE_TYPE');
 --    fnd_message.raise_error;
     --
   end if;
   --
   hr_utility.set_location(l_proc, 60);
   --
-- changes are done Nitesh

if p_node_type IN ('EST','PAR','LOC') then
     open csr_ent_exists;
       --
       fetch csr_ent_exists into l_ent_exists;
       if csr_ent_exists%found then
         close csr_ent_exists;
         fnd_message.set_name('PER', 'HR_289064_PGN_DUP_ENTITY');
         fnd_message.raise_error;
       end if;
       --
     close csr_ent_exists;
end if;

   end if;
--
   hr_utility.set_location('Leaving: '||l_proc, 70);
--
end chk_entity_id;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_hierarchy_version_id >-------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_hierarchy_version_id
  ( p_hierarchy_version_id  in per_gen_hierarchy_versions.hierarchy_version_id%TYPE
  , p_hierarchy_node_id     in per_gen_hierarchy_nodes.hierarchy_node_id%TYPE
  , p_object_version_number in per_gen_hierarchy_nodes.object_version_number%TYPE
  )  IS
--
-- Declare local variables
--
   l_exists  varchar2(1) := 'Y';
   l_proc  varchar2(72) := g_package||'chk_hierarchy_version_id';
   l_api_updating   BOOLEAN;
--
  cursor csr_hier_vers is
    select 'Y'
    from per_gen_hierarchy_versions
    where hierarchy_version_id = p_hierarchy_version_id;
  --
Begin
--
  hr_utility.set_location('Entering:'||l_proc, 5);
--
--
   l_api_updating := per_pgn_shd.api_updating
         (p_hierarchy_node_id          =>  p_hierarchy_node_id
         ,p_object_version_number =>  p_object_version_number);
--
   if ((l_api_updating and
        nvl(per_pgn_shd.g_old_rec.hierarchy_version_id, hr_api.g_number) <>
        nvl(p_hierarchy_version_id, hr_api.g_number))
     or
        NOT l_api_updating) then
--
   open csr_hier_vers;
   fetch csr_hier_vers into l_exists;
   if csr_hier_vers%notfound then
      close csr_hier_vers;
      fnd_message.set_name('PER','HR_289065_PGN_INV_HIER_VERS');
      fnd_message.raise_error;
   else
      close csr_hier_vers;
   end if;
--
   end if;
   hr_utility.set_location('Leaving: '||l_proc, 10);
end chk_hierarchy_version_id;
--
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_seq >--------------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_seq
  (p_seq                      IN per_gen_hierarchy_nodes.seq%TYPE
  ,p_hierarchy_version_id     IN per_gen_hierarchy_versions.hierarchy_version_id%TYPE
  ,p_parent_hierarchy_node_id IN per_gen_hierarchy_nodes.parent_hierarchy_node_id%TYPE
  ,p_hierarchy_node_id        IN per_gen_hierarchy_nodes.hierarchy_node_id%TYPE
  ,p_object_version_number    IN per_gen_hierarchy_nodes.object_version_number%TYPE
  )
IS
   l_proc           VARCHAR2(72)  :=  g_package||'chk_seq';
   l_api_updating   BOOLEAN;
   --
   cursor c1 is
     select seq
     from   per_gen_hierarchy_nodes
     where  seq = p_seq
     and    hierarchy_version_id = p_hierarchy_version_id
     and    parent_hierarchy_node_id = p_parent_hierarchy_node_id;
     --
   --
   l_seq c1%ROWTYPE;
--
BEGIN
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
--
-- Check if the sequence number is unique for a given parent
   hr_utility.set_location(l_proc, 20);
--
   l_api_updating := per_pgn_shd.api_updating
         (p_hierarchy_node_id     =>  p_hierarchy_node_id
         ,p_object_version_number =>  p_object_version_number);
--
   if ((l_api_updating and
        nvl(per_pgn_shd.g_old_rec.seq, hr_api.g_number) <>
        nvl(p_seq, hr_api.g_number))
     or
        NOT l_api_updating) then
        open c1;
        fetch c1 into l_seq;
        if c1%found then
          fnd_message.set_name('PER', 'HR_289066_PGN_INV_SEQ');
          fnd_message.raise_error;
        end if;
        close c1;
--
   hr_utility.set_location(l_proc, 30);
--
        if p_seq < 0 then
          fnd_message.set_name('PER', 'HR_289082_PGN_NEG_SEQ');
          fnd_message.raise_error;
        end if;
--
      end if;
  hr_utility.set_location('Leaving:'||l_proc, 40);
--
END chk_seq;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_node_type >--------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_node_type
  ( p_node_type               IN per_gen_hierarchy_nodes.node_type%TYPE
   ,p_effective_date          IN DATE
   ,p_hierarchy_node_id       IN per_gen_hierarchy_nodes.hierarchy_node_id%TYPE
   ,p_hierarchy_version_id    IN per_gen_hierarchy_nodes.hierarchy_version_id%TYPE
   ,p_object_version_number   IN per_gen_hierarchy_nodes.object_version_number%TYPE
   )
IS
   l_proc           VARCHAR2(72)  :=  g_package||'chk_node_type';
   l_api_updating   BOOLEAN;
   l_exists         varchar2(1);
   --
   cursor c1 is
     select 'Y'
     from   per_gen_hierarchy_nodes
     where  node_type = 'PAR'
     and    hierarchy_version_id = p_hierarchy_version_id;
     --
   --
--
BEGIN
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
-- Check mandatory parameters have been set
--
   hr_utility.set_location(l_proc, 20);
--
   hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'effective date'
     ,p_argument_value => p_effective_date
     );
--
-- Check if the node type is valid
   hr_utility.set_location(l_proc, 30);
--
   l_api_updating := per_pgn_shd.api_updating
         (p_hierarchy_node_id     =>  p_hierarchy_node_id
         ,p_object_version_number =>  p_object_version_number);
--
   if ((l_api_updating and
        nvl(per_pgn_shd.g_old_rec.node_type, hr_api.g_varchar2) <>
        nvl(p_node_type, hr_api.g_varchar2))
     or
        NOT l_api_updating) then
   if hr_api.NOT_EXISTS_IN_HRSTANLOOKUPS
             ( p_effective_date  => p_effective_date
             , p_lookup_type     => 'HIERARCHY_NODE_TYPE'
             , p_lookup_code     => p_node_type
             ) then
     fnd_message.set_name('PER', 'HR_289063_PGN_INV_NODE_TYPE');
     fnd_message.raise_error;
--
   end if;
--
   hr_utility.set_location(l_proc, 40);
--
   if p_node_type = 'PAR' then
     open c1;
     fetch c1 into l_exists;
     if c1%found then
       fnd_message.set_name('PER', 'HR_289067_PGN_TOO_MANY_PARENTS');
       fnd_message.raise_error;
     end if;
     close c1;
   end if;
--
   end if;
--
  hr_utility.set_location('Leaving:'||l_proc, 50);
--
END chk_node_type;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_parent_hierarchy_node_id >---------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_parent_hierarchy_node_id
  (p_parent_hierarchy_node_id  in per_gen_hierarchy_nodes.parent_hierarchy_node_id%TYPE
  , p_hierarchy_version_id     in per_gen_hierarchy_nodes.hierarchy_version_id%TYPE
  , p_node_type                in per_gen_hierarchy_nodes.node_type%TYPE
  ,p_hierarchy_node_id         in per_gen_hierarchy_nodes.hierarchy_node_id%TYPE
  ,p_object_version_number     in per_gen_hierarchy_nodes.object_version_number%TYPE
  ) IS
  --
  l_proc           varchar2(72) := g_package||'chk_parent_hierarchy_node_id';
  l_exists         varchar2(1) := 'N';
  l_api_updating   boolean;
--
  cursor csr_par_node is
     select 'Y'
       from per_gen_hierarchy_nodes
      where hierarchy_version_id = p_hierarchy_version_id
        and hierarchy_node_id = p_parent_hierarchy_node_id;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  -- Check mandatory parameters
  --
  hr_utility.set_location(l_proc, 10);
  --
   hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'hierarchy_version_id'
     ,p_argument_value => p_hierarchy_version_id
     );
--
   l_api_updating := per_pgn_shd.api_updating
         (p_hierarchy_node_id     =>  p_hierarchy_node_id
         ,p_object_version_number =>  p_object_version_number);
--
   if ((l_api_updating and
        nvl(per_pgn_shd.g_old_rec.parent_hierarchy_node_id, hr_api.g_number) <>
        nvl(p_parent_hierarchy_node_id, hr_api.g_number))
     or
        NOT l_api_updating) then
  --
  hr_utility.set_location(l_proc, 20);
  --
  if p_parent_hierarchy_node_id is not null then
  --
  hr_utility.set_location(l_proc, 30);
  --
     open csr_par_node;
     fetch csr_par_node into l_exists;
     if csr_par_node%notfound then
        close csr_par_node;
        fnd_message.set_name('PER', 'HR_289068_PGN_INV_PARENT_ID');
        fnd_message.raise_error;
     else
        close csr_par_node;
     end if;
  else
  --
  hr_utility.set_location(l_proc, 40);
  --
-- if p_node_type <> 'PAR' then
-- fnd_message.set_name('PER', 'HR_289069_PGN_PARENT_ID');
-- fnd_message.raise_error;
--     end if;
  end if;
end if;
  hr_utility.set_location('Leaving:'||l_proc,50);
end chk_parent_hierarchy_node_id;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_delete >---------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_delete
  ( p_hierarchy_node_id    in  per_gen_hierarchy_nodes.hierarchy_node_id%TYPE
  ) is
--
-- Declare local variables
--
   l_exists       varchar2(1) := 'N';
   l_proc         varchar2(72) := g_package||'chk_delete';
--
   cursor csr_node_id is
     select 'Y'
     from   per_gen_hierarchy_nodes
     where  parent_hierarchy_node_id = p_hierarchy_node_id;

   cursor csr_ev is
    select 'X'
    from per_cal_entry_values
    where hierarchy_node_id = p_hierarchy_node_id;
--
Begin
--
  hr_utility.set_location('Entering :'||l_proc, 5);
-- Check mandatory arguments
--
  hr_utility.set_location(l_proc, 10);
--
-- Check if the node has children
--
  hr_utility.set_location(l_proc, 20);
--
   open csr_node_id;
   fetch csr_node_id into l_exists;
   if csr_node_id%notfound then
      close csr_node_id;
   else
      close csr_node_id;
      fnd_message.set_name('PER', 'HR_289070_PGN_DEL_PARENT');
      fnd_message.raise_error;
   end if;

   -- check if there is a row referencing this record
   -- in the Calendar Module schema before allowing update.
   open csr_ev;
   fetch csr_ev into l_exists;
   if csr_ev%notfound then
      close csr_ev;
   else
      close csr_ev;
      fnd_message.set_name('PER', 'HR_449077_CAL_ENTRY_VAL_EXISTS');
      fnd_message.raise_error;
   end if;

--
  hr_utility.set_location('Leaving :'||l_proc, 10);
--
end chk_delete;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_pgn_shd.g_rec_type
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
  -- Validate Entity ID
  -- ==================
  --
  chk_entity_id
  ( p_entity_id            =>  p_rec.entity_id
  , p_business_group_id    =>  p_rec.business_group_id
  , p_node_type            =>  p_rec.node_type
  , p_hierarchy_version_id =>  p_rec.hierarchy_version_id
  );
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Validate Hierarchy Version ID
  -- =============================
  --
  chk_hierarchy_version_id
  ( p_hierarchy_version_id  => p_rec.hierarchy_version_id
  , p_hierarchy_node_id     => p_rec.hierarchy_node_id
  , p_object_version_number => p_rec.object_version_number
  );
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Validate Sequence (Seq)
  -- ========================
  --
  chk_seq
  ( p_seq                      => p_rec.seq
   ,p_hierarchy_version_id     => p_rec.hierarchy_version_id
   ,p_parent_hierarchy_node_id => p_rec.parent_hierarchy_node_id
   ,p_hierarchy_node_id        => p_rec.hierarchy_node_id
   ,p_object_version_number    => p_rec.object_version_number
  );
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Validate Hierarchy Node Type
  -- ============================
  --
  chk_node_type
  ( p_node_type             => p_rec.node_type
   ,p_effective_date        => p_effective_date
   ,p_hierarchy_node_id     => p_rec.hierarchy_node_id
   ,p_hierarchy_version_id  => p_rec.hierarchy_version_id
   ,p_object_version_number => p_rec.object_version_number
  );
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Validate Parent Hierarchy Node ID
  -- ================================
  --
  chk_parent_hierarchy_node_id
  (p_parent_hierarchy_node_id  => p_rec.parent_hierarchy_node_id
  , p_hierarchy_version_id     => p_rec.hierarchy_version_id
  , p_node_type                => p_rec.node_type
  , p_hierarchy_node_id        => p_rec.hierarchy_node_id
  , p_object_version_number    => p_rec.object_version_number
  );
  --
  hr_utility.set_location(l_proc, 60);
  --
  --
  -- Call developer descriptive flexfield validation routines
  per_pgn_bus.chk_ddf(p_rec);
  --
 hr_utility.set_location(l_proc, 65);
  --
  per_pgn_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_pgn_shd.g_rec_type
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
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Validate Entity ID
  -- ==================
  --
  chk_entity_id
  ( p_entity_id            =>  p_rec.entity_id
  , p_business_group_id    =>  p_rec.business_group_id
  , p_node_type            =>  p_rec.node_type
  , p_hierarchy_version_id =>  p_rec.hierarchy_version_id
  );
  --
   hr_utility.set_location(l_proc, 20);
  --
  -- Validate Hierarchy Version ID
  -- =============================
  --
  chk_hierarchy_version_id
  ( p_hierarchy_version_id  => p_rec.hierarchy_version_id
  , p_hierarchy_node_id     => p_rec.hierarchy_node_id
  , p_object_version_number => p_rec.object_version_number
  );
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Validate Sequence (Seq)
  -- ========================
  --
  chk_seq
  ( p_seq                      => p_rec.seq
   ,p_hierarchy_version_id     => p_rec.hierarchy_version_id
   ,p_parent_hierarchy_node_id => p_rec.parent_hierarchy_node_id
   ,p_hierarchy_node_id        => p_rec.hierarchy_node_id
   ,p_object_version_number    => p_rec.object_version_number
  );
  --
   hr_utility.set_location(l_proc, 40);
  --
  -- Validate Parent Hierarchy Node ID
  -- ================================
  --
  chk_parent_hierarchy_node_id
  (p_parent_hierarchy_node_id  => p_rec.parent_hierarchy_node_id
  , p_hierarchy_version_id     => p_rec.hierarchy_version_id
  , p_node_type                => p_rec.node_type
  , p_hierarchy_node_id        => p_rec.hierarchy_node_id
  , p_object_version_number    => p_rec.object_version_number
  );
  --
  hr_utility.set_location(l_proc, 50);
  --
  --
  -- Call developer descriptive flexfield validation routines
  per_pgn_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 60);
  --
  per_pgn_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_pgn_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Verify if the node included in the record has children
  -- ======================================================
  --
  hr_utility.set_location(l_proc, 10);
  --
  chk_delete
  ( p_hierarchy_node_id    =>  p_rec.hierarchy_node_id
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End delete_validate;
--
end per_pgn_bus;

/
