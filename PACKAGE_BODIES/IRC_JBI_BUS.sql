--------------------------------------------------------
--  DDL for Package Body IRC_JBI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_JBI_BUS" as
/* $Header: irjbirhi.pkb 120.0 2005/07/26 15:13:16 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_jbi_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_party_id                    number         default null;
g_recruitment_activity_id     number         default null;
g_job_basket_item_id          number         default null;
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
--   p_person_id
--   p_party_id
--   p_effective_date
--
-- Post Success:
--   Processing continues if the mandatory parameters have been set and the
--   specified person id exists.
--
-- Post Failure:
--   An application error is raised if the person id does not exist.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_person_id
  (p_person_id      in irc_job_basket_items.person_id%type
  ,p_party_id       in out nocopy irc_job_basket_items.party_id%type
  ,p_effective_date in date
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_person_id';
  l_party_id irc_job_basket_items.party_id%type;
  l_var varchar2(30);
--
--
--   Cursor to check that the person_id exists in PER_ALL_PEOPLE_F.
--
cursor csr_person_id is
  select party_id
      from per_all_people_f
  where person_id = p_person_id
    and p_effective_date between effective_start_date
    and effective_end_date;
--
Begin
--
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
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
  hr_utility.set_location(' Leaving:'||l_proc,70);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'IRC_JOB_BASKET_ITEMS.PARTY_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 80);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 90);
--
End chk_person_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_recruitment_activity_id >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_recruitment_activity_id(p_recruitment_activity_id in number) is
-- Cursor to check recruitment_activity_id exists in PER_RECRUITMENT_ACTIVITIES
cursor csr_recruitment_activity_id(p_recruitment_activity_id number) is
select 1
from per_recruitment_activities
where recruitment_activity_id = p_recruitment_activity_id;
l_proc varchar2(72) := g_package||'chk_recruitment_activity_id';
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  open csr_recruitment_activity_id(p_recruitment_activity_id);
  if csr_recruitment_activity_id%notfound then
    close csr_recruitment_activity_id;
    hr_utility.set_message(800,'IRC_412044_JBI_INV_REC_ACT_ID');
    hr_utility.raise_error;
  end if;
  close csr_recruitment_activity_id;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 20);
end;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_unique_item >----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_unique_item(p_job_basket_item_id    in    number) is
-- Cursor to check composite primary key is unique
cursor csr_unique_prim_key(p_job_basket_item_id number) is
select 1
from irc_job_basket_items
where
     job_basket_item_id = p_job_basket_item_id;

l_proc varchar2(72) := g_package||'chk_unique_item';
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  open csr_unique_prim_key(p_job_basket_item_id);
  if csr_unique_prim_key%found then
    close csr_unique_prim_key;
    hr_utility.set_message(800,'IRC_412043_JBI_INV_COMP_PK');
    hr_utility.raise_error;
  end if;
  close csr_unique_prim_key;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 20);
end;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_job_basket_item_id              in number
  ,p_recruitment_activity_id         in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg,
           per_recruitment_activities pra
     where
           pra.recruitment_activity_id = p_recruitment_activity_id
       and pra.business_group_id       = pbg.business_group_id;
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
    ,p_argument           => 'JOB_BASKET_ITEM_ID'
    ,p_argument_value     => p_job_basket_item_id
    );
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'recruitment_activity_id'
    ,p_argument_value     => p_recruitment_activity_id
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
     fnd_message.raise_error;
     --
  end if;
  close csr_sec_grp;
  --
  -- Set the security_group_id in CLIENT_INFO
  --
  hr_api.set_security_group_id
    (p_security_group_id => l_security_group_id
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
  (p_job_basket_item_id   in     number
  ) Return Varchar2 Is
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
    ,p_argument           => 'JOB_BASKET_ITEM_ID'
    ,p_argument_value     => p_job_basket_item_id
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
  ,p_rec in irc_jbi_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT irc_jbi_shd.api_updating
      (p_job_basket_item_id              => p_rec.job_basket_item_id
      ,p_object_version_number           => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in out nocopy irc_jbi_shd.g_rec_type
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
  chk_recruitment_activity_id(p_rec.recruitment_activity_id);
  --
  --
  chk_unique_item(p_rec.job_basket_item_id);
  --
  -- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in irc_jbi_shd.g_rec_type
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
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in irc_jbi_shd.g_rec_type
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
end irc_jbi_bus;

/
