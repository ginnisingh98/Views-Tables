--------------------------------------------------------
--  DDL for Package Body IRC_CMP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_CMP_BUS" as
/* $Header: ircmprhi.pkb 120.0 2007/11/19 11:38:55 sethanga noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_cmp_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_communication_property_id   number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_communication_property_id            in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- irc_comm_properties and PER_BUSINESS_GROUPS_PERF
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , irc_comm_properties cmp
      --   , EDIT_HERE table_name(s) 333
     where cmp.communication_property_id = p_communication_property_id;
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
    ,p_argument           => 'communication_property_id'
    ,p_argument_value     => p_communication_property_id
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
        => nvl(p_associated_column1,'COMMUNICATION_PROPERTY_ID')
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
  (p_communication_property_id            in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- irc_comm_properties and PER_BUSINESS_GROUPS_PERF
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , irc_comm_properties cmp
      --   , EDIT_HERE table_name(s) 333
     where cmp.communication_property_id = p_communication_property_id;
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
    ,p_argument           => 'communication_property_id'
    ,p_argument_value     => p_communication_property_id
    );
  --
  if ( nvl(irc_cmp_bus.g_communication_property_id, hr_api.g_number)
       = p_communication_property_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := irc_cmp_bus.g_legislation_code;
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
    irc_cmp_bus.g_communication_property_id   := p_communication_property_id;
    irc_cmp_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in irc_cmp_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.communication_property_id is not null)  and (
    nvl(irc_cmp_shd.g_old_rec.information_category, hr_api.g_varchar2) <>
    nvl(p_rec.information_category, hr_api.g_varchar2)  or
    nvl(irc_cmp_shd.g_old_rec.information1, hr_api.g_varchar2) <>
    nvl(p_rec.information1, hr_api.g_varchar2)  or
    nvl(irc_cmp_shd.g_old_rec.information2, hr_api.g_varchar2) <>
    nvl(p_rec.information2, hr_api.g_varchar2)  or
    nvl(irc_cmp_shd.g_old_rec.information3, hr_api.g_varchar2) <>
    nvl(p_rec.information3, hr_api.g_varchar2)  or
    nvl(irc_cmp_shd.g_old_rec.information4, hr_api.g_varchar2) <>
    nvl(p_rec.information4, hr_api.g_varchar2)  or
    nvl(irc_cmp_shd.g_old_rec.information5, hr_api.g_varchar2) <>
    nvl(p_rec.information5, hr_api.g_varchar2)  or
    nvl(irc_cmp_shd.g_old_rec.information6, hr_api.g_varchar2) <>
    nvl(p_rec.information6, hr_api.g_varchar2)  or
    nvl(irc_cmp_shd.g_old_rec.information7, hr_api.g_varchar2) <>
    nvl(p_rec.information7, hr_api.g_varchar2)  or
    nvl(irc_cmp_shd.g_old_rec.information8, hr_api.g_varchar2) <>
    nvl(p_rec.information8, hr_api.g_varchar2)  or
    nvl(irc_cmp_shd.g_old_rec.information9, hr_api.g_varchar2) <>
    nvl(p_rec.information9, hr_api.g_varchar2)  or
    nvl(irc_cmp_shd.g_old_rec.information10, hr_api.g_varchar2) <>
    nvl(p_rec.information10, hr_api.g_varchar2) ))
    or (p_rec.communication_property_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'IRC'
      ,p_descflex_name                   => 'EDIT_HERE: Enter descflex name'
      ,p_attribute_category              => p_rec.information_category
      ,p_attribute1_name                 => 'INFORMATION1'
      ,p_attribute1_value                => p_rec.information1
      ,p_attribute2_name                 => 'INFORMATION2'
      ,p_attribute2_value                => p_rec.information2
      ,p_attribute3_name                 => 'INFORMATION3'
      ,p_attribute3_value                => p_rec.information3
      ,p_attribute4_name                 => 'INFORMATION4'
      ,p_attribute4_value                => p_rec.information4
      ,p_attribute5_name                 => 'INFORMATION5'
      ,p_attribute5_value                => p_rec.information5
      ,p_attribute6_name                 => 'INFORMATION6'
      ,p_attribute6_value                => p_rec.information6
      ,p_attribute7_name                 => 'INFORMATION7'
      ,p_attribute7_value                => p_rec.information7
      ,p_attribute8_name                 => 'INFORMATION8'
      ,p_attribute8_value                => p_rec.information8
      ,p_attribute9_name                 => 'INFORMATION9'
      ,p_attribute9_value                => p_rec.information9
      ,p_attribute10_name                => 'INFORMATION10'
      ,p_attribute10_value               => p_rec.information10
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
  (p_rec in irc_cmp_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.communication_property_id is not null)  and (
    nvl(irc_cmp_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(irc_cmp_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(irc_cmp_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(irc_cmp_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(irc_cmp_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(irc_cmp_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(irc_cmp_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(irc_cmp_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(irc_cmp_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(irc_cmp_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(irc_cmp_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2) ))
    or (p_rec.communication_property_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'IRC'
      ,p_descflex_name                   => 'EDIT_HERE: Enter descflex name'
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
  ,p_rec in irc_cmp_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT irc_cmp_shd.api_updating
      (p_communication_property_id         => p_rec.communication_property_id
      ,p_object_version_number             => p_rec.object_version_number
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
  IF p_rec.object_type <>
       irc_cmp_shd.g_old_rec.object_type then
     hr_api.argument_changed_error
     (p_api_name   => l_proc
     ,p_argument   => 'OBJECT_TYPE'
     ,p_base_table => irc_cmp_shd.g_tab_nam
     );
  END IF;
  --
  IF p_rec.object_id <> irc_cmp_shd.g_old_rec.object_id  THEN
    IF p_rec.object_type = 'VACANCY' THEN
      hr_api.argument_changed_error
      ( p_api_name     => l_proc
       ,p_argument     => 'VACANCY_ID'
       ,p_base_table   => irc_cmp_shd.g_tab_nam
      );
     END IF;
  END IF;
--
End chk_non_updateable_args;
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_default_comm_status >------------------|
--  ---------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This process validates that 'status' exists in the lookup
--   IRC_COMM_DEFAULT_COMM_STATUS.
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--   status                     varchar2(50) default communication status
--   communication_property_id  number(15)   PK of irc_comm_properties
--   effective_date             date         date record effective
--   object_version_number      number(9)    version of row
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised for the following faliure conditions:
--   1: p_status does not exist in lookup IRC_COMM_DEFAULT_COMM_STATUS
--
-- Access Status:
--   Internal Table Handler Use Only.
Procedure chk_default_comm_status(p_status in varchar2,
                                  p_communication_property_id in number,
                                  p_effective_date in date,
                                  p_object_version_number in number) is
--
  l_proc varchar2(72) := g_package||'chk_default_comm_status';
  l_api_updating boolean;
--
begin
    hr_utility.set_location('Entering: '|| l_proc, 10);
    l_api_updating := irc_cmp_shd.api_updating
           (p_communication_property_id   => p_communication_property_id,
            p_object_version_number       => p_object_version_number);
    --
    if (l_api_updating
      and nvl(p_status,hr_api.g_varchar2)
          <> nvl(irc_cmp_shd.g_old_rec.default_comm_status,hr_api.g_varchar2)
      or not l_api_updating) then
      --
      -- check if value of type falls within lookup.
      --
      if hr_api.not_exists_in_hr_lookups(p_lookup_type    => 'IRC_COMM_DEFAULT_COMM_STATUS',
                                         p_lookup_code    => p_status,
                                         p_effective_date => sysdate)
                                        then
        --
        -- raise error as does not exist as lookup
        --
        hr_utility.set_location('Leaving: '|| l_proc, 20);
        fnd_message.set_name('PER','IRC_412408_INVALID_COMM_STATUS');
        fnd_message.raise_error;
      end if;
    end if;
    hr_utility.set_location('Leaving: '|| l_proc, 30);
end chk_default_comm_status;
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_allow_attachment_flag >------------------|
--  ---------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This process validates that 'status' exists in the lookup
--   IRC_COMM_ALLOW_ATTACHMENT_FLAG.
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--   flag                       varchar2(50) allow attachement flag
--   communication_property_id  number(15)   PK of irc_comm_properties
--   effective_date             date         date record effective
--   object_version_number      number(9)    version of row
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised for the following faliure conditions:
--   1: p_flag does not exist in lookup IRC_COMM_ALLOW_ATTACHMENT_FLAG.
--
-- Access Status:
--   Internal Table Handler Use Only.
Procedure chk_allow_attachment_flag(p_flag in varchar2,
                                    p_communication_property_id in number,
                                    p_effective_date in date,
                                    p_object_version_number in number) is
--
  l_proc varchar2(72) := g_package||'chk_allow_attachment_flag';
  l_api_updating boolean;
--
begin
    hr_utility.set_location('Entering: '|| l_proc, 10);
    l_api_updating := irc_cmp_shd.api_updating
           (p_communication_property_id   => p_communication_property_id,
            p_object_version_number       => p_object_version_number);
    --
    if (l_api_updating
      and nvl(p_flag,hr_api.g_varchar2)
          <> nvl(irc_cmp_shd.g_old_rec.allow_attachment_flag,hr_api.g_varchar2)
      or not l_api_updating) then
      --
      -- check if value of type falls within lookup.
      --
      if hr_api.not_exists_in_hr_lookups(p_lookup_type    => 'IRC_COMM_ALLOW_ATTACHMENT_FLAG',
                                         p_lookup_code    => p_flag,
                                         p_effective_date => sysdate)
                                        then
        --
        -- raise error as does not exist as lookup
        --
        hr_utility.set_location('Leaving: '|| l_proc, 20);
        fnd_message.set_name('PER','IRC_412409_INVALID_ATTACHMENT_FLAG');
        fnd_message.raise_error;
      end if;
    end if;
    hr_utility.set_location('Leaving: '|| l_proc, 30);
end chk_allow_attachment_flag;
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_allow_add_recipients >-----------------|
--  ---------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This process validates that 'allow_add_recipients' exists in the lookup
--   IRC_COMM_ALLOW_ADD_RECIPIENTS.
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--   allow_add_recipients       varchar2(50) allow add recipients
--   communication_property_id  number(15)   PK of irc_comm_properties
--   effective_date             date         date record effective
--   object_version_number      number(9)    version of row
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised for the following faliure conditions:
--   1: p_allow_add_recipients does not exist in lookup IRC_COMM_ALLOW_ADD_RECIPIENTS.
--
-- Access Status:
--   Internal Table Handler Use Only.
Procedure chk_allow_add_recipients(p_allow_add_recipients in varchar2,
                                   p_communication_property_id in number,
                                   p_effective_date in date,
                                   p_object_version_number in number) is
--
  l_proc varchar2(72) := g_package||'chk_allow_add_recipients';
  l_api_updating boolean;
--
begin
    hr_utility.set_location('Entering: '|| l_proc, 10);
    l_api_updating := irc_cmp_shd.api_updating
           (p_communication_property_id   => p_communication_property_id,
            p_object_version_number       => p_object_version_number);
    --
    if (l_api_updating
      and nvl(p_allow_add_recipients,hr_api.g_varchar2)
          <> nvl(irc_cmp_shd.g_old_rec.allow_add_recipients,hr_api.g_varchar2)
      or not l_api_updating) then
      --
      -- check if value of type falls within lookup.
      --
      if hr_api.not_exists_in_hr_lookups(p_lookup_type    => 'IRC_COMM_ALLOW_ADD_RECIPIENTS',
                                         p_lookup_code    => p_allow_add_recipients,
                                         p_effective_date => sysdate)
                                        then
        --
        -- raise error as does not exist as lookup
        --
        hr_utility.set_location('Leaving: '|| l_proc, 20);
        fnd_message.set_name('PER','IRC_412410_INVALID_ALLOW_ADD_RECIPIENT');
        fnd_message.raise_error;
      end if;
    end if;
    hr_utility.set_location('Leaving: '|| l_proc, 30);
end chk_allow_add_recipients;
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_auto_notification_flag  >--------------|
--  ---------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This process validates that 'auto_notification_flag' exists in the lookup
--   YES_NO.
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--   auto_notification_flag     varchar2(1)  auto_notification_flag
--   communication_property_id  number(15)   PK of irc_comm_properties
--   effective_date             date         date record effective
--   object_version_number      number(9)    version of row
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised for the following faliure conditions:
--   1: p_auto_notification_flag does not exist in lookup YES_NO
--
-- Access Status:
--   Internal Table Handler Use Only.
Procedure chk_auto_notification_flag(p_auto_notification_flag in varchar2,
                                     p_communication_property_id in number,
                                     p_effective_date in date,
                                     p_object_version_number in number) is
--
  l_proc varchar2(72) := g_package||'chk_auto_notification_flag';
  l_api_updating boolean;
--
begin
    hr_utility.set_location('Entering: '|| l_proc, 10);
    l_api_updating := irc_cmp_shd.api_updating
           (p_communication_property_id   => p_communication_property_id,
            p_object_version_number       => p_object_version_number);
    --
    if (l_api_updating
      and nvl(p_auto_notification_flag,hr_api.g_varchar2)
          <> nvl(irc_cmp_shd.g_old_rec.auto_notification_flag,hr_api.g_varchar2)
      or not l_api_updating) then
      --
      -- check if value of type falls within lookup.
      --
      if hr_api.not_exists_in_hr_lookups(p_lookup_type    => 'YES_NO',
                                         p_lookup_code    => p_auto_notification_flag,
                                         p_effective_date => sysdate)
                                        then
        --
        -- raise error as does not exist as lookup
        --
        hr_utility.set_location('Leaving: '|| l_proc, 20);
        fnd_message.set_name('PER','IRC_412411_INVALID_NOTIFICATION_FLAG');
        fnd_message.raise_error;
      end if;
    end if;
    hr_utility.set_location('Leaving: '|| l_proc, 30);
end chk_auto_notification_flag;
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_default_moderator >-----------------|
--  ---------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This process validates that 'default_moderator' exists in the lookup
--   IRC_COMM_DEFAULT_MODERATOR.
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--   default_moderator          varchar2(50) default_moderator
--   communication_property_id  number(15)   PK of irc_comm_properties
--   effective_date             date         date record effective
--   object_version_number      number(9)    version of row
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised for the following faliure conditions:
--   1: p_default_moderator does not exist in lookup IRC_COMM_DEFAULT_MODERATOR.
--
-- Access Status:
--   Internal Table Handler Use Only.
Procedure chk_default_moderator(p_default_moderator in varchar2,
                                p_communication_property_id in number,
                                p_effective_date in date,
                                p_object_version_number in number) is
--
  l_proc varchar2(72) := g_package||'chk_default_moderator';
  l_api_updating boolean;
--
begin
    hr_utility.set_location('Entering: '|| l_proc, 10);
    l_api_updating := irc_cmp_shd.api_updating
           (p_communication_property_id   => p_communication_property_id,
            p_object_version_number       => p_object_version_number);
    --
    if (l_api_updating
      and nvl(p_default_moderator,hr_api.g_varchar2)
          <> nvl(irc_cmp_shd.g_old_rec.default_moderator,hr_api.g_varchar2)
      or not l_api_updating) then
      --
      -- check if value of type falls within lookup.
      --
      if hr_api.not_exists_in_hr_lookups(p_lookup_type    => 'IRC_COMM_DEFAULT_MODERATOR',
                                         p_lookup_code    => p_default_moderator,
                                         p_effective_date => sysdate)
                                        then
        --
        -- raise error as does not exist as lookup
        --
        hr_utility.set_location('Leaving: '|| l_proc, 20);
        fnd_message.set_name('PER','IRC_412412_INVALID_DEFAULT_MODERATOR');
        fnd_message.raise_error;
      end if;
    end if;
    hr_utility.set_location('Leaving: '|| l_proc, 30);
end chk_default_moderator;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_object_id >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure-
--  1) that object_id exists in PER_ALL_VACANCIES
--     when the object_type is 'VACANCY'
--  2) that combination of (object_id,object_type) is
--     unique.

-- Pre Conditions:
--
-- In Arguments:
--  p_object_id
--  p_object_type
-- Post Success:
--  Processing continues if object_id is valid.
--
-- Post Failure:
--   An application error is raised if object_id is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_object_id
  (p_object_id in irc_comm_properties.object_id%TYPE,
   p_object_type in irc_comm_properties.object_type%TYPE
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_object_id';
  l_object_id varchar2(1);
  l_object_type varchar2(1);
--
  cursor csr_object_id is
    select null
    from per_all_vacancies pav
    where pav.vacancy_id = p_object_id ;
--
  cursor csr_object_type is
    select null
    from irc_comm_properties icp
    where icp.object_id = p_object_id
     and  icp.object_type = p_object_type;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
-- Check that object_id is not null.
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'OBJECT_ID'
  ,p_argument_value     => p_object_id
  );
-- Check that object_id exists in per_all_vacancies
  hr_utility.set_location(l_proc,20);
  open csr_object_id;
  fetch csr_object_id into l_object_id;
  hr_utility.set_location(l_proc,30);
  if csr_object_id%NOTFOUND then
    close csr_object_id;
    fnd_message.set_name('PER','IRC_412413_BAD_OBJECT_ID');
    fnd_message.raise_error;
  end if;
  close csr_object_id;

  -- Check that combination of (object_id,object_type) is unique.
  open csr_object_type;
  fetch csr_object_type into l_object_type;
  hr_utility.set_location(l_proc,40);
  if csr_object_type%FOUND then
    close csr_object_type;
    fnd_message.set_name('PER','IRC_412414_OBJID_OBJTYP_NOT_UNQ');
    fnd_message.raise_error;
  end if;
  close csr_object_type;

  hr_utility.set_location(' Leaving:'||l_proc,50);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
       'IRC_COMM_PROPERTIES.OBJECT_ID'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
end chk_object_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_object_type >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that object_type has one of the following
--   values :
--   'VACANCY'
--
-- Pre Conditions:
--
-- In Arguments:
--  p_object_type
--
-- Post Success:
--  Processing continues if object_type is valid.
--
-- Post Failure:
--   An application error is raised if object_type is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_object_type
  (p_object_type in irc_comm_properties.object_type%TYPE
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_object_type';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
-- Check that object_type is not null.
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'OBJECT_TYPE'
  ,p_argument_value     => p_object_type
  );

   if p_object_type <> 'VACANCY' then
    fnd_message.set_name('PER','IRC_412415_BAD_OBJECT_TYPE');
    fnd_message.raise_error;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,20);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
       'IRC_COMM_PROPERTIES.OBJECT_TYPE'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,30);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,40);
end chk_object_type;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_update_validate >----------------------|
-- ----------------------------------------------------------------------------
Procedure insert_update_validate
  (p_effective_date               in date
  ,p_rec                          in irc_cmp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
      irc_cmp_bus.chk_default_comm_status
      (
       p_rec.default_comm_status,
       p_rec.communication_property_id,
       p_effective_date,
       p_rec.object_version_number
      );

      irc_cmp_bus.chk_allow_attachment_flag
      (
       p_rec.allow_attachment_flag,
       p_rec.communication_property_id,
       p_effective_date,
       p_rec.object_version_number
      );

      irc_cmp_bus.chk_allow_add_recipients
      (
       p_rec.allow_add_recipients,
       p_rec.communication_property_id,
       p_effective_date,
       p_rec.object_version_number
      );

      irc_cmp_bus.chk_auto_notification_flag
      (
       p_rec.auto_notification_flag,
       p_rec.communication_property_id,
       p_effective_date,
       p_rec.object_version_number
      );

      irc_cmp_bus.chk_default_moderator
      (
       p_rec.default_moderator,
       p_rec.communication_property_id,
       p_effective_date,
       p_rec.object_version_number
      );
--
End insert_update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in irc_cmp_shd.g_rec_type
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
  --  irc_cmp_bus.chk_ddf(p_rec);
  --
  --  irc_cmp_bus.chk_df(p_rec);
  --
      irc_cmp_bus.insert_update_validate(p_effective_date, p_rec);
      irc_cmp_bus.chk_object_type(p_rec.object_type);
      irc_cmp_bus.chk_object_id(p_rec.object_id,p_rec.object_type);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in irc_cmp_shd.g_rec_type
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
  -- irc_cmp_bus.chk_ddf(p_rec);
  --
  -- irc_cmp_bus.chk_df(p_rec);
  --
  irc_cmp_bus.insert_update_validate(p_effective_date, p_rec);

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in irc_cmp_shd.g_rec_type
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
end irc_cmp_bus;

/
