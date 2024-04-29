--------------------------------------------------------
--  DDL for Package Body IRC_ISS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_ISS_BUS" as
/* $Header: irissrhi.pkb 120.0.12000000.1 2007/03/23 11:28:28 vboggava noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_iss_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_saved_search_criteria_id    number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--

--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--

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
  (p_rec in irc_iss_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT irc_iss_shd.api_updating
      (p_saved_search_criteria_id          => p_rec.saved_search_criteria_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  if p_rec.saved_search_criteria_id <> irc_iss_shd.g_old_rec.saved_search_criteria_id
      then
      hr_api.argument_changed_error
        (p_api_name   => l_proc
        ,p_argument   => 'SAVED_SEARCH_CRITERIA_ID'
        ,p_base_table => irc_iss_shd.g_tab_nam
        );
    end if;
--
End chk_non_updateable_args;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_vacancy_id >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Verifies that the vacancy_id exists in PER_ALL_VACANCIES_F.
--
-- Prerequisites:
--   Must be called as the first step in insert_validate.
--
-- In Arguments:
--   p_vacancy_id
--
-- Post Success:
--   If vacancy_id exists in PER_ALL_VACANCIES_F, then continue.
--
-- Post Failure:
--   If the p_vacancy_id does not exists in PER_ALL_VACANCIES_F, then throw
--   an error indicating the same.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
procedure chk_vacancy_id
  (p_vacancy_id             in  number
  ,p_saved_search_criteria_id   in
                    irc_saved_search_criteria.saved_search_criteria_id%TYPE
  ,p_object_version_number  in
                    irc_saved_search_criteria.object_version_number%TYPE
  )
IS
--
  l_proc              varchar2(72)  :=  g_package||'chk_vacancy_id';
  l_api_updating      boolean;
  l_dummy             varchar2(1);
  --
  cursor vacancy_exists(p_vacancy_id number) is
    select null
    from per_all_vacancies
    where vacancy_id = p_vacancy_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_api_updating := irc_iss_shd.api_updating
  (p_saved_search_criteria_id => p_saved_search_criteria_id
  ,p_object_version_number  => p_object_version_number
  );
  --
  if ((l_api_updating and
       nvl(irc_iss_shd.g_old_rec.vacancy_id, hr_api.g_number) <>
          nvl(p_vacancy_id, hr_api.g_number)) or
      (NOT l_api_updating)) then
    hr_utility.set_location(l_proc, 20);
    --
    -- Check if p_vacancy_id is not null
    --
    if p_vacancy_id IS NOT NULL then
      --
      -- p_vacancy_id must exist in PER_ALL_VACANCIES_F
      --
      open vacancy_exists(p_vacancy_id);
      fetch vacancy_exists into l_dummy;
      --
      if vacancy_exists%notfound then
        close vacancy_exists;
        hr_utility.set_location(l_proc, 30);
        fnd_message.set_name('PER', 'HR_52591_CEL_INVL_VAC_ID  ');
        fnd_message.raise_error;
      else
        close vacancy_exists;
      end if;
      --
    end if;
  end if;
  hr_utility.set_location('Leaving: '||l_proc, 50);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
        (p_associated_column1      => 'IRC_SAVED_SEARCH_CRITERIA.VACANCY_ID'
        ) then
        raise;
      end if;
end chk_vacancy_id;
--
-- ----------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in irc_iss_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate Dependent Attributes
  -- This procedure check for given vacancy id is valid or not


  If (p_rec.vacancy_id is not null) then
	  chk_vacancy_id
	  (p_vacancy_id			=> p_rec.vacancy_id
	  ,p_saved_search_criteria_id	=> p_rec.saved_search_criteria_id
	  ,p_object_version_number	=> p_rec.object_version_number
	  );
  End if;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in irc_iss_shd.g_rec_type
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
    (p_rec              => p_rec
    );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in irc_iss_shd.g_rec_type
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
end irc_iss_bus;

/
