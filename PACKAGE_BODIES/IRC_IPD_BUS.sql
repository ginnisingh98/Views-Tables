--------------------------------------------------------
--  DDL for Package Body IRC_IPD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IPD_BUS" as
/* $Header: iripdrhi.pkb 120.0 2005/07/26 15:09:42 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_ipd_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_pending_data_id             number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_pending_data_id                      in number
  ,p_associated_column1                   in varchar2 default null
  ) is
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
    ,p_argument           => 'pending_data_id'
    ,p_argument_value     => p_pending_data_id
    );
  --
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
  (p_pending_data_id                      in     number
  )
  Return Varchar2 Is
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150) :=  'NONE';
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
    ,p_argument           => 'pending_data_id'
    ,p_argument_value     => p_pending_data_id
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
  (p_rec in irc_ipd_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.pending_data_id is not null)  and (
    nvl(irc_ipd_shd.g_old_rec.per_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.per_information_category, hr_api.g_varchar2)  or
    nvl(irc_ipd_shd.g_old_rec.per_information1, hr_api.g_varchar2) <>
    nvl(p_rec.per_information1, hr_api.g_varchar2)  or
    nvl(irc_ipd_shd.g_old_rec.per_information2, hr_api.g_varchar2) <>
    nvl(p_rec.per_information2, hr_api.g_varchar2)  or
    nvl(irc_ipd_shd.g_old_rec.per_information3, hr_api.g_varchar2) <>
    nvl(p_rec.per_information3, hr_api.g_varchar2)  or
    nvl(irc_ipd_shd.g_old_rec.per_information4, hr_api.g_varchar2) <>
    nvl(p_rec.per_information4, hr_api.g_varchar2)  or
    nvl(irc_ipd_shd.g_old_rec.per_information5, hr_api.g_varchar2) <>
    nvl(p_rec.per_information5, hr_api.g_varchar2)  or
    nvl(irc_ipd_shd.g_old_rec.per_information6, hr_api.g_varchar2) <>
    nvl(p_rec.per_information6, hr_api.g_varchar2)  or
    nvl(irc_ipd_shd.g_old_rec.per_information7, hr_api.g_varchar2) <>
    nvl(p_rec.per_information7, hr_api.g_varchar2)  or
    nvl(irc_ipd_shd.g_old_rec.per_information8, hr_api.g_varchar2) <>
    nvl(p_rec.per_information8, hr_api.g_varchar2)  or
    nvl(irc_ipd_shd.g_old_rec.per_information9, hr_api.g_varchar2) <>
    nvl(p_rec.per_information9, hr_api.g_varchar2)  or
    nvl(irc_ipd_shd.g_old_rec.per_information10, hr_api.g_varchar2) <>
    nvl(p_rec.per_information10, hr_api.g_varchar2)  or
    nvl(irc_ipd_shd.g_old_rec.per_information11, hr_api.g_varchar2) <>
    nvl(p_rec.per_information11, hr_api.g_varchar2)  or
    nvl(irc_ipd_shd.g_old_rec.per_information12, hr_api.g_varchar2) <>
    nvl(p_rec.per_information12, hr_api.g_varchar2)  or
    nvl(irc_ipd_shd.g_old_rec.per_information13, hr_api.g_varchar2) <>
    nvl(p_rec.per_information13, hr_api.g_varchar2)  or
    nvl(irc_ipd_shd.g_old_rec.per_information14, hr_api.g_varchar2) <>
    nvl(p_rec.per_information14, hr_api.g_varchar2)  or
    nvl(irc_ipd_shd.g_old_rec.per_information15, hr_api.g_varchar2) <>
    nvl(p_rec.per_information15, hr_api.g_varchar2)  or
    nvl(irc_ipd_shd.g_old_rec.per_information16, hr_api.g_varchar2) <>
    nvl(p_rec.per_information16, hr_api.g_varchar2)  or
    nvl(irc_ipd_shd.g_old_rec.per_information17, hr_api.g_varchar2) <>
    nvl(p_rec.per_information17, hr_api.g_varchar2)  or
    nvl(irc_ipd_shd.g_old_rec.per_information18, hr_api.g_varchar2) <>
    nvl(p_rec.per_information18, hr_api.g_varchar2)  or
    nvl(irc_ipd_shd.g_old_rec.per_information19, hr_api.g_varchar2) <>
    nvl(p_rec.per_information19, hr_api.g_varchar2)  or
    nvl(irc_ipd_shd.g_old_rec.per_information20, hr_api.g_varchar2) <>
    nvl(p_rec.per_information20, hr_api.g_varchar2)  or
    nvl(irc_ipd_shd.g_old_rec.per_information21, hr_api.g_varchar2) <>
    nvl(p_rec.per_information21, hr_api.g_varchar2)  or
    nvl(irc_ipd_shd.g_old_rec.per_information22, hr_api.g_varchar2) <>
    nvl(p_rec.per_information22, hr_api.g_varchar2)  or
    nvl(irc_ipd_shd.g_old_rec.per_information23, hr_api.g_varchar2) <>
    nvl(p_rec.per_information23, hr_api.g_varchar2)  or
    nvl(irc_ipd_shd.g_old_rec.per_information24, hr_api.g_varchar2) <>
    nvl(p_rec.per_information24, hr_api.g_varchar2)  or
    nvl(irc_ipd_shd.g_old_rec.per_information25, hr_api.g_varchar2) <>
    nvl(p_rec.per_information25, hr_api.g_varchar2)  or
    nvl(irc_ipd_shd.g_old_rec.per_information26, hr_api.g_varchar2) <>
    nvl(p_rec.per_information26, hr_api.g_varchar2)  or
    nvl(irc_ipd_shd.g_old_rec.per_information27, hr_api.g_varchar2) <>
    nvl(p_rec.per_information27, hr_api.g_varchar2)  or
    nvl(irc_ipd_shd.g_old_rec.per_information28, hr_api.g_varchar2) <>
    nvl(p_rec.per_information28, hr_api.g_varchar2)  or
    nvl(irc_ipd_shd.g_old_rec.per_information29, hr_api.g_varchar2) <>
    nvl(p_rec.per_information29, hr_api.g_varchar2)  or
    nvl(irc_ipd_shd.g_old_rec.per_information30, hr_api.g_varchar2) <>
    nvl(p_rec.per_information30, hr_api.g_varchar2) ))
    or (p_rec.pending_data_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'Person Developer DF'
      ,p_attribute_category              => p_rec.per_information_category
      ,p_attribute1_name                 => 'PER_INFORMATION1'
      ,p_attribute1_value                => p_rec.per_information1
      ,p_attribute2_name                 => 'PER_INFORMATION2'
      ,p_attribute2_value                => p_rec.per_information2
      ,p_attribute3_name                 => 'PER_INFORMATION3'
      ,p_attribute3_value                => p_rec.per_information3
      ,p_attribute4_name                 => 'PER_INFORMATION4'
      ,p_attribute4_value                => p_rec.per_information4
      ,p_attribute5_name                 => 'PER_INFORMATION5'
      ,p_attribute5_value                => p_rec.per_information5
      ,p_attribute6_name                 => 'PER_INFORMATION6'
      ,p_attribute6_value                => p_rec.per_information6
      ,p_attribute7_name                 => 'PER_INFORMATION7'
      ,p_attribute7_value                => p_rec.per_information7
      ,p_attribute8_name                 => 'PER_INFORMATION8'
      ,p_attribute8_value                => p_rec.per_information8
      ,p_attribute9_name                 => 'PER_INFORMATION9'
      ,p_attribute9_value                => p_rec.per_information9
      ,p_attribute10_name                => 'PER_INFORMATION10'
      ,p_attribute10_value               => p_rec.per_information10
      ,p_attribute11_name                => 'PER_INFORMATION11'
      ,p_attribute11_value               => p_rec.per_information11
      ,p_attribute12_name                => 'PER_INFORMATION12'
      ,p_attribute12_value               => p_rec.per_information12
      ,p_attribute13_name                => 'PER_INFORMATION13'
      ,p_attribute13_value               => p_rec.per_information13
      ,p_attribute14_name                => 'PER_INFORMATION14'
      ,p_attribute14_value               => p_rec.per_information14
      ,p_attribute15_name                => 'PER_INFORMATION15'
      ,p_attribute15_value               => p_rec.per_information15
      ,p_attribute16_name                => 'PER_INFORMATION16'
      ,p_attribute16_value               => p_rec.per_information16
      ,p_attribute17_name                => 'PER_INFORMATION17'
      ,p_attribute17_value               => p_rec.per_information17
      ,p_attribute18_name                => 'PER_INFORMATION18'
      ,p_attribute18_value               => p_rec.per_information18
      ,p_attribute19_name                => 'PER_INFORMATION19'
      ,p_attribute19_value               => p_rec.per_information19
      ,p_attribute20_name                => 'PER_INFORMATION20'
      ,p_attribute20_value               => p_rec.per_information20
      ,p_attribute21_name                => 'PER_INFORMATION21'
      ,p_attribute21_value               => p_rec.per_information21
      ,p_attribute22_name                => 'PER_INFORMATION22'
      ,p_attribute22_value               => p_rec.per_information22
      ,p_attribute23_name                => 'PER_INFORMATION23'
      ,p_attribute23_value               => p_rec.per_information23
      ,p_attribute24_name                => 'PER_INFORMATION24'
      ,p_attribute24_value               => p_rec.per_information24
      ,p_attribute25_name                => 'PER_INFORMATION25'
      ,p_attribute25_value               => p_rec.per_information25
      ,p_attribute26_name                => 'PER_INFORMATION26'
      ,p_attribute26_value               => p_rec.per_information26
      ,p_attribute27_name                => 'PER_INFORMATION27'
      ,p_attribute27_value               => p_rec.per_information27
      ,p_attribute28_name                => 'PER_INFORMATION28'
      ,p_attribute28_value               => p_rec.per_information28
      ,p_attribute29_name                => 'PER_INFORMATION29'
      ,p_attribute29_value               => p_rec.per_information29
      ,p_attribute30_name                => 'PER_INFORMATION30'
      ,p_attribute30_value               => p_rec.per_information30
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
  (p_rec in irc_ipd_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT irc_ipd_shd.api_updating
      (p_pending_data_id                   => p_rec.pending_data_id
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  --
  -- Checks to ensure non-updateable args have
  --            not been updated.
  if p_rec.pending_data_id <> irc_ipd_shd.g_old_rec.pending_data_id
    then
    hr_api.argument_changed_error
      (p_api_name   => l_proc
      ,p_argument   => 'PENDING_DATA_ID'
      ,p_base_table => irc_ipd_shd.g_tab_nam
      );
  end if;
  --
  if nvl(p_rec.vacancy_id, hr_api.g_number) <>
     nvl(irc_ipd_shd.g_old_rec.vacancy_id
        ,hr_api.g_number)
    then
    hr_api.argument_changed_error
      (p_api_name   => l_proc
      ,p_argument   => 'VACANCY_ID'
      ,p_base_table => irc_ipd_shd.g_tab_nam
      );
  end if;
  --
  if p_rec.creation_date <> irc_ipd_shd.g_old_rec.creation_date
    then
    hr_api.argument_changed_error
      (p_api_name   => l_proc
      ,p_argument   => 'CREATION_DATE'
      ,p_base_table => irc_ipd_shd.g_tab_nam
      );
  end if;
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_vacancy_id >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that vacancy_id exists in
--   per_all_vacancies and is valid on creation_date.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_vacancy_id
--   p_creation_date
--
-- Post Success:
--   Processing continues if the vacancy id exists and is valid on
--   creation_date.
--
-- Post Failure:
--   An application error is raised if the vacancy id does not exist
--   or is not valid on creation_date.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_vacancy_id
  (p_vacancy_id in irc_pending_data.vacancy_id%type
  ,p_creation_date in irc_pending_data.creation_date%type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_vacancy_id';
  l_num number;
  --
  cursor csr_vacancy_id is
    select 1
    from per_all_vacancies
    where vacancy_id = p_vacancy_id
    and nvl(date_to,hr_api.g_eot) >= p_creation_date
    and  date_from <= p_creation_date;
  --
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'creation date'
    ,p_argument_value => p_creation_date
    );
  --
  -- Check if the vacancy id is valid on creation date.
  --
  open csr_vacancy_id;
  fetch csr_vacancy_id into l_num;
  hr_utility.set_location(l_proc,20);
  if csr_vacancy_id%notfound then
    close csr_vacancy_id;
    hr_utility.set_message(800,'IRC_412015_BAD_VACANCY_ID');
    hr_utility.raise_error;
  end if;
  close csr_vacancy_id;
  hr_utility.set_location(l_proc,30);
--
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1 =>
      'IRC_PENDING_DATA.VACANCY_ID'
      ) then
      hr_utility.set_location(' Leaving:'||l_proc,50);
      raise;
    end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,60);
End chk_vacancy_id;
--
-- ----------------------------------------------------------------------------
--   |-------------------< chk_job_already_apld_for >--------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that person has not already for the job
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_vacancy_id
--   p_email_address
--
-- Post Success:
--   Processing continues if the person has not already for the job.
--
-- Post Failure:
--   An application error is raised if the vacancy id exists for the person id.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_job_already_apld_for
  (p_vacancy_id in irc_pending_data.vacancy_id%type
  ,p_email_address  in irc_pending_data.email_address%type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_job_already_apld_for';
  l_num number;
--
  cursor csr_job  is
    select 1
    from irc_pending_data
    where vacancy_id = p_vacancy_id
    and   upper(email_address) = upper(p_email_address);
  --
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  if hr_multi_message.no_exclusive_error(
    p_check_column1      => 'IRC_PENDING_DATA.VACANCY_ID'
    ) then
  --
    open csr_job;
    fetch csr_job into l_num;
    hr_utility.set_location(l_proc,20);
    if csr_job%found then
      close csr_job;
      hr_utility.set_message(800,'IRC_APL_ALREADY_APPLIED');
      hr_utility.raise_error;
    end if;
    close csr_job;
  end if;
--
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1 => 'IRC_PENDING_DATA.VACANCY_ID'
      ,p_associated_column2 => 'IRC_PENDING_DATA.EMAIL_ADDRESS'
      ) then
      hr_utility.set_location(' Leaving:'||l_proc,30);
      raise;
    end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,40);
End chk_job_already_apld_for;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_sex >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that sex exists in
--   lookup.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_sex
--   p_creation_date
--
-- Post Success:
--   Processing continues if the sex exists in lookup.
--
-- Post Failure:
--   An application error is raised if the sex does not exist
--   in the lookup.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_sex
  (p_sex in irc_pending_data.sex%type
  ,p_creation_date in irc_pending_data.creation_date%type
  ,p_pending_data_id in irc_pending_data.pending_data_id%type
  ) IS
--
  l_api_updating   boolean;
  l_proc  varchar2(72) := g_package||'chk_sex';
  --
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'creation date'
    ,p_argument_value => p_creation_date
    );
  l_api_updating := irc_ipd_shd.api_updating
            (p_pending_data_id                 => p_pending_data_id
            );
  --
  if hr_multi_message.no_exclusive_error(
     p_check_column1      => 'IRC_PENDING_DATA.VACANCY_ID'
    ) then
  --
    if (l_api_updating and nvl(p_sex,hr_api.g_varchar2)
        <> nvl(irc_ipd_shd.g_old_rec.sex,hr_api.g_varchar2)
        or not l_api_updating) then
      --
      --Check if sex is set
      --
      if p_sex is not null then
        hr_utility.set_location('Entering:'||l_proc,20);
        --
        --Check if the sex exists in hr_lookups
        --
        if hr_api.not_exists_in_hr_lookups
          (p_effective_date    => p_creation_date
          ,p_lookup_type       => 'SEX'
          ,p_lookup_code       => p_sex
        ) then
          hr_utility.set_message(800,'HR_7511_PER_SEX_INVALID');
          hr_utility.raise_error;
        end if;
      end if;
    end if;
  end if;
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1 =>
      'IRC_PENDING_DATA.SEX'
      ) then
      hr_utility.set_location(' Leaving:'||l_proc,30);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,50);
--
--
End chk_sex;
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
  (p_allow_access  in irc_pending_data.allow_access%type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_allow_access';
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
  hr_utility.set_location(l_proc,20);
  --
  if p_allow_access not in ('Y','N') then
    hr_utility.set_message(800,'IRC_412005_BAD_ALLOW_ACCESS');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,30);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1 => 'IRC_PENDING_DATA.ALLOW_ACCESS'
      ) then
      --
      hr_utility.set_location(' Leaving:'||l_proc,40);
      --
      raise;
    end if;
    --
    hr_utility.set_location(' Leaving:'||l_proc,50);
    --
--
--
End chk_allow_access;
--
--  ---------------------------------------------------------------------------
--  |---------------------<  chk_GB_per_information >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Checks that the values held in developer descriptive flexfields
--      are valid for a category of 'GB'
--    - Validates that per information3  and per information11 to 20 are null.
--    - Validates that per information2, 4 ,9 and 10 exists as a lookup code on
--      HR_LOOKUPS for the lookup type 'YES_NO' with an enabled flag set to 'Y'
--      and the person is active on HR_LOOKUPS on creation date.
--    - Validates that per information1 exists as a lookup code on HR_LOOKUPS
--      for the lookup type 'ETH_TYPE' with an enabled flag set to 'Y' and the
--      person is active on HR_LOOKUPS on effective  date.
--    - Validates that per information5 is less than or equal to 30 characters
--      and in uppercase.
--
--  Pre-conditions:
--    A GB per information category
--
--  In Arguments:
--    p_person_id
--    p_per_information_category
--    p_per_information1
--    p_per_information2
--    p_per_information3
--    p_per_information4
--    p_per_information5
--    p_per_information6
--    p_per_information7
--    p_per_information8
--    p_per_information9
--    p_per_information10
--    p_per_information11
--    p_per_information12
--    p_per_information13
--    p_per_information14
--    p_per_information15
--    p_per_information16
--    p_per_information17
--    p_per_information18
--    p_per_information19
--    p_per_information20
--    p_effective_date
--
--  Post Success:
--    Processing continues if:
--      - per_information3 and per_information11 to 20 values are null
--      - per information2, 4 , 9 and 10 exists as a lookup code in HR_LOOKUPS
--        for the lookup type 'YES_NO' where the enabled flag is 'Y'
--        and active on HR_LOOKUPS on creation_date.
--      - per information1 exists as a lookup code in HR_LOOKUPS
--        for the lookup type 'ETH_TYPE' where the enabled flag is 'Y'
--        and active on HR_LOOKUPS on creation_date.
--      - per_information5 is less than or equal to 30 characters long
--        and upper case.
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - any of per_information3 and per_information10 to 20 values are
--        not null.
--      - any of per information2, 4,9 and 10 does'nt exist as a lookup code
--        in HR_LOOKUPS for the lookup type 'YES_NO' where the enabled flag
--        is 'Y' and the person is active on HR_LOOKUPS on creation date.
--      - per information1 does'nt exist as a lookup code in HR_LOOKUPS
--        for the lookup type 'ETH_TYPE' where the enabled flag is 'Y'
--        the person is active on HR_LOOKUPS on creation date.
--      - per_information5 is not less than or equal to 30 characters long
--        or not upper case.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_GB_per_information
  (p_person_id                in     irc_pending_data.person_id%TYPE
  ,p_per_information_category in     irc_pending_data.per_information_category
                                                                      %TYPE
  ,p_per_information1         in     irc_pending_data.per_information1%TYPE
  ,p_per_information2         in     irc_pending_data.per_information2%TYPE
  ,p_per_information3         in     irc_pending_data.per_information3%TYPE
  ,p_per_information4         in     irc_pending_data.per_information4%TYPE
  ,p_per_information5         in     irc_pending_data.per_information5%TYPE
  ,p_per_information6         in     irc_pending_data.per_information6%TYPE
  ,p_per_information7         in     irc_pending_data.per_information7%TYPE
  ,p_per_information8         in     irc_pending_data.per_information8%TYPE
  ,p_per_information9         in     irc_pending_data.per_information9%TYPE
  ,p_per_information10        in     irc_pending_data.per_information10%TYPE
  ,p_per_information11        in     irc_pending_data.per_information11%TYPE
  ,p_per_information12        in     irc_pending_data.per_information12%TYPE
  ,p_per_information13        in     irc_pending_data.per_information13%TYPE
  ,p_per_information14        in     irc_pending_data.per_information14%TYPE
  ,p_per_information15        in     irc_pending_data.per_information15%TYPE
  ,p_per_information16        in     irc_pending_data.per_information16%TYPE
  ,p_per_information17        in     irc_pending_data.per_information17%TYPE
  ,p_per_information18        in     irc_pending_data.per_information18%TYPE
  ,p_per_information19        in     irc_pending_data.per_information19%TYPE
  ,p_per_information20        in     irc_pending_data.per_information20%TYPE
  ,p_per_information21        in     irc_pending_data.per_information21%TYPE
  ,p_per_information22        in     irc_pending_data.per_information22%TYPE
  ,p_per_information23        in     irc_pending_data.per_information23%TYPE
  ,p_per_information24        in     irc_pending_data.per_information24%TYPE
  ,p_per_information25        in     irc_pending_data.per_information25%TYPE
  ,p_per_information26        in     irc_pending_data.per_information26%TYPE
  ,p_per_information27        in     irc_pending_data.per_information27%TYPE
  ,p_per_information28        in     irc_pending_data.per_information28%TYPE
  ,p_per_information29        in     irc_pending_data.per_information29%TYPE
  ,p_per_information30        in     irc_pending_data.per_information30%TYPE
  ,p_creation_date            in     irc_pending_data.creation_date%TYPE
  )
is
--
  l_error          exception;
  l_proc           varchar2(72)  :=  g_package||'chk_GB_per_information';
  l_api_updating   boolean;
  l_lookup_type    varchar2(30);
  l_info_attribute number(2);
  l_per_information6 irc_pending_data.per_information6%TYPE;
  l_per_information7 irc_pending_data.per_information7%TYPE;
  l_per_information8 irc_pending_data.per_information8%TYPE;
  l_output           varchar2(150);
  l_rgeflg           varchar2(10);
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check the mandatory parameters
  --
  --
   hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'creation_date'
    ,p_argument_value =>  p_creation_date
    );
  --
  -- We know the per_information_category is GB, so check the rest of
  -- the per_information fields within this context.
  --
  --  Check if the per_information1 value exists in hr_lookups
  --  where the lookup_type is 'ETH_TYPE'
  --
  if p_per_information1 is not null then
    --
    -- Check that per information1 exists in hr_lookups for the
    -- lookup type 'ETH_TYPE' with an enabled flag set to 'Y' and that
    -- the person is active on creation date in hr_lookups.
    --
    if hr_api.not_exists_in_hr_lookups
      (p_effective_date        => p_creation_date
      ,p_lookup_type           => 'ETH_TYPE'
      ,p_lookup_code           => p_per_information1
      )
    then
      --
      hr_utility.set_message(801, 'HR_7524_PER_INFO1_INVALID');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  --  Check if the per_information2 value exists in hr_lookups
  --  where the lookup_type is 'YES_NO'
  --
  if p_per_information2 is not null then
    --
    -- Check that per information2 exists in hr_lookups for the
    -- lookup type 'YES_NO' with an enabled flag set to 'Y' and that
    -- the person is active on creation date in hr_lookups.
    --
    if hr_api.not_exists_in_hr_lookups
      (p_effective_date        => p_creation_date
      ,p_lookup_type           => 'YES_NO'
      ,p_lookup_code           => p_per_information2
      )
    then
      --
      hr_utility.set_message(801, 'HR_7525_PER_INFO2_INVALID');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  --  Check if the per_information4 value exists in hr_lookups
  --  where the lookup_type is 'YES_NO'
  --
  if p_per_information4 is not null then
    --
    -- Check that per information4 exists in hr_lookups for the
    -- lookup type 'YES_NO' with an enabled flag set to 'Y' and that
    -- the person is active on creation date in hr_lookups.
    --
    if hr_api.not_exists_in_hr_lookups
      (p_effective_date        => p_creation_date
      ,p_lookup_type           => 'YES_NO'
      ,p_lookup_code           => p_per_information4
      )
    then
      --
      hr_utility.set_message(801, 'HR_7526_PER_INFO4_INVALID');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  -- Check if p_per_information5 is greater than 30 characters long
  --
  if p_per_information5 is not null then
    if length(p_per_information5) > 30 then
      --  Error: Work Permit (PER_INFORMATION5) cannot be longer than
      --         30 characters
      hr_utility.set_message(801, 'HR_7527_PER_INFO5_LENGTH');
      hr_utility.raise_error;
    end if;
    --
    --  Check if p_per_information5 is not upper case
    --
    --if p_per_information5 <> upper(p_per_information5) then
      --  Error: Enter the Work Permit value (PER_INFORMATION5) in
      --         upper case
      --hr_utility.set_message(801, 'HR_7528_PER_INFO5_CASE');
      --hr_utility.raise_error;
    --end if;
  end if;
  --
  -- Check if p_per_information6 is in the range 0 - 99.
  --
  if p_per_information6 is not null then
    --
    l_per_information6 := p_per_information6;
    hr_chkfmt.checkformat(value   => l_per_information6
                         ,format  => 'I'
                         ,output  => l_output
                         ,minimum => NULL
                         ,maximum => NULL
                         ,nullok  => 'Y'
                         ,rgeflg  => l_rgeflg
                         ,curcode => NULL);
    --
    if to_number(l_per_information6) < 0  or
       to_number(l_per_information6) > 99 then
      --  Error: Additional pension years (PER_INFORMATION6) not in the
      --         range 0 - 99.
      hr_utility.set_message(801, 'HR_51272_PER_INFO6_INVALID');
      hr_utility.raise_error;
    end if;
  end if;
  --
  -- Check if p_per_information7 is in the range 1 - 11.
  --
  if p_per_information7 is not null then
    --
    l_per_information7 := p_per_information7;
    hr_chkfmt.checkformat(value   => l_per_information7
                         ,format  => 'I'
                         ,output  => l_output
                         ,minimum => NULL
                         ,maximum => NULL
                         ,nullok  => 'Y'
                         ,rgeflg  => l_rgeflg
                         ,curcode => NULL);
    --
    if to_number(l_per_information7) < 1  or
       to_number(l_per_information7) > 11 then
      --  Error: Additional pension months (PER_INFORMATION7) not in the
      --         range 1 - 11.
      hr_utility.set_message(801, 'HR_51273_PER_INFO7_INVALID');
      hr_utility.raise_error;
    end if;
  end if;
  --
  -- Check if p_per_information8 is number.
  --
  if p_per_information8 is not null then
    --
    l_per_information8 := p_per_information8;
    hr_chkfmt.checkformat(value   => l_per_information8
                         ,format  => 'I'
                         ,output  => l_output
                         ,minimum => NULL
                         ,maximum => NULL
                         ,nullok  => 'Y'
                         ,rgeflg  => l_rgeflg
                         ,curcode => NULL);
  end if;
  --
  --  Check if the per_information9 value exists in hr_lookups
  --  where the lookup_type is 'YES_NO'
  --
  if p_per_information9 is not null then
    --
    -- Check that per information9 exists in hr_lookups for the
    -- lookup type 'YES_NO' with an enabled flag set to 'Y' and that
    -- the person is active on creation date in hr_lookups.
    --
    if hr_api.not_exists_in_hr_lookups
      (p_effective_date        => p_creation_date
      ,p_lookup_type           => 'YES_NO'
      ,p_lookup_code           => p_per_information9
      )
    then
      --
      hr_utility.set_message(801, 'HR_51274_PER_INFO9_INVALID');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  if p_per_information10 is not null then
     --
     -- Check that per information10 exists in hr_lookups for the
     -- lookup type 'YES_NO' with an enabled flag set to 'Y' and that
     -- the person is active on creation date in hr_lookups.
     --
    if hr_api.not_exists_in_hr_lookups
      (p_effective_date        => p_creation_date
      ,p_lookup_type           => 'YES_NO'
      ,p_lookup_code           => p_per_information10
      )
     then
     --
     hr_utility.set_message(801, 'HR_78105_PER_INFO10_INVALID');
     hr_utility.raise_error;
     --
     end if;
     --
  end if;
  --
  --  Check if any of the remaining per_information parameters are not
  --  null
  --  (developer descriptive flexfields not used for GB)
  --
  if p_per_information3 is not null then
    l_info_attribute := 3;
    raise l_error;
  elsif p_per_information11 is not null then
    l_info_attribute := 11;
    raise l_error;
  elsif p_per_information12 is not null then
    l_info_attribute := 12;
    raise l_error;
  elsif p_per_information13 is not null then
    l_info_attribute := 13;
    raise l_error;
  elsif p_per_information14 is not null then
    l_info_attribute := 14;
    raise l_error;
  elsif p_per_information15 is not null then
    l_info_attribute := 15;
    raise l_error;
  elsif p_per_information16 is not null then
    l_info_attribute := 16;
    raise l_error;
  elsif p_per_information17 is not null then
    l_info_attribute := 17;
    raise l_error;
  elsif p_per_information18 is not null then
    l_info_attribute := 18;
    raise l_error;
  elsif p_per_information19 is not null then
    l_info_attribute := 19;
    raise l_error;
  elsif p_per_information20 is not null then
    l_info_attribute := 20;
    raise l_error;
  elsif p_per_information21 is not null then
    l_info_attribute := 21;
    raise l_error;
  elsif p_per_information22 is not null then
    l_info_attribute := 22;
    raise l_error;
  elsif p_per_information23 is not null then
    l_info_attribute := 23;
    raise l_error;
  elsif p_per_information24 is not null then
    l_info_attribute := 24;
    raise l_error;
  elsif p_per_information25 is not null then
    l_info_attribute := 25;
    raise l_error;
  elsif p_per_information26 is not null then
    l_info_attribute := 26;
    raise l_error;
  elsif p_per_information27 is not null then
    l_info_attribute := 27;
    raise l_error;
  elsif p_per_information28 is not null then
    l_info_attribute := 28;
    raise l_error;
  elsif p_per_information29 is not null then
    l_info_attribute := 29;
    raise l_error;
  elsif p_per_information30 is not null then
    l_info_attribute := 30;
    raise l_error;
  end if;
exception
    when l_error then
      --  Error: Do not enter PER_INFORMATION99 for this legislation
      hr_utility.set_message(801, 'HR_7529_PER_INFO_NOT_NULL');
      hr_utility.set_message_token('NUM',to_char(l_info_attribute));
      hr_utility.raise_error;
--
hr_utility.set_location(' Leaving:'|| l_proc, 220);
end chk_GB_per_information;
--
--  ---------------------------------------------------------------------------
--  |---------------------<  chk_US_per_information >-------------------------|
--  ---------------------------------------------------------------------------
--  Description:
--    - Checks that the values held in developer descriptive flexfields
--      are valid for a category of 'US'.
--    - Validates that per information6 and 9 exist as a lookup code on
--      HR_LOOKUPS for the lookup type 'YES_NO' with an enabled flag
--      set to 'Y' and the person is active on creation_date in HR_LOOKUPS.
--    - Validates that per information1 exists as a lookup code on HR_LOOKUPS
--      for the lookup type 'US_ETHNIC_GROUP' with an enabled flag set to 'Y'
--      and the person is active on creation_date in HR_LOOKUPS.
--    - Validates that per information2 exists as a lookup code on HR_LOOKUPS
--      for the lookup type 'PER_US_I9_STATE' with an enabled flag set to 'Y'
--      and the person is active on creation_date in HR_LOOKUPS.
--    - Validates that per information4 exists as a lookup code on HR_LOOKUPS
--      for the lookup type 'US_VISA_TYPE' with an enabled flag set to 'Y'
--      and the person is active on creation_date in HR_LOOKUPS.
--    - Validates that per information5 exists as a lookup code on HR_LOOKUPS
--      for the lookup type 'US_VETERAN_STATUS' with an enabled flag set to 'Y'
--      and the person is active on creation_date in HR_LOOKUPS.
--    - Validates that per information7 exists as a lookup code on HR_LOOKUPS
--      for the lookup type 'US_NEW_HIRE_STATUS' with enabled flag set to 'Y'
--      and the person is active on creation_date in HR_LOOKUPS.
--    - Validates that when per information7 is set to 'EXCL' that per
--      information8 exists as a lookup code on HR_LOOKUPS for the lookup type
--      'US_NEW_HIRE_EXCEPTIONS' with an enabled flag set to 'Y' and the
--      person is active on creation_date in HR_LOOKUPS.
--    - Validates that per information10 exists as a lookup code on
--      HR_LOOKUPS for the lookup type 'YES_NO' with an enabled flag
--      set to 'Y' and the person is active on creation_date in HR_LOOKUPS.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_person_id
--    p_per_information_category
--    p_per_information1
--    p_per_information2
--    p_per_information3
--    p_per_information4
--    p_per_information5
--    p_per_information6
--    p_per_information7
--    p_per_information8
--    p_per_information9
--    p_per_information10
--    p_per_information11
--    p_per_information12
--    p_per_information13
--    p_per_information14
--    p_per_information15
--    p_per_information16
--    p_per_information17
--    p_per_information18
--    p_per_information19
--    p_per_information20
--    p_per_information21
--    p_per_information22
--    p_per_information23
--    p_per_information24
--    p_per_information25
--    p_per_information26
--    p_per_information27
--    p_per_information28
--    p_per_information29
--    p_per_information30
--    p_effective_date
--    p_api_updating
--
--  Post Success:
--    Processing continues if:
--      - per information6 and 9 exist as a lookup code in HR_LOOKUPS
--        for the lookup type 'YES_NO' where the enabled flag is 'Y' and
--        the person is active on creation_date in HR_LOOKUPS.
--      - per information1 exists as a lookup code in HR_LOOKUPS
--        for the lookup type 'US_ETHNIC_GROUP' where the enabled flag is
--        'Y' and the person is active on creation_date in HR_LOOKUPS.
--      - per information2 exists as a lookup code in HR_LOOKUPS
--        for the lookup type 'PER_US_I9_STATE' where the enabled flag is
--        'Y' and the person is active on creation_date in HR_LOOKUPS.
--      - per information3 is a valid date and 11 characters long.
--      - per information4 exists as a lookup code in HR_LOOKUPS
--        for the lookup type 'US_VISA_TYPE' where the enabled flag is
--        'Y' and the person is active on creation_date in HR_LOOKUPS.
--      - per information5 exists as a lookup code in HR_LOOKUPS
--        for the lookup type 'US_VETERAN_STATUS' where the enabled flag is
--        'Y' and the person is active on creation_date in HR_LOOKUPS.
--      - per information7 exists as a lookup code in HR_LOOKUPS
--        for the lookup type 'US_NEW_HIRE_STATUS' where the enabled flag is
--        'Y' and the person is active on creation_date in HR_LOOKUPS.
--      - when per information7 is set to 'EXCL' and per information8 exists
--        as a lookup code in HR_LOOKUPS for the lookup type
--        'US_NEW_HIRE_EXCEPTIONS' where the enabled flag is 'Y' and
--        the person is active on creation_date in HR_LOOKUPS.
--
--     9) per_information9 value exists in hr_lookups
--        where lookup_type = 'YES_NO'
--
--    10) per information10 exists as a lookup code in HR_LOOKUPS
--        for the lookup type 'YES_NO' where the enabled flag is 'Y' and
--        the person is active on creation_date in HR_LOOKUPS.
--
--    11) per_information11 to 20 values are null
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - per information6 and 9 does not exist as a lookup code in
--        HR_LOOKUPS for the lookup type 'YES_NO' where the
--        enabled flag is 'Y' and the person is active on
--        creation_date on HR_LOOKUPS.
--      - per information1 doesn't exist as a lookup code in HR_LOOKUPS
--        for the lookup type 'US_ETHNIC_GROUP' where the enabled flag is
--        'Y' and and the person is active on creation_date on HR_LOOKUPS.
--      - per information2 doesn't exist as a lookup code in HR_LOOKUPS
--        for the lookup type 'PER_US_I9_STATE' where the enabled flag is
--        'Y' and and the person is active on creation_date on HR_LOOKUPS.
--      - per information3 value is an invalid date or less than 11
--        characters long.
--      - per information4 doesn't exist as a lookup code in HR_LOOKUPS
--        for the lookup type 'US_VISA_TYPE' where the enabled flag is
--        'Y' and and the person is active on creation_date on HR_LOOKUPS.
--      - per information5 doesn't exist as a lookup code in HR_LOOKUPS
--        for the lookup type 'US_VETERAN_STATUS' where the enabled flag is
--        'Y' and and the person is active on creation_date on HR_LOOKUPS.
--      - per information7 doesn't exist as a lookup code in HR_LOOKUPS
--        for the lookup type 'US_NEW_HIRE_STATUS' where the enabled flag is
--        'Y' and and the person is active on creation_date on HR_LOOKUPS.
--      - per information8 doesn't exist as a lookup code in HR_LOOKUPS
--        for the lookup type 'US_NEW_HIRE_EXCEPTION' where the enabled flag is
--        'Y' and the person is active on creation_date on HR_LOOKUPS.
--      - when per information7 is set to 'EXCL' and per information8 doesn't
--        exist as a lookup code in HR_LOOKUPS for the lookup type
--        'US_NEW_HIRE_EXCEPTIONS' where the enabled flag is 'Y'
--        and the person is active on creation_date on HR_LOOKUPS.
--
--     9) per_information9 value does not exists in hr_lookups
--        where lookup_type = 'YES_NO'
--
--    10) per information10 does not exist as a lookup code in HR_LOOKUPS
--        for the lookup type 'YES_NO' where the enabled flag is 'Y'
--        and the person is active on creation_date on HR_LOOKUPS.
--
--    11) per_information11 to 20 values are not null
--
--  Access Status:
--    Internal Table Handler Use Only
--
procedure chk_US_per_information
  (p_person_id                in     irc_pending_data.person_id%TYPE
  ,p_per_information_category in     irc_pending_data.per_information_category
                                                                      %TYPE
  ,p_per_information1         in     irc_pending_data.per_information1%TYPE
  ,p_per_information2         in     irc_pending_data.per_information2%TYPE
  ,p_per_information3         in     irc_pending_data.per_information3%TYPE
  ,p_per_information4         in     irc_pending_data.per_information4%TYPE
  ,p_per_information5         in     irc_pending_data.per_information5%TYPE
  ,p_per_information6         in     irc_pending_data.per_information6%TYPE
  ,p_per_information7         in     irc_pending_data.per_information7%TYPE
  ,p_per_information8         in     irc_pending_data.per_information8%TYPE
  ,p_per_information9         in     irc_pending_data.per_information9%TYPE
  ,p_per_information10        in     irc_pending_data.per_information10%TYPE
  ,p_per_information11        in     irc_pending_data.per_information11%TYPE
  ,p_per_information12        in     irc_pending_data.per_information12%TYPE
  ,p_per_information13        in     irc_pending_data.per_information13%TYPE
  ,p_per_information14        in     irc_pending_data.per_information14%TYPE
  ,p_per_information15        in     irc_pending_data.per_information15%TYPE
  ,p_per_information16        in     irc_pending_data.per_information16%TYPE
  ,p_per_information17        in     irc_pending_data.per_information17%TYPE
  ,p_per_information18        in     irc_pending_data.per_information18%TYPE
  ,p_per_information19        in     irc_pending_data.per_information19%TYPE
  ,p_per_information20        in     irc_pending_data.per_information20%TYPE
  ,p_per_information21        in     irc_pending_data.per_information21%TYPE
  ,p_per_information22        in     irc_pending_data.per_information22%TYPE
  ,p_per_information23        in     irc_pending_data.per_information23%TYPE
  ,p_per_information24        in     irc_pending_data.per_information24%TYPE
  ,p_per_information25        in     irc_pending_data.per_information25%TYPE
  ,p_per_information26        in     irc_pending_data.per_information26%TYPE
  ,p_per_information27        in     irc_pending_data.per_information27%TYPE
  ,p_per_information28        in     irc_pending_data.per_information28%TYPE
  ,p_per_information29        in     irc_pending_data.per_information29%TYPE
  ,p_per_information30        in     irc_pending_data.per_information30%TYPE
  ,p_creation_date            in     irc_pending_data.creation_date%TYPE
  ,p_api_updating             in     boolean
  )
is
--
  l_error            exception;
  l_per_information3 per_all_people_f.per_information3%TYPE;
  l_output           varchar2(150);
  l_info_attribute   number(2);
  l_proc             varchar2(72)  :=  g_package||'chk_US_per_information';
--
Begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check the mandatory parameters
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'creation_date'
    ,p_argument_value =>  p_creation_date
    );
  --
  -- We know the per_information_category is US, so check the rest of
  -- the per_information fields within this context.
  --
  -- Check if the value for per information1 is set on insert or has
  -- changed on update.
  --
  if (((nvl(p_per_information1,hr_api.g_varchar2)
        <> nvl(irc_ipd_shd.g_old_rec.per_information1,hr_api.g_varchar2)
        and p_api_updating)
      or (NOT p_api_updating))
    and p_per_information1 is not null)
  then
    -- Check that per information1 exists in hr_lookups for the
    -- lookup type 'US_ETHNIC_GROUP' with an enabled flag set to 'Y'
    -- the person is active on creation date in hr_lookups.
    --
    if hr_api.not_exists_in_hr_lookups
      (p_effective_date        => p_creation_date
      ,p_lookup_type           => 'US_ETHNIC_GROUP'
      ,p_lookup_code           => p_per_information1
      )
    then
    --
      hr_utility.set_message(801, 'HR_7524_PER_INFO1_INVALID');
      hr_utility.raise_error;
      --
    end if;
  end if;
  -- Check if the value for per information2 is set on insert or has
  -- changed on update.
  --
  if (((nvl(p_per_information2,hr_api.g_varchar2) <>
        nvl(irc_ipd_shd.g_old_rec.per_information2,hr_api.g_varchar2)
                     and p_api_updating) or
       (NOT p_api_updating)) and
        p_per_information2 is not null)
  then
    --
    -- Check that per information2 exists in hr_lookups for the
    -- lookup type 'PER_US_I9_STATE' with an enabled flag set to 'Y' and that
    -- the person is active on creation date in hr_lookups.
    --
    if hr_api.not_exists_in_hr_lookups
      (p_effective_date        => p_creation_date
      ,p_lookup_type           => 'PER_US_I9_STATE'
      ,p_lookup_code           => p_per_information2
      )
    then
    --
      hr_utility.set_message(801, 'HR_51243_PER_INFO2_INVALID');
      hr_utility.raise_error;
    end if;
  end if;
-- Check if the value for per information3 is set on insert or has
  -- changed on update.
  --
  if (((nvl(p_per_information3,hr_api.g_varchar2) <>
        nvl(irc_ipd_shd.g_old_rec.per_information3,hr_api.g_varchar2)
                     and p_api_updating) or
       (NOT p_api_updating)) and
        p_per_information3 is not null)
  then
    --
    --  Check if the per_information3 value is an 11 character date
    --  field.
    --
    l_per_information3 := p_per_information3;
    hr_chkfmt.changeformat(input  => l_per_information3
                         ,output  => l_output
                         ,format  => 'D'
                         ,curcode => NULL);
  end if;
  --
  -- Check if the value for per information4 is set on insert or has
  -- changed on update.
  --
  if (((nvl(p_per_information4,hr_api.g_varchar2) <>
        nvl(irc_ipd_shd.g_old_rec.per_information4,hr_api.g_varchar2)
                     and p_api_updating) or
       (NOT p_api_updating)) and
        p_per_information4 is not null)
  then
    --
    -- Check that per information4 exists in hr_lookups for the
    -- lookup type 'US_VISA_TYPE' with an enabled flag set to 'Y'
    -- the person is active on creation date in hr_lookups.
    --
    if hr_api.not_exists_in_hr_lookups
      (p_effective_date        => p_creation_date
      ,p_lookup_type           => 'US_VISA_TYPE'
      ,p_lookup_code           => p_per_information4
      )
    then
      --
      hr_utility.set_message(801, 'HR_51245_PER_INFO4_INVALID');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
  -- Check if the value for per information5 is set on insert or has
  -- changed on update.
  --
  if (((nvl(p_per_information5,hr_api.g_varchar2) <>
        nvl(irc_ipd_shd.g_old_rec.per_information5,hr_api.g_varchar2)
                     and p_api_updating) or
       (NOT p_api_updating)) and
        p_per_information5 is not null)
  then
    --
    -- Check that per information5 exists in hr_lookups for the
    -- lookup type 'US_VISA_TYPE' with an enabled flag set to 'Y'
    -- the person is active on creation date in hr_lookups.
    --
    if hr_api.not_exists_in_hr_lookups
      (p_effective_date        => p_creation_date
      ,p_lookup_type           => 'US_VETERAN_STATUS'
      ,p_lookup_code           => p_per_information5
      )
    then
      --
      hr_utility.set_message(801, 'HR_51246_PER_INFO5_INVALID');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
  -- Check if the value for per information6 is set on insert or has
  -- changed on update.
  --
  if (((nvl(p_per_information6,hr_api.g_varchar2) <>
        nvl(irc_ipd_shd.g_old_rec.per_information6,hr_api.g_varchar2)
                     and p_api_updating) or
       (NOT p_api_updating)) and
        p_per_information6 is not null)
  then
    --
    -- Check that per information6 exists in hr_lookups for the
    -- lookup type 'YES_NO' with an enabled flag set to 'Y' and that
    -- the person is active on creation date in hr_lookups.
    --
    if hr_api.not_exists_in_hr_lookups
      (p_effective_date        => p_creation_date
      ,p_lookup_type           => 'YES_NO'
      ,p_lookup_code           => p_per_information6
      )
    then
      --
      hr_utility.set_message(801, 'HR_51247_PER_INFO6_INVALID');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
  -- Check if the value for per information7 is set on insert or has
  -- changed on update.
  --
  if (((nvl(p_per_information7,hr_api.g_varchar2) <>
        nvl(irc_ipd_shd.g_old_rec.per_information7,hr_api.g_varchar2)
                     and p_api_updating) or
       (NOT p_api_updating)) and
        p_per_information7 is not null)
  then
    --
    -- Check that per information7 exists in hr_lookups for the
    -- lookup type 'US_NEW_HIRE_STATUS' with an enabled flag set to 'Y'
    -- the person is active on creation date in hr_lookups.
    --
    if hr_api.not_exists_in_hr_lookups
      (p_effective_date        => p_creation_date
      ,p_lookup_type           => 'US_NEW_HIRE_STATUS'
      ,p_lookup_code           => p_per_information7
      )
    then
      --
      hr_utility.set_message(801, 'HR_51285_PER_INFO7_INVALID');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  -- Check if the value for per information8 is set on insert or has
  -- changed on update.
  --
  if (((nvl(p_per_information8,hr_api.g_varchar2) <>
        nvl(irc_ipd_shd.g_old_rec.per_information8,hr_api.g_varchar2)
                     and p_api_updating) or
       (NOT p_api_updating)) and
        p_per_information8 is not null)
  then
    --
    -- Check if per information7 is 'EXCL'
    --
    if nvl(p_per_information7,hr_api.g_varchar2) <> 'EXCL'
    then
      --
      -- Error: Field must be null because per_info7 is not 'EXCL'
      --
      hr_utility.set_message(801, 'HR_51286_PER_INFO8_NOT_NULL');
      hr_utility.raise_error;
    else
      --
      -- Check that per information7 exists in hr_lookups for the
      -- lookup type 'US_NEW_HIRE_EXCEPTIONS' with an enabled flag set to 'Y'
      -- the person is active on creation date in hr_lookups.
      --
      if hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_creation_date
        ,p_lookup_type           => 'US_NEW_HIRE_EXCEPTIONS'
        ,p_lookup_code           => p_per_information8
        )
      then
        --
        hr_utility.set_message(801, 'HR_51287_PER_INFO8_INVALID');
        hr_utility.raise_error;
        --
      end if;
    end if;
  end if;
  --
  -- Check if the value for per information9 is set on insert or has
  -- changed on update.
  --
  if (((nvl(p_per_information9,hr_api.g_varchar2) <>
        nvl(irc_ipd_shd.g_old_rec.per_information9,hr_api.g_varchar2)
                     and p_api_updating) or
       (NOT p_api_updating)) and
        p_per_information9 is not null)
  then
    --
    -- Check that per information9 exists in hr_lookups for the
    -- lookup type 'YES_NO' with an enabled flag set to 'Y' and that
    -- the person is active on creation date in hr_lookups.
    --
    if hr_api.not_exists_in_hr_lookups
      (p_effective_date        => p_creation_date
      ,p_lookup_type           => 'YES_NO'
      ,p_lookup_code           => p_per_information9
      )
    then
      --
      hr_utility.set_message(801, 'HR_51288_PER_INFO9_INVALID');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
  if (((nvl(p_per_information10,hr_api.g_varchar2) <>
        nvl(irc_ipd_shd.g_old_rec.per_information10,hr_api.g_varchar2)
                     and p_api_updating) or
       (NOT p_api_updating)) and
        p_per_information10 is not null)
  then
    --
    -- Check that per information10 exists in hr_lookups for the
    -- lookup type 'YES_NO' with an enabled flag set to 'Y' and that
    -- the person is active on creation date in hr_lookups.
    --
    if hr_api.not_exists_in_hr_lookups
      (p_effective_date        => p_creation_date
      ,p_lookup_type           => 'YES_NO'
      ,p_lookup_code           => p_per_information10
      )
    then
      --
      hr_utility.set_message(801, 'PER_52390_PER_INFO10_INVALID');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
  --  Check if any of the remaining per_information parameters are not
  --  null
  --  (developer descriptive flexfields not used for US)
  --

  -- TM removed check for p_per_information10 now that it is being used.
  if p_per_information11 is not null then
    l_info_attribute := 11;
    raise l_error;
  elsif p_per_information12 is not null then
    l_info_attribute := 12;
    raise l_error;
  elsif p_per_information13 is not null then
    l_info_attribute := 13;
    raise l_error;
  elsif p_per_information14 is not null then
    l_info_attribute := 14;
    raise l_error;
  elsif p_per_information15 is not null then
    l_info_attribute := 15;
    raise l_error;
  elsif p_per_information16 is not null then
    l_info_attribute := 16;
    raise l_error;
  elsif p_per_information17 is not null then
    l_info_attribute := 17;
    raise l_error;
  elsif p_per_information18 is not null then
    l_info_attribute := 18;
    raise l_error;
  elsif p_per_information19 is not null then
    l_info_attribute := 19;
    raise l_error;
  elsif p_per_information20 is not null then
    l_info_attribute := 20;
    raise l_error;
  elsif p_per_information21 is not null then
    l_info_attribute := 21;
    raise l_error;
  elsif p_per_information22 is not null then
    l_info_attribute := 22;
    raise l_error;
  elsif p_per_information23 is not null then
    l_info_attribute := 23;
    raise l_error;
  elsif p_per_information24 is not null then
    l_info_attribute := 24;
    raise l_error;
  elsif p_per_information25 is not null then
    l_info_attribute := 25;
    raise l_error;
  elsif p_per_information26 is not null then
    l_info_attribute := 26;
    raise l_error;
  elsif p_per_information27 is not null then
    l_info_attribute := 27;
    raise l_error;
  elsif p_per_information28 is not null then
    l_info_attribute := 28;
    raise l_error;
  elsif p_per_information29 is not null then
    l_info_attribute := 29;
    raise l_error;
  elsif p_per_information30 is not null then
    l_info_attribute := 30;
    raise l_error;
  end if;
  --
exception
    when l_error then
      --  Error: Do not enter PER_INFORMATION99 for this legislation
      hr_utility.set_message(801, 'HR_7529_PER_INFO_NOT_NULL');
      hr_utility.set_message_token('NUM',to_char(l_info_attribute));
      hr_utility.raise_error;
  --
  hr_utility.set_location(' Leaving:'||l_proc,50);
End chk_US_per_information;
--
--
--  ---------------------------------------------------------------------------
--  |-----------------------<  chk_per_information >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks that the values held in developer descriptive flexfields
--    are valid
--
--    This routine calls separate local validation procedures to perform
--    validation for each specific category. At present the suppported
--    categories are 'GB', 'US'

--  Pre-conditions:
--    None
--
--  In Arguments:
--  p_rec
--
--
--  Post Success:
--    If the value in per_information_category value is 'GB' or 'US' then
--    processing continues
--
--  Post Failure:
--    If the value in per_information_category value is not 'GB' or 'US' then
--    an application error will be raised and processing is terminated
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- ----------------------------------------------------------------------------
Procedure chk_per_information
  (p_rec    in out nocopy irc_ipd_shd.g_rec_type
  ) is
--
  l_error          exception;
  l_api_updating   boolean;
  l_info_attribute number(2);
  l_proc   varchar2(72) := g_package || 'chk_per_information';
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
--
--
--  Only proceed with validation if:
--  a) The current g_old_rec is current and
--  b) Any of the per_information (developer descriptive flex) values have
--     changed
--  c) A record is being inserted
  l_api_updating := irc_ipd_shd.api_updating
    (p_pending_data_id      => p_rec.pending_data_id
    );
  if ((l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information_category,
                              hr_api.g_varchar2)
    <> nvl(p_rec.per_information_category,hr_api.g_varchar2)) or
    (l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information1,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information1,hr_api.g_varchar2)) or
    (l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information2,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information2,hr_api.g_varchar2)) or
    (l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information3,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information3,hr_api.g_varchar2)) or
    (l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information4,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information4,hr_api.g_varchar2)) or
    (l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information5,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information5,hr_api.g_varchar2)) or
    (l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information6,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information6,hr_api.g_varchar2)) or
    (l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information7,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information7,hr_api.g_varchar2)) or
    (l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information8,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information8,hr_api.g_varchar2)) or
    (l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information9,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information9,hr_api.g_varchar2)) or
    (l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information10,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information10,hr_api.g_varchar2)) or
    (l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information11,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information11,hr_api.g_varchar2)) or
    (l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information12,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information12,hr_api.g_varchar2)) or
    (l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information13,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information13,hr_api.g_varchar2)) or
    (l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information14,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information14,hr_api.g_varchar2)) or
    (l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information15,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information15,hr_api.g_varchar2)) or
    (l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information16,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information16,hr_api.g_varchar2)) or
    (l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information17,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information17,hr_api.g_varchar2)) or
    (l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information18,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information18,hr_api.g_varchar2)) or
    (l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information19,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information19,hr_api.g_varchar2)) or
    (l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information20,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information20,hr_api.g_varchar2)) or
    (l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information21,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information21,hr_api.g_varchar2)) or
    (l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information22,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information22,hr_api.g_varchar2)) or
    (l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information23,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information23,hr_api.g_varchar2)) or
    (l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information24,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information24,hr_api.g_varchar2)) or
    (l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information25,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information25,hr_api.g_varchar2)) or
    (l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information26,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information26,hr_api.g_varchar2)) or
    (l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information27,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information27,hr_api.g_varchar2)) or
    (l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information28,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information28,hr_api.g_varchar2)) or
    (l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information29,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information29,hr_api.g_varchar2)) or
    (l_api_updating and nvl(irc_ipd_shd.g_old_rec.per_information30,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information30,hr_api.g_varchar2)) or
    (NOT l_api_updating))
  then
    --  Check if the per_information_category is 'GB' or 'US' calling
    --  the appropriate validation routine or generating an error
    --
    --  If p_rec.per_information_category is not null then
      If p_rec.per_information_category = 'GB' then
        --
        -- GB specific validation.
        --
        hr_utility.set_location('Entering:'||l_proc,20);
        irc_ipd_bus.chk_GB_per_information
          (p_person_id                 => p_rec.person_id
          ,p_per_information_category  => p_rec.per_information_category
          ,p_per_information1          => p_rec.per_information1
          ,p_per_information2          => p_rec.per_information2
          ,p_per_information3          => p_rec.per_information3
          ,p_per_information4          => p_rec.per_information4
          ,p_per_information5          => p_rec.per_information5
          ,p_per_information6          => p_rec.per_information6
          ,p_per_information7          => p_rec.per_information7
          ,p_per_information8          => p_rec.per_information8
          ,p_per_information9          => p_rec.per_information9
          ,p_per_information10         => p_rec.per_information10
          ,p_per_information11         => p_rec.per_information11
          ,p_per_information12         => p_rec.per_information12
          ,p_per_information13         => p_rec.per_information13
          ,p_per_information14         => p_rec.per_information14
          ,p_per_information15         => p_rec.per_information15
          ,p_per_information16         => p_rec.per_information16
          ,p_per_information17         => p_rec.per_information17
          ,p_per_information18         => p_rec.per_information18
          ,p_per_information19         => p_rec.per_information19
          ,p_per_information20         => p_rec.per_information20
          ,p_per_information21         => p_rec.per_information21
          ,p_per_information22         => p_rec.per_information22
          ,p_per_information23         => p_rec.per_information23
          ,p_per_information24         => p_rec.per_information24
          ,p_per_information25         => p_rec.per_information25
          ,p_per_information26         => p_rec.per_information26
          ,p_per_information27         => p_rec.per_information27
          ,p_per_information28         => p_rec.per_information28
          ,p_per_information29         => p_rec.per_information29
          ,p_per_information30         => p_rec.per_information30
          ,p_creation_date             => p_rec.creation_date
          );
      elsif p_rec.per_information_category = 'US' then
        --
        -- US specific validation.
        --
        hr_utility.set_location('Entering:'||l_proc,30);
        irc_ipd_bus.chk_US_per_information
          (p_person_id                 => p_rec.person_id
          ,p_per_information_category  => p_rec.per_information_category
          ,p_per_information1          => p_rec.per_information1
          ,p_per_information2          => p_rec.per_information2
          ,p_per_information3          => p_rec.per_information3
          ,p_per_information4          => p_rec.per_information4
          ,p_per_information5          => p_rec.per_information5
          ,p_per_information6          => p_rec.per_information6
          ,p_per_information7          => p_rec.per_information7
          ,p_per_information8          => p_rec.per_information8
          ,p_per_information9          => p_rec.per_information9
          ,p_per_information10         => p_rec.per_information10
          ,p_per_information11         => p_rec.per_information11
          ,p_per_information12         => p_rec.per_information12
          ,p_per_information13         => p_rec.per_information13
          ,p_per_information14         => p_rec.per_information14
          ,p_per_information15         => p_rec.per_information15
          ,p_per_information16         => p_rec.per_information16
          ,p_per_information17         => p_rec.per_information17
          ,p_per_information18         => p_rec.per_information18
          ,p_per_information19         => p_rec.per_information19
          ,p_per_information20         => p_rec.per_information20
          ,p_per_information21         => p_rec.per_information21
          ,p_per_information22         => p_rec.per_information22
          ,p_per_information23         => p_rec.per_information23
          ,p_per_information24         => p_rec.per_information24
          ,p_per_information25         => p_rec.per_information25
          ,p_per_information26         => p_rec.per_information26
          ,p_per_information27         => p_rec.per_information27
          ,p_per_information28         => p_rec.per_information28
          ,p_per_information29         => p_rec.per_information29
          ,p_per_information30         => p_rec.per_information30
          ,p_creation_date            =>  p_rec.creation_date
          ,p_api_updating              => l_api_updating
          );
      else
        irc_ipd_bus.chk_ddf(p_rec=>p_rec);
    end if;
  end if;
exception
    when l_error then
      hr_utility.set_message(800, 'HR_7529_PER_INFO_NOT_NULL');
      hr_utility.set_message_token('NUM',to_char(l_info_attribute));
      hr_multi_message.add;
  hr_utility.set_location(' Leaving:'||l_proc,50);
End chk_per_information;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in  out nocopy irc_ipd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  -- Validate Dependent Attributes
  --
  hr_utility.set_location(l_proc, 20);
  --
  if (p_rec.vacancy_id is not null) then
    irc_ipd_bus.chk_vacancy_id(
      p_vacancy_id            => p_rec.vacancy_id
      ,p_creation_date         => p_rec.creation_date
    );
    irc_ipd_bus.chk_job_already_apld_for(
      p_vacancy_id           => p_rec.vacancy_id
      ,p_email_address       => p_rec.email_address
    );
    irc_ipd_bus.chk_sex(
      p_sex              => p_rec.sex
      ,p_creation_date   => p_rec.creation_date
      ,p_pending_data_id => p_rec.pending_data_id
    );
  end if;
  --
  hr_utility.set_location(l_proc, 30);
  --
  if (p_rec.allow_access is not null) then
  --
    hr_utility.set_location(l_proc, 40);
  --
    irc_ipd_bus.chk_allow_access(
      p_allow_access   => p_rec.allow_access
    );
  end if;
  --
  hr_utility.set_location(l_proc, 50);
  -- Validate Developer Descriptive Flexfields
  --
  irc_ipd_bus.chk_per_information(
    p_rec                      =>  p_rec
  );
  --
  hr_utility.set_location(l_proc, 60);
  --
  irc_ipd_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in out nocopy irc_ipd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args(
    p_rec              => p_rec
  );
  --
  hr_utility.set_location(l_proc, 30);
  --
  irc_ipd_bus.chk_sex(
    p_sex             => p_rec.sex
    ,p_creation_date   => p_rec.creation_date
    ,p_pending_data_id => p_rec.pending_data_id
  );
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Validate Developer Descriptive Flexfields
  --
  irc_ipd_bus.chk_per_information(
    p_rec                      =>  p_rec
  );
  --
  hr_utility.set_location(l_proc, 50);

  irc_ipd_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 60);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in irc_ipd_shd.g_rec_type
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
end irc_ipd_bus;

/
