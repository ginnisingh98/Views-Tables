--------------------------------------------------------
--  DDL for Package Body OTA_TSP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TSP_BUS" as
/* $Header: ottsp01t.pkb 120.0 2005/05/29 07:54:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tsp_bus.';  -- Global package name
g_legislation_code            varchar2(150)  default null;
--
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
  (p_rec in ota_tsp_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.skill_provision_id is not null)  and (
    nvl(ota_tsp_shd.g_old_rec.tsp_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.tsp_information_category, hr_api.g_varchar2)  or
    nvl(ota_tsp_shd.g_old_rec.tsp_information1, hr_api.g_varchar2) <>
    nvl(p_rec.tsp_information1, hr_api.g_varchar2)  or
    nvl(ota_tsp_shd.g_old_rec.tsp_information2, hr_api.g_varchar2) <>
    nvl(p_rec.tsp_information2, hr_api.g_varchar2)  or
    nvl(ota_tsp_shd.g_old_rec.tsp_information3, hr_api.g_varchar2) <>
    nvl(p_rec.tsp_information3, hr_api.g_varchar2)  or
    nvl(ota_tsp_shd.g_old_rec.tsp_information4, hr_api.g_varchar2) <>
    nvl(p_rec.tsp_information4, hr_api.g_varchar2)  or
    nvl(ota_tsp_shd.g_old_rec.tsp_information5, hr_api.g_varchar2) <>
    nvl(p_rec.tsp_information5, hr_api.g_varchar2)  or
    nvl(ota_tsp_shd.g_old_rec.tsp_information6, hr_api.g_varchar2) <>
    nvl(p_rec.tsp_information6, hr_api.g_varchar2)  or
    nvl(ota_tsp_shd.g_old_rec.tsp_information7, hr_api.g_varchar2) <>
    nvl(p_rec.tsp_information7, hr_api.g_varchar2)  or
    nvl(ota_tsp_shd.g_old_rec.tsp_information8, hr_api.g_varchar2) <>
    nvl(p_rec.tsp_information8, hr_api.g_varchar2)  or
    nvl(ota_tsp_shd.g_old_rec.tsp_information9, hr_api.g_varchar2) <>
    nvl(p_rec.tsp_information9, hr_api.g_varchar2)  or
    nvl(ota_tsp_shd.g_old_rec.tsp_information10, hr_api.g_varchar2) <>
    nvl(p_rec.tsp_information10, hr_api.g_varchar2)  or
    nvl(ota_tsp_shd.g_old_rec.tsp_information11, hr_api.g_varchar2) <>
    nvl(p_rec.tsp_information11, hr_api.g_varchar2)  or
    nvl(ota_tsp_shd.g_old_rec.tsp_information12, hr_api.g_varchar2) <>
    nvl(p_rec.tsp_information12, hr_api.g_varchar2)  or
    nvl(ota_tsp_shd.g_old_rec.tsp_information13, hr_api.g_varchar2) <>
    nvl(p_rec.tsp_information13, hr_api.g_varchar2)  or
    nvl(ota_tsp_shd.g_old_rec.tsp_information14, hr_api.g_varchar2) <>
    nvl(p_rec.tsp_information14, hr_api.g_varchar2)  or
    nvl(ota_tsp_shd.g_old_rec.tsp_information15, hr_api.g_varchar2) <>
    nvl(p_rec.tsp_information15, hr_api.g_varchar2)  or
    nvl(ota_tsp_shd.g_old_rec.tsp_information16, hr_api.g_varchar2) <>
    nvl(p_rec.tsp_information16, hr_api.g_varchar2)  or
    nvl(ota_tsp_shd.g_old_rec.tsp_information17, hr_api.g_varchar2) <>
    nvl(p_rec.tsp_information17, hr_api.g_varchar2)  or
    nvl(ota_tsp_shd.g_old_rec.tsp_information18, hr_api.g_varchar2) <>
    nvl(p_rec.tsp_information18, hr_api.g_varchar2)  or
    nvl(ota_tsp_shd.g_old_rec.tsp_information19, hr_api.g_varchar2) <>
    nvl(p_rec.tsp_information19, hr_api.g_varchar2)  or
    nvl(ota_tsp_shd.g_old_rec.tsp_information20, hr_api.g_varchar2) <>
    nvl(p_rec.tsp_information20, hr_api.g_varchar2) ))
    or (p_rec.skill_provision_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'OTA'
      ,p_descflex_name                   => 'OTA_SKILL_PROVISIONS'
      ,p_attribute_category              => p_rec.tsp_information_category
      ,p_attribute1_name                 => 'TSP_INFORMATION1'
      ,p_attribute1_value                => p_rec.tsp_information1
      ,p_attribute2_name                 => 'TSP_INFORMATION2'
      ,p_attribute2_value                => p_rec.tsp_information2
      ,p_attribute3_name                 => 'TSP_INFORMATION3'
      ,p_attribute3_value                => p_rec.tsp_information3
      ,p_attribute4_name                 => 'TSP_INFORMATION4'
      ,p_attribute4_value                => p_rec.tsp_information4
      ,p_attribute5_name                 => 'TSP_INFORMATION5'
      ,p_attribute5_value                => p_rec.tsp_information5
      ,p_attribute6_name                 => 'TSP_INFORMATION6'
      ,p_attribute6_value                => p_rec.tsp_information6
      ,p_attribute7_name                 => 'TSP_INFORMATION7'
      ,p_attribute7_value                => p_rec.tsp_information7
      ,p_attribute8_name                 => 'TSP_INFORMATION8'
      ,p_attribute8_value                => p_rec.tsp_information8
      ,p_attribute9_name                 => 'TSP_INFORMATION9'
      ,p_attribute9_value                => p_rec.tsp_information9
      ,p_attribute10_name                => 'TSP_INFORMATION10'
      ,p_attribute10_value               => p_rec.tsp_information10
      ,p_attribute11_name                => 'TSP_INFORMATION11'
      ,p_attribute11_value               => p_rec.tsp_information11
      ,p_attribute12_name                => 'TSP_INFORMATION12'
      ,p_attribute12_value               => p_rec.tsp_information12
      ,p_attribute13_name                => 'TSP_INFORMATION13'
      ,p_attribute13_value               => p_rec.tsp_information13
      ,p_attribute14_name                => 'TSP_INFORMATION14'
      ,p_attribute14_value               => p_rec.tsp_information14
      ,p_attribute15_name                => 'TSP_INFORMATION15'
      ,p_attribute15_value               => p_rec.tsp_information15
      ,p_attribute16_name                => 'TSP_INFORMATION16'
      ,p_attribute16_value               => p_rec.tsp_information16
      ,p_attribute17_name                => 'TSP_INFORMATION17'
      ,p_attribute17_value               => p_rec.tsp_information17
      ,p_attribute18_name                => 'TSP_INFORMATION18'
      ,p_attribute18_value               => p_rec.tsp_information18
      ,p_attribute19_name                => 'TSP_INFORMATION19'
      ,p_attribute19_value               => p_rec.tsp_information19
      ,p_attribute20_name                => 'TSP_INFORMATION20'
      ,p_attribute20_value               => p_rec.tsp_information20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;

-- ----------------------------------------------------------------------------
-- |----------------------< check_analysis_criteria_id >----------------------|
-- ----------------------------------------------------------------------------
Procedure check_analysis_criteria_id (p_analysis_criteria_id number) is
--
  l_proc varchar2(30) := 'check_analysis_criteria_id';
--
Begin
--
  hr_utility.set_location('Entering '||l_proc, 10);
  --
  if p_analysis_criteria_id is null then
    --
    fnd_message.set_name('OTA', 'OTA_13637_TSP_INFO_FIELD_NULL');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving '||l_proc, 10);
  --
end check_analysis_criteria_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ota_tsp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  check_analysis_criteria_id (p_rec.analysis_criteria_id);
  --
  --
ota_tsp_bus.chk_ddf(p_rec);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ota_tsp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  check_analysis_criteria_id (p_rec.analysis_criteria_id);
  --
  --
ota_tsp_bus.chk_ddf(p_rec);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ota_tsp_shd.g_rec_type) is
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
-- ---------------------------------------------------------------------------
-- |----------------------< set_security_group_id >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Sets the security_group_id in CLIENT_INFO for the appropriate business
--    group context.
--
--  Prerequisites:
--    The primary key identified by p_SKILL_PROVISION_ID
--     already exists.
--
--  In Arguments:
--    p_skill_provision_id
--
--
--  Post Success:
--    The security_group_id will be set in CLIENT_INFO.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure set_security_group_id
  (p_skill_provision_id                 in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_skill_provisions  tsp
         ,ota_activity_versions tav
     where tav.activity_version_id = tsp.activity_version_id
       and pbg.business_group_id = tav.business_group_id
       and tsp.skill_provision_id = p_skill_provision_id;
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
    ,p_argument           => 'skill_provision_id'
    ,p_argument_value     => p_skill_provision_id
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
        => nvl(p_associated_column1,'SKILL_PROVISION_ID')
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
-- ----------------------------------------------------------------------------
-- |-----------------------< return_legislation_code >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This function will be used by the user hooks. This will be  used
--   of by the user hooks of ota_skill_provisions usiness process.
--
-- Pre Conditions:
--   This function will be called by the user hook packages.
--
-- In Arguments:
--   p_skill_provison_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Errors out
--
-- Developer Implementation Notes:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--------------------------------------------------------------------------------
--

Function return_legislation_code
         ( p_skill_provision_id     in number
          ) return varchar2 is
--
-- Declare cursor
--
   cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_skill_provisions  tsp
         ,ota_activity_versions tav
     where tav.activity_version_id = tsp.activity_version_id
       and pbg.business_group_id = tav.business_group_id
       and tsp.skill_provision_id = p_skill_provision_id;


   l_proc              varchar2(72) := g_package||'return_legislation_code';
   l_legislation_code  varchar2(150);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that all the mandatory parameters are not null
  --
  hr_api.mandatory_arg_error (p_api_name       => l_proc,
                              p_argument       => 'skill_provision_id',
                              p_argument_value => p_skill_provision_id);
  open csr_leg_code;
  fetch csr_leg_code into l_legislation_code;
  if csr_leg_code%notfound then
     close csr_leg_code;
     --
     -- The primary key is invalid therefore we must error out
     --
     hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
     hr_utility.raise_error;
  end if;
  --
  close csr_leg_code;
  return l_legislation_code;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End return_legislation_code;
end ota_tsp_bus;

/
