--------------------------------------------------------
--  DDL for Package Body IRC_INP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_INP_BUS" as
/* $Header: irinprhi.pkb 120.2 2006/02/23 15:36:24 gjaggava noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_inp_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_party_id                    number         default null;
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
  (p_rec in irc_inp_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.notification_preference_id is not null)  and (
    nvl(irc_inp_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(irc_inp_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(irc_inp_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(irc_inp_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(irc_inp_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(irc_inp_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(irc_inp_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(irc_inp_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(irc_inp_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(irc_inp_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(irc_inp_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(irc_inp_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(irc_inp_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(irc_inp_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(irc_inp_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(irc_inp_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(irc_inp_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(irc_inp_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(irc_inp_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(irc_inp_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(irc_inp_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(irc_inp_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(irc_inp_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(irc_inp_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(irc_inp_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(irc_inp_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(irc_inp_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(irc_inp_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(irc_inp_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(irc_inp_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(irc_inp_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    or (p_rec.notification_preference_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'IRC_NOTIFICATION_PREFERENCES'
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
  ,p_rec in irc_inp_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT irc_inp_shd.api_updating
      (p_notification_preference_id           => p_rec.notification_preference_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  if nvl(p_rec.notification_preference_id, hr_api.g_number) <>
     nvl(irc_inp_shd.g_old_rec.notification_preference_id, hr_api.g_number)
     then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => 'NOTIFICATION_PREFERENCE_ID'
         ,p_base_table => irc_inp_shd.g_tab_nam
         );
  end if;
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_person_id >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates if the person id exists in the PER_ALL_PEOPLE_F table
--
-- Prerequisites:
--   Must be called as the first step in insert_validate.
--
-- In Arguments:
--   p_person_id
--
-- Post Success:
--   If the person_id is existing in PER_ALL_PEOPLE_F
--   then continue.
--
-- Post Failure:
--   If the person_id is not present in PER_ALL_PEOPLE_F
--   then throw an error indicating the same.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
Procedure chk_person_id
  (p_person_id           in irc_notification_preferences.person_id%type
  ,p_party_id in out nocopy irc_notification_preferences.party_id%type
  ,p_effective_date      in date
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_person_id';
  l_party_id irc_notification_preferences.party_id%type;
  cursor l_person is
    select party_id
      from per_all_people_f
     where person_id = p_person_id
       and p_effective_date between
           effective_start_date and effective_end_date;
--
--
--
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  open l_person;
  fetch l_person into l_party_id;
  if l_person%notfound
  then
    close l_person;
    fnd_message.set_name('PER','IRC_412157_PARTY_PERS_MISMTCH');
    fnd_message.raise_error;
  end if;
  close l_person;
  if p_party_id is not null then
    if p_party_id<>l_party_id then
      fnd_message.set_name('PER','IRC_412033_RTM_INV_PARTY_ID');
      fnd_message.raise_error;
  end if;
  else
    p_party_id:=l_party_id;
  end if;
  --
  hr_utility.set_location(l_proc,30);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc,50);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1 => 'IRC_NOTIFICATION_PREFERENCES.PERSON_ID'
      ) then
      --
      hr_utility.set_location(' Leaving:'||l_proc,60);
      --
      raise;
    end if;
    --
    hr_utility.set_location(' Leaving:'||l_proc,70);
    --
End chk_person_id;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_party_id >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates if the party id exists in the HZ_PARTIES with party_type = 'PERSON'
--
-- Prerequisites:
--   Must be called as the first step in insert_validate.
--
-- In Arguments:
--   p_party_id
--
-- Post Success:
--   If the party_id is existing in HZ_PARTIES with party_type = 'PERSON'
--   then continue.
--
-- Post Failure:
--   If the party_id does not existing in HZ_PARTIES with party_type = 'PERSON'
--   then throw an error indicating the same.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
Procedure chk_party_id
  (p_party_id           in irc_notification_preferences.party_id%type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_party_id';
  --
  l_party_id irc_notification_preferences.party_id%type;
  --
  l_inp_pk varchar2(1);
  cursor csr_party_id is
  select 1
  from hz_parties
  where party_id = p_party_id
  and party_type = 'PERSON';
  --
  cursor csr_chk_inp_pk is
  select null
  from irc_notification_preferences
  where party_id = p_party_id;
--
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'PARTY_ID'
  ,p_argument_value     => p_party_id
  );
  --
  open csr_party_id;
  fetch csr_party_id into l_party_id;
  --
  hr_utility.set_location(l_proc,20);
  --
  if csr_party_id%notfound then
    close csr_party_id;
    fnd_message.set_name('PER','IRC_412000_BAD_PARTY_PERSON_ID');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc,30);
  --
  close csr_party_id;
  --
  open csr_chk_inp_pk;
  fetch csr_chk_inp_pk into l_inp_pk;
  --
  hr_utility.set_location(l_proc,40);
  --
  if csr_chk_inp_pk%found then
    close csr_chk_inp_pk;
    fnd_message.set_name('PER','HR_6123_ALL_UNIQUE_NAME');
    fnd_message.set_token('INFORMATION_TYPE','PARTY ID');
    fnd_message.raise_error;
  end if;
  --
  close csr_chk_inp_pk;
  --
  hr_utility.set_location(' Leaving:'||l_proc,50);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1 => 'IRC_NOTIFICATION_PREFERENCES.PARTY_ID'
      ) then
      --
      hr_utility.set_location(' Leaving:'||l_proc,60);
      --
      raise;
    end if;
    --
    hr_utility.set_location(' Leaving:'||l_proc,70);
    --
End chk_party_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_address_id >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates if the address id exists in PER_ADDRESSES table, if its not null
--
-- Prerequisites:
--   Must be called after the chk_party_id in insert_validate.
--
-- In Arguments:
--   p_party_id
--   p_address_id
--   p_object_version_number
--
-- Post Success:
--   If the address_id is existing in PER_ADDRESSES then continue.
--
-- Post Failure:
--   If the party_id does not exist in PER_ADDRESSES
--   then throw an error indicating the same.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
Procedure chk_address_id
  (p_notification_preference_id
    in irc_notification_preferences.notification_preference_id%type
  ,p_address_id
    in irc_notification_preferences.address_id%type
  ,p_person_id
    in irc_notification_preferences.person_id%type
  ,p_object_version_number
    in irc_notification_preferences.object_version_number%type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_address_id';
  --
  l_address_id irc_notification_preferences.address_id%type;
  --
  l_api_updating boolean;
  --
  cursor csr_address_id is
  select 1
  from per_addresses
  where person_id = p_person_id
  and address_id = p_address_id;
--
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  -- Only proceed with person_id, address_id validation when
  -- multi message list does not already contain an error with
  -- person_id
  --
  if hr_multi_message.no_exclusive_error
    (p_check_column1      => 'IRC_NOTIFICATION_PREFERENCES.PERSON_ID'
    ,p_associated_column1 => 'IRC_NOTIFICATION_PREFERENCES.PERSON_ID'
    ) then
    if p_address_id is not null then
      --
      hr_utility.set_location(l_proc,20);
      --
      l_api_updating := irc_inp_shd.api_updating
        (p_notification_preference_id => p_notification_preference_id
        ,p_object_version_number => p_object_version_number);
      --
      hr_utility.set_location(l_proc,30);
      --
      if(l_api_updating and nvl(p_address_id, hr_api.g_number)
        <> nvl(irc_inp_shd.g_old_rec.address_id, hr_api.g_number))
        or (not l_api_updating) then
        --
        hr_utility.set_location(l_proc,40);
        --
        open csr_address_id;
        fetch csr_address_id into l_address_id;
        --
        hr_utility.set_location(l_proc,50);
        --
        if csr_address_id%notfound then
          close csr_address_id;
          fnd_message.set_name('PER','IRC_412001_BAD_ADDRESS_ID');
          fnd_message.raise_error;
        end if;
        --
        hr_utility.set_location(l_proc,60);
        --
        close csr_address_id;
        --
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,70);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1 => 'IRC_NOTIFICATION_PREFERENCES.ADDRESS_ID'
      ) then
      --
      hr_utility.set_location(' Leaving:'||l_proc,80);
      --
      raise;
    end if;
    --
    hr_utility.set_location(' Leaving:'||l_proc,90);
    --
End chk_address_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_matching_jobs >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates if the matching_jobs has a value of 'Y' or 'N'
--
-- Prerequisites:
--   Must be called in insert_validate.
--
-- In Arguments:
--   p_matching_jobs
--   p_party_id
--   p_object_version_number
--
-- Post Success:
--   If p_matching_jobs has a value of 'Y' or 'N' then continue.
--
-- Post Failure:
--   If p_mathcing_jobs has any other value other than 'Y' or 'N'
--   then throw an error indicating the same.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
Procedure chk_matching_jobs
  (p_matching_jobs
    in irc_notification_preferences.matching_jobs%type
  ,p_notification_preference_id
    in irc_notification_preferences.notification_preference_id%type
  ,p_object_version_number
    in irc_notification_preferences.object_version_number%type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_matching_jobs';
  --
  l_api_updating boolean;
--
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'MATCHING_JOBS'
  ,p_argument_value     => p_matching_jobs
  );
  --
  l_api_updating := irc_inp_shd.api_updating
    (p_notification_preference_id => p_notification_preference_id
    ,p_object_version_number => p_object_version_number);
  --
  hr_utility.set_location(l_proc,20);
  --
  if (l_api_updating
    and nvl(p_matching_jobs, hr_api.g_varchar2)
    <> nvl(irc_inp_shd.g_old_rec.matching_jobs, hr_api.g_varchar2))
    or (not l_api_updating) then
      --
      hr_utility.set_location(l_proc,30);
      --
      if (p_matching_jobs not in ('Y','N')) then
        fnd_message.set_name('PER','IRC_412002_BAD_MATCHING_JOBS');
        fnd_message.raise_error;
      end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,40);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1 => 'IRC_NOTIFICATION_PREFERENCES.MATCHING_JOBS'
      ) then
      --
      hr_utility.set_location(' Leaving:'||l_proc,50);
      --
      raise;
    end if;
    --
    hr_utility.set_location(' Leaving:'||l_proc,60);
    --
End chk_matching_jobs;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_matching_job_freq >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates the matching_job_freq against LOOKUP_TYPE = 'IRC_MESSAGE_FREQ'
--
-- Prerequisites:
--   Must be called in insert_validate.
--
-- In Arguments:
--   p_matching_job_freq
--   p_effective_date
--   p_party_id
--   p_object_version_number
--
-- Post Success:
--   If p_matching_job_freq exists for the LOOKUP_TYPE = 'IRC_MESSAGE_FREQ'
--   then continue.
--
-- Post Failure:
--   If p_mathcing_job_freq doesnt exist for the LOOKUP_TYPE =
--   'IRC_MESSAGE_FREQ' then throw an error indicating the same.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
Procedure chk_matching_job_freq
  (p_matching_job_freq
    in irc_notification_preferences.matching_job_freq%type
  ,p_notification_preference_id
    in irc_notification_preferences.notification_preference_id%type
  ,p_effective_date
    in date
  ,p_object_version_number
    in irc_notification_preferences.object_version_number%type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_matching_job_freq';
  --
  l_api_updating boolean;
--
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'MATCHING_JOB_FREQ'
  ,p_argument_value     => p_matching_job_freq
  );
  --
  l_api_updating := irc_inp_shd.api_updating
    (p_notification_preference_id => p_notification_preference_id
    ,p_object_version_number => p_object_version_number);
  --
  hr_utility.set_location(l_proc,20);
  --
  if (l_api_updating
    and nvl(p_matching_job_freq, hr_api.g_varchar2)
    <> nvl(irc_inp_shd.g_old_rec.matching_job_freq, hr_api.g_varchar2))
    or (not l_api_updating) then
      --
      hr_utility.set_location(l_proc,30);
      --
      if hr_api.not_exists_in_hr_lookups
        ( p_effective_date => p_effective_date
        , p_lookup_type    => 'IRC_MESSAGE_FREQ'
        , p_lookup_code    => p_matching_job_freq) then
          fnd_message.set_name('PER','IRC_412003_BAD_MATCH_JOB_FREQ');
          fnd_message.raise_error;
      end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,40);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1 => 'IRC_NOTIFICATION_PREFERENCES.MATCHING_JOB_FREQ'
      ) then
      --
      hr_utility.set_location(' Leaving:'||l_proc,50);
      --
      raise;
    end if;
    --
    hr_utility.set_location(' Leaving:'||l_proc,60);
    --
End chk_matching_job_freq;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_receive_info_mail >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates that the p_receive_info_mail is either 'Y' or 'N'
--
-- Prerequisites:
--   Must be called in insert_validate.
--
-- In Arguments:
--   p_receive_info_mail
--   p_party_id
--   p_object_version_number
--
-- Post Success:
--   If p_receive_info_mail is either 'Y' or 'N' then continue.
--
-- Post Failure:
--   If p_receive_info_mail is not 'Y' or 'N'
--   then throw an error indicating the same.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
Procedure chk_receive_info_mail
  (p_receive_info_mail
    in irc_notification_preferences.receive_info_mail%type
  ,p_notification_preference_id
    in irc_notification_preferences.notification_preference_id%type
  ,p_object_version_number
    in irc_notification_preferences.object_version_number%type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_receive_info_mail';
  --
  l_api_updating boolean;
--
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'RECEIVE_INFO_MAIL'
  ,p_argument_value     => p_receive_info_mail
  );
  --
  l_api_updating := irc_inp_shd.api_updating
    (p_notification_preference_id => p_notification_preference_id
    ,p_object_version_number => p_object_version_number);
  --
  hr_utility.set_location(l_proc,20);
  --
  if (l_api_updating
    and nvl(p_receive_info_mail, hr_api.g_varchar2)
    <> nvl(irc_inp_shd.g_old_rec.receive_info_mail, hr_api.g_varchar2))
    or (not l_api_updating) then
      --
      hr_utility.set_location(l_proc,30);
      --
      if p_receive_info_mail not in ('Y','N') then
          fnd_message.set_name('PER','IRC_412004_BAD_REC_INFO_MAIL');
          fnd_message.raise_error;
      end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,40);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1 => 'IRC_NOTIFICATION_PREFERENCES.RECEIVE_INFO_MAIL'
      ) then
      --
      hr_utility.set_location(' Leaving:'||l_proc,50);
      --
      raise;
    end if;
    --
    hr_utility.set_location(' Leaving:'||l_proc,60);
    --
End chk_receive_info_mail;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_allow_access >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates that the p_allow_access is either 'Y' or 'N'
--
-- Prerequisites:
--   Must be called in insert_validate.
--
-- In Arguments:
--   p_allow_access
--   p_party_id
--   p_object_version_number
--
-- Post Success:
--   If p_allow_access is either 'Y' or 'N' then continue.
--
-- Post Failure:
--   If p_allow_access is not 'Y' or 'N'
--   then throw an error indicating the same.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
Procedure chk_allow_access
  (p_allow_access
    in irc_notification_preferences.allow_access%type
  ,p_notification_preference_id
    in irc_notification_preferences.notification_preference_id%type
  ,p_object_version_number
    in irc_notification_preferences.object_version_number%type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_allow_access';
  --
  l_api_updating boolean;
--
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'ALLOW_ACCESS'
  ,p_argument_value     => p_allow_access
  );
  --
  l_api_updating := irc_inp_shd.api_updating
    (p_notification_preference_id => p_notification_preference_id
    ,p_object_version_number => p_object_version_number);
  --
  hr_utility.set_location(l_proc,20);
  --
  if (l_api_updating
    and nvl(p_allow_access, hr_api.g_varchar2)
    <> nvl(irc_inp_shd.g_old_rec.allow_access, hr_api.g_varchar2))
    or (not l_api_updating) then
      if p_allow_access not in ('Y','N') then
        fnd_message.set_name('PER','IRC_412005_BAD_ALLOW_ACCESS');
        fnd_message.raise_error;
      end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,30);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1 => 'IRC_NOTIFICATION_PREFERENCES.ALLOW_ACCESS'
      ) then
      --
      hr_utility.set_location(' Leaving:'||l_proc,40);
      --
      raise;
    end if;
    --
    hr_utility.set_location(' Leaving:'||l_proc,50);
    --
End chk_allow_access;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_agency_id >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates if the agency id exists in the PO_VENDORS with
--   vendor_type_lookup_code = 'IRC_JOB_AGENCY'
--
-- Prerequisites:
--   Must be called as the first step in insert_validate.
--
-- In Arguments:
--   p_agency_id
--
-- Post Success:
--   If the agency_id is existing in PO_VENDORS with
--   vendor_type_lookup_code = 'IRC_JOB_AGENCY', then continue.
--
-- Post Failure:
--   If the agency_id does not existing in PO_VENDORS with vendor_type_lookup_code =
--   'IRC_JOB_AGENCY' then throw an error indicating the same.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
Procedure chk_agency_id
  (p_agency_id
    in irc_notification_preferences.agency_id%type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_agency_id';
  l_agency_id irc_notification_preferences.agency_id%type;
  cursor csr_agency_id is
    select 1
      from po_vendors
     where vendor_id = p_agency_id
       and vendor_type_lookup_code = 'IRC_JOB_AGENCY';
--
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  open csr_agency_id;
  fetch csr_agency_id into l_agency_id;
  --
  hr_utility.set_location(l_proc,20);

  if csr_agency_id%notfound then
      close csr_agency_id;
      fnd_message.set_name('PER','IRC_BAD_AGENCY_ID');
      fnd_message.raise_error;
  end if;
    --
    hr_utility.set_location(l_proc,30);
    --
    close csr_agency_id;
    --
    hr_utility.set_location(' Leaving:'||l_proc,50);
    --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
        (p_associated_column1 => 'IRC_NOTIFICATION_PREFERENCES.AGENCY_ID'
        ) then
        --
        hr_utility.set_location(' Leaving:'||l_proc,60);
        --
        raise;
      end if;
      --
      hr_utility.set_location(' Leaving:'||l_proc,70);
      --
End chk_agency_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_attempt_id>------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates if the attempt id exists in OTA_ATTEMPTS
--
-- Prerequisites:
--   Must be called as the first step in insert_validate.
--
-- In Arguments:
--   p_attempt_id
--
-- Post Success:
--   If attempt_id exists in OTA_ATTEMPTS, then continue.
--
-- Post Failure:
--   If the attempt_id does not exists in OTA_ATTEMPTS, then
--      throw an error indicating the same.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
Procedure chk_attempt_id
  (p_attempt_id in
              irc_notification_preferences.attempt_id%type
  ,p_notification_preference_id  in
              irc_notification_preferences.notification_preference_id%type
  ,p_object_version_number in
              irc_notification_preferences.object_version_number%type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_attempt_id';
  l_attempt_exists number;
  l_api_updating     boolean;
  --
  cursor csr_attempt_exists is
    select 1
      from ota_attempts
     where attempt_id = p_attempt_id;
--
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  l_api_updating := irc_inp_shd.api_updating
         (p_notification_preference_id   => p_notification_preference_id
         ,p_object_version_number        => p_object_version_number
         );
  --
  hr_utility.set_location(l_proc, 20);
  if ((l_api_updating and
         nvl(irc_inp_shd.g_old_rec.attempt_id, hr_api.g_number) <>
         nvl(p_attempt_id, hr_api.g_number))
      or
      (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc, 30);
    --
    -- Check if attempt_id is not null
    --
    if p_attempt_id IS NOT NULL then
      --
      -- attempt_id must exist in ota_attempts
      --
      open csr_attempt_exists;
      fetch csr_attempt_exists into l_attempt_exists;
      --
      hr_utility.set_location(l_proc,40);
      --
      if csr_attempt_exists%notfound then
        close csr_attempt_exists;
        hr_utility.set_location(l_proc,50);
        fnd_message.set_name('PER','IRC_412233_INV_OTA_ATTEMPT');
        fnd_message.raise_error;
      else
        close csr_attempt_exists;
      end if;
      --
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,60);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
        (p_associated_column1 => 'IRC_NOTIFICATION_PREFERENCES.ATTEMPT_ID'
        ) then
        --
        hr_utility.set_location(' Leaving:'||l_proc,70);
        --
        raise;
      end if;
      --
      hr_utility.set_location(' Leaving:'||l_proc,80);
      --
End chk_attempt_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in out nocopy irc_inp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_person_id
  (p_person_id =>p_rec.person_id
  ,p_party_id => p_rec.party_id
  ,p_effective_date=>p_effective_date
  );
  --
  hr_utility.set_location(l_proc, 10);
  --
  chk_address_id
    (p_address_id => p_rec.address_id
    ,p_notification_preference_id => p_rec.notification_preference_id
    ,p_person_id => p_rec.person_id
    ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 20);
  --
  chk_matching_jobs
    (p_matching_jobs => p_rec.matching_jobs
    ,p_notification_preference_id => p_rec.notification_preference_id
    ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 30);
  --
  chk_matching_job_freq
    (p_matching_job_freq => p_rec.matching_job_freq
    ,p_effective_date => p_effective_date
    ,p_notification_preference_id => p_rec.notification_preference_id
    ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 40);
  --
  chk_receive_info_mail
    (p_receive_info_mail => p_rec.receive_info_mail
    ,p_notification_preference_id => p_rec.notification_preference_id
    ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 50);
  --
  chk_allow_access
    (p_allow_access => p_rec.allow_access
    ,p_notification_preference_id => p_rec.notification_preference_id
    ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 60);
  --
  if p_rec.agency_id is not null then
    chk_agency_id
      (p_agency_id => p_rec.agency_id);
  end if;
  --
  hr_utility.set_location(l_proc, 65);
  chk_attempt_id
    (p_attempt_id => p_rec.attempt_id
    ,p_notification_preference_id => p_rec.notification_preference_id
    ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 70);
  --
  irc_inp_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in out nocopy irc_inp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_person_id
  (p_person_id =>p_rec.person_id
  ,p_party_id => p_rec.party_id
  ,p_effective_date=>p_effective_date
  );
  --
  --
  hr_utility.set_location('Entering:'||l_proc, 6);
  --
   chk_address_id
    (p_address_id => p_rec.address_id
    ,p_notification_preference_id => p_rec.notification_preference_id
    ,p_person_id => p_rec.person_id
    ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 10);
  --
  chk_matching_jobs
    (p_matching_jobs => p_rec.matching_jobs
    ,p_notification_preference_id => p_rec.notification_preference_id
    ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 20);
  --
  chk_matching_job_freq
    (p_matching_job_freq => p_rec.matching_job_freq
    ,p_effective_date => p_effective_date
    ,p_notification_preference_id => p_rec.notification_preference_id
    ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 30);
  --
  chk_receive_info_mail
    (p_receive_info_mail => p_rec.receive_info_mail
    ,p_notification_preference_id => p_rec.notification_preference_id
    ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 40);
  --
  chk_allow_access
    (p_allow_access => p_rec.allow_access
    ,p_notification_preference_id => p_rec.notification_preference_id
    ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 50);
  --
  if p_rec.agency_id is not null then
    chk_agency_id
      (p_agency_id => p_rec.agency_id);
  end if;
  --
  hr_utility.set_location(l_proc, 55);
  chk_attempt_id
    (p_attempt_id => p_rec.attempt_id
    ,p_notification_preference_id => p_rec.notification_preference_id
    ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 60);
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  irc_inp_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 60);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in irc_inp_shd.g_rec_type
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
end irc_inp_bus;

/
