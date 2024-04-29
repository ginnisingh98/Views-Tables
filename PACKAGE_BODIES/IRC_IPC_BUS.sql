--------------------------------------------------------
--  DDL for Package Body IRC_IPC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IPC_BUS" as
/* $Header: iripcrhi.pkb 120.0 2005/07/26 15:08:54 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_ipc_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_posting_content_id          number         default null;
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
  (p_rec in irc_ipc_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.posting_content_id is not null)  and (
    nvl(irc_ipc_shd.g_old_rec.ipc_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information_category, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.ipc_information1, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information1, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.ipc_information2, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information2, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.ipc_information3, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information3, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.ipc_information4, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information4, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.ipc_information5, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information5, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.ipc_information6, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information6, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.ipc_information7, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information7, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.ipc_information8, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information8, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.ipc_information9, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information9, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.ipc_information10, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information10, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.ipc_information11, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information11, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.ipc_information12, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information12, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.ipc_information13, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information13, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.ipc_information14, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information14, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.ipc_information15, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information15, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.ipc_information16, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information16, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.ipc_information17, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information17, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.ipc_information18, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information18, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.ipc_information19, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information19, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.ipc_information20, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information20, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.ipc_information21, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information21, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.ipc_information22, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information22, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.ipc_information23, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information23, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.ipc_information24, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information24, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.ipc_information25, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information25, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.ipc_information26, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information26, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.ipc_information27, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information27, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.ipc_information28, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information28, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.ipc_information29, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information29, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.ipc_information30, hr_api.g_varchar2) <>
    nvl(p_rec.ipc_information30, hr_api.g_varchar2) ))
    or (p_rec.posting_content_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'IRC_POSTING_CONTENT_DDF'
      ,p_attribute_category              => p_rec.ipc_information_category
      ,p_attribute1_name                 => 'IPC_INFORMATION1'
      ,p_attribute1_value                => p_rec.ipc_information1
      ,p_attribute2_name                 => 'IPC_INFORMATION2'
      ,p_attribute2_value                => p_rec.ipc_information2
      ,p_attribute3_name                 => 'IPC_INFORMATION3'
      ,p_attribute3_value                => p_rec.ipc_information3
      ,p_attribute4_name                 => 'IPC_INFORMATION4'
      ,p_attribute4_value                => p_rec.ipc_information4
      ,p_attribute5_name                 => 'IPC_INFORMATION5'
      ,p_attribute5_value                => p_rec.ipc_information5
      ,p_attribute6_name                 => 'IPC_INFORMATION6'
      ,p_attribute6_value                => p_rec.ipc_information6
      ,p_attribute7_name                 => 'IPC_INFORMATION7'
      ,p_attribute7_value                => p_rec.ipc_information7
      ,p_attribute8_name                 => 'IPC_INFORMATION8'
      ,p_attribute8_value                => p_rec.ipc_information8
      ,p_attribute9_name                 => 'IPC_INFORMATION9'
      ,p_attribute9_value                => p_rec.ipc_information9
      ,p_attribute10_name                => 'IPC_INFORMATION10'
      ,p_attribute10_value               => p_rec.ipc_information10
      ,p_attribute11_name                => 'IPC_INFORMATION11'
      ,p_attribute11_value               => p_rec.ipc_information11
      ,p_attribute12_name                => 'IPC_INFORMATION12'
      ,p_attribute12_value               => p_rec.ipc_information12
      ,p_attribute13_name                => 'IPC_INFORMATION13'
      ,p_attribute13_value               => p_rec.ipc_information13
      ,p_attribute14_name                => 'IPC_INFORMATION14'
      ,p_attribute14_value               => p_rec.ipc_information14
      ,p_attribute15_name                => 'IPC_INFORMATION15'
      ,p_attribute15_value               => p_rec.ipc_information15
      ,p_attribute16_name                => 'IPC_INFORMATION16'
      ,p_attribute16_value               => p_rec.ipc_information16
      ,p_attribute17_name                => 'IPC_INFORMATION17'
      ,p_attribute17_value               => p_rec.ipc_information17
      ,p_attribute18_name                => 'IPC_INFORMATION18'
      ,p_attribute18_value               => p_rec.ipc_information18
      ,p_attribute19_name                => 'IPC_INFORMATION19'
      ,p_attribute19_value               => p_rec.ipc_information19
      ,p_attribute20_name                => 'IPC_INFORMATION20'
      ,p_attribute20_value               => p_rec.ipc_information20
      ,p_attribute21_name                => 'IPC_INFORMATION21'
      ,p_attribute21_value               => p_rec.ipc_information21
      ,p_attribute22_name                => 'IPC_INFORMATION22'
      ,p_attribute22_value               => p_rec.ipc_information22
      ,p_attribute23_name                => 'IPC_INFORMATION23'
      ,p_attribute23_value               => p_rec.ipc_information23
      ,p_attribute24_name                => 'IPC_INFORMATION24'
      ,p_attribute24_value               => p_rec.ipc_information24
      ,p_attribute25_name                => 'IPC_INFORMATION25'
      ,p_attribute25_value               => p_rec.ipc_information25
      ,p_attribute26_name                => 'IPC_INFORMATION26'
      ,p_attribute26_value               => p_rec.ipc_information26
      ,p_attribute27_name                => 'IPC_INFORMATION27'
      ,p_attribute27_value               => p_rec.ipc_information27
      ,p_attribute28_name                => 'IPC_INFORMATION28'
      ,p_attribute28_value               => p_rec.ipc_information28
      ,p_attribute29_name                => 'IPC_INFORMATION29'
      ,p_attribute29_value               => p_rec.ipc_information29
      ,p_attribute30_name                => 'IPC_INFORMATION30'
      ,p_attribute30_value               => p_rec.ipc_information30
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
  (p_rec in irc_ipc_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.posting_content_id is not null)  and (
    nvl(irc_ipc_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(irc_ipc_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    or (p_rec.posting_content_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'IRC_POSTING_CONTENTS'
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
  (p_rec in irc_ipc_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT irc_ipc_shd.api_updating
      (p_posting_content_id                   => p_rec.posting_content_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
--
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_display_manager_info >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that valid values for
--   display_manager_info column is entered
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_display_manager_info
--   p_posting_content_id
--   p_object_version_number
--
-- Post Success:
--   Processing continues if valid values are entered for
--   display_manager_info column.
--
-- Post Failure:
--   An application error is raised if invalid values are entered
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
Procedure chk_display_manager_info
(
 p_display_manager_info in irc_posting_contents.display_manager_info%TYPE
,p_posting_content_id in irc_posting_contents.posting_content_id%TYPE
,p_object_version_number in irc_posting_contents.object_version_number%TYPE
)
is
  l_proc     varchar2(72) := g_package || 'chk_display_manager_info';
  l_api_updating boolean;
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  l_api_updating := irc_ipc_shd.api_updating
  (p_posting_content_id    => p_posting_content_id
  ,p_object_version_number => p_object_version_number);
      --
  hr_utility.set_location(l_proc,20);
  if ((l_api_updating
    and
    irc_ipc_shd.g_old_rec.display_manager_info <>
    nvl(p_display_manager_info, hr_api.g_varchar2))
    or
    (NOT l_api_updating)) then
    hr_utility.set_location(l_proc,30);
    hr_api.mandatory_arg_error
      (p_api_name           => l_proc
      ,p_argument           => 'display_manager_info'
      ,p_argument_value     => p_display_manager_info
    );
    hr_utility.set_location(l_proc,40);
    if (p_display_manager_info not in ('Y','N'))
    then
      fnd_message.set_name('PER','IRC_412027_IPC_MAN_INFO_INV');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,45);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1 => 'IRC_POSTING_CONTENTS.DISPLAY_MANAGER_INFO'
      )then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
  hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_display_manager_info;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_display_recruiter_info >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that valid values for
--   display_recruiter_info column is entered
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_display_recruiter_info
--   p_posting_content_id
--   p_object_version_number
--
-- Post Success:
--   Processing continues if valid values are entered for
--   display_recruiter_info column.
--
-- Post Failure:
--   An application error is raised if invalid values are entered
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
Procedure chk_display_recruiter_info
(
 p_display_recruiter_info in irc_posting_contents.display_recruiter_info%TYPE
,p_posting_content_id in irc_posting_contents.posting_content_id%TYPE
,p_object_version_number in irc_posting_contents.object_version_number%TYPE
)
is
  l_proc     varchar2(72) := g_package || 'chk_display_recruiter_info';
  l_api_updating boolean;
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := irc_ipc_shd.api_updating
  (p_posting_content_id    => p_posting_content_id
  ,p_object_version_number => p_object_version_number);
      --
  hr_utility.set_location(l_proc,20);
  if ((l_api_updating
    and
    irc_ipc_shd.g_old_rec.display_recruiter_info <>
    nvl(p_display_recruiter_info, hr_api.g_varchar2))
    or
    (NOT l_api_updating)) then
    hr_utility.set_location(l_proc,30);
    hr_api.mandatory_arg_error
      (p_api_name           => l_proc
      ,p_argument           => 'display_recruiter_info'
      ,p_argument_value     => p_display_recruiter_info
      );
    hr_utility.set_location(l_proc,40);
    if (p_display_recruiter_info not in ('Y','N'))
    then
      fnd_message.set_name('PER','IRC_412028_IPC_REC_INFO_INV');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,45);
  exception
      when app_exception.application_exception then
        if hr_multi_message.exception_add
        (p_associated_column1 => 'IRC_POSTING_CONTENTS.DISPLAY_RECRUITER_INFO'
        )then
          hr_utility.set_location(' Leaving:'||l_proc, 50);
          raise;
        end if;
  hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_display_recruiter_info;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_posting_content_delete >------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks whether a posting content record can be deleted. If
--   a Vacancies record is referencing this record then it can not be
--   deleted.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_posting_content_id   PK
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_posting_content_delete
  (p_posting_content_id in irc_posting_contents.posting_content_id%TYPE
  )
   is
  --
  l_proc       varchar2(72) := g_package||'chk_posting_content_delete';
  l_api_updating    boolean;
  l_posting_content varchar2(1);
  --
  cursor csr_posting_content is
    select null
      from per_all_vacancies vac
     where vac.primary_posting_id = p_posting_content_id;
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- check if referenced records exist in the PER_ALL_VACANCIES table.
  --
  open csr_posting_content;
  fetch csr_posting_content into l_posting_content;
  hr_utility.set_location(l_proc,20);
  if csr_posting_content%found then
    --
    -- raise error as child records exist.
    --
    close csr_posting_content;
    fnd_message.set_name('PER','IRC_412209_VAC_POSTING_EXISTS');
    fnd_message.raise_error;
  end if;
  close csr_posting_content;
  hr_utility.set_location(l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
        (p_associated_column1 => 'IRC_POSTING_CONTENTS.POSTING_CONTENT_ID'
        )then
        hr_utility.set_location(l_proc,40);
        raise;
      end if;
    hr_utility.set_location(' Leaving:'||l_proc,50);
    --
end chk_posting_content_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in irc_ipc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  irc_ipc_bus.chk_display_manager_info
  (
   p_display_manager_info  => p_rec.display_manager_info
  ,p_posting_content_id    => p_rec.posting_content_id
  ,p_object_version_number => p_rec.object_version_number
  );
  hr_utility.set_location(l_proc, 10);
  irc_ipc_bus.chk_display_recruiter_info
  (
   p_display_recruiter_info => p_rec.display_recruiter_info
  ,p_posting_content_id     => p_rec.posting_content_id
  ,p_object_version_number  => p_rec.object_version_number
  );
  hr_utility.set_location(l_proc, 20);
  irc_ipc_bus.chk_df(p_rec);
  hr_utility.set_location(l_proc, 30);
  irc_ipc_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in irc_ipc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  chk_non_updateable_args
  (p_rec              => p_rec
  );
  hr_utility.set_location('Entering:'||l_proc, 10);
  irc_ipc_bus.chk_display_manager_info
  (
   p_display_manager_info  => p_rec.display_manager_info
  ,p_posting_content_id    => p_rec.posting_content_id
  ,p_object_version_number => p_rec.object_version_number
  );
  hr_utility.set_location(l_proc, 20);
  irc_ipc_bus.chk_display_recruiter_info
  (
   p_display_recruiter_info => p_rec.display_recruiter_info
  ,p_posting_content_id     => p_rec.posting_content_id
  ,p_object_version_number  => p_rec.object_version_number
  );
  hr_utility.set_location(l_proc,30);
  irc_ipc_bus.chk_df(p_rec);
  hr_utility.set_location(l_proc,40);
  irc_ipc_bus.chk_ddf(p_rec);
 --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in irc_ipc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  if(p_rec.posting_content_id is not null) then
    irc_ipc_bus.chk_posting_content_delete
    (p_posting_content_id   => p_rec.posting_content_id
    );
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end irc_ipc_bus;

/
