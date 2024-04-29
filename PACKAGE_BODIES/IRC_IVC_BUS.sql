--------------------------------------------------------
--  DDL for Package Body IRC_IVC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IVC_BUS" as
/* $Header: irivcrhi.pkb 120.0 2005/07/26 15:12:26 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_ivc_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_party_id                    number         default null;
g_vacancy_id                  number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_vacancy_consideration_id                           in number
  ,p_associated_column1                   in varchar2 default null
  ) is

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
    ,p_argument           => 'vacancy_consideration_id'
    ,p_argument_value     => p_vacancy_consideration_id
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
  (p_vacancy_consideration_id                           in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
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
    ,p_argument           => 'vacancy_consideration_id'
    ,p_argument_value     => p_vacancy_consideration_id
    );
  --

  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
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
  ,p_rec in irc_ivc_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT irc_ivc_shd.api_updating
      (p_vacancy_consideration_id             => p_rec.vacancy_consideration_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- Checks to ensure non-updateable args have
  --            not been updated.
  if p_rec.vacancy_consideration_id <> irc_ivc_shd.g_old_rec.vacancy_consideration_id
    then
    hr_api.argument_changed_error
      (p_api_name   => l_proc
      ,p_argument   => 'VACANCY_CONSIDERATION_ID'
      ,p_base_table => irc_ivc_shd.g_tab_nam
      );
  end if;
  --
  if p_rec.vacancy_id <> irc_ivc_shd.g_old_rec.vacancy_id
    then
    hr_api.argument_changed_error
      (p_api_name   => l_proc
      ,p_argument   => 'VACANCY_ID'
      ,p_base_table => irc_ivc_shd.g_tab_nam
      );
  end if;
  --
  if p_rec.person_id <> irc_ivc_shd.g_old_rec.person_id
    then
     hr_api.argument_changed_error
      (p_api_name   => l_proc
      ,p_argument   => 'PERSON_ID'
      ,p_base_table => irc_ivc_shd.g_tab_nam
      );
  end if;
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_vacancy_id >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that mandatory parameters have been set.
--   If the vacancy id is not found in per_all_vacancies an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_vacancy_id
--   p_consideration_status
--   p_effective_date
--
-- Post Success:
--   Processing continues if the mandatory parameters have been set and the
--   specified vacancy id exists.
--
-- Post Failure:
--   An application error is raised if the vacancy id does not exist.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_vacancy_id
  (p_vacancy_id in irc_vacancy_considerations.vacancy_id%type
  ,p_consideration_status in irc_vacancy_considerations.consideration_status%type
  ,p_effective_date date
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_vacancy_id';
  l_date_from per_all_vacancies.date_from%type;
  l_date_to per_all_vacancies.date_to%type;
--
--
--   Cursor to check if the vacancy is future-dated or past-dated
--   and display the appropriate error messages
--
cursor csr_vacancy_dates is
  select date_from
        ,date_to
    from per_all_vacancies
   where vacancy_id = p_vacancy_id;
--
--
Begin
--
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'vacancy_id'
    ,p_argument_value     => p_vacancy_id
    );
  --
  -- Check if the vacancy is future-dated or past-dated.
  -- and display the appropriate error messages.
  --
  open csr_vacancy_dates;
  fetch csr_vacancy_dates into l_date_from,l_date_to;
  hr_utility.set_location(l_proc, 30);
  if csr_vacancy_dates%notfound then
    close csr_vacancy_dates;
    fnd_message.set_name('PER','IRC_412032_RTM_INV_VACANCY_ID');
    fnd_message.raise_error;
  --
  elsif (p_effective_date > l_date_to) then
    hr_utility.set_location(l_proc, 35);
    close csr_vacancy_dates;
    fnd_message.set_name('PER','IRC_412132_CLOSED_VACANCY_ID');
    fnd_message.raise_error;
  --
  elsif (l_date_from > p_effective_date and p_consideration_status = 'PURSUE')
  then
    hr_utility.set_location(l_proc, 37);
    close csr_vacancy_dates;
    fnd_message.set_name('PER','IRC_FUTURE_VACANCY_ID');
    fnd_message.raise_error;
  --
  end if;
  close csr_vacancy_dates;
  --
  hr_utility.set_location(' Leaving:'||l_proc,40);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'IRC_VACANCY_CONSIDERATIONS.VACANCY_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 50);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 60);
--
End chk_vacancy_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_person_id >-----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that mandatory parameters have been set.
--   If the person id is not found in per_all_people_f an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_party_id
--
-- Post Success:
--   Processing continues if the mandatory parameters have been set and the
--   specified party id exists.
--
-- Post Failure:
--   An application error is raised if the party id does not exist.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_person_id
  (p_person_id in irc_vacancy_considerations.person_id%type
  ,p_party_id in out nocopy irc_vacancy_considerations.party_id%type
  ,p_effective_date date
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_person_id';
  l_party_id irc_notification_preferences.party_id%type;
  l_var varchar2(30);
--
--
--   Cursor to check that the person_id exists in PER_ALL_PEOPLE_F.
--
cursor csr_person_id is
  select party_id
      from per_all_people_f
  where person_id = p_person_id;
--
--   Cursor to check that the Person can be contacted ie., to check
--   if the ALLOW_ACCESS = 'Y' in irc_notification_preferences
--
cursor csr_not_pref is
  select null
      from IRC_NOTIFICATION_PREFERENCES
  where person_id = p_person_id
  and allow_access = 'Y';
Begin
--
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  -- Check if the person_id exists in PER_ALL_PEOPLE_F.
  --
  open csr_person_id;
  fetch csr_person_id into l_party_id;
  hr_utility.set_location(l_proc, 30);
  if csr_person_id%notfound then
    close csr_person_id;
    fnd_message.set_name('PER','IRC_412157_PARTY_PERS_MISMTCH');
    fnd_message.raise_error;
  end if;
  close csr_person_id;
  if p_party_id is not null then
    if p_party_id<>l_party_id then
      fnd_message.set_name('PER','IRC_412033_RTM_INV_PARTY_ID');
      fnd_message.raise_error;
    end if;
  else
    p_party_id:=l_party_id;
  end if;
  --
  -- Check if the person can be contacted
  --
  open csr_not_pref;
  fetch csr_not_pref into l_var;
  hr_utility.set_location(l_proc, 40);
  if csr_not_pref%notfound then
    close csr_not_pref;
    fnd_message.set_name('PER','IRC_412047_IVC_NO_ALLOW_ACCESS');
    fnd_message.raise_error;
  end if;
  close csr_not_pref;
  --
  hr_utility.set_location(' Leaving:'||l_proc,70);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'IRC_VACANCY_CONSIDERATIONS.PARTY_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 80);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 90);
--
End chk_person_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_consideration_status >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure a valid 'Consideration Status' value.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_consideration_status
--  p_party_id
--  p_vacancy_id
--  p_object_version_number
--  p_effective_date
--
-- Post Success:
--   Processing continues if a valid 'Consideration Status' value is entered.
--
-- Post Failure:
--   An application error is raised if a valid 'Consideration Status' value
--   is not entered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_consideration_status
  (p_consideration_status  in irc_vacancy_considerations.
    consideration_status%type
  ,p_vacancy_consideration_id in irc_vacancy_considerations.vacancy_consideration_id%type
  ,p_object_version_number in irc_vacancy_considerations.
    object_version_number%type
  ,p_effective_date in date
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_consideration_status';
  l_var      boolean;
  l_api_updating boolean;
--
Begin
--
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  l_api_updating := irc_ivc_shd.api_updating(p_vacancy_consideration_id
    ,p_object_version_number);
  --
  --  Check to see if the consideration_status value has changed
  --
  hr_utility.set_location(l_proc, 20);
  if ((l_api_updating
    and (irc_ivc_shd.g_old_rec.consideration_status <>
          p_consideration_status))
    or (NOT l_api_updating)) then
    --
    -- Check that a valid 'Consideration Status' value is entered.
    --
    l_var := hr_api.not_exists_in_hr_lookups
             (p_effective_date
             ,'IRC_CONSIDERATION'
             ,p_consideration_status
             );
    hr_utility.set_location(l_proc, 30);
    if (l_var = true) then
      fnd_message.set_name('PER','IRC_412048_IVC_INV_CONS_STATUS');
      fnd_message.raise_error;
    end if;
    --
    -- Check that the updated consideration status value is 'Pursue' if the
    -- old value was 'Pursue'
    --
    hr_utility.set_location(l_proc, 40);
    if(l_api_updating and irc_ivc_shd.g_old_rec.consideration_status = 'PURSUE'
      and (p_consideration_status <> 'PURSUE')) then
        fnd_message.set_name('PER','IRC_412049_IVC_INV_UPD_CONS_ST');
        fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,50);
  --
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1 =>
              irc_ivc_shd.g_tab_nam||'.CONSIDERATION_STATUS'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 80);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 90);
--
End chk_consideration_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in out nocopy irc_ivc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(l_proc, 10);
  chk_person_id
  (p_person_id =>p_rec.person_id
  ,p_party_id => p_rec.party_id
  ,p_effective_date=>p_effective_date
  );
  --
  hr_utility.set_location(l_proc, 20);
  chk_vacancy_id
  (p_vacancy_id => p_rec.vacancy_id
  ,p_consideration_status => p_rec.consideration_status
  ,p_effective_date => p_effective_date
  );
  --
  hr_utility.set_location(l_proc, 40);
  chk_consideration_status
  (p_consideration_status => p_rec.consideration_status
  ,p_effective_date => p_effective_date
  ,p_vacancy_consideration_id => p_rec.vacancy_consideration_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 60);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in irc_ivc_shd.g_rec_type
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
  hr_utility.set_location(l_proc, 10);
  --
  chk_consideration_status
  (p_consideration_status => p_rec.consideration_status
  ,p_effective_date => p_effective_date
  ,p_vacancy_consideration_id => p_rec.vacancy_consideration_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  --
  hr_utility.set_location(l_proc, 30);
  chk_non_updateable_args
    (p_effective_date   => p_effective_date
    ,p_rec              => p_rec
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in irc_ivc_shd.g_rec_type
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
end irc_ivc_bus;

/
