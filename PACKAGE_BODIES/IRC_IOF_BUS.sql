--------------------------------------------------------
--  DDL for Package Body IRC_IOF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IOF_BUS" as
/* $Header: iriofrhi.pkb 120.13.12010000.2 2009/03/06 06:12:46 kvenukop ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_iof_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_offer_id                    number         default null;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_offer_id                             in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , irc_offers iof
         , per_all_vacancies vac
     where iof.offer_id = p_offer_id
       and vac.vacancy_id = iof.vacancy_id
       and pbg.business_group_id = vac.business_group_id;
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
    ,p_argument           => 'offer_id'
    ,p_argument_value     => p_offer_id
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
     hr_multi_message.add
     (p_associated_column1 => nvl(p_associated_column1,'OFFER_ID'));
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
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_offer_id                             in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , irc_offers iof
         , per_all_vacancies vac
     where iof.offer_id = p_offer_id
       and iof.vacancy_id = vac.vacancy_id
       and pbg.business_group_id = vac.business_group_id;
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
  ,p_argument           => 'offer_id'
  ,p_argument_value     => p_offer_id
  );
  --
  if ( nvl(irc_iof_bus.g_offer_id, hr_api.g_number)
       = p_offer_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := irc_iof_bus.g_legislation_code;
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
    irc_iof_bus.g_offer_id          := p_offer_id;
    irc_iof_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
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
  (p_rec in irc_iof_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.offer_id is not null)  and (
    nvl(irc_iof_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(irc_iof_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(irc_iof_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(irc_iof_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(irc_iof_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(irc_iof_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(irc_iof_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(irc_iof_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(irc_iof_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(irc_iof_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(irc_iof_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(irc_iof_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(irc_iof_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(irc_iof_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(irc_iof_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(irc_iof_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(irc_iof_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(irc_iof_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(irc_iof_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(irc_iof_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(irc_iof_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(irc_iof_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(irc_iof_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(irc_iof_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(irc_iof_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(irc_iof_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(irc_iof_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(irc_iof_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(irc_iof_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(irc_iof_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(irc_iof_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    or (p_rec.offer_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'IRC_OFFERS'
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
      null;
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
  ,p_rec in irc_iof_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT irc_iof_shd.api_updating
      (p_offer_id                          => p_rec.offer_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  if irc_iof_shd.g_old_rec.offer_id <> p_rec.offer_id
    then
        hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => 'offer_id'
         ,p_base_table => irc_iof_shd.g_tab_name
         );
  end if;
  --
  if irc_iof_shd.g_old_rec.applicant_assignment_id <> p_rec.applicant_assignment_id
    then
        hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => 'applicant_assignment_id'
         ,p_base_table => irc_iof_shd.g_tab_name
         );
  end if;
  --
  if irc_iof_shd.g_old_rec.offer_assignment_id <> p_rec.offer_assignment_id
    then
        hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => 'offer_assignment_id'
         ,p_base_table => irc_iof_shd.g_tab_name
         );
  end if;
  --
  if irc_iof_shd.g_old_rec.vacancy_id <> p_rec.vacancy_id
    then
        hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => 'vacancy_id'
         ,p_base_table => irc_iof_shd.g_tab_name
         );
  end if;
  --
  if irc_iof_shd.g_old_rec.offer_version <> p_rec.offer_version
    then
        hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => 'offer_version'
         ,p_base_table => irc_iof_shd.g_tab_name
         );
  end if;
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_applicant_assignment_id >--------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that an active assignment of type applicant('A')
--   is present.
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   p_applicant_assignment_id
--   p_effective_date
--
-- Post Success:
--   Processing continues if applicant assignment ID is not null and there is
--   an active assignment of type is Applicant.
--
-- Post Failure:
--   An application error is raised if offer ID is null or exists already
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_applicant_assignment_id
  (p_effective_date               in date
  ,p_applicant_assignment_id in irc_offers.applicant_assignment_id%TYPE
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_applicant_assignment_id';
  l_applicant_assignment_id     number;
--
  cursor csr_applicant_assignment_id is
         select 1
           from per_all_assignments_f
          where assignment_id = p_applicant_assignment_id
            and assignment_type = 'A'
            and p_effective_date
        between effective_start_date
            and effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
--
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'effective_date'
  ,p_argument_value => p_effective_date
  );

  hr_api.mandatory_arg_error
  (p_api_name         => l_proc
  ,p_argument         => 'APPLICANT_ASSIGNMENT_ID'
  ,p_argument_value   => p_applicant_assignment_id
  );
--
  open csr_applicant_assignment_id;
  fetch csr_applicant_assignment_id into l_applicant_assignment_id;
--
  hr_utility.set_location(l_proc,20);
  if (csr_applicant_assignment_id%notfound)
  then
    close csr_applicant_assignment_id;
    fnd_message.set_name('PER','IRC_412006_ASG_NOT_APPL');
    fnd_message.raise_error;
  end if;
  close csr_applicant_assignment_id;
--
  hr_utility.set_location(' Leaving:'||l_proc,30);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'IRC_OFFERS.APPLICANT_ASSIGNMENT_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 50);
End chk_applicant_assignment_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_offer_assignment_id >--------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that assignment of type 'O'(Offers) is present
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   p_offer_assignment_id
--
-- Post Success:
--   Processing continues if applicant assignment ID is not null and
--   assignment_type is Offers
--
-- Post Failure:
--   An application error is raised if offer ID is null or exists already
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_offer_assignment_id
  (p_offer_assignment_id in irc_offers.offer_assignment_id%TYPE
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_offer_assignment_id';
  l_offer_assignment_id     number;
  l_offer_assignment_exists number;
--
  cursor csr_offer_assignment_id is
         select 1
           from per_all_assignments_f
          where assignment_id = p_offer_assignment_id
            and assignment_type = 'O';
--
  cursor csr_offer_assigment_exists is
         select 1
           from irc_offers
          where offer_assignment_id = p_offer_assignment_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
--
  if hr_multi_message.no_exclusive_error(
   p_check_column1      => 'IRC_OFFERS.APPLICANT_ASSIGNMENT_ID'
   ) then
--
  hr_api.mandatory_arg_error
  (p_api_name         => l_proc
  ,p_argument         => 'OFFER_ASSIGNMENT_ID'
  ,p_argument_value   => p_offer_assignment_id
  );
--
  open csr_offer_assignment_id;
  fetch csr_offer_assignment_id into l_offer_assignment_id;
--
  if (csr_offer_assignment_id%notfound)
  then
    --
    hr_utility.set_location(l_proc,20);
    --
    close csr_offer_assignment_id;
    fnd_message.set_name('PER','IRC_412006_ASG_NOT_APPL');
    fnd_message.raise_error;
  end if;
  close csr_offer_assignment_id;
  --
  -- Check to see if an offer already exists with this
  -- offer assignment.
  --
  open csr_offer_assigment_exists;
  fetch csr_offer_assigment_exists into l_offer_assignment_exists;

  if (csr_offer_assigment_exists%found)
  then
    --
    hr_utility.set_location(l_proc,25);
    --
    close csr_offer_assigment_exists;
    fnd_message.set_name('PER','IRC_412348_OFR_ASNMT_EXISTS');
    fnd_message.raise_error;
  end if;
  close csr_offer_assigment_exists;
  end if; -- no_exclusive_error
--
  hr_utility.set_location(' Leaving:'||l_proc,30);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'IRC_OFFERS.OFFER_ASSIGNMENT_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 50);
End chk_offer_assignment_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< set_vacancy_id >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure sets the vacancy from the applicant assignment vacancy_id
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   p_effective_date
--   p_applicant_assignment_id
--
-- Post Success:
--   The vacancy_id is set from assignment record
--
-- Out Arguments:
--   p_vacancy_id
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure set_vacancy_id
  (p_vacancy_id              out nocopy irc_offers.vacancy_id%TYPE
  ,p_effective_date          in date
  ,p_applicant_assignment_id in irc_offers.applicant_assignment_id%TYPE
  ) IS
--
  l_proc           varchar2(72) := g_package || 'set_vacancy_id';
  l_vacancy_id     irc_offers.vacancy_id%TYPE;
--
  cursor csr_appl_vac_id is
         select paaf.vacancy_id
           from per_all_assignments_f paaf
          where paaf.assignment_id = p_applicant_assignment_id
            and p_effective_date
        between effective_start_date
            and effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
--
  if hr_multi_message.no_exclusive_error(
    p_check_column1      => 'IRC_OFFERS.APPLICANT_ASSIGNMENT_ID'
   ,p_check_column2      => 'IRC_OFFERS.OFFER_ASSIGNMENT_ID'
    ) then
--
-- Select the vacancy_id from Applicant assignment record.
--
  open csr_appl_vac_id;
  fetch csr_appl_vac_id into l_vacancy_id;
--
  hr_utility.set_location(l_proc,20);
  if (csr_appl_vac_id%notfound)
  then
    --
    hr_utility.set_location(l_proc,30);
    --
    close csr_appl_vac_id;
    fnd_message.set_name('PER','IRC_412006_ASG_NOT_APPL');
    fnd_message.raise_error;
  end if;
  close csr_appl_vac_id;
--
  p_vacancy_id   :=  l_vacancy_id;
--
  end if; -- no_exclusive_error
--
  hr_utility.set_location(' Leaving:'||l_proc,40);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'IRC_OFFERS.VACANCY_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 50);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 60);
End set_vacancy_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_offers_exceeds_openings >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that Number of Openings on a vacancy does not exceed
--   the number of Offers with the Status of Extended and Applicant Assignments
--   for the Vacancy with status of Accepted.
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   p_vacancy_id
--   p_offer_status
--
-- Post Success:
--   Processing continues if the number of openings for the vacancy have not been
--   exceeded.
--
-- Post Failure:
--   An application error is raised if number of offers for the vacancy have
--   exceeded the number of openings.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_offers_exceeds_openings
  (p_vacancy_id   in irc_offers.vacancy_id%TYPE
  ,p_offer_status in irc_offers.offer_status%TYPE
  ,p_offer_id     in irc_offers.offer_id%TYPE
  ) IS
--
  l_proc                       varchar2(72) := g_package || 'chk_offers_exceeds_openings';
  l_offer_count                number(15);
  l_prev_offer_status          irc_offers.offer_status%TYPE;
  l_prev_change_reason         irc_offer_status_history.change_reason%TYPE;
  l_prev_to_prev_offer_status  irc_offers.offer_status%TYPE;
  l_prev_to_prev_change_reason irc_offer_status_history.change_reason%TYPE;
  l_chk_vacancy_count          boolean := false;
--
  cursor csr_vacancy_opening_count is
         select budget_measurement_value
               ,budget_measurement_type
           from per_all_vacancies
          where vacancy_id = p_vacancy_id;
--
  cursor csr_prev_to_prev_offer_chg_rsn is
  select ios1.offer_status
        ,ios1.change_reason
    from irc_offer_status_history ios1
   where ios1.offer_id = p_offer_id
     and  EXISTS
       (SELECT 1
       FROM irc_offer_status_history iosh1
       WHERE iosh1.offer_id = ios1.offer_id
           AND iosh1.status_change_date > ios1.status_change_date
       )
     AND ios1.offer_status_history_id =
       (SELECT MAX(iosh2.offer_status_history_id)
       FROM irc_offer_status_history iosh2
       WHERE iosh2.offer_id = ios1.offer_id
           AND iosh2.status_change_date = ios1.status_change_date
       )
   AND 1 =
    (SELECT COUNT(*)
     FROM irc_offer_status_history ios3
     WHERE ios3.offer_id = ios1.offer_id
     AND ios3.status_change_date > ios1.status_change_date
    );
--
  cursor csr_prev_offer_status is
         select offer_status
           from irc_offers
          where offer_id = p_offer_id;
--
  cursor csr_offer_count is
         select count(*)
           from irc_offers iof
               ,per_all_vacancies pav
               ,irc_offer_status_history iosh
          where pav.vacancy_id = p_vacancy_id
            and iof.vacancy_id = pav.vacancy_id
            and iosh.offer_id = p_offer_id
            AND NOT EXISTS
                     (SELECT 1
                        FROM irc_offer_status_history iosh1
                       WHERE iosh1.offer_id = iosh.offer_id
                         AND iosh1.status_change_date > iosh.status_change_date
                     )
            AND iosh.offer_status_history_id =
                    (SELECT MAX(iosh2.offer_status_history_id)
                       FROM irc_offer_status_history iosh2
                      WHERE iosh2.offer_id = iosh.offer_id
                        AND iosh2.status_change_date = iosh.status_change_date
                    )
            and iof.latest_offer = 'Y'
            and ( iof.offer_status = 'EXTENDED'  or ( iof.offer_status = 'CLOSED' and   iosh.change_reason = 'APL_ACCEPTED'));
--
  l_vacancy_opening_count    csr_vacancy_opening_count%ROWTYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
--
  if p_offer_status = 'CLOSED'
  then
    --
    open csr_prev_offer_status;
    fetch csr_prev_offer_status into l_prev_offer_status;
    if csr_prev_offer_status%notfound
    then
      --
      close csr_prev_offer_status;
      fnd_message.set_name('PER','IRC_412322_INVALID_OFFER_ID');
      fnd_message.raise_error;
      --
    end if;
    close csr_prev_offer_status;
    --
    if l_prev_offer_status = 'HOLD'
    then
      --
      -- We now know that a closed offer has been taken off hold.
      -- Check if the offer was closed because it was accepted.
      --
      open csr_prev_to_prev_offer_chg_rsn;
      fetch csr_prev_to_prev_offer_chg_rsn into l_prev_to_prev_offer_status
                                               ,l_prev_to_prev_change_reason;
      if csr_prev_to_prev_offer_chg_rsn%notfound
      then
        --
        close csr_prev_to_prev_offer_chg_rsn;
        fnd_message.set_name('PER','IRC_412305_INV_PREVTOPREV_OFR');
        fnd_message.raise_error;
        --
      end if;
      close csr_prev_to_prev_offer_chg_rsn;
      --
      if (   l_prev_to_prev_offer_status = 'CLOSED' -- just a double check
         AND l_prev_to_prev_change_reason = 'APL_ACCEPTED'
         )
      then
        --
        -- We now know that an Accepted offer, on hold has been taken off hold.
        -- Hence, check for vacancy count
        --
        l_chk_vacancy_count := true;
        --
      end if;
      --
    end if;
    --
  elsif p_offer_status = 'EXTENDED'
  then
    --
    l_chk_vacancy_count := true;
    --
  end if;
  --
  if l_chk_vacancy_count = true
  then
    --
    if hr_multi_message.no_exclusive_error(
      p_check_column1      => 'IRC_OFFERS.APPLICANT_ASSIGNMENT_ID'
     ,p_check_column2      => 'IRC_OFFERS.OFFER_ASSIGNMENT_ID'
     ,p_check_column3      => 'IRC_OFFERS.VACANCY_ID'
      )
    then
      --
      hr_api.mandatory_arg_error
      (p_api_name         => l_proc
      ,p_argument         => 'VACANCY_ID'
      ,p_argument_value   => p_vacancy_id
      );
      --
      open csr_vacancy_opening_count;
      fetch csr_vacancy_opening_count into l_vacancy_opening_count;
      close csr_vacancy_opening_count;
      --
      hr_utility.set_location(l_proc,20);
      --
      if (l_vacancy_opening_count.budget_measurement_type <> 'FTE')
      then
        --
        open csr_offer_count;
        fetch csr_offer_count into l_offer_count;
        close csr_offer_count;
        --
        if (l_offer_count >= l_vacancy_opening_count.budget_measurement_value)
        then
          fnd_message.set_name('PER','IRC_412331_OFR_EXCDD_VAC_COUNT');
          fnd_message.raise_error;
        end if;
        --
      end if;
      --
    end if; -- no_exclusive_error
    --
  end if; -- if l_chk_vacancy_count check
  hr_utility.set_location(' Leaving:'||l_proc,30);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'IRC_OFFERS.VACANCY_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 50);
End chk_offers_exceeds_openings;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_respondent_id >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that the respondent is an existing user.
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   p_respondent_id
--   p_offer_id
--   p_object_version_number
--
-- Post Success:
--   Processing continues if the respondent exists
--
-- Post Failure:
--   An application error is raised if Respondent is not an existing user
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_respondent_id
  (p_respondent_id in irc_offers.respondent_id%TYPE
  ,p_offer_id in irc_offers.offer_id%TYPE
  ,p_object_version_number in irc_offers.object_version_number%TYPE
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_respondent_id';
  l_api_updating     boolean;
  l_respondent_id    number;
--
  cursor csr_respondent_id is
         select 1
           from fnd_user
          where user_id = p_respondent_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
--
  if hr_multi_message.no_exclusive_error(
    p_check_column1      => 'IRC_OFFERS.APPLICANT_ASSIGNMENT_ID'
   ,p_check_column2      => 'IRC_OFFERS.OFFER_ASSIGNMENT_ID'
   ,p_check_column3      => 'IRC_OFFERS.VACANCY_ID'
    ) then
--
-- Only proceed with validation if :
-- a) The current g_old_rec is current and
-- b) The value for respondant_id has changed
--
  l_api_updating := irc_iof_shd.api_updating
                        (p_offer_id => p_offer_id
                        ,p_object_version_number => p_object_version_number);
--
  hr_utility.set_location(l_proc,20);

  if ((l_api_updating
       and nvl(irc_iof_shd.g_old_rec.respondent_id, hr_api.g_number) <>
                                    nvl(p_respondent_id, hr_api.g_number))
      or
      (NOT l_api_updating)) then
    --
    -- Check if respondent id is not null.
    --
    if p_respondent_id is not null then

      hr_utility.set_location(l_proc, 30);

      open csr_respondent_id;
      fetch csr_respondent_id into l_respondent_id;
    --
      hr_utility.set_location(l_proc,40);
      if (csr_respondent_id%notfound)
      then
        close csr_respondent_id;
        fnd_message.set_name('FND','FND_GRANTS_GNT_USER_INVALID');
        fnd_message.raise_error;
      end if;
      close csr_respondent_id;
    --
      hr_utility.set_location(' Leaving:'||l_proc,50);
    --
    end if;
  end if;
  end if; -- no_exclusive_error
--
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'IRC_OFFERS.RESPONDENT_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 60);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 70);
End chk_respondent_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_expiry_date >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that while EXTENDING the offer, if the expirty date
--   is NULL, it is set to the calculated value from the profiles
--   IRC_OFFER_DURATION_MEASUREMENT and IRC_OFFER_DURATION_VALUE.
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   p_expiry_date
--   p_offer_status
--   p_effective_date
--
-- Out Arguments:
--   p_expiry_date
--
-- Post Success:
--   The expiry date is set to a calculated value if null.
--
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_expiry_date
  (p_expiry_date                  in out nocopy irc_offers.expiry_date%TYPE
  ,p_offer_status                 in irc_offers.offer_status%TYPE
  ,p_offer_id                     in irc_offers.offer_id%TYPE
  ,p_offer_postal_service         in irc_offers.offer_postal_service%TYPE
  ,p_offer_letter_tracking_code   in irc_offers.offer_letter_tracking_code%TYPE
  ,p_offer_shipping_date          in irc_offers.offer_shipping_date%TYPE
  ,p_effective_date               date
  ) IS
--
  l_proc                       varchar2(72) := g_package || 'chk_expiry_date';
  l_offer_duration_value       varchar2(30);
  l_offer_duration_measurement varchar2(30);
  l_expiry_date                irc_offers.expiry_date%TYPE                 := p_expiry_date;
  l_prev_expiry_date           irc_offers.expiry_date%TYPE                 := irc_iof_shd.g_old_rec.expiry_date;
  l_prev_offer_postal_service  irc_offers.offer_postal_service%TYPE        := irc_iof_shd.g_old_rec.offer_postal_service;
  l_prev_letter_tracking_code  irc_offers.offer_letter_tracking_code%TYPE  := irc_iof_shd.g_old_rec.offer_letter_tracking_code;
  l_prev_offer_shipping_date   irc_offers.offer_shipping_date%TYPE         := irc_iof_shd.g_old_rec.offer_shipping_date;
  l_effective_date             date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
--
  if hr_multi_message.no_exclusive_error(
    p_check_column1      => 'IRC_OFFERS.APPLICANT_ASSIGNMENT_ID'
   ,p_check_column2      => 'IRC_OFFERS.OFFER_ASSIGNMENT_ID'
   ,p_check_column3      => 'IRC_OFFERS.VACANCY_ID'
    ) then
--
  if   p_offer_status = 'EXTENDED'
  then
    --
    hr_utility.set_location(l_proc, 20);
    --
    if      p_expiry_date is not null
    then
      --
      -- Set the effective date
      --
      if p_expiry_date < p_effective_date
      then
        --
        fnd_message.set_name('PER','IRC_412352_INV_EXP_DATE');
        fnd_message.raise_error;
        --
      end if;
    --
    else -- p_expiry_date is null or is the previous expiry date
      --
      -- Check if the intend of this update is to indeed update the expiry date.
      --
      if(   nvl(p_offer_postal_service,hr_api.g_varchar2) = nvl(l_prev_offer_postal_service,hr_api.g_varchar2) -- Postal Service has not changed
        and nvl(p_offer_letter_tracking_code,hr_api.g_varchar2) = nvl(l_prev_letter_tracking_code,hr_api.g_varchar2) -- Tracking Code has not changed
        and nvl(p_offer_shipping_date,hr_api.g_date) = nvl(l_prev_offer_shipping_date,hr_api.g_date) -- Shipping Date has not changed
        )
      then
        --
        -- No value has been entered for the expiry date.
        -- Set the expiry date to the calculated value.
        --
        l_offer_duration_value := to_number(fnd_profile.value('IRC_OFFER_DURATION_VALUE'));
        l_offer_duration_measurement := fnd_profile.value('IRC_OFFER_DURATION_MEASUREMENT');
        --
        if   l_offer_duration_value is not null
        then
          --
          hr_utility.set_location(l_proc, 30);
          --
          -- Set the effective date
          --
          if l_prev_expiry_date > p_effective_date
          then
            --
            l_effective_date := l_prev_expiry_date;
            --
          else
            --
            l_effective_date := p_effective_date;
            --
          end if;
          --
          if l_offer_duration_measurement = 'MONTH'
          then
            --
            hr_utility.set_location(l_proc, 60);
            --
            l_expiry_date := add_months(l_effective_date,l_offer_duration_value);
            --
          elsif l_offer_duration_measurement = 'WEEK'
          then
            --
            hr_utility.set_location(l_proc, 50);
            --
            l_expiry_date := l_effective_date + (l_offer_duration_value * 7);
            --
          else -- By default l_offer_duration_measurement = 'DAY'
            --
            hr_utility.set_location(l_proc, 40);
            --
            l_expiry_date := l_effective_date + l_offer_duration_value;
            --
          end if;
        --
        else -- l_offer_duration_value is null
          --
          -- Both, the entered value and the profile value are null. Throw an error
          --
          fnd_message.set_name('PER','IRC_412353_NULL_EXPIRY_DATE');
          fnd_message.raise_error;
          --
        end if;
      --
      end if;
    --
    end if;
  --
  end if; -- p_offer_status = 'EXTENDED'
  --
  end if; -- no_exclusive_error
  --
  -- Set the in out variable
  --
  p_expiry_date := l_expiry_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc,70);
--
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'IRC_OFFERS.EXPIRY_DATE'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 80);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 90);
End chk_expiry_date;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< set_address_id >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure defaults the address to the Recruiting address Id if it is
--   available for the primary person and if not address_id is passed in
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   p_address_id
--   p_applicant_assignment_id
--   p_effective_date
--
-- Out Arguments:
--   p_address_id
--
-- Post Success:
--   If a Recruiting address exists for the person, that address is set in the offer
--   record
--
-- Post Failure:
--   If the person does not have a recruiting address, the value remains null
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure set_address_id
  (p_address_id              in out nocopy irc_offers.address_id%TYPE
  ,p_applicant_assignment_id in irc_offers.applicant_assignment_id%TYPE
  ,p_effective_date          date
  ) IS
--
  l_proc     varchar2(72) := g_package || 'set_address_id';
  l_rec_address_id     irc_offers.address_id%TYPE;
--
  cursor csr_rec_address_id is
         select adr.address_id
           from per_addresses adr
               ,per_all_assignments_f asg
          where asg.assignment_id = p_applicant_assignment_id
            and adr.person_id = irc_utilities_pkg.get_recruitment_person_id(asg.person_id,trunc(sysdate))
            and adr.address_type = 'REC'
            and p_effective_date
        between adr.date_from
            and nvl(adr.date_to, trunc(sysdate));
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
--
  if hr_multi_message.no_exclusive_error(
    p_check_column1      => 'IRC_OFFERS.APPLICANT_ASSIGNMENT_ID'
   ,p_check_column2      => 'IRC_OFFERS.OFFER_ASSIGNMENT_ID'
   ,p_check_column3      => 'IRC_OFFERS.VACANCY_ID'
    ) then
--
  hr_utility.set_location(l_proc,20);
  --
  -- Default the address_id only if it is null
  --
  if p_address_id is null then
  --
    open csr_rec_address_id;
    fetch csr_rec_address_id into l_rec_address_id;
    --
    hr_utility.set_location(l_proc,30);
    if (csr_rec_address_id%found)
    then
      --
      -- The person has a recruiting address. Hence, default the address_id
      -- in offer record to this value.
      --
      p_address_id := l_rec_address_id;
      --
    end if;
    close csr_rec_address_id;
    --
    hr_utility.set_location(' Leaving:'||l_proc,40);
  end if;
  end if; -- no_exclusive_error
--
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'IRC_OFFERS.ADDRESS_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 50);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 60);
End set_address_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_address_id >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that the address is a valid address
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   p_address_id
--   p_offer_id
--   p_object_version_number
--
-- Post Success:
--   Processing continues if the address exists
--
-- Post Failure:
--   An application error is raised if address is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_address_id
  (p_address_id in irc_offers.address_id%TYPE
  ,p_offer_id in irc_offers.offer_id%TYPE
  ,p_object_version_number in irc_offers.object_version_number%TYPE
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_address_id';
  l_address_id     number;
  l_api_updating     boolean;
--
  cursor csr_address_id is
         select 1
           from per_addresses
          where address_id = p_address_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
--
  if hr_multi_message.no_exclusive_error(
    p_check_column1      => 'IRC_OFFERS.APPLICANT_ASSIGNMENT_ID'
   ,p_check_column2      => 'IRC_OFFERS.OFFER_ASSIGNMENT_ID'
   ,p_check_column3      => 'IRC_OFFERS.VACANCY_ID'
    ) then
--
-- Only proceed with validation if :
-- a) The current g_old_rec is current and
-- b) The value for address_id has changed
--
  l_api_updating := irc_iof_shd.api_updating
                        (p_offer_id => p_offer_id
                        ,p_object_version_number => p_object_version_number);
--
  hr_utility.set_location(l_proc,20);

  if ((l_api_updating
       and nvl(irc_iof_shd.g_old_rec.address_id, hr_api.g_number) <>
                                    nvl(p_address_id, hr_api.g_number))
      or
      (NOT l_api_updating)) then
    --
    -- Check if address id is not null.
    --
    if p_address_id is not null then
    --
      open csr_address_id;
      fetch csr_address_id into l_address_id;
    --
      hr_utility.set_location(l_proc,30);
      if (csr_address_id%notfound)
      then
        close csr_address_id;
        fnd_message.set_name('PER','IRC_412001_BAD_ADDRESS_ID');
        fnd_message.raise_error;
     end if;
     close csr_address_id;
    --
     hr_utility.set_location(' Leaving:'||l_proc,40);
    end if;
  end if;
  end if; -- no_exclusive_error
--
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'IRC_OFFERS.ADDRESS_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 50);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 60);
End chk_address_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_template_id >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that the offer template is valid
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   p_template_id
--   p_offer_id
--   p_object_version_number
--   p_effective_date
--
-- Post Success:
--   Processing continues if the template exists
--
-- Out Arguments:
--   p_template_id
--
-- Post Failure:
--   An application error is raised if template is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_template_id
  (p_template_id           in out nocopy irc_offers.template_id%TYPE
  ,p_offer_id              in irc_offers.offer_id%TYPE
  ,p_object_version_number in irc_offers.object_version_number%TYPE
  ,p_effective_date date
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_template_id';
  l_template_id     irc_template_associations.template_id%TYPE;
  l_api_updating    boolean;
--
  cursor csr_template_id is
         select 1
           from xdo_templates_b
          where template_id = p_template_id
            and p_effective_date
        between start_date
            and nvl(end_date,p_effective_date);
--
  cursor csr_default_template_job is
         select ita.template_id
           from irc_template_associations ita
               ,per_all_assignments_f ppaf
               ,irc_offers iof
          where ita.default_association = 'Y'
            and iof.offer_id = p_offer_id
            and iof.offer_assignment_id = ppaf.assignment_id
            and ita.job_id = ppaf.job_id;
--
  cursor csr_default_template_pos is
         select ita.template_id
           from irc_template_associations ita
               ,per_all_assignments_f ppaf
               ,irc_offers iof
          where ita.default_association = 'Y'
            and iof.offer_id = p_offer_id
            and iof.offer_assignment_id = ppaf.assignment_id
            and ita.position_id = ppaf.position_id;
--
  cursor csr_default_template_org is
         select ita.template_id
           from irc_template_associations ita
               ,per_all_assignments_f ppaf
               ,irc_offers iof
          where ita.default_association = 'Y'
            and iof.offer_id = p_offer_id
            and iof.offer_assignment_id = ppaf.assignment_id
            and ita.organization_id = ppaf.organization_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
--
  if hr_multi_message.no_exclusive_error(
    p_check_column1      => 'IRC_OFFERS.APPLICANT_ASSIGNMENT_ID'
   ,p_check_column2      => 'IRC_OFFERS.OFFER_ASSIGNMENT_ID'
   ,p_check_column3      => 'IRC_OFFERS.VACANCY_ID'
    ) then
--
-- Only proceed with validation if :
-- a) The current g_old_rec is current and
-- b) The value for template_id has changed
--
  l_api_updating := irc_iof_shd.api_updating
                        (p_offer_id => p_offer_id
                        ,p_object_version_number => p_object_version_number);
--
  hr_utility.set_location(l_proc,20);

  if ((l_api_updating
       and nvl(irc_iof_shd.g_old_rec.template_id, hr_api.g_number) <>
                                    nvl(p_template_id, hr_api.g_number)) or
     (NOT l_api_updating)) then
    --
    -- Check if template id is not null and if it is active
    --
    if p_template_id is not null then
    --
    hr_utility.set_location(l_proc,30);
    --
      open csr_template_id;
      fetch csr_template_id into l_template_id;
    --
      if (csr_template_id%notfound)
      then
        --
        hr_utility.set_location(l_proc,40);
        --
        close csr_template_id;
        fnd_message.set_name('PER','IRC_412326_OFFER_INV_TEMPLT_ID');
        fnd_message.raise_error;
      end if;
      close csr_template_id;
    --
    else
    --
      hr_utility.set_location(l_proc,50);
      --
      open csr_default_template_job;
      fetch csr_default_template_job into l_template_id;
      --
      if (csr_default_template_job%notfound)
      then
        --
        hr_utility.set_location(l_proc,60);
        --
        close csr_default_template_job;
        --
        open csr_default_template_pos;
        fetch csr_default_template_pos into l_template_id;
        --
        if (csr_default_template_pos%notfound)
        then
          --
          hr_utility.set_location(l_proc,70);
          --
          close csr_default_template_pos;
          --
          open csr_default_template_org;
          fetch csr_default_template_org into l_template_id;
          --
          if (csr_default_template_org%notfound)
          then
            --
            hr_utility.set_location(l_proc,80);
            --
            close csr_default_template_org;
            l_template_id := p_template_id;
            --
          end if; --org
        end if; --pos
      end if; --job
    --
    end if; -- if - else - endif;
  end if; -- l_api_updating
  end if; -- no_exclusive_error
  hr_utility.set_location(' Leaving:'||l_proc,90);
--
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'IRC_OFFERS.TEMPLATE_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 100);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 110);
End chk_template_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< gen_offer_version >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure generates then offer_version number
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   p_offer_version
--   p_applicant_assignment_id
--
-- Post Success:
--   A new offer version number is generated.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure gen_offer_version
  (p_offer_version            out nocopy irc_offers.offer_version%TYPE
  ,p_applicant_assignment_id  in  irc_offers.applicant_assignment_id%TYPE
  ) IS
--
  l_proc              varchar2(72) := g_package || 'gen_offer_version';
  l_offer_version     irc_offers.offer_version%TYPE;
--
   cursor csr_get_offer_version is
     select nvl(max(offer_version),0) + 1
     from   irc_offers
     where  applicant_assignment_id = p_applicant_assignment_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
--
  hr_api.mandatory_arg_error
  (p_api_name         => l_proc
  ,p_argument         => 'APPLICANT_ASSIGNMENT_ID'
  ,p_argument_value   => p_applicant_assignment_id
  );
--
  --
  --  Generate next offer version number
  --
  open csr_get_offer_version;
  fetch csr_get_offer_version into l_offer_version;
  close csr_get_offer_version;
  p_offer_version := l_offer_version;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
--
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'IRC_OFFERS.OFFER_VERSION'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);
End gen_offer_version;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_latest_offer >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- The following checks ensure that only one offer is the latest offer for a particular
-- applicant assignment. This check works in the following manner:
--
-- 1) During Insert:
--    If the offer is in SFL status:
--       The latest offer for this record will be 'N', hence not required to perform this
--       validation.
--    Else
--       The offer being insterted should be the latest offer and there should be no
--       other latest offers for this applicant assignment.
--
-- 2) During Update:
--    If the offer is not in SFL status:
--       The offer being updated should be the latest offer and there should be no
--       other latest offers for this applicant assignment.
--
-- 3) The value entered should be validated against HR_LOOKUPS.LOOKUP_CODE
--    where the LOOKUP_TYPE is 'YES_NO'.  (I, U)
--    Process:        hr_api.not_exists_in_hr_lookups
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   p_latest_offer
--   p_offer_id
--   p_offer_status
--   p_applicant_assignment_id
--   p_effective_date
--   p_object_version_number
--
-- Post Success:
--   During insert:
--   Processing continues if no other record for this application assignment id
--   is the latest offer.
--   During update:
--   Processing continues if latest_offer exists
--
-- Post Failure:
--   An application error is raised.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_latest_offer
  (p_latest_offer in irc_offers.latest_offer%TYPE
  ,p_offer_id in irc_offers.offer_id%TYPE
  ,p_offer_status in irc_offers.offer_status%TYPE
  ,p_applicant_assignment_id in irc_offers.applicant_assignment_id%TYPE
  ,p_effective_date         in date
  ,p_object_version_number in irc_offers.object_version_number%TYPE
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_latest_offer';
  l_latest_offer     number;
  l_api_updating     boolean;
--
  cursor csr_latest_offer_upd is
         select 1
           from irc_offers
          where latest_offer = 'Y'
            and applicant_assignment_id = p_applicant_assignment_id
            and offer_id <> p_offer_id;
--
  cursor csr_latest_offer_ins is
         select 1
           from irc_offers
          where latest_offer = 'Y'
            and applicant_assignment_id = p_applicant_assignment_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
--
  if hr_multi_message.no_exclusive_error(
    p_check_column1      => 'IRC_OFFERS.APPLICANT_ASSIGNMENT_ID'
   ,p_check_column2      => 'IRC_OFFERS.OFFER_ASSIGNMENT_ID'
   ,p_check_column3      => 'IRC_OFFERS.VACANCY_ID'
    ) then
--
-- Only proceed with validation if :
-- a) The current g_old_rec is current and
-- b) The value for latest_offer has changed
--
  l_api_updating := irc_iof_shd.api_updating
                        (p_offer_id => p_offer_id
                        ,p_object_version_number => p_object_version_number);
--
  hr_utility.set_location(l_proc,20);
  --
  -- If a newly created offer is in SFL status, there
  -- should not be a validation as the offer_status for this
  -- offer will always be 'N'.
  --
  if (NOT l_api_updating)
  then
      if ( p_offer_status <> 'SAVED')
      then
      --
        open csr_latest_offer_ins;
        fetch csr_latest_offer_ins into l_latest_offer;
      --
        hr_utility.set_location(l_proc,30);
        if (csr_latest_offer_ins%found)
        then
          close csr_latest_offer_ins;
          fnd_message.set_name('PER','IRC_412332_INV_APL_LSTOFR_COMB');
          fnd_message.raise_error;
        end if;
        close csr_latest_offer_ins;
      --
      end if;
   --
   elsif (l_api_updating
          and nvl(irc_iof_shd.g_old_rec.latest_offer, hr_api.g_varchar2) <>
                                    nvl(p_latest_offer, hr_api.g_varchar2))
   then
      if ( p_offer_status <> 'SAVED')
      then
      --
        open csr_latest_offer_upd;
        fetch csr_latest_offer_upd into l_latest_offer;
      --
        hr_utility.set_location(l_proc,30);
        if (csr_latest_offer_upd%found)
        then
          close csr_latest_offer_upd;
          fnd_message.set_name('PER','IRC_412332_INV_APL_LSTOFR_COMB');
          fnd_message.raise_error;
        end if;
        close csr_latest_offer_upd;
      --
      end if;
   --
   end if;
   --
   if ((l_api_updating
          and nvl(irc_iof_shd.g_old_rec.latest_offer, hr_api.g_varchar2) <>
                                    nvl(p_latest_offer, hr_api.g_varchar2))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,40);
    --
    -- Checks that the value for latest_offer is
    -- valid and exists on YES_NO lookup
    --
    if hr_api.not_exists_in_hr_lookups
      (p_effective_date => p_effective_date
      ,p_lookup_type    => 'YES_NO'
      ,p_lookup_code    => p_latest_offer
      ) then
    --
    --  Error: Invalid latest offer value.
    --
    hr_utility.set_location(l_proc,50);
    --
    fnd_message.set_name(800, 'IRC_412307_INV_LATEST_OFR_VAL');
    fnd_message.raise_error;
    end if;
    --
    hr_utility.set_location(' Leaving:'||l_proc,60);
    end if;
  end if; -- no_exclusive_error
--
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'IRC_OFFERS.LATEST_OFFER'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 70);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 80);
End chk_latest_offer;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_offer_version_combination >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the offer version and applicant
--   assignment comination is unique.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_offer_id
--   p_offer_version
--   p_applicant_assignment_id
--   p_object_version_number
--
-- Post Success:
--   Processing continues if the combination is unique.
--
-- Post Failure:
--   An application error is raised if the combination already exists.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_offer_version_combination
  (p_offer_id in irc_offers.offer_id%TYPE
  ,p_offer_version in irc_offers.offer_version%TYPE
  ,p_applicant_assignment_id in irc_offers.applicant_assignment_id%TYPE
  ,p_object_version_number in irc_offers.object_version_number%TYPE
  ) IS
--
  l_proc varchar2(72) := g_package || 'chk_offer_version_combination';
  l_version number;
  l_api_updating boolean;
--
  cursor csr_version  is
    select 1
      from irc_offers
     where offer_version = p_offer_version
       and applicant_assignment_id = p_applicant_assignment_id;
--
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  if hr_multi_message.no_exclusive_error(
    p_check_column1      => 'IRC_OFFERS.APPLICANT_ASSIGNMENT_ID'
   ,p_check_column2      => 'IRC_OFFERS.OFFER_ASSIGNMENT_ID'
   ,p_check_column3      => 'IRC_OFFERS.VACANCY_ID'
    ) then
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for offer version has changed or applicant_assignment_id has changed
  --
  l_api_updating := irc_iof_shd.api_updating
                        (p_offer_id => p_offer_id
                        ,p_object_version_number => p_object_version_number);
  --
  if ((l_api_updating and
       ((nvl(irc_iof_shd.g_old_rec.offer_version, hr_api.g_number) <>
                                    nvl(p_offer_version, hr_api.g_number))
       or
       (nvl(irc_iof_shd.g_old_rec.applicant_assignment_id, hr_api.g_number) <>
                                    nvl(p_applicant_assignment_id, hr_api.g_number))
       ))
       or
      (NOT l_api_updating)) then
  --
    open csr_version;
    fetch csr_version into l_version;
    hr_utility.set_location(l_proc,20);
    if csr_version%found then
      close csr_version;
      fnd_message.set_name(800,'IRC_412308_INV_OFFER_VER_COMB');
      fnd_message.raise_error;
    end if;
    close csr_version;
  end if;
  end if; -- no_exclusive_error
--
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1 => 'IRC_OFFER.OFFER_VERSION'
      ,p_associated_column2 => 'IRC_OFFER.APPLICANT_ASSIGNMENT_ID'
      ) then
      hr_utility.set_location(' Leaving:'||l_proc,30);
      raise;
    end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,40);
End chk_offer_version_combination;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_offer_status >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--   This procedure is used to ensure that Offer Status is a valid value
--   from IRC_OFFER_STATUSES lookup
--
--  Pre-conditions:
--   Effective_date must be valid.
--
--  In Arguments:
--    p_offer_id
--    p_offer_status
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    If the given offer status exists in IRC_OFFER_STATUSES Lookup,
--    processing continues.
--
--  Post Failure:
--    If the given offer status does not exist in IRC_OFFER_STATUSES Lookup,
--    an application error will be raised and processing will be terminated.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_offer_status
  (p_offer_id in irc_offers.offer_id%TYPE
  ,p_offer_status in irc_offers.offer_status%TYPE
  ,p_effective_date         in date
  ,p_object_version_number in irc_offers.object_version_number%TYPE
  )IS
  --
   l_proc           varchar2(72)  :=  g_package||'chk_offer_status';
   l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
--
  if hr_multi_message.no_exclusive_error(
    p_check_column1      => 'IRC_OFFERS.APPLICANT_ASSIGNMENT_ID'
   ,p_check_column2      => 'IRC_OFFERS.OFFER_ASSIGNMENT_ID'
   ,p_check_column3      => 'IRC_OFFERS.VACANCY_ID'
    ) then
--
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value of offer status has changed
  --
  l_api_updating := irc_iof_shd.api_updating
                        (p_offer_id => p_offer_id
                        ,p_object_version_number => p_object_version_number);
  --
  if ((l_api_updating
       and nvl(irc_iof_shd.g_old_rec.offer_status, hr_api.g_varchar2) <>
                                    nvl(p_offer_status, hr_api.g_varchar2))
      or
      (NOT l_api_updating)) then
    --
        hr_utility.set_location(l_proc, 20);
        --
        -- Checks that the value for offer_status is
        -- valid and exists on irc_offer_statuses within
        -- the specified date range
        --
        if hr_api.not_exists_in_hr_lookups
          (p_effective_date => p_effective_date
          ,p_lookup_type    => 'IRC_OFFER_STATUSES'
          ,p_lookup_code    => p_offer_status
          ) then
          --
          hr_utility.set_location(l_proc, 30);
          --  Error: Invalid offer status type.
          fnd_message.set_name('PER', 'IRC_412323_INV_OFFER_STATUS');
          fnd_message.raise_error;
        end if;
  end if;
  --
  -- While creation the offer cannot of any of the following statuses:
  -- 'CLOSED', 'EXTENDED', 'APPROVED', 'HOLD' or 'PENDING_EXTENDED'
  --
  if NOT l_api_updating
  then
     --
     hr_utility.set_location(l_proc, 40);
     if p_offer_status in ('CLOSED', 'EXTENDED', 'HOLD', 'CORRECTION', 'PENDING_EXTENDED')
     then
     --
        hr_utility.set_location(l_proc, 50);
        fnd_message.set_name('PER', 'IRC_412309_INV_CRT_OFR_STATUS');
        fnd_message.raise_error;
     --
     end if;
  end if;
  --
  --
  end if; -- no_exclusive_error
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 60);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'IRC_OFFERS.OFFER_STATUS'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 70);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 80);
end chk_offer_status;
--
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_offer_status_update >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--   This procedure ensures the following:
--   1) If the offer_status is 'CLOSED' do nothing - This is because we have already
--      checked for offer_status 'CLOSED' in update_offer procedure of irc_offers_api.
--
--   2) If the offer is in 'HOLD' state now, and the offer_status was previously 'HOLD'
--      too, throw an error saying that an offer in HOLD status cannot be updated.
--
--   3) If the offer was previously in 'HOLD' status, the current offer_status should
--      be the status in which the offer was before it was Held.
--
--  Pre-conditions:
--   none
--
--  In Arguments:
--    p_current_offer_record
--
--  Post Success:
--    If the above mentioned checks succeed, processing continues.
--
--  Post Failure:
--    Incase any of the cases fail, appropriate errors will be thrown.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_offer_status_update
  ( p_current_offer_record    in irc_iof_shd.g_rec_type
  )IS
  --
  l_proc           varchar2(72)  :=  g_package||'chk_offer_status_update';
  l_prev_offer_status           irc_offers.offer_status%TYPE := irc_iof_shd.g_old_rec.offer_status;
  l_prev_to_prev_offer_status   irc_offers.offer_status%TYPE;
  l_mutiple_fields_updated      boolean;
  --
  cursor csr_prev_to_prev_offer_status is
  select ios1.offer_status
    from irc_offer_status_history ios1
   where ios1.offer_id = p_current_offer_record.offer_id
     and  EXISTS
       (SELECT 1
       FROM irc_offer_status_history iosh1
       WHERE iosh1.offer_id = ios1.offer_id
           AND iosh1.status_change_date > ios1.status_change_date
       )
     AND ios1.offer_status_history_id =
       (SELECT MAX(iosh2.offer_status_history_id)
       FROM irc_offer_status_history iosh2
       WHERE iosh2.offer_id = ios1.offer_id
           AND iosh2.status_change_date = ios1.status_change_date
       )
   AND 1 =
    (SELECT COUNT(*)
     FROM irc_offer_status_history ios3
     WHERE ios3.offer_id = ios1.offer_id
     AND ios3.status_change_date > ios1.status_change_date
    );
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if  p_current_offer_record.offer_status <> 'CLOSED'
      and p_current_offer_record.offer_status <> 'APPROVED'
      and p_current_offer_record.offer_status <> 'CORRECTION'
      and p_current_offer_record.offer_status <> 'EXTENDED'
  then
      --
      hr_utility.set_location(l_proc,20);
      --
      -- Check to see if the offer status is 'Hold'.
      --
      if ( p_current_offer_record.offer_status = 'HOLD'
         ) then
        --
        hr_utility.set_location(l_proc,30);
        --
        -- Check if the offer was previously in 'Hold'
        -- state too. If so, the offer has been updated. Hence,
        -- throw an error saying that the offer cannot be updated.
        --
        if (  l_prev_offer_status = 'HOLD'
           ) then
           --
           hr_utility.set_location(l_proc,40);
           --
           fnd_message.set_name('PER','IRC_412306_CANT_UPD_HELD_OFFER');
           fnd_message.raise_error;
        end if;
        --
        -- Also Check that when in HOLD, no other data can be
        -- changed in the offer record.
        --
        IRC_IOF_BUS.chk_multiple_fields_updated
        (     p_offer_id                     => p_current_offer_record.offer_id
             ,p_offer_status                 => p_current_offer_record.offer_status
             ,p_discretionary_job_title      => p_current_offer_record.discretionary_job_title
             ,p_offer_extended_method        => p_current_offer_record.offer_extended_method
             ,p_expiry_date                  => p_current_offer_record.expiry_date
             ,p_proposed_start_date          => p_current_offer_record.proposed_start_date
             ,p_offer_letter_tracking_code   => p_current_offer_record.offer_letter_tracking_code
             ,p_offer_postal_service         => p_current_offer_record.offer_postal_service
             ,p_offer_shipping_date          => p_current_offer_record.offer_shipping_date
             ,p_applicant_assignment_id      => p_current_offer_record.applicant_assignment_id
             ,p_offer_assignment_id          => p_current_offer_record.offer_assignment_id
             ,p_address_id                   => p_current_offer_record.address_id
             ,p_template_id                  => p_current_offer_record.template_id
             ,p_offer_letter_file_type       => p_current_offer_record.offer_letter_file_type
             ,p_offer_letter_file_name       => p_current_offer_record.offer_letter_file_name
             ,p_attribute_category           => p_current_offer_record.attribute_category
             ,p_attribute1                   => p_current_offer_record.attribute1
             ,p_attribute2                   => p_current_offer_record.attribute2
             ,p_attribute3                   => p_current_offer_record.attribute3
             ,p_attribute4                   => p_current_offer_record.attribute4
             ,p_attribute5                   => p_current_offer_record.attribute5
             ,p_attribute6                   => p_current_offer_record.attribute6
             ,p_attribute7                   => p_current_offer_record.attribute7
             ,p_attribute8                   => p_current_offer_record.attribute8
             ,p_attribute9                   => p_current_offer_record.attribute9
             ,p_attribute10                  => p_current_offer_record.attribute10
             ,p_attribute11                  => p_current_offer_record.attribute11
             ,p_attribute12                  => p_current_offer_record.attribute12
             ,p_attribute13                  => p_current_offer_record.attribute13
             ,p_attribute14                  => p_current_offer_record.attribute14
             ,p_attribute15                  => p_current_offer_record.attribute15
             ,p_attribute16                  => p_current_offer_record.attribute16
             ,p_attribute17                  => p_current_offer_record.attribute17
             ,p_attribute18                  => p_current_offer_record.attribute18
             ,p_attribute19                  => p_current_offer_record.attribute19
             ,p_attribute20                  => p_current_offer_record.attribute20
             ,p_attribute21                  => p_current_offer_record.attribute21
             ,p_attribute22                  => p_current_offer_record.attribute22
             ,p_attribute23                  => p_current_offer_record.attribute23
             ,p_attribute24                  => p_current_offer_record.attribute24
             ,p_attribute25                  => p_current_offer_record.attribute25
             ,p_attribute26                  => p_current_offer_record.attribute26
             ,p_attribute27                  => p_current_offer_record.attribute27
             ,p_attribute28                  => p_current_offer_record.attribute28
             ,p_attribute29                  => p_current_offer_record.attribute29
             ,p_attribute30                  => p_current_offer_record.attribute30
             ,p_mutiple_fields_updated       => l_mutiple_fields_updated
        );
        if ( l_mutiple_fields_updated = true )
        then
           --
           hr_utility.set_location(l_proc,45);
           --
           fnd_message.set_name('PER','IRC_412306_CANT_UPD_HELD_OFFER');
           fnd_message.raise_error;
        end if;
      --
      else
      --
      -- If the offer status is anything else.
      --
      hr_utility.set_location(l_proc,50);
      --
      -- Check if the offer was previously in 'Hold' State.
      -- If so, the current state should be the state which existed
      -- before the offer was Held.
      --
        if (  l_prev_offer_status = 'HOLD'
           ) then
           --
           hr_utility.set_location(l_proc,60);
           --
           open csr_prev_to_prev_offer_status;
           fetch csr_prev_to_prev_offer_status into l_prev_to_prev_offer_status;
           close csr_prev_to_prev_offer_status;
           --
           if ( p_current_offer_record.offer_status <> l_prev_to_prev_offer_status
              ) then
              --
              hr_utility.set_location(l_proc,70);
              --
              fnd_message.set_name('PER','IRC_412305_INV_PREVTOPREV_OFR');
              fnd_message.raise_error;
              --
           end if;
         end if;
      end if; -- if-else-end if
   end if; -- Offer_status = 'CLOSED'
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 80);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'IRC_OFFERS.OFFER_STATUS'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 90);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 100);
end chk_offer_status_update;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_multiple_fields_updated >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that not more than one field has been updated in the
--   offer record.
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   All the IRC_OFFERS table fields except object_version_number and respondent_id.
--
-- Post Success:
--   If only one field has been updated, p_mutiple_fields_updated will be set to
--   'false'. If multiple fields have been updated, p_mutiple_fields_updated will be
--   set to 'true'.
--
-- Post Failure:
--   None
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_multiple_fields_updated
  ( p_offer_id                     in   number
   ,p_offer_status                 in   varchar2  default null
   ,p_discretionary_job_title      in   varchar2  default null
   ,p_offer_extended_method        in   varchar2  default null
   ,p_expiry_date                  in   date      default null
   ,p_proposed_start_date          in   date      default null
   ,p_offer_letter_tracking_code   in   varchar2  default null
   ,p_offer_postal_service         in   varchar2  default null
   ,p_offer_shipping_date          in   date      default null
   ,p_applicant_assignment_id      in   number    default null
   ,p_offer_assignment_id          in   number    default null
   ,p_address_id                   in   number    default null
   ,p_template_id                  in   number    default null
   ,p_offer_letter_file_type       in   varchar2  default null
   ,p_offer_letter_file_name       in   varchar2  default null
   ,p_attribute_category           in   varchar2  default null
   ,p_attribute1                   in   varchar2  default null
   ,p_attribute2                   in   varchar2  default null
   ,p_attribute3                   in   varchar2  default null
   ,p_attribute4                   in   varchar2  default null
   ,p_attribute5                   in   varchar2  default null
   ,p_attribute6                   in   varchar2  default null
   ,p_attribute7                   in   varchar2  default null
   ,p_attribute8                   in   varchar2  default null
   ,p_attribute9                   in   varchar2  default null
   ,p_attribute10                  in   varchar2  default null
   ,p_attribute11                  in   varchar2  default null
   ,p_attribute12                  in   varchar2  default null
   ,p_attribute13                  in   varchar2  default null
   ,p_attribute14                  in   varchar2  default null
   ,p_attribute15                  in   varchar2  default null
   ,p_attribute16                  in   varchar2  default null
   ,p_attribute17                  in   varchar2  default null
   ,p_attribute18                  in   varchar2  default null
   ,p_attribute19                  in   varchar2  default null
   ,p_attribute20                  in   varchar2  default null
   ,p_attribute21                  in   varchar2  default null
   ,p_attribute22                  in   varchar2  default null
   ,p_attribute23                  in   varchar2  default null
   ,p_attribute24                  in   varchar2  default null
   ,p_attribute25                  in   varchar2  default null
   ,p_attribute26                  in   varchar2  default null
   ,p_attribute27                  in   varchar2  default null
   ,p_attribute28                  in   varchar2  default null
   ,p_attribute29                  in   varchar2  default null
   ,p_attribute30                  in   varchar2  default null
   ,p_mutiple_fields_updated       out nocopy boolean
  ) IS
--
  l_proc             varchar2(72)  := g_package || 'chk_multiple_fields_updated';
  l_update_count     number(2)     := 0;
  l_api_updating     boolean;
  --
  Cursor C_Sel1 is
    select
       offer_id
      ,offer_version
      ,latest_offer
      ,offer_status
      ,discretionary_job_title
      ,offer_extended_method
      ,respondent_id
      ,expiry_date
      ,proposed_start_date
      ,offer_letter_tracking_code
      ,offer_postal_service
      ,offer_shipping_date
      ,applicant_assignment_id
      ,offer_assignment_id
      ,address_id
      ,template_id
      ,offer_letter_file_type
      ,offer_letter_file_name
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,attribute21
      ,attribute22
      ,attribute23
      ,attribute24
      ,attribute25
      ,attribute26
      ,attribute27
      ,attribute28
      ,attribute29
      ,attribute30
      ,object_version_number
    from        irc_offers
    where       offer_id = p_offer_id;
    --
    l_offer_old_rec  C_Sel1%ROWTYPE;
Begin
    --
    hr_utility.set_location('Entering:'||l_proc,10);
    --
      Open C_Sel1;
      Fetch C_Sel1 Into l_offer_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
    --
    -- If any field has changed, increment l_update_count.
    --
    if( p_offer_id <> hr_api.g_number) then
    if
    nvl(l_offer_old_rec.offer_id, hr_api.g_number) <>
    nvl(p_offer_id, hr_api.g_number)
    then
    --
    hr_utility.set_location(l_proc,20);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_offer_status <> hr_api.g_varchar2) then
    --
    hr_utility.set_location(l_proc,30);
    --
    if
    nvl(l_offer_old_rec.offer_status, hr_api.g_varchar2) <>
    nvl(p_offer_status, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,50);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_discretionary_job_title <> hr_api.g_varchar2)
      or p_discretionary_job_title is null
    then
    if
    nvl(l_offer_old_rec.discretionary_job_title, hr_api.g_varchar2) <>
    nvl(p_discretionary_job_title, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,60);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_offer_extended_method <> hr_api.g_varchar2)
      or p_offer_extended_method is null
    then
    if
    nvl(l_offer_old_rec.offer_extended_method, hr_api.g_varchar2) <>
    nvl(p_offer_extended_method, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,70);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_expiry_date <> hr_api.g_date)
      or p_expiry_date is null
    then
    if
    nvl(l_offer_old_rec.expiry_date, hr_api.g_date) <>
    nvl(p_expiry_date, hr_api.g_date)
    then
    --
    hr_utility.set_location(l_proc,90);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_proposed_start_date <> hr_api.g_date)
      or p_proposed_start_date is null
    then
    if
    nvl(l_offer_old_rec.proposed_start_date, hr_api.g_date) <>
    nvl(p_proposed_start_date, hr_api.g_date)
    then
    --
    hr_utility.set_location(l_proc,100);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;
    --
    if(p_offer_letter_tracking_code <> hr_api.g_varchar2)
      or p_offer_letter_tracking_code is null
    then
    if
    nvl(l_offer_old_rec.offer_letter_tracking_code, hr_api.g_varchar2) <>
    nvl(p_offer_letter_tracking_code, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,110);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_offer_postal_service <> hr_api.g_varchar2)
      or p_offer_postal_service is null
    then
    if
    nvl(l_offer_old_rec.offer_postal_service, hr_api.g_varchar2) <>
    nvl(p_offer_postal_service, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,120);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_offer_shipping_date <> hr_api.g_date)
      or p_offer_shipping_date is null
    then
    if
    nvl(l_offer_old_rec.offer_shipping_date, hr_api.g_date) <>
    nvl(p_offer_shipping_date, hr_api.g_date)
    then
    --
    hr_utility.set_location(l_proc,130);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;
    --

    if(p_applicant_assignment_id <> hr_api.g_number) then
    if
    nvl(l_offer_old_rec.applicant_assignment_id, hr_api.g_number) <>
    nvl(p_applicant_assignment_id, hr_api.g_number)
    then
    --
    hr_utility.set_location(l_proc,150);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_offer_assignment_id <> hr_api.g_number) then
    if
    nvl(l_offer_old_rec.offer_assignment_id, hr_api.g_number) <>
    nvl(p_offer_assignment_id, hr_api.g_number)
    then
    --
    hr_utility.set_location(l_proc,160);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_address_id <> hr_api.g_number)
      or p_address_id is null
    then
    if
    nvl(l_offer_old_rec.address_id, hr_api.g_number) <>
    nvl(p_address_id, hr_api.g_number)
    then
    --
    hr_utility.set_location(l_proc,170);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_template_id <> hr_api.g_number)
      or p_template_id is null
    then
    if
    nvl(l_offer_old_rec.template_id, hr_api.g_number) <>
    nvl(p_template_id, hr_api.g_number)
    then
    --
    hr_utility.set_location(l_proc,180);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_offer_letter_file_type <> hr_api.g_varchar2)
      or p_offer_letter_file_type is null
    then
    if
    nvl(l_offer_old_rec.offer_letter_file_type, hr_api.g_varchar2) <>
    nvl(p_offer_letter_file_type, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,190);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_offer_letter_file_name <> hr_api.g_varchar2)
      or p_offer_letter_file_name is null
    then
    if
    nvl(l_offer_old_rec.offer_letter_file_name, hr_api.g_varchar2) <>
    nvl(p_offer_letter_file_name, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,200);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute_category <> hr_api.g_varchar2)
      or p_attribute_category is null
    then
    if
    nvl(l_offer_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_attribute_category, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,210);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute1 <> hr_api.g_varchar2)
      or p_attribute1 is null
    then
    if
    nvl(l_offer_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_attribute1, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,220);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute2 <> hr_api.g_varchar2)
      or p_attribute2 is null
    then
    if
    nvl(l_offer_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_attribute2, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,230);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute3 <> hr_api.g_varchar2)
      or p_attribute3 is null
    then
    if
    nvl(l_offer_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_attribute3, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,240);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute4 <> hr_api.g_varchar2)
      or p_attribute4 is null
    then
    if
    nvl(l_offer_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_attribute4, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,250);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute5 <> hr_api.g_varchar2)
      or p_attribute5 is null
    then
    if
    nvl(l_offer_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_attribute5, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,260);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute6 <> hr_api.g_varchar2)
      or p_attribute6 is null
    then
    if
    nvl(l_offer_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_attribute6, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,270);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute7 <> hr_api.g_varchar2)
      or p_attribute7 is null
    then
    if
    nvl(l_offer_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_attribute7, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,280);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute8 <> hr_api.g_varchar2)
      or p_attribute8 is null
    then
    if
    nvl(l_offer_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_attribute8, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,290);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute9 <> hr_api.g_varchar2)
      or p_attribute9 is null
    then
    if
    nvl(l_offer_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_attribute9, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,300);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute10 <> hr_api.g_varchar2)
      or p_attribute10 is null
    then
    if
    nvl(l_offer_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_attribute10, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,310);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute11 <> hr_api.g_varchar2)
      or p_attribute11 is null
    then
    if
    nvl(l_offer_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_attribute11, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,320);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute12 <> hr_api.g_varchar2)
      or p_attribute12 is null
    then
    if
    nvl(l_offer_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_attribute12, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,330);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute13 <> hr_api.g_varchar2)
      or p_attribute13 is null
    then
    if
    nvl(l_offer_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_attribute13, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,340);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute14 <> hr_api.g_varchar2)
      or p_attribute14 is null
    then
    if
    nvl(l_offer_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_attribute14, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,350);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute15 <> hr_api.g_varchar2)
      or p_attribute15 is null
    then
    if
    nvl(l_offer_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_attribute15, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,360);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute16 <> hr_api.g_varchar2)
      or p_attribute16 is null
    then
    if
    nvl(l_offer_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_attribute16, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,370);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute17 <> hr_api.g_varchar2)
      or p_attribute17 is null
    then
    if
    nvl(l_offer_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_attribute17, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,380);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute18 <> hr_api.g_varchar2)
      or p_attribute18 is null
    then
    if
    nvl(l_offer_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_attribute18, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,390);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute19 <> hr_api.g_varchar2)
      or p_attribute19 is null
    then
    if
    nvl(l_offer_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_attribute19, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,400);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute20 <> hr_api.g_varchar2)
      or p_attribute20 is null
    then
    if
    nvl(l_offer_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_attribute20, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,410);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute21 <> hr_api.g_varchar2)
      or p_attribute21 is null
    then
    if
    nvl(l_offer_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_attribute21, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,420);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute22 <> hr_api.g_varchar2)
      or p_attribute22 is null
    then
    if
    nvl(l_offer_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_attribute22, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,430);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute23 <> hr_api.g_varchar2)
      or p_attribute23 is null
    then
    if
    nvl(l_offer_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_attribute23, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,440);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute24 <> hr_api.g_varchar2)
      or p_attribute24 is null
    then
    if
    nvl(l_offer_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_attribute24, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,450);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute25 <> hr_api.g_varchar2)
      or p_attribute25 is null
    then
    if
    nvl(l_offer_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_attribute25, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,460);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute26 <> hr_api.g_varchar2)
      or p_attribute26 is null
    then
    if
    nvl(l_offer_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_attribute26, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,470);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute27 <> hr_api.g_varchar2)
      or p_attribute27 is null
    then
    if
    nvl(l_offer_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_attribute27, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,480);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute28 <> hr_api.g_varchar2)
      or p_attribute28 is null
    then
    if
    nvl(l_offer_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_attribute28, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,490);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute29 <> hr_api.g_varchar2)
      or p_attribute29 is null
    then
    if
    nvl(l_offer_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_attribute29, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,500);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;

    if(p_attribute30 <> hr_api.g_varchar2)
      or p_attribute30 is null
    then
    if
    nvl(l_offer_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_attribute30, hr_api.g_varchar2)
    then
    --
    hr_utility.set_location(l_proc,510);
    --
    l_update_count := l_update_count + 1;
    end if;
    end if;
    --
    -- Check if l_update_count > 1, if Yes, set p_mutiple_fields_updated
    -- to True.
    --
    if l_update_count > 1
    then
       --
       hr_utility.set_location(l_proc,520);
       --
       p_mutiple_fields_updated := true;
    else
       --
       hr_utility.set_location(l_proc,530);
       --
       p_mutiple_fields_updated := false;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,540);
--
exception
  when others then
  hr_utility.set_location(' Leaving:'||l_proc,550);
  raise;
End chk_multiple_fields_updated;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_offer_extended_method >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--   This procedure is used to ensure that offer extended method is a valid
--   value from IRC_OFFER_EXTENDED_METHOD lookup
--
--  Pre-conditions:
--   Effective_date must be valid.
--
--  In Arguments:
--    p_offer_id
--    p_offer_extended_method
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    If the given offer extended method exists in IRC_OFFER_EXTENDED_METHOD
--    Lookup, processing continues.
--
--  Post Failure:
--    If the offer extended method does not exist in IRC_OFFER_EXTENDED_METHOD
--    Lookup, an application error will be raised and processing will be terminated.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_offer_extended_method
  (p_offer_id in irc_offers.offer_id%TYPE
  ,p_offer_extended_method in irc_offers.offer_extended_method%TYPE
  ,p_effective_date in date
  ,p_object_version_number in irc_offers.object_version_number%TYPE
  )IS
  --
   l_proc           varchar2(72)  :=  g_package||'chk_offer_extended_method';
   l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if hr_multi_message.no_exclusive_error(
    p_check_column1      => 'IRC_OFFERS.APPLICANT_ASSIGNMENT_ID'
   ,p_check_column2      => 'IRC_OFFERS.OFFER_ASSIGNMENT_ID'
   ,p_check_column3      => 'IRC_OFFERS.VACANCY_ID'
    ) then
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for offer extended method has changed
  --
  l_api_updating := irc_iof_shd.api_updating
                        (p_offer_id => p_offer_id
                        ,p_object_version_number => p_object_version_number);
  --
  if ((l_api_updating
       and nvl(irc_iof_shd.g_old_rec.offer_extended_method, hr_api.g_varchar2) <>
                                    nvl(p_offer_extended_method, hr_api.g_varchar2))
      or
      (NOT l_api_updating)) then
    --
    -- Check if offer_extended_method is not null.
    --
    if p_offer_extended_method is not null then
    --
        hr_utility.set_location(l_proc, 20);
        --
        -- Checks that the value for offer_extended_method is
        -- valid and exists on irc_offer_extended_method lookup
        -- within the specified date range
        --
        if hr_api.not_exists_in_hr_lookups
          (p_effective_date => p_effective_date
          ,p_lookup_type    => 'IRC_OFFER_EXTENDED_METHOD'
          ,p_lookup_code    => p_offer_extended_method
          ) then
          --
          --  Error: Invalid offer extended method.
          fnd_message.set_name(800, 'IRC_412310_INV_OFR_EXTNDD_MTHD');
          fnd_message.raise_error;
        end if;
    end if;
  end if;
  end if; -- no_exclusive_error
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 30);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'IRC_OFFERS.OFFER_EXTENDED_METHOD'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_offer_extended_method;
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_offer_postal_service >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--   This procedure is used to ensure that offer postal service is a valid
--   value from IRC_OFFER_POSTAL_SERVICE lookup
--
--  Pre-conditions:
--   Effective_date must be valid.
--
--  In Arguments:
--    p_offer_id
--    p_offer_postal_service
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    If the given offer postal service exists in IRC_OFFER_POSTAL_SERVICE
--    Lookup, processing continues.
--
--  Post Failure:
--    If the offer extended method does not exist in IRC_OFFER_POSTAL_SERVICE
--    Lookup, an application error will be raised and processing will be terminated.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_offer_postal_service
  (p_offer_id in irc_offers.offer_id%TYPE
  ,p_offer_postal_service in irc_offers.offer_postal_service%TYPE
  ,p_effective_date in date
  ,p_object_version_number in irc_offers.object_version_number%TYPE
  )IS
  --
   l_proc           varchar2(72)  :=  g_package||'chk_offer_postal_service';
   l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if hr_multi_message.no_exclusive_error(
    p_check_column1      => 'IRC_OFFERS.APPLICANT_ASSIGNMENT_ID'
   ,p_check_column2      => 'IRC_OFFERS.OFFER_ASSIGNMENT_ID'
   ,p_check_column3      => 'IRC_OFFERS.VACANCY_ID'
    ) then
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for offer postal service has changed
  --
  l_api_updating := irc_iof_shd.api_updating
                        (p_offer_id => p_offer_id
                        ,p_object_version_number => p_object_version_number);
  --
  if ((l_api_updating
       and nvl(irc_iof_shd.g_old_rec.offer_postal_service, hr_api.g_varchar2) <>
                                    nvl(p_offer_postal_service, hr_api.g_varchar2))
      or
      (NOT l_api_updating)) then
      --
      -- Check if offer_postal_service is not null.
      --
      if p_offer_postal_service is not null then
      --
        hr_utility.set_location(l_proc, 20);
        --
        -- Checks that the value for offer_postal_service is
        -- valid and exists on IRC_OFFER_POSTAL_SERVICE lookup
        -- within the specified date range
        --
        if hr_api.not_exists_in_hr_lookups
          (p_effective_date => p_effective_date
          ,p_lookup_type    => 'IRC_OFFER_POSTAL_SERVICE'
          ,p_lookup_code    => p_offer_postal_service
          ) then
          --
          --  Error: Invalid offer extended method.
          fnd_message.set_name(800, 'IRC_412311_INV_OFR_POSTAL_SERV');
          fnd_message.raise_error;
        end if;
      end if;
  end if;
  end if; -- no_exclusive_error
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 30);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'IRC_OFFERS.OFFER_POSTAL_SERVICE'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_offer_postal_service;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_offer_letter >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--   This procedure checks if, when the offer is moved to APPROVED status,
--   an offer letter has been uploaded.
--
--  Pre-conditions:
--   The offer status should be changed to APPROVED.
--
--  In Arguments:
--    p_offer_id
--    p_offer_status
--
--  Post Success:
--    If the given offer letter file type exists in XDO_OUTPUT_TYPE Lookup,
--    processing continues.
--
--  Post Failure:
--    If the offer letter file type does not exist in XDO_OUTPUT_TYPE Lookup,
--    an application error will be raised and processing will be terminated.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_offer_letter
  (p_offer_id     in irc_offers.offer_id%TYPE
  ,p_offer_status in irc_offers.offer_status%TYPE
  )IS
  --
   l_proc           varchar2(72)  :=  g_package||'chk_offer_letter';
   l_offer_letter   irc_offers.offer_letter%TYPE;
  --
   cursor csr_offer_letter is
   select offer_letter
     from irc_offers
    where offer_id = p_offer_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if hr_multi_message.no_exclusive_error(
    p_check_column1      => 'IRC_OFFERS.APPLICANT_ASSIGNMENT_ID'
   ,p_check_column2      => 'IRC_OFFERS.OFFER_ASSIGNMENT_ID'
   ,p_check_column3      => 'IRC_OFFERS.VACANCY_ID'
    ) then
  --
  if    p_offer_status = 'APPROVED'
    and nvl(irc_iof_shd.g_old_rec.offer_status, hr_api.g_varchar2) <>
                                    nvl(p_offer_status, hr_api.g_varchar2)
  then
     --
     hr_utility.set_location(l_proc, 20);
     --
     open csr_offer_letter;
     fetch csr_offer_letter into l_offer_letter;
     if csr_offer_letter%notfound
     then
        --
        hr_utility.set_location(l_proc, 30);
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
        --
     end if;
     --
     -- Check if the offer letter is present. If blob length is 0, it means that
     -- the blob is not uploaded.
     --
     if dbms_lob.getlength(l_offer_letter) = 0
     then
        --
        hr_utility.set_location(l_proc, 40);
        --
        fnd_message.set_name('PER','IRC_412312_UPLOAD_OFFER_LETTER');
        hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
        --
     end if;
     --
  end if;
  end if; -- no_exclusive_error
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 50);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'IRC_OFFERS.OFFER_LETTER'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 60);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_offer_letter;
--
--
--  ---------------------------------------------------------------------------
--  |--------------------< chk_offer_letter_file_type >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--   This procedure is used to ensure that offer letter file type is a valid
--   value from XDO_OUTPUT_TYPE lookup
--
--  Pre-conditions:
--   Effective_date must be valid.
--
--  In Arguments:
--    p_offer_id
--    p_offer_letter_file_type
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    If the given offer letter file type exists in XDO_OUTPUT_TYPE Lookup,
--    processing continues.
--
--  Post Failure:
--    If the offer letter file type does not exist in XDO_OUTPUT_TYPE Lookup,
--    an application error will be raised and processing will be terminated.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_offer_letter_file_type
  (p_offer_id in irc_offers.offer_id%TYPE
  ,p_offer_letter_file_type in irc_offers.offer_letter_file_type%TYPE
  ,p_effective_date in date
  ,p_object_version_number in irc_offers.object_version_number%TYPE
  )IS
  --
   l_proc           varchar2(72)  :=  g_package||'chk_offer_letter_file_type';
   l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if hr_multi_message.no_exclusive_error(
    p_check_column1      => 'IRC_OFFERS.APPLICANT_ASSIGNMENT_ID'
   ,p_check_column2      => 'IRC_OFFERS.OFFER_ASSIGNMENT_ID'
   ,p_check_column3      => 'IRC_OFFERS.VACANCY_ID'
    ) then
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for offer postal service has changed
  --
  l_api_updating := irc_iof_shd.api_updating
                        (p_offer_id => p_offer_id
                        ,p_object_version_number => p_object_version_number);
  --
  if ((l_api_updating
       and nvl(irc_iof_shd.g_old_rec.offer_letter_file_type, hr_api.g_varchar2) <>
                                    nvl(p_offer_letter_file_type, hr_api.g_varchar2))
      or
      (NOT l_api_updating)) then
      --
      -- Check if offer_postal_service is not null.
      --
      if p_offer_letter_file_type is not null then
      --
        hr_utility.set_location(l_proc, 20);
        --
        -- Checks that the value for offer_postal_service is
        -- valid and exists on IRC_OFFER_POSTAL_SERVICE lookup
        -- within the specified date range
        --
        if hr_api.not_exists_in_fnd_lookups
          (p_effective_date => p_effective_date
          ,p_lookup_type    => 'XDO_OUTPUT_TYPE'
          ,p_lookup_code    => p_offer_letter_file_type
          ) then

          fnd_message.set_name(800, 'IRC_412312_UPLOAD_OFFER_LETTER');
          fnd_message.raise_error;
        end if;
      end if;
  end if;
  end if; -- no_exclusive_error
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 30);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'IRC_OFFERS.OFFER_LETTER_FILE_TYPE'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_offer_letter_file_type;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in out nocopy irc_iof_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(l_proc, 20);
  --
  chk_applicant_assignment_id
  (p_effective_date          => p_effective_date
  ,p_applicant_assignment_id => p_rec.applicant_assignment_id
  );
  --
  hr_utility.set_location(l_proc, 30);
  --
  chk_offer_assignment_id
  (p_offer_assignment_id     => p_rec.offer_assignment_id
  );
  --
  hr_utility.set_location(l_proc, 40);
  --
  set_vacancy_id
  (p_vacancy_id              => p_rec.vacancy_id
  ,p_applicant_assignment_id => p_rec.applicant_assignment_id
  ,p_effective_date          => p_effective_date
  );
  --
  hr_utility.set_location(l_proc, 50);
  --
  chk_offers_exceeds_openings
  (p_vacancy_id              => p_rec.vacancy_id
  ,p_offer_status            => p_rec.offer_status
  ,p_offer_id                => p_rec.offer_id
  );
  --
  hr_utility.set_location(l_proc, 60);
  --
  chk_respondent_id
  (p_respondent_id           => p_rec.respondent_id
  ,p_offer_id                => p_rec.offer_id
  ,p_object_version_number   => p_rec.object_version_number
  );
  --
  hr_utility.set_location(l_proc, 70);
  --
  set_address_id
  (p_address_id              => p_rec.address_id
  ,p_applicant_assignment_id => p_rec.applicant_assignment_id
  ,p_effective_date          => p_effective_date
  );
  --
  hr_utility.set_location(l_proc, 75);
  --
  chk_address_id
  (p_address_id              => p_rec.address_id
  ,p_offer_id                => p_rec.offer_id
  ,p_object_version_number   => p_rec.object_version_number
  );
  --
  hr_utility.set_location(l_proc, 80);
  --
  chk_template_id
  (p_template_id             => p_rec.template_id
  ,p_offer_id                => p_rec.offer_id
  ,p_object_version_number   => p_rec.object_version_number
  ,p_effective_date          => p_effective_date
  );
  --
  hr_utility.set_location(l_proc, 90);
  --
  gen_offer_version
  (p_offer_version           => p_rec.offer_version
  ,p_applicant_assignment_id => p_rec.applicant_assignment_id
  );
  --
  hr_utility.set_location(l_proc, 100);
  --
  chk_latest_offer
  (p_latest_offer            => p_rec.latest_offer
  ,p_offer_id                => p_rec.offer_id
  ,p_offer_status            => p_rec.offer_status
  ,p_applicant_assignment_id => p_rec.applicant_assignment_id
  ,p_effective_date          => p_effective_date
  ,p_object_version_number   => p_rec.object_version_number
  );
  --
  hr_utility.set_location(l_proc, 110);
  --
  chk_offer_version_combination
  (p_offer_id                => p_rec.offer_id
  ,p_offer_version           => p_rec.offer_version
  ,p_applicant_assignment_id => p_rec.applicant_assignment_id
  ,p_object_version_number   => p_rec.object_version_number
  );
  --
  hr_utility.set_location(l_proc, 120);
  --
  chk_offer_status
  (p_offer_id                => p_rec.offer_id
  ,p_offer_status            => p_rec.offer_status
  ,p_effective_date          => p_effective_date
  ,p_object_version_number   => p_rec.object_version_number
  );
  --
  hr_utility.set_location(l_proc, 130);
  --
  chk_offer_extended_method
  (p_offer_id                => p_rec.offer_id
  ,p_offer_extended_method   => p_rec.offer_extended_method
  ,p_effective_date          => p_effective_date
  ,p_object_version_number   => p_rec.object_version_number
  );
  --
  hr_utility.set_location(l_proc, 140);
  --
  chk_offer_postal_service
  (p_offer_id                => p_rec.offer_id
  ,p_offer_postal_service    => p_rec.offer_postal_service
  ,p_effective_date          => p_effective_date
  ,p_object_version_number   => p_rec.object_version_number
  );
  --
  hr_utility.set_location(l_proc, 150);
  --
  chk_offer_letter_file_type
  (p_offer_id                => p_rec.offer_id
  ,p_offer_letter_file_type  => p_rec.offer_letter_file_type
  ,p_effective_date          => p_effective_date
  ,p_object_version_number   => p_rec.object_version_number
  );
  --
  hr_utility.set_location(l_proc, 170);
  --
  irc_iof_bus.chk_df(p_rec);
  --
  hr_utility.set_location(l_proc, 180);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 180);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in out nocopy irc_iof_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(l_proc, 20);
  --
  chk_non_updateable_args
  (p_effective_date          => p_effective_date
  ,p_rec                     => p_rec
  );
  --
  hr_utility.set_location(l_proc, 30);
  --
  chk_offers_exceeds_openings
  (p_vacancy_id              => p_rec.vacancy_id
  ,p_offer_status            => p_rec.offer_status
  ,p_offer_id                => p_rec.offer_id
  );
  --
  hr_utility.set_location(l_proc, 35);
  --
  chk_respondent_id
  (p_respondent_id           => p_rec.respondent_id
  ,p_offer_id                => p_rec.offer_id
  ,p_object_version_number   => p_rec.object_version_number
  );
  --
  hr_utility.set_location(l_proc, 40);
  --
  chk_expiry_date
  (p_expiry_date                 => p_rec.expiry_date
  ,p_offer_status                => p_rec.offer_status
  ,p_offer_id                    => p_rec.offer_id
  ,p_offer_postal_service        => p_rec.offer_postal_service
  ,p_offer_letter_tracking_code  => p_rec.offer_letter_tracking_code
  ,p_offer_shipping_date         => p_rec.offer_shipping_date
  ,p_effective_date              => p_effective_date
  );
  --
  hr_utility.set_location(l_proc, 45);
  --
  chk_address_id
  (p_address_id              => p_rec.address_id
  ,p_offer_id                => p_rec.offer_id
  ,p_object_version_number   => p_rec.object_version_number
  );
  --
  hr_utility.set_location(l_proc, 50);
  --
  chk_template_id
  (p_template_id             => p_rec.template_id
  ,p_offer_id                => p_rec.offer_id
  ,p_object_version_number   => p_rec.object_version_number
  ,p_effective_date          => p_effective_date
  );
  --
  hr_utility.set_location(l_proc, 60);
  --
  chk_latest_offer
  (p_latest_offer            => p_rec.latest_offer
  ,p_offer_id                => p_rec.offer_id
  ,p_offer_status            => p_rec.offer_status
  ,p_applicant_assignment_id => p_rec.applicant_assignment_id
  ,p_effective_date          => p_effective_date
  ,p_object_version_number   => p_rec.object_version_number
  );
  --
  hr_utility.set_location(l_proc, 70);
  --
  chk_offer_status
  (p_offer_id                => p_rec.offer_id
  ,p_offer_status            => p_rec.offer_status
  ,p_effective_date          => p_effective_date
  ,p_object_version_number   => p_rec.object_version_number
  );
  --
  hr_utility.set_location(l_proc, 80);
  --
  chk_offer_status_update
  (p_current_offer_record   => p_rec
  );
  --
  hr_utility.set_location(l_proc, 90);
  --
  chk_offer_extended_method
  (p_offer_id                => p_rec.offer_id
  ,p_offer_extended_method   => p_rec.offer_extended_method
  ,p_effective_date          => p_effective_date
  ,p_object_version_number   => p_rec.object_version_number
  );
  --
  hr_utility.set_location(l_proc, 100);
  --
  chk_offer_postal_service
  (p_offer_id                => p_rec.offer_id
  ,p_offer_postal_service    => p_rec.offer_postal_service
  ,p_effective_date          => p_effective_date
  ,p_object_version_number   => p_rec.object_version_number
  );
  --
  hr_utility.set_location(l_proc, 110);
  --
  chk_offer_letter
  (p_offer_id                => p_rec.offer_id
  ,p_offer_status            => p_rec.offer_status
  );
  --
  hr_utility.set_location(l_proc, 120);
  --
  chk_offer_letter_file_type
  (p_offer_id                => p_rec.offer_id
  ,p_offer_letter_file_type  => p_rec.offer_letter_file_type
  ,p_effective_date          => p_effective_date
  ,p_object_version_number   => p_rec.object_version_number
  );
  --
  hr_utility.set_location(l_proc, 130);
  --
  irc_iof_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 140);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in irc_iof_shd.g_rec_type
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
end irc_iof_bus;

/
