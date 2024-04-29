--------------------------------------------------------
--  DDL for Package Body PER_CNI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CNI_BUS" as
/* $Header: pecnirhi.pkb 120.0 2005/05/31 06:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_cni_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_config_information_id       number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_config_information_id                in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- per_ri_config_information and PER_BUSINESS_GROUPS_PERF
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select Null--pbg.security_group_id,
           --pbg.legislation_code
      from --per_business_groups_perf pbg
          per_ri_config_information cni
      --   , EDIT_HERE table_name(s) 333
     where cni.config_information_id = p_config_information_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
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
    ,p_argument           => 'config_information_id'
    ,p_argument_value     => p_config_information_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_legislation_code;
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
        => nvl(p_associated_column1,'CONFIG_INFORMATION_ID')
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
  (p_config_information_id                in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- per_ri_config_information and PER_BUSINESS_GROUPS_PERF
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select Null--pbg.legislation_code
      from --per_business_groups_perf     pbg
          per_ri_config_information cni
      --   , EDIT_HERE table_name(s) 333
     where cni.config_information_id = p_config_information_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
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
    ,p_argument           => 'config_information_id'
    ,p_argument_value     => p_config_information_id
    );
  --
  if ( nvl(per_cni_bus.g_config_information_id, hr_api.g_number)
       = p_config_information_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_cni_bus.g_legislation_code;
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
    per_cni_bus.g_config_information_id       := p_config_information_id;
    per_cni_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in per_cni_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
/*
  if ((p_rec.config_information_id is not null)  and (
    nvl(per_cni_shd.g_old_rec.config_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.config_information_category, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information1, hr_api.g_varchar2) <>
    nvl(p_rec.config_information1, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information2, hr_api.g_varchar2) <>
    nvl(p_rec.config_information2, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information3, hr_api.g_varchar2) <>
    nvl(p_rec.config_information3, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information4, hr_api.g_varchar2) <>
    nvl(p_rec.config_information4, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information5, hr_api.g_varchar2) <>
    nvl(p_rec.config_information5, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information6, hr_api.g_varchar2) <>
    nvl(p_rec.config_information6, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information7, hr_api.g_varchar2) <>
    nvl(p_rec.config_information7, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information8, hr_api.g_varchar2) <>
    nvl(p_rec.config_information8, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information9, hr_api.g_varchar2) <>
    nvl(p_rec.config_information9, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information10, hr_api.g_varchar2) <>
    nvl(p_rec.config_information10, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information11, hr_api.g_varchar2) <>
    nvl(p_rec.config_information11, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information12, hr_api.g_varchar2) <>
    nvl(p_rec.config_information12, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information13, hr_api.g_varchar2) <>
    nvl(p_rec.config_information13, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information14, hr_api.g_varchar2) <>
    nvl(p_rec.config_information14, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information15, hr_api.g_varchar2) <>
    nvl(p_rec.config_information15, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information16, hr_api.g_varchar2) <>
    nvl(p_rec.config_information16, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information17, hr_api.g_varchar2) <>
    nvl(p_rec.config_information17, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information18, hr_api.g_varchar2) <>
    nvl(p_rec.config_information18, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information19, hr_api.g_varchar2) <>
    nvl(p_rec.config_information19, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information20, hr_api.g_varchar2) <>
    nvl(p_rec.config_information20, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information21, hr_api.g_varchar2) <>
    nvl(p_rec.config_information21, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information22, hr_api.g_varchar2) <>
    nvl(p_rec.config_information22, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information23, hr_api.g_varchar2) <>
    nvl(p_rec.config_information23, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information24, hr_api.g_varchar2) <>
    nvl(p_rec.config_information24, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information25, hr_api.g_varchar2) <>
    nvl(p_rec.config_information25, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information26, hr_api.g_varchar2) <>
    nvl(p_rec.config_information26, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information27, hr_api.g_varchar2) <>
    nvl(p_rec.config_information27, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information28, hr_api.g_varchar2) <>
    nvl(p_rec.config_information28, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information29, hr_api.g_varchar2) <>
    nvl(p_rec.config_information29, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information30, hr_api.g_varchar2) <>
    nvl(p_rec.config_information30, hr_api.g_varchar2)  or
    nvl(per_cni_shd.g_old_rec.config_information_id, hr_api.g_varchar2) <>
    nvl(p_rec.config_information_id, hr_api.g_number) ))
    or (p_rec.config_information_id is null)  then
*/
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
  If 1=1 Then
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'Configuration Information DF'
      ,p_attribute_category              => p_rec.config_information_category
      ,p_attribute1_name                 => 'CONFIG_INFORMATION1'
      ,p_attribute1_value                => p_rec.config_information1
      ,p_attribute2_name                 => 'CONFIG_INFORMATION2'
      ,p_attribute2_value                => p_rec.config_information2
      ,p_attribute3_name                 => 'CONFIG_INFORMATION3'
      ,p_attribute3_value                => p_rec.config_information3
      ,p_attribute4_name                 => 'CONFIG_INFORMATION4'
      ,p_attribute4_value                => p_rec.config_information4
      ,p_attribute5_name                 => 'CONFIG_INFORMATION5'
      ,p_attribute5_value                => p_rec.config_information5
      ,p_attribute6_name                 => 'CONFIG_INFORMATION6'
      ,p_attribute6_value                => p_rec.config_information6
      ,p_attribute7_name                 => 'CONFIG_INFORMATION7'
      ,p_attribute7_value                => p_rec.config_information7
      ,p_attribute8_name                 => 'CONFIG_INFORMATION8'
      ,p_attribute8_value                => p_rec.config_information8
      ,p_attribute9_name                 => 'CONFIG_INFORMATION9'
      ,p_attribute9_value                => p_rec.config_information9
      ,p_attribute10_name                => 'CONFIG_INFORMATION10'
      ,p_attribute10_value               => p_rec.config_information10
      ,p_attribute11_name                => 'CONFIG_INFORMATION11'
      ,p_attribute11_value               => p_rec.config_information11
      ,p_attribute12_name                => 'CONFIG_INFORMATION12'
      ,p_attribute12_value               => p_rec.config_information12
      ,p_attribute13_name                => 'CONFIG_INFORMATION13'
      ,p_attribute13_value               => p_rec.config_information13
      ,p_attribute14_name                => 'CONFIG_INFORMATION14'
      ,p_attribute14_value               => p_rec.config_information14
      ,p_attribute15_name                => 'CONFIG_INFORMATION15'
      ,p_attribute15_value               => p_rec.config_information15
      ,p_attribute16_name                => 'CONFIG_INFORMATION16'
      ,p_attribute16_value               => p_rec.config_information16
      ,p_attribute17_name                => 'CONFIG_INFORMATION17'
      ,p_attribute17_value               => p_rec.config_information17
      ,p_attribute18_name                => 'CONFIG_INFORMATION18'
      ,p_attribute18_value               => p_rec.config_information18
      ,p_attribute19_name                => 'CONFIG_INFORMATION19'
      ,p_attribute19_value               => p_rec.config_information19
      ,p_attribute20_name                => 'CONFIG_INFORMATION20'
      ,p_attribute20_value               => p_rec.config_information20
      ,p_attribute21_name                => 'CONFIG_INFORMATION21'
      ,p_attribute21_value               => p_rec.config_information21
      ,p_attribute22_name                => 'CONFIG_INFORMATION22'
      ,p_attribute22_value               => p_rec.config_information22
      ,p_attribute23_name                => 'CONFIG_INFORMATION23'
      ,p_attribute23_value               => p_rec.config_information23
      ,p_attribute24_name                => 'CONFIG_INFORMATION24'
      ,p_attribute24_value               => p_rec.config_information24
      ,p_attribute25_name                => 'CONFIG_INFORMATION25'
      ,p_attribute25_value               => p_rec.config_information25
      ,p_attribute26_name                => 'CONFIG_INFORMATION26'
      ,p_attribute26_value               => p_rec.config_information26
      ,p_attribute27_name                => 'CONFIG_INFORMATION27'
      ,p_attribute27_value               => p_rec.config_information27
      ,p_attribute28_name                => 'CONFIG_INFORMATION28'
      ,p_attribute28_value               => p_rec.config_information28
      ,p_attribute29_name                => 'CONFIG_INFORMATION29'
      ,p_attribute29_value               => p_rec.config_information29
      ,p_attribute30_name                => 'CONFIG_INFORMATION30'
      ,p_attribute30_value               => p_rec.config_information30
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
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
  ,p_rec in per_cni_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_cni_shd.api_updating
      (p_config_information_id             => p_rec.config_information_id
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
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_cni_shd.g_rec_type
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
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate Dependent Attributes
  --
  --
  hr_utility.trace('Context is ' || p_rec.config_information_category);
  per_cni_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_cni_shd.g_rec_type
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
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  --
  per_cni_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_cni_shd.g_rec_type
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
end per_cni_bus;

/
