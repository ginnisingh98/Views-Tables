--------------------------------------------------------
--  DDL for Package Body IRC_ISC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_ISC_BUS" as
/* $Header: iriscrhi.pkb 120.0 2005/07/26 15:11:17 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_isc_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_search_criteria_id          number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_search_criteria_id                   in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare local variables
  --
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
    ,p_argument           => 'search_criteria_id'
    ,p_argument_value     => p_search_criteria_id
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
  (p_search_criteria_id                   in     number
  )
  Return Varchar2 Is
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150) := 'NONE';
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
    ,p_argument           => 'search_criteria_id'
    ,p_argument_value     => p_search_criteria_id
    );
  --
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
  (p_rec in irc_isc_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.search_criteria_id is not null)  and (
    nvl(irc_isc_shd.g_old_rec.isc_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information_category, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.isc_information1, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information1, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.isc_information2, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information2, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.isc_information3, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information3, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.isc_information4, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information4, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.isc_information5, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information5, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.isc_information6, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information6, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.isc_information7, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information7, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.isc_information8, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information8, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.isc_information9, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information9, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.isc_information10, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information10, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.isc_information11, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information11, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.isc_information12, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information12, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.isc_information13, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information13, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.isc_information14, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information14, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.isc_information15, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information15, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.isc_information16, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information16, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.isc_information17, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information17, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.isc_information18, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information18, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.isc_information19, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information19, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.isc_information20, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information20, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.isc_information21, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information21, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.isc_information22, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information22, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.isc_information23, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information23, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.isc_information24, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information24, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.isc_information25, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information25, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.isc_information26, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information26, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.isc_information27, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information27, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.isc_information28, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information28, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.isc_information29, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information29, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.isc_information30, hr_api.g_varchar2) <>
    nvl(p_rec.isc_information30, hr_api.g_varchar2) ))
    or (p_rec.search_criteria_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'IRC_SEARCH_CRITERIA_DDF'
      ,p_attribute_category              => p_rec.isc_information_category
      ,p_attribute1_name                 => 'ISC_INFORMATION1'
      ,p_attribute1_value                => p_rec.isc_information1
      ,p_attribute2_name                 => 'ISC_INFORMATION2'
      ,p_attribute2_value                => p_rec.isc_information2
      ,p_attribute3_name                 => 'ISC_INFORMATION3'
      ,p_attribute3_value                => p_rec.isc_information3
      ,p_attribute4_name                 => 'ISC_INFORMATION4'
      ,p_attribute4_value                => p_rec.isc_information4
      ,p_attribute5_name                 => 'ISC_INFORMATION5'
      ,p_attribute5_value                => p_rec.isc_information5
      ,p_attribute6_name                 => 'ISC_INFORMATION6'
      ,p_attribute6_value                => p_rec.isc_information6
      ,p_attribute7_name                 => 'ISC_INFORMATION7'
      ,p_attribute7_value                => p_rec.isc_information7
      ,p_attribute8_name                 => 'ISC_INFORMATION8'
      ,p_attribute8_value                => p_rec.isc_information8
      ,p_attribute9_name                 => 'ISC_INFORMATION9'
      ,p_attribute9_value                => p_rec.isc_information9
      ,p_attribute10_name                => 'ISC_INFORMATION10'
      ,p_attribute10_value               => p_rec.isc_information10
      ,p_attribute11_name                => 'ISC_INFORMATION11'
      ,p_attribute11_value               => p_rec.isc_information11
      ,p_attribute12_name                => 'ISC_INFORMATION12'
      ,p_attribute12_value               => p_rec.isc_information12
      ,p_attribute13_name                => 'ISC_INFORMATION13'
      ,p_attribute13_value               => p_rec.isc_information13
      ,p_attribute14_name                => 'ISC_INFORMATION14'
      ,p_attribute14_value               => p_rec.isc_information14
      ,p_attribute15_name                => 'ISC_INFORMATION15'
      ,p_attribute15_value               => p_rec.isc_information15
      ,p_attribute16_name                => 'ISC_INFORMATION16'
      ,p_attribute16_value               => p_rec.isc_information16
      ,p_attribute17_name                => 'ISC_INFORMATION17'
      ,p_attribute17_value               => p_rec.isc_information17
      ,p_attribute18_name                => 'ISC_INFORMATION18'
      ,p_attribute18_value               => p_rec.isc_information18
      ,p_attribute19_name                => 'ISC_INFORMATION19'
      ,p_attribute19_value               => p_rec.isc_information19
      ,p_attribute20_name                => 'ISC_INFORMATION20'
      ,p_attribute20_value               => p_rec.isc_information20
      ,p_attribute21_name                => 'ISC_INFORMATION21'
      ,p_attribute21_value               => p_rec.isc_information21
      ,p_attribute22_name                => 'ISC_INFORMATION22'
      ,p_attribute22_value               => p_rec.isc_information22
      ,p_attribute23_name                => 'ISC_INFORMATION23'
      ,p_attribute23_value               => p_rec.isc_information23
      ,p_attribute24_name                => 'ISC_INFORMATION24'
      ,p_attribute24_value               => p_rec.isc_information24
      ,p_attribute25_name                => 'ISC_INFORMATION25'
      ,p_attribute25_value               => p_rec.isc_information25
      ,p_attribute26_name                => 'ISC_INFORMATION26'
      ,p_attribute26_value               => p_rec.isc_information26
      ,p_attribute27_name                => 'ISC_INFORMATION27'
      ,p_attribute27_value               => p_rec.isc_information27
      ,p_attribute28_name                => 'ISC_INFORMATION28'
      ,p_attribute28_value               => p_rec.isc_information28
      ,p_attribute29_name                => 'ISC_INFORMATION29'
      ,p_attribute29_value               => p_rec.isc_information29
      ,p_attribute30_name                => 'ISC_INFORMATION30'
      ,p_attribute30_value               => p_rec.isc_information30
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
  (p_rec in irc_isc_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.search_criteria_id is not null)  and (
    nvl(irc_isc_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(irc_isc_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    or (p_rec.search_criteria_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'IRC_SEARCH_CRITERIA'
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
  ,p_rec in irc_isc_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT irc_isc_shd.api_updating
      (p_search_criteria_id                => p_rec.search_criteria_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- Add checks to ensure non-updateable args have
  -- not been updated.
  --
  if p_rec.search_criteria_id <>
       irc_isc_shd.g_old_rec.search_criteria_id then
     hr_api.argument_changed_error
     (p_api_name   => l_proc
     ,p_argument   => 'SEARCH_CRITERIA_ID'
     ,p_base_table => irc_isc_shd.g_tab_nam
     );
  end if;
  --
  --
  if p_rec.object_id <> irc_isc_shd.g_old_rec.object_id  then
    if p_rec.object_type = 'PERSON' then
      hr_api.argument_changed_error
      ( p_api_name     => l_proc
       ,p_argument     => 'PERSON_ID'
       ,p_base_table   => irc_isc_shd.g_tab_nam
      );
    elsif p_rec.object_type = 'VACANCY' then
      hr_api.argument_changed_error
      ( p_api_name     => l_proc
       ,p_argument     => 'VACANCY_ID'
       ,p_base_table   => irc_isc_shd.g_tab_nam
      );
    end if;
  end if;
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_person_id >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that object_id exists in PER_ALL_PEOPLE_F
--   as 'PERSON' type when the object_type is 'PERSON'
--
-- Pre Conditions:
--
-- In Arguments:
--  p_person_id
--
-- Post Success:
--  Processing continues if object_id is valid.
--
-- Post Failure:
--   An application error is raised if object_id is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_person_id
  (p_person_id in irc_search_criteria.object_id%TYPE
  ,p_effective_date in Date
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_person_id';
  l_person_id varchar2(1);
--
  cursor csr_person_id is
    select null
    from per_all_people_f ppf
    where ppf.person_id = p_person_id
    and trunc(p_effective_date) between ppf.effective_start_date
    and ppf.effective_end_date;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
-- Check that Person_ID is not null.
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'PERSON_ID'
  ,p_argument_value     => p_person_id
  );
-- Check that Person_ID(Object_id) exists in per_all_people_f
  hr_utility.set_location(l_proc,20);
  open csr_person_id;
  fetch csr_person_id into l_person_id;
  hr_utility.set_location(l_proc,30);
  if csr_person_id%NOTFOUND then
    close csr_person_id;
    fnd_message.set_name('PER','IRC_412008_BAD_PARTY_PERSON_ID');
    fnd_message.raise_error;
  end if;
  close csr_person_id;
  hr_utility.set_location(' Leaving:'||l_proc,40);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
       'IRC_SEARCH_CRITERIA.OBJECT_ID'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,50);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_person_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_unique_work >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure only one set of work preferences exists
--   for a person
--
-- Pre Conditions:
--
-- In Arguments:
--  p_person_id
--
-- Post Success:
--  Processing continues if there is not an existing set of work choices .
--
-- Post Failure:
--   An application error is raised if the work choices exist.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_unique_work
  (p_object_id in irc_search_criteria.object_id%TYPE
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_unique_work';
--
  cursor csr_work_choices is
    select 1
    from irc_search_criteria isc
    where isc.object_id = p_object_id
    and isc.object_type = 'WPREF';
l_dummy number;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  open csr_work_choices;
  fetch csr_work_choices into l_dummy;
  hr_utility.set_location(l_proc,20);
  if csr_work_choices%found then
    close csr_work_choices;
    fnd_message.set_name('PER','IRC_412127_TOO_MANY_WORK_CH');
    fnd_message.raise_error;
  else
    close csr_work_choices;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,40);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
       'IRC_SEARCH_CRITERIA.OBJECT_ID'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,50);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_unique_work;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_search_name >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that search_name is unique for a person_id
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_search_name
--  p_person_id
--  p_search_criteria_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if search_name is valid.
--
-- Post Failure:
--   An application error is raised search_name is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_search_name
  (p_search_name           in irc_search_criteria.search_name%TYPE
  ,p_person_id             in irc_search_criteria.object_id%TYPE
  ,p_search_criteria_id    in irc_search_criteria.search_criteria_id%TYPE
  ,p_object_version_number in irc_search_criteria.object_version_number%TYPE
  ) IS
--
  l_proc         varchar2(72) := g_package || 'chk_search_name';
  l_search_name  varchar2(1);
  l_api_updating boolean;
--
  cursor csr_search_name is
    select null from irc_search_criteria isc
    where isc.search_name  = p_search_name
    and isc.object_id = p_person_id ;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  if p_search_name is not null then
    --
    hr_utility.set_location(l_proc,20);
    l_api_updating  :=   irc_isc_shd.api_updating
                         (p_search_criteria_id    => p_search_criteria_id
                         ,p_object_version_number => p_object_version_number
                         );
      hr_utility.set_location(l_proc,30);
    if (l_api_updating  and
        p_search_name <>
        NVL(irc_isc_shd.g_old_rec.search_name,hr_api.g_varchar2)
       ) or (NOT l_api_updating) then
      -- Check that search_name is unique for a person_id
      hr_utility.set_location(l_proc,40);
      open csr_search_name;
      fetch csr_search_name into l_search_name;
      hr_utility.set_location(l_proc,50);
      if csr_search_name%FOUND then
        close csr_search_name;
        fnd_message.set_name('PER','IRC_412009_SEARCH_NAME_EXISTS');
        fnd_message.raise_error;
      end if;
      close csr_search_name;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,60);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
       'IRC_SEARCH_CRITERIA.SEARCH_NAME'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,70);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,80);
end chk_search_name;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_distance_to_location >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that distance to location is not less then zero.
--   Checks that location is not null if distance to location is a valid
--   positive number.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_distance_to_location
--  p_location
--  p_search_criteria_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if distance_to_location and location are valid.
--
-- Post Failure:
--   An application error is raised if either distance_to_location or location
--   is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_distance_to_location
  (p_distance_to_location  in irc_search_criteria.distance_to_location%TYPE
  ,p_geocode_location      in irc_search_criteria.geocode_location%TYPE
  ,p_search_criteria_id    in irc_search_criteria.search_criteria_id%TYPE
  ,p_object_version_number in irc_search_criteria.object_version_number%TYPE
  ) IS
--
  l_proc         varchar2(72) := g_package || 'chk_distance_to_location';
  l_api_updating boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  if p_distance_to_location is not null then
    --
    hr_utility.set_location(l_proc,20);
    l_api_updating  :=   irc_isc_shd.api_updating
                         (p_search_criteria_id    => p_search_criteria_id
                         ,p_object_version_number => p_object_version_number
                         );
    --
    hr_utility.set_location(l_proc,30);
    if (l_api_updating  and
        p_distance_to_location <>
        NVL(irc_isc_shd.g_old_rec.distance_to_location,hr_api.g_number))
        or (NOT l_api_updating) then
      -- Check that distance_to_location is a valid positive number.
      hr_utility.set_location(l_proc,40);
      if p_distance_to_location < 0 then
        fnd_message.set_name('PER','IRC_412010_BAD_DISTANCE_TO_LOC');
        hr_multi_message.add
          (p_associated_column1 => 'IRC_SEARCH_CRITERIA.DISTANCE_TO_LOCATION'
          );
      else
        -- Check that location is a valid.
        hr_utility.set_location(l_proc,50);
        if p_geocode_location is null  then
          fnd_message.set_name('PER','IRC_412011_BAD_LOCATION');
          hr_multi_message.add
          (p_associated_column1 => 'IRC_SEARCH_CRITERIA.GEOCODE_LOCATION'
          );
        end if;
      end if;
    end if;
  else
  -- the distance to location is null - check that the geocode location is too
      hr_utility.set_location(l_proc,60);
    if p_geocode_location is not null then
        fnd_message.set_name('PER','IRC_412164_NO_DISTANCE');
        hr_multi_message.add
          (p_associated_column1 => 'IRC_SEARCH_CRITERIA.DISTANCE_TO_LOCATION'
          );
    end if;
  end if;
hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_distance_to_location;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_location_id >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that the location_id is valid
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_location_id
--  p_search_criteria_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if the location_id is valid
--
-- Post Failure:
--   An application error is raised if the location_id is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_location_id
  (p_location_id  in irc_search_criteria.location_id%TYPE
  ,p_search_criteria_id    in irc_search_criteria.search_criteria_id%TYPE
  ,p_object_version_number in irc_search_criteria.object_version_number%TYPE
  ) IS
--
  l_proc         varchar2(72) := g_package || 'chk_location_id';
  l_api_updating boolean;
--
  l_dummy number;
--
  cursor chk_loc is
  select 1 from hr_locations_all
  where location_id=p_location_id;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  if p_location_id is not null then
    --
    hr_utility.set_location(l_proc,20);
    l_api_updating  :=   irc_isc_shd.api_updating
                         (p_search_criteria_id    => p_search_criteria_id
                         ,p_object_version_number => p_object_version_number
                         );
    --
    hr_utility.set_location(l_proc,30);
    if (l_api_updating  and
        p_location_id <>
        NVL(irc_isc_shd.g_old_rec.location_id,hr_api.g_number))
        or (NOT l_api_updating) then
      -- Check that location_id is a valid
      hr_utility.set_location(l_proc,40);
      open chk_loc;
      fetch chk_loc into l_dummy;
      if chk_loc%notfound then
        close chk_loc;
        fnd_message.set_name('PER','IRC_412165_BAD_LOCATION_ID');
        hr_multi_message.add
          (p_associated_column1 => 'IRC_SEARCH_CRITERIA.LOCATION_ID'
          );
      else
        close chk_loc;
      end if;
    end if;
  end if;
hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_location_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_longitude_latitude >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that either both the longitude and latitude are
--   specified, or neither is specified
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_longitude
--  p_latitude
--  p_search_criteria_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if the data is correct
--
-- Post Failure:
--   An application error is raised if only one of longitude or latitude are
--   specified
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_longitude_latitude
  (p_longitude  in number
  ,p_latitude   in number
  ,p_search_criteria_id    in irc_search_criteria.search_criteria_id%TYPE
  ,p_object_version_number in irc_search_criteria.object_version_number%TYPE
  ) IS
--
  l_proc         varchar2(72) := g_package || 'chk_longitude_latitude';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  if (p_longitude is not null and p_latitude is null)
    or (p_longitude is null and p_latitude is not null) then
    --
    hr_utility.set_location(l_proc,20);
    fnd_message.set_name('PER','IRC_412166_LONG_LAT');
    hr_multi_message.add
    (p_associated_column1 => 'IRC_SEARCH_CRITERIA.GEOMETRY'
    );
  end if;
hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_longitude_latitude;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_use_for_matching >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that use for matching should have a value of 'Y' or
--   'N'
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_use_for_matching
--  p_search_criteria_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if use_for_matching is valid.
--
-- Post Failure:
--   An application error is raised use_for_matching is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_use_for_matching
  (p_use_for_matching      in irc_search_criteria.use_for_matching%TYPE
  ,p_search_criteria_id    in irc_search_criteria.search_criteria_id%TYPE
  ,p_object_version_number in irc_search_criteria.object_version_number%TYPE
  ) IS
--
  l_proc         varchar2(72) := g_package || 'chk_use_for_matching';
  l_api_updating boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  if p_use_for_matching is not null then
    --
    hr_utility.set_location(l_proc,20);
    l_api_updating  :=   irc_isc_shd.api_updating
                         (p_search_criteria_id    => p_search_criteria_id
                         ,p_object_version_number => p_object_version_number
                         );
    --
    hr_utility.set_location(l_proc,30);
    if (l_api_updating  and
        p_use_for_matching <>
        NVL(irc_isc_shd.g_old_rec.use_for_matching,hr_api.g_varchar2)
       ) or (NOT l_api_updating) then
      -- Check that use_for_matching is having a valid value of 'Y' or 'N'
      hr_utility.set_location(l_proc,40);
      if not p_use_for_matching in ('Y','N') then
        fnd_message.set_name('PER','IRC_412012_BAD_USE_FOR_MATCHIN');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,50);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
       'IRC_SEARCH_CRITERIA.USE_FOR_MATCHING'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
end chk_use_for_matching;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_match_competence >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that use for matching should have a value of 'Y' or
--   'N'
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_match_competence
--  p_search_criteria_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if match_competence is valid.
--
-- Post Failure:
--   An application error is raised match_competence is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_match_competence
  (p_match_competence      in irc_search_criteria.match_competence%TYPE
  ,p_search_criteria_id    in irc_search_criteria.search_criteria_id%TYPE
  ,p_object_version_number in irc_search_criteria.object_version_number%TYPE
  ) IS
--
  l_proc         varchar2(72) := g_package || 'chk_match_competence';
  l_api_updating boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  if p_match_competence is not null then
    hr_utility.set_location(l_proc,20);
    l_api_updating  :=   irc_isc_shd.api_updating
                         (p_search_criteria_id    => p_search_criteria_id
                         ,p_object_version_number => p_object_version_number
                         );
    --
    hr_utility.set_location(l_proc,30);
    if (l_api_updating  and
        p_match_competence <>
        NVL(irc_isc_shd.g_old_rec.match_competence,hr_api.g_varchar2)
       ) or (NOT l_api_updating) then
      -- Check that match_competence is having a valid value of 'Y' or 'N'
      hr_utility.set_location(l_proc,40);
      if not p_match_competence in ('Y','N') then
        fnd_message.set_name('PER','IRC_412013_BAD_MATCH_COMPETENC');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,50);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
       'IRC_SEARCH_CRITERIA.MATCH_COMPETENCE'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
end chk_match_competence;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_match_qualification >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that match qualification should have a value of 'Y'
--   or 'N'
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_match_qualification
--  p_search_criteria_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if match_qualification is valid.
--
-- Post Failure:
--   An application error is raised match_qualification is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_match_qualification
  (p_match_qualification   in irc_search_criteria.match_qualification%TYPE
  ,p_search_criteria_id    in irc_search_criteria.search_criteria_id%TYPE
  ,p_object_version_number in irc_search_criteria.object_version_number%TYPE
  ) IS
--
  l_proc         varchar2(72) := g_package || 'chk_match_qualification';
  l_api_updating boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  if p_match_qualification is not null then
    --
    hr_utility.set_location(l_proc,20);
    l_api_updating  :=   irc_isc_shd.api_updating
                         (p_search_criteria_id    => p_search_criteria_id
                         ,p_object_version_number => p_object_version_number
                         );
    --
    hr_utility.set_location(l_proc,30);
    if (l_api_updating  and
        p_match_qualification <>
        NVL(irc_isc_shd.g_old_rec.match_qualification,hr_api.g_varchar2)
       ) or (NOT l_api_updating) then
      -- Check that match_qualification is having a valid value of 'Y' or 'N'
      hr_utility.set_location(l_proc,40);
      if not p_match_qualification in ('Y','N') then
        fnd_message.set_name('PER','IRC_412014_BAD_MATCH_QUALIFICA');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,50);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
       'IRC_SEARCH_CRITERIA.MATCH_QUALIFICATION'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
end chk_match_qualification;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_vacancy_id >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that vacancy_id exists in per_all_vacancies.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_vacancy_id
--  p_effective_date
--
-- Post Success:
--   Processing continues if vacancy_id is valid.
--
-- Post Failure:
--   An application error is raised if vacancy_id is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_vacancy_id
  (p_vacancy_id     in irc_search_criteria.object_id%TYPE
  ,p_effective_date in date
  ) IS
--
  l_proc       varchar2(72) := g_package || 'chk_vacancy_id';
  l_vacancy_id varchar2(1);
--
  cursor csr_vacancy_id is
    select null from per_all_vacancies pav
    where pav.vacancy_id = p_vacancy_id;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  -- Check that Vacancy_id is not null.
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'VACANCY_ID'
  ,p_argument_value     => p_vacancy_id
  );
  -- Check that vacancy_id exists in per_all_vacancies.
  hr_utility.set_location(l_proc,20);
  open csr_vacancy_id;
  fetch csr_vacancy_id into l_vacancy_id;
  hr_utility.set_location(l_proc,30);
  if csr_vacancy_id%NOTFOUND then
    close csr_vacancy_id;
    fnd_message.set_name('PER','IRC_412015_BAD_VACANCY_ID');
    fnd_message.raise_error;
  end if;
  close csr_vacancy_id;
  hr_utility.set_location(' Leaving:'||l_proc,40);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
       'IRC_SEARCH_CRITERIA.OBJECT_ID'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,50);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_vacancy_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_min_qual_level >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that min_qual_level exists in
--   per_qualification_types.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_min_qual_level
--  p_search_criteria_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if min_qual_level is valid.
--
-- Post Failure:
--   An application error is raised if min_qual_level is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_min_qual_level
  (p_min_qual_level        in irc_search_criteria.min_qual_level%TYPE
  ,p_search_criteria_id    in irc_search_criteria.search_criteria_id%TYPE
  ,p_object_version_number in irc_search_criteria.object_version_number%TYPE
  ) IS
--
  l_proc           varchar2(72) := g_package || 'chk_min_qual_level';
  l_min_qual_level varchar2(1);
  l_api_updating   boolean;
--
  cursor csr_min_qual_level is
    select null from per_qualification_types pqt
    where pqt.qualification_type_id = p_min_qual_level;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  if p_min_qual_level is not null then
    --
    hr_utility.set_location(l_proc,20);
    l_api_updating  :=   irc_isc_shd.api_updating
                         (p_search_criteria_id    => p_search_criteria_id
                         ,p_object_version_number => p_object_version_number
                         );
    --
    hr_utility.set_location(l_proc,30);
    if (l_api_updating  and
        p_min_qual_level <>
        NVL(irc_isc_shd.g_old_rec.min_qual_level,hr_api.g_number)
       ) or (NOT l_api_updating) then
      hr_utility.set_location(l_proc,40);
      open csr_min_qual_level;
      fetch csr_min_qual_level into l_min_qual_level ;
      hr_utility.set_location(l_proc,50);
      -- Check that min_qual_level exists in per_qualification_types
      if csr_min_qual_level%NOTFOUND then
        close csr_min_qual_level;
        fnd_message.set_name('PER','IRC_412016_BAD_MIN_QUAL_LEVEL');
        fnd_message.raise_error;
      end if;
      close csr_min_qual_level;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,60);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
       'IRC_SEARCH_CRITERIA.MIN_QUAL_LEVEL'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,70);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,80);
end chk_min_qual_level;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_qual_rank >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that max_qual_level is greater than min_qual_level
--   based on values of rank in PER_QUALIFICATION_TYPES.
--
-- Pre Conditions:
--
-- In Arguments:
--  p_min_qual_level
--  p_max_qual_level
--
-- Post Success:
--   Processing continues if max_qual_level is greater than min_qual_level.
--
-- Post Failure:
--   An application error is raised if min_qual_level is greater than
--   max_qual_level.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_qual_rank
  ( p_min_qual_level in irc_search_criteria.min_qual_level%TYPE
  , p_max_qual_level in irc_search_criteria.max_qual_level%TYPE
  ) IS
--
  l_proc varchar2(72):= g_package|| 'chk_qual_rank';
  l_min_qual_rank  per_qualification_types.rank%TYPE;
  l_max_qual_rank  per_qualification_types.rank%TYPE;
--
cursor csr_qual_rank(c_qual_type_id per_qualification_types.qualification_type_id%TYPE) is
  select rank from per_qualification_types where qualification_type_id = c_qual_type_id;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  -- Only proceed with rank validation when multiple message list does not
  -- already contain an error associated with the min_qual_level or max_qual_level
  -- columns.
  hr_utility.set_location(l_proc,15);
  if hr_multi_message.no_all_inclusive_error
  ( p_check_column1 => 'IRC_SEARCH_CRITERIA.MIN_QUAL_LEVEL'
   ,p_check_column2 => 'IRC_SEARCH_CRITERIA.MAX_QUAL_LEVEL'
   ) then
  --
    hr_utility.set_location(l_proc,20);
    if ( p_min_qual_level is not null) AND (p_max_qual_level is not null) then
      hr_utility.set_location(l_proc,25);
      open csr_qual_rank(p_min_qual_level);
      fetch csr_qual_rank into l_min_qual_rank;
      close csr_qual_rank;
      open csr_qual_rank(p_max_qual_level);
      fetch csr_qual_rank into l_max_qual_rank;
      close csr_qual_rank;
    end if;
    if (l_min_qual_rank > l_max_qual_rank)then
      hr_utility.set_location(l_proc,30);
      fnd_message.set_name('PER', 'IRC_412139_MIN_MAX_QUAL_RANK');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location('Leaving:'||l_proc,40);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'IRC_SEARCH_CRITERIA.MIN_QUAL_LEVEL'
       ,p_associated_column2 => 'IRC_SEARCH_CRITERIA.MAX_QUAL_LEVEL'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,50);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_qual_rank;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_min_salary >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that min_salary is a positive number.
--   Also checks that salary_currency is not null when min_salary is a valid
--   positive number.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  min_salary
--  p_search_criteria_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if both min_salary and salary_currency are valid.
--
-- Post Failure:
--   An application error is raised if either min_salary or salary_currency is
--   invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_min_salary
  (p_min_salary            in irc_search_criteria.min_salary%TYPE
  ,p_search_criteria_id    in irc_search_criteria.search_criteria_id%TYPE
  ,p_object_version_number in irc_search_criteria.object_version_number%TYPE
  ) IS
--
  l_proc       varchar2(72) := g_package || 'chk_min_salary';
  l_min_salary varchar2(1);
  l_api_updating boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  if p_min_salary is not null then
    --
    hr_utility.set_location(l_proc,20);
    l_api_updating  :=   irc_isc_shd.api_updating
                         (p_search_criteria_id    => p_search_criteria_id
                         ,p_object_version_number => p_object_version_number
                         );
    --
    hr_utility.set_location(l_proc,30);
    if (l_api_updating  and
        p_min_salary <>
        NVL(irc_isc_shd.g_old_rec.min_salary,hr_api.g_number)
       ) or (NOT l_api_updating) then
      -- Check that min_salary is a valid positive number.
      hr_utility.set_location(l_proc,40);
      if p_min_salary < 0 then
        fnd_message.set_name('PER','IRC_412017_BAD_MIN_SALARY');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,50);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'IRC_SEARCH_CRITERIA.MIN_SALARY'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
end chk_min_salary;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_max_salary >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that max_salary is a positive number and is greater
--   then min_salary.
--   Also checks that salary_currency is not null when max_salary is a valid
--   positive number.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  max_salary
--  min_salary
--  p_search_criteria_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if max_salary and salary_currency are valid.
--
-- Post Failure:
--   An application error is raised if either max_salary or salary_currency is
--   invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_max_salary
  (p_max_salary            in irc_search_criteria.max_salary%TYPE
  ,p_min_salary            in irc_search_criteria.min_salary%TYPE
  ,p_search_criteria_id    in irc_search_criteria.search_criteria_id%TYPE
  ,p_object_version_number in irc_search_criteria.object_version_number%TYPE
  ) IS
--
  l_proc       varchar2(72) := g_package || 'chk_max_salary';
  l_min_salary varchar2(1);
  l_api_updating boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Only proceed with max_salary validation when multiple message list does not
  -- already contain an error associated with the min_salary columns.
  hr_utility.set_location(l_proc,15);
  if hr_multi_message.no_exclusive_error(
     p_check_column1      => 'IRC_SEARCH_CRITERIA.MIN_SALARY'
    ) then
    if p_max_salary is not null then
      --
      hr_utility.set_location(l_proc,20);
    l_api_updating  :=   irc_isc_shd.api_updating
                         (p_search_criteria_id    => p_search_criteria_id
                         ,p_object_version_number => p_object_version_number
                         );
      --
      hr_utility.set_location(l_proc,30);
      if (l_api_updating  and
          p_max_salary <>
          NVL(irc_isc_shd.g_old_rec.max_salary,hr_api.g_number)
         ) or (NOT l_api_updating) then
        -- Check that max_salary is greater then min salary.
        hr_utility.set_location(l_proc,40);
        if p_max_salary < 0 or p_max_salary < NVL(p_min_salary,hr_api.g_number)
        then
          fnd_message.set_name('PER','IRC_412019_MAX_BELOW_MIN_SAL');
          fnd_message.raise_error;
        end if;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,50);
   exception
  -- When Multiple error detection is enabled handle the application errors
  -- which have been raised by this procedure. Transfer the error to the
  -- Multiple message list and associate the error with max_salary and
  -- min_salary
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'IRC_SEARCH_CRITERIA.MIN_SALARY'
       ,p_associated_column2 => 'IRC_SEARCH_CRITERIA.MAX_SALARY'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
end chk_max_salary;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_employee >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that employee has a valid value of 'Y' or
--   'N'.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_employee
--  p_search_criteria_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if employee value is valid.
--
-- Post Failure:
--   An application error is raised if employee value is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_employee
  (p_employee              in irc_search_criteria.employee%TYPE
  ,p_search_criteria_id    in irc_search_criteria.search_criteria_id%TYPE
  ,p_object_version_number in irc_search_criteria.object_version_number%TYPE
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_employee';
  l_api_updating      boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  l_api_updating  :=   irc_isc_shd.api_updating
                       (p_search_criteria_id    => p_search_criteria_id
                       ,p_object_version_number => p_object_version_number
                       );
  --
  hr_utility.set_location(l_proc,20);
  if (l_api_updating  and p_employee <> irc_isc_shd.g_old_rec.employee)
       or (NOT l_api_updating) then
    -- Check that employee is having a valid value of 'Y' or 'N'
    hr_utility.set_location(l_proc,30);
    if (p_employee is null) or (p_employee Not in ('Y','N')) then
      fnd_message.set_name('PER','IRC_412020_BAD_EMPLOYEE');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,40);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'IRC_SEARCH_CRITERIA.EMPLOYEE'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,50);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_employee;
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_contractor >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that contractor has a valid value of 'Y'
--   or 'N'.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_contractor
--  p_search_criteria_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if contractor value is valid.
--
-- Post Failure:
--   An application error is raised if contractor value is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_contractor
  (p_contractor            in irc_search_criteria.contractor%TYPE
  ,p_search_criteria_id    in irc_search_criteria.search_criteria_id%TYPE
  ,p_object_version_number in irc_search_criteria.object_version_number%TYPE
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_contractor';
  l_api_updating      boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  l_api_updating  :=   irc_isc_shd.api_updating
                       (p_search_criteria_id    => p_search_criteria_id
                       ,p_object_version_number => p_object_version_number
                       );
  hr_utility.set_location(l_proc,20);
  if (l_api_updating  and p_contractor <> irc_isc_shd.g_old_rec.contractor)
       or (NOT l_api_updating) then
    -- Check that contractor is having a valid value of 'Y' or 'N'
    hr_utility.set_location(l_proc,30);
    if (p_contractor is null) or (p_contractor Not in ('Y','N')) then
      fnd_message.set_name('PER','IRC_412021_BAD_CONTRACTOR');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,40);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>  'IRC_SEARCH_CRITERIA.CONTRACTOR'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,50);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_contractor;
-- ----------------------------------------------------------------------------
-- |------------------------< chk_professional_area >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that professional area exists in
--   hr_lookups
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_professional_area
--  p_effective_date
--  p_search_criteria_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if professional_area is valid.
--
-- Post Failure:
--   An application error is raised if professional_area is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_professional_area
  (p_professional_area     in irc_search_criteria.professional_area%TYPE
  ,p_effective_date        in date
  ,p_search_criteria_id    in irc_search_criteria.search_criteria_id%TYPE
  ,p_object_version_number in irc_search_criteria.object_version_number%TYPE
  ) IS
--
  l_proc              varchar2(72) := g_package || 'chk_professional_area';
  l_api_updating      boolean;
  l_ret               boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  l_api_updating  :=   irc_isc_shd.api_updating
                       (p_search_criteria_id    => p_search_criteria_id
                       ,p_object_version_number => p_object_version_number
                       );
  hr_utility.set_location(l_proc,20);
  if p_professional_area is not null then
    hr_utility.set_location(l_proc,30);
    if (l_api_updating  and
        p_professional_area <>
        NVL(irc_isc_shd.g_old_rec.professional_area,hr_api.g_varchar2)
        ) or (NOT l_api_updating) then
      -- Check that professional_area exists in hr_lookups
      hr_utility.set_location(l_proc,40);
      l_ret := hr_api.not_exists_in_hr_lookups(
                                     p_effective_date => p_effective_date
                                    ,p_lookup_type    => 'IRC_PROFESSIONAL_AREA'
                                    ,p_lookup_code    => p_professional_area);
      if l_ret = true then
        fnd_message.set_name('PER','IRC_412022_BAD_PROF_AREA');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
hr_utility.set_location(' Leaving:'||l_proc,50);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'IRC_SEARCH_CRITERIA.PROFESSIONAL_AREA'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
end chk_professional_area;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_employment_category >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that employment category exists in
--   hr_lookups
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_employment_category
--  p_effective_date
--  p_search_criteria_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if employment category is valid.
--
-- Post Failure:
--   An application error is raised if employment category is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_employment_category
  (p_employment_category   in irc_search_criteria.employment_category%TYPE
  ,p_effective_date        in date
  ,p_search_criteria_id    in irc_search_criteria.search_criteria_id%TYPE
  ,p_object_version_number in irc_search_criteria.object_version_number%TYPE
  ) IS
--
  l_proc              varchar2(72) := g_package || 'chk_employment_category';
  l_api_updating      boolean;
  l_ret               boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  if p_employment_category is not null then
    --
    hr_utility.set_location(l_proc,20);
    l_api_updating  :=   irc_isc_shd.api_updating
                         (p_search_criteria_id    => p_search_criteria_id
                         ,p_object_version_number => p_object_version_number
                         );
    --
    hr_utility.set_location(l_proc,30);
    if (l_api_updating  and
        p_employment_category <>
        NVL(irc_isc_shd.g_old_rec.employment_category,hr_api.g_varchar2)
       ) or (NOT l_api_updating) then
      -- Check that employment_category exists in hr_lookups
      hr_utility.set_location(l_proc,40);
      l_ret := hr_api.not_exists_in_hr_lookups(
                                     p_effective_date => p_effective_date
                                    ,p_lookup_type    => 'IRC_EMP_CAT'
                                    ,p_lookup_code    => p_employment_category);
      if l_ret = true then
        fnd_message.set_name('PER','IRC_412023_BAD_EMP_CATEGORY');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,50);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'IRC_SEARCH_CRITERIA.EMPLOYMENT_CATEGORY'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
end chk_employment_category;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_work_at_home >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that work_at_home exists in
--   hr_lookups
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_work_at_home
--  p_effective_date
--  p_search_criteria_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if work_at_home is valid.
--
-- Post Failure:
--   An application error is raised if work_at_home is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_work_at_home
  (p_work_at_home          in irc_search_criteria.work_at_home%TYPE
  ,p_effective_date        in date
  ,p_search_criteria_id    in irc_search_criteria.search_criteria_id%TYPE
  ,p_object_version_number in irc_search_criteria.object_version_number%TYPE
  ) IS
--
  l_proc              varchar2(72) := g_package || 'chk_work_at_home';
  l_api_updating      boolean;
  l_ret               boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  if p_work_at_home is not null then
    --
    hr_utility.set_location(l_proc,20);
    l_api_updating  :=   irc_isc_shd.api_updating
                         (p_search_criteria_id    => p_search_criteria_id
                         ,p_object_version_number => p_object_version_number
                         );
    --
    hr_utility.set_location(l_proc,30);
    if (l_api_updating  and
        p_work_at_home <>
        NVL(irc_isc_shd.g_old_rec.work_at_home,hr_api.g_varchar2)
        ) or (NOT l_api_updating) then
      -- Check that work_at_home exists in hr_lookups
      hr_utility.set_location(l_proc,40);
      l_ret := hr_api.not_exists_in_hr_lookups(
                                     p_effective_date => p_effective_date
                                    ,p_lookup_type    => 'IRC_WORK_AT_HOME'
                                    ,p_lookup_code    => p_work_at_home);
      if l_ret = true then
        fnd_message.set_name('PER','IRC_412024_BAD_WORK_AT_HOME');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,50);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'IRC_SEARCH_CRITERIA.WORK_AT_HOME'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
end chk_work_at_home;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_travel_percentage >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that travel percentage exists in
--   hr_lookups
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_travel_percentage
--  p_effective_date
--  p_search_criteria_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if travel_percentage is valid.
--
-- Post Failure:
--   An application error is raised if travel_percentage is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_travel_percentage
  (p_travel_percentage     in irc_search_criteria.travel_percentage%TYPE
  ,p_effective_date        in date
  ,p_search_criteria_id    in irc_search_criteria.search_criteria_id%TYPE
  ,p_object_version_number in irc_search_criteria.object_version_number%TYPE
  ) IS
--
  l_proc              varchar2(72) := g_package || 'chk_travel_percentage';
  l_api_updating      boolean;
  l_ret               boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  if p_travel_percentage is not null then
    --
    hr_utility.set_location(l_proc,20);
    l_api_updating  :=   irc_isc_shd.api_updating
                         (p_search_criteria_id    => p_search_criteria_id
                         ,p_object_version_number => p_object_version_number
                         );
    --
    hr_utility.set_location(l_proc,30);
    if (l_api_updating  and
        p_travel_percentage <>
        NVL(irc_isc_shd.g_old_rec.travel_percentage,hr_api.g_number))
        or (NOT l_api_updating) then
      -- Check that travel_percentage exists in hr_lookups
      hr_utility.set_location(l_proc,40);
      l_ret := hr_api.not_exists_in_hr_lookups(
                           p_effective_date => p_effective_date
                          ,p_lookup_type    => 'IRC_TRAVEL_PERCENTAGE'
                          ,p_lookup_code    => to_char(p_travel_percentage));
      if l_ret = true then
        fnd_message.set_name('PER','IRC_412025_BAD_TRAVEL_PERCENT');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,50);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'IRC_SEARCH_CRITERIA.TRAVEL_PERCENTAGE'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
end chk_travel_percentage;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_salary_period >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that salary period exists in
--   hr_lookups
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_salary_period
--  p_effective_date
--  p_search_criteria_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if salary_period is valid.
--
-- Post Failure:
--   An application error is raised if salary_period is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_salary_period
  (p_salary_period         in irc_search_criteria.salary_period%TYPE
  ,p_min_salary            in irc_search_criteria.min_salary%TYPE
  ,p_max_salary            in irc_search_criteria.max_salary%TYPE
  ,p_effective_date        in date
  ,p_search_criteria_id    in irc_search_criteria.search_criteria_id%TYPE
  ,p_object_version_number in irc_search_criteria.object_version_number%TYPE
  ) IS
--
  l_proc              varchar2(72) := g_package || 'chk_salary_period';
  l_api_updating      boolean;
  l_max_salary        irc_search_criteria.min_salary%type;
  l_min_salary        irc_search_criteria.max_salary%type;
  l_ret               boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  l_api_updating  :=   irc_isc_shd.api_updating
                       (p_search_criteria_id    => p_search_criteria_id
                       ,p_object_version_number => p_object_version_number
                       );
  hr_utility.set_location(l_proc,20);
  if (p_max_salary = hr_api.g_number) then
    l_max_salary :=irc_isc_shd.g_old_rec.max_salary;
  else
    l_max_salary := p_max_salary;
  end if;
  --
  if (p_min_salary = hr_api.g_number) then
    l_min_salary :=irc_isc_shd.g_old_rec.min_salary;
  else
    l_min_salary := p_min_salary;
  end if;
  --
  hr_utility.set_location(l_proc,30);
  if (l_api_updating  and
        p_salary_period <>
        NVL(irc_isc_shd.g_old_rec.salary_period,hr_api.g_varchar2)
        ) or (NOT l_api_updating) then
      -- Check that p_salary_period is not null if there is a salary
    if ((l_max_salary is not null or l_min_salary is not null)
         and  p_salary_period is null)  then
      fnd_message.set_name('PER','IRC_412065_NO_SAL_PERIOD');
      fnd_message.raise_error;
    end if;
    if p_salary_period is not null then
        -- Check that p_salary_period exists in hr_lookups
      hr_utility.set_location(l_proc,40);
      if hr_api.not_exists_in_hr_lookups(
                                       p_effective_date => p_effective_date
                                      ,p_lookup_type    => 'PAY_BASIS'
                                      ,p_lookup_code    => p_salary_period)
      then
        fnd_message.set_name('PER','IRC_412066_BAD_SAL_PERIOD');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
hr_utility.set_location(' Leaving:'||l_proc,50);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'IRC_SEARCH_CRITERIA.SALARY_PERIOD'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
end chk_salary_period;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_salary_currency >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that salary_currency exists in
--   fnd_currencies
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_salary_currency
--  p_min_sal
--  p_max_sal
--  p_effective_date
--  p_search_criteria_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if salary_currency is valid.
--
-- Post Failure:
--   An application error is raised salary_currency is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_salary_currency
  (p_salary_currency       in irc_search_criteria.salary_currency%TYPE
  ,p_min_salary            in irc_search_criteria.min_salary%TYPE
  ,p_max_salary            in irc_search_criteria.max_salary%TYPE
  ,p_effective_date        in date
  ,p_search_criteria_id    in irc_search_criteria.search_criteria_id%TYPE
  ,p_object_version_number in irc_search_criteria.object_version_number%TYPE
  ) IS
--
  l_proc            varchar2(72) := g_package || 'chk_salary_currency';
  l_salary_currency varchar2(1);
  l_api_updating    boolean;
--
  cursor csr_salary_currency is
    select null from fnd_currencies fc
    where p_salary_currency = fc.currency_code
    and p_effective_date between
        nvl(fc.start_date_active, p_effective_date)
    and nvl(fc.end_date_active, p_effective_date);
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  -- Only proceed with max_salary validation when multiple message list does not
  -- already contain an error associated with the min_salary or max_salary
  -- columns.
  hr_utility.set_location(l_proc,15);
  if hr_multi_message.no_all_inclusive_error
  ( p_check_column1 => 'IRC_SEARCH_CRITERIA.MIN_SALARY'
   ,p_check_column2 => 'IRC_SEARCH_CRITERIA.MAX_SALARY'
   ) then
    --
    l_api_updating  :=   irc_isc_shd.api_updating
                         (p_search_criteria_id    => p_search_criteria_id
                         ,p_object_version_number => p_object_version_number
                         );
    --
    hr_utility.set_location(l_proc,20);
    if (l_api_updating  and
        (NVL(p_salary_currency,hr_api.g_varchar2) <>
         NVL(irc_isc_shd.g_old_rec.salary_currency,hr_api.g_varchar2))
         or
        (NVL(p_max_salary,hr_api.g_number) <>
         NVL(irc_isc_shd.g_old_rec.max_salary,hr_api.g_number))
         or
        (NVL(p_min_salary,hr_api.g_number) <>
         NVL(irc_isc_shd.g_old_rec.min_salary,hr_api.g_number))
        )
        or (NOT l_api_updating) then
      --
      -- Check that salary currency is not null if either min_sal or max_sal is
      -- not null.
      --
      hr_utility.set_location(l_proc,30);
      if (p_min_salary is not null or p_max_salary is not null) and
         (p_salary_currency is null) then
        fnd_message.set_name('PER','IRC_412018_CURRENCY_NOT_FOUND');
        fnd_message.raise_error;
      end if;
      --
      -- Check that salary_currency exists in fnd_currencies.
      --
      if p_salary_currency is not null then
        hr_utility.set_location(l_proc,40);
        open csr_salary_currency;
        fetch csr_salary_currency into l_salary_currency;
        hr_utility.set_location(l_proc,50);
        if csr_salary_currency%NOTFOUND then
          close csr_salary_currency;
          fnd_message.set_name('PER','IRC_412026_BAD_SALARY_CURRENCY');
          fnd_message.raise_error;
        end if;
        close csr_salary_currency;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,60);
  exception
  --
  -- When Multiple error detection is enabled handle the application errors
  -- which have been raised by this procedure. Transfer the error to the
  -- Multiple message list and associate the error with max_salary,
  -- min_salary and salary_currency columns.
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>  'IRC_SEARCH_CRITERIA.MIN_SALARY'
       ,p_associated_column2 =>  'IRC_SEARCH_CRITERIA.MAX_SALARY'
       ,p_associated_column3 =>  'IRC_SEARCH_CRITERIA.SALARY_CURRENCY'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,70);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,80);
end chk_salary_currency;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_date_posted >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that date posted value exists in
--   hr_lookups
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_date_posted
--  p_effective_date
--  p_search_criteria_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if date posted is valid.
--
-- Post Failure:
--   An application error is raised if date posted is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_date_posted
  (p_date_posted           in irc_search_criteria.date_posted%TYPE
  ,p_effective_date        in date
  ,p_search_criteria_id    in irc_search_criteria.search_criteria_id%TYPE
  ,p_object_version_number in irc_search_criteria.object_version_number%TYPE
  ) IS
--
  l_proc              varchar2(72) := g_package || 'chk_date_posted';
  l_api_updating      boolean;
  l_ret               boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  if p_date_posted is not null then
    --
    hr_utility.set_location(l_proc,20);
    l_api_updating  :=   irc_isc_shd.api_updating
                         (p_search_criteria_id    => p_search_criteria_id
                         ,p_object_version_number => p_object_version_number
                         );
    --
    hr_utility.set_location(l_proc,30);
    if (l_api_updating  and
        p_date_posted <>
        NVL(irc_isc_shd.g_old_rec.date_posted,hr_api.g_varchar2)
       ) or (NOT l_api_updating) then
      -- Check that date_posted exists in hr_lookups
      hr_utility.set_location(l_proc,40);
      l_ret := hr_api.not_exists_in_hr_lookups(
                                  p_effective_date => p_effective_date
                                 ,p_lookup_type    => 'IRC_VACANCY_SEARCH_DATE'
                                 ,p_lookup_code    => p_date_posted);
      if l_ret = true then
        fnd_message.set_name('PER','IRC_412112_BAD_DATE_POSTED');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,50);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'IRC_SEARCH_CRITERIA.DATE_POSTED'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
end chk_date_posted;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_employee_contractor>------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to raise a warning to the manager if both the
--   Employee and Contractor flags are unchecked
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_employee
--  p_contractor
--
-- Post Success:
--   Processing continues if both the employee and contractor checkboxes are
--   not unchecked.
--
-- Post Failure:
--   A warning message is raised if both the employee and contractor
--   checkboxes are unchecked.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_employee_contractor
  (p_employee   in irc_search_criteria.employee%TYPE
  ,p_contractor in irc_search_criteria.contractor%TYPE
  ) IS
--
  l_proc              varchar2(72) := g_package || 'chk_employee_contractor';
  l_api_updating      boolean;
  l_ret               boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  if p_employee = 'N' and p_contractor = 'N' then
    --
    hr_utility.set_location(l_proc,20);
    fnd_message.set_name('PER', 'IRC_412152_VAC_EMP_CON_WARN');
    hr_multi_message.add
      (p_message_type => hr_multi_message.g_warning_msg
      );
    --
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,30);
--
end chk_employee_contractor;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_keywords >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the keyword is valid
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_keywords
--  p_search_criteria_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if the keyword is valid.
--
-- Post Failure:
--   An application error is raised if the keyword is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_keywords
  (p_keywords              in irc_search_criteria.keywords%TYPE
  ,p_search_criteria_id    in irc_search_criteria.search_criteria_id%TYPE
  ,p_object_version_number in irc_search_criteria.object_version_number%TYPE
  ) IS
--
  l_proc              varchar2(72) := g_package || 'chk_keywords';
  l_api_updating      boolean;
  l_ret               boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  if p_keywords is not null then
    --
    hr_utility.set_location(l_proc,20);
    l_api_updating  :=   irc_isc_shd.api_updating
                         (p_search_criteria_id    => p_search_criteria_id
                         ,p_object_version_number => p_object_version_number
                         );
    --
    hr_utility.set_location(l_proc,30);
    if ((l_api_updating  and
        p_keywords <>
        NVL(irc_isc_shd.g_old_rec.keywords,hr_api.g_varchar2)
       ) or (NOT l_api_updating)) then
      hr_utility.set_location(l_proc,40);
      --
      -- Check the validity of the keywords by using the
      -- procedure irc_query_parser_pkg.isInvalidKeyword()
      --
      l_ret := irc_query_parser_pkg.isInvalidKeyword (input_text => p_keywords);
      if l_ret  then
        hr_utility.set_location(l_proc,45);
        fnd_message.set_name('PER','IRC_INVALID_KEYWORDS');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,50);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'IRC_SEARCH_CRITERIA.KEYWORDS'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
end chk_keywords;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in irc_isc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate Important Attributes
  --
  -- Call all supporting business operations
  --
  -- No business group context.  HR_STANDARD_LOOKUPS used for validation.
  --
  -- After validating the set of important attributes,
  -- if Multiple message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  -- Validate Dependent Attributes
  --
  hr_utility.set_location(l_proc, 20);
  if p_rec.object_type in ('PERSON','WPREF') then
  --
    hr_utility.set_location(l_proc, 30);
     hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'EFFECTIVE_DATE'
    ,p_argument_value     => p_effective_date
    );
  --
    hr_utility.set_location(l_proc, 40);
    irc_isc_bus.chk_person_id(
        p_person_id       => p_rec.object_id
        ,p_effective_date => p_effective_date
        );
  --
    hr_utility.set_location(l_proc, 50);
    irc_isc_bus.chk_search_name(
        p_search_name           => p_rec.search_name
       ,p_person_id             => p_rec.object_id
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
    hr_utility.set_location(l_proc, 60);
    irc_isc_bus.chk_distance_to_location(
        p_distance_to_location  => p_rec.distance_to_location
       ,p_geocode_location      => p_rec.geocode_location
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
    hr_utility.set_location(l_proc, 63);
    irc_isc_bus.chk_location_id(
        p_location_id           => p_rec.location_id
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
    hr_utility.set_location(l_proc, 66);
    irc_isc_bus.chk_longitude_latitude(
        p_longitude             => p_rec.longitude
       ,p_latitude              => p_rec.latitude
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
    hr_utility.set_location(l_proc, 70);
    irc_isc_bus.chk_use_for_matching(
        p_use_for_matching      => p_rec.use_for_matching
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
    hr_utility.set_location(l_proc, 80);
    irc_isc_bus.chk_match_competence(
        p_match_competence      => p_rec.match_competence
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
    hr_utility.set_location(l_proc, 90);
    irc_isc_bus.chk_match_qualification(
        p_match_qualification   => p_rec.match_qualification
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
    hr_utility.set_location(l_proc, 100);
    irc_isc_bus.chk_min_salary(
        p_min_salary            => p_rec.min_salary
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
  end if;

  if p_rec.object_type= 'WPREF' then
    hr_utility.set_location(l_proc, 114);
    irc_isc_bus.chk_unique_work (
        p_object_id           => p_rec.object_id
     );
  hr_utility.set_location(l_proc, 117);
  irc_isc_bus.chk_work_at_home(
        p_work_at_home          => p_rec.work_at_home
       ,p_effective_date        => p_effective_date
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  hr_utility.set_location(l_proc, 119);
  irc_isc_bus.chk_keywords(
       p_keywords               => p_rec.keywords
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  end if;
  --
  hr_utility.set_location(l_proc, 110);
  if p_rec.object_type= 'VACANCY' then
    --
    hr_utility.set_location(l_proc, 70);
    irc_isc_bus.chk_vacancy_id(
        p_vacancy_id           => p_rec.object_id
       ,p_effective_date       => p_effective_date
     );
    --
    hr_utility.set_location(l_proc, 120);
    irc_isc_bus.chk_min_qual_level(
        p_min_qual_level       => p_rec.min_qual_level
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
    --
    hr_utility.set_location(l_proc, 130);
    irc_isc_bus.chk_min_salary(
        p_min_salary            => p_rec.min_salary
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
    --
    hr_utility.set_location(l_proc, 140);
    irc_isc_bus.chk_max_salary(
        p_max_salary            => p_rec.max_salary
       ,p_min_salary            => p_rec.min_salary
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
    --
    hr_utility.set_location(l_proc, 145);
    irc_isc_bus.chk_qual_rank(
        p_min_qual_level            => p_rec.min_qual_level
       ,p_max_qual_level            => p_rec.max_qual_level
       );
    --
    hr_utility.set_location(l_proc, 147);
    irc_isc_bus.chk_employee_contractor(
        p_employee            => p_rec.employee
       ,p_contractor          => p_rec.contractor
       );
    --
  end if;
  --
  hr_utility.set_location(l_proc, 150);
  irc_isc_bus.chk_salary_currency
       (p_salary_currency       => p_rec.salary_currency
       ,p_min_salary            => p_rec.min_salary
       ,p_max_salary            => p_rec.max_salary
       ,p_effective_date        => p_effective_date
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
  --
  hr_utility.set_location(l_proc, 155);
  irc_isc_bus.chk_salary_period(
        p_salary_period         => p_rec.salary_period
       ,p_min_salary            => p_rec.min_salary
       ,p_max_salary            => p_rec.max_salary
       ,p_effective_date        => p_effective_date
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
  hr_utility.set_location(l_proc, 160);
  irc_isc_bus.chk_employee(
        p_employee              => p_rec.employee
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
  hr_utility.set_location(l_proc, 170);
  irc_isc_bus.chk_contractor(
        p_contractor            => p_rec.contractor
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
  hr_utility.set_location(l_proc, 180);
  irc_isc_bus.chk_professional_area(
        p_professional_area     => p_rec.professional_area
       ,p_effective_date        => p_effective_date
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
  hr_utility.set_location(l_proc, 190);
  irc_isc_bus.chk_employment_category(
        p_employment_category   => p_rec.employment_category
       ,p_effective_date        => p_effective_date
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
  hr_utility.set_location(l_proc, 200);
  irc_isc_bus.chk_work_at_home(
        p_work_at_home          => p_rec.work_at_home
       ,p_effective_date        => p_effective_date
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
  hr_utility.set_location(l_proc, 210);
  irc_isc_bus.chk_travel_percentage(
        p_travel_percentage     => p_rec.travel_percentage
       ,p_effective_date        => p_effective_date
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
  hr_utility.set_location(l_proc, 215);
  irc_isc_bus.chk_date_posted(
        p_date_posted           => p_rec.date_posted
       ,p_effective_date        => p_effective_date
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
  hr_utility.set_location(l_proc, 220);
  irc_isc_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(l_proc, 230);
  irc_isc_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 240);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in irc_isc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Validate Important Attributes
  --
  -- Call all supporting business operations
  --
  -- No business group context.  HR_STANDARD_LOOKUPS used for validation.
  -- After validating the set of important attributes,
  -- if Multiple message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  -- Validate Dependent Attributes
  --
  hr_utility.set_location(l_proc,15);
  chk_non_updateable_args
    (p_effective_date   => p_effective_date
    ,p_rec              => p_rec
    );
  --
    --
  hr_utility.set_location(l_proc, 20);

  if p_rec.object_type in( 'PERSON','WPREF') then
  --
    hr_utility.set_location(l_proc, 30);
    irc_isc_bus.chk_search_name(
        p_search_name           => p_rec.search_name
       ,p_person_id             => p_rec.object_id
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
   --
    hr_utility.set_location(l_proc, 40);
    irc_isc_bus.chk_distance_to_location(
        p_distance_to_location  => p_rec.distance_to_location
       ,p_geocode_location      => p_rec.geocode_location
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
    hr_utility.set_location(l_proc, 43);
    irc_isc_bus.chk_location_id(
        p_location_id           => p_rec.location_id
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
    hr_utility.set_location(l_proc, 46);
    irc_isc_bus.chk_longitude_latitude(
        p_longitude             => p_rec.longitude
       ,p_latitude              => p_rec.latitude
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
    hr_utility.set_location(l_proc, 50);
    irc_isc_bus.chk_use_for_matching(
        p_use_for_matching      => p_rec.use_for_matching
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
    hr_utility.set_location(l_proc, 60);
    irc_isc_bus.chk_match_competence(
        p_match_competence      => p_rec.match_competence
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
    hr_utility.set_location(l_proc, 70);
    irc_isc_bus.chk_match_qualification(
        p_match_qualification   => p_rec.match_qualification
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
    hr_utility.set_location(l_proc, 80);
    irc_isc_bus.chk_min_salary(
        p_min_salary            => p_rec.min_salary
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
    hr_utility.set_location(l_proc, 85);
    irc_isc_bus.chk_date_posted(
        p_date_posted           => p_rec.date_posted
       ,p_effective_date        => p_effective_date
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
  end if;
  --
  if p_rec.object_type= 'WPREF' then
  hr_utility.set_location(l_proc, 87);
  irc_isc_bus.chk_work_at_home(
        p_work_at_home          => p_rec.work_at_home
       ,p_effective_date        => p_effective_date
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
  irc_isc_bus.chk_keywords(
       p_keywords               => p_rec.keywords
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  end if;
  --
  hr_utility.set_location(l_proc, 90);
  if p_rec.object_type= 'VACANCY' then
    --
    hr_utility.set_location(l_proc, 100);
    irc_isc_bus.chk_min_qual_level(
        p_min_qual_level        => p_rec.min_qual_level
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
    --
    hr_utility.set_location(l_proc, 110);
    irc_isc_bus.chk_min_salary(
        p_min_salary            => p_rec.min_salary
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
    --
    hr_utility.set_location(l_proc, 120);
    irc_isc_bus.chk_max_salary(
        p_max_salary            => p_rec.max_salary
       ,p_min_salary            => p_rec.min_salary
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
    --
    hr_utility.set_location(l_proc, 125);
    irc_isc_bus.chk_qual_rank(
        p_min_qual_level            => p_rec.min_qual_level
       ,p_max_qual_level            => p_rec.max_qual_level
       );
    --
    hr_utility.set_location(l_proc, 127);
    irc_isc_bus.chk_employee_contractor(
        p_employee            => p_rec.employee
       ,p_contractor          => p_rec.contractor
       );
    --
  end if;
  --
  hr_utility.set_location(l_proc, 130);
  irc_isc_bus.chk_salary_currency
       (p_salary_currency       => p_rec.salary_currency
       ,p_min_salary            => p_rec.min_salary
       ,p_max_salary            => p_rec.max_salary
       ,p_effective_date        => p_effective_date
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
  hr_utility.set_location(l_proc, 135);
  irc_isc_bus.chk_salary_period(
        p_salary_period         => p_rec.salary_period
       ,p_min_salary            => p_rec.min_salary
       ,p_max_salary            => p_rec.max_salary
       ,p_effective_date        => p_effective_date
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
  hr_utility.set_location(l_proc, 140);
  irc_isc_bus.chk_employee(
        p_employee              => p_rec.employee
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
  hr_utility.set_location(l_proc, 150);
  irc_isc_bus.chk_contractor(
        p_contractor            => p_rec.contractor
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
  hr_utility.set_location(l_proc, 160);
  irc_isc_bus.chk_professional_area(
        p_professional_area     => p_rec.professional_area
       ,p_effective_date        => p_effective_date
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
  hr_utility.set_location(l_proc, 170);
  irc_isc_bus.chk_employment_category(
        p_employment_category   => p_rec.employment_category
       ,p_effective_date        => p_effective_date
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
  hr_utility.set_location(l_proc, 180);
  irc_isc_bus.chk_work_at_home(
        p_work_at_home          => p_rec.work_at_home
       ,p_effective_date        => p_effective_date
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
  hr_utility.set_location(l_proc, 190);
  irc_isc_bus.chk_travel_percentage(
        p_travel_percentage     => p_rec.travel_percentage
       ,p_effective_date        => p_effective_date
       ,p_search_criteria_id    => p_rec.search_criteria_id
       ,p_object_version_number => p_rec.object_version_number
       );
  --
  hr_utility.set_location(l_proc, 200);
  irc_isc_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(l_proc, 210);
  irc_isc_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in irc_isc_shd.g_rec_type
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
end irc_isc_bus;

/
