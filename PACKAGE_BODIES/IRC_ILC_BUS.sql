--------------------------------------------------------
--  DDL for Package Body IRC_ILC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_ILC_BUS" as
/* $Header: irilcrhi.pkb 120.0.12010000.1 2010/03/17 14:09:28 vmummidi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_ilc_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_link_id  number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_link_id           in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- IRC_LINKED_CANDIDATES and PER_BUSINESS_GROUPS_PERF
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , IRC_LINKED_CANDIDATES ilc
      --   , EDIT_HERE table_name(s) 333
     where ilc.link_id = p_link_id;
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
    ,p_argument           => 'LINK_ID'
    ,p_argument_value     => p_link_id
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
        => nvl(p_associated_column1,'LINK_ID')
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
  (p_link_id           in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- IRC_LINKED_CANDIDATES and PER_BUSINESS_GROUPS_PERF
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , IRC_LINKED_CANDIDATES ilc
      --   , EDIT_HERE table_name(s) 333
     where ilc.link_id = p_link_id;
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
    ,p_argument           => 'LINK_ID'
    ,p_argument_value     => p_link_id
    );
  --
  if ( nvl(irc_ilc_bus.g_link_id, hr_api.g_number)
       = p_link_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := irc_ilc_bus.g_legislation_code;
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
    irc_ilc_bus.g_link_id  := p_link_id;
    irc_ilc_bus.g_legislation_code  := l_legislation_code;
  end if;
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
  ,p_rec in irc_ilc_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT irc_ilc_shd.api_updating
      (p_link_id        => p_rec.link_id
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
  if p_rec.party_id <> irc_ilc_shd.g_old_rec.party_id
  then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'PARTY_ID'
     ,p_base_table => irc_ilc_shd.g_tab_nam
     );
  end if;
  --
  if p_rec.duplicate_set_id <> irc_ilc_shd.g_old_rec.duplicate_set_id
  then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'DUPLICATE_SET_ID'
     ,p_base_table => irc_ilc_shd.g_tab_nam
     );
  end if;
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_party_id >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that party_id exists in PER_ALL_PEOPLE_F
--
-- Pre Conditions:
--
-- In Arguments:
--  p_party_id
--
-- Post Success:
--  Processing continues if p_party_id is valid.
--
-- Post Failure:
--   An application error is raised if p_party_id is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_party_id
  (p_party_id in irc_linked_candidates.party_id%TYPE
  ,p_effective_date in Date
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_party_id';
  l_party_id varchar2(1);
--
  cursor csr_party_id is
    select null
    from per_all_people_f ppf
    where ppf.party_id = p_party_id
    and trunc(p_effective_date) between ppf.effective_start_date
    and ppf.effective_end_date;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
-- Check that Party_ID(Object_id) exists in per_all_people_f
  open csr_party_id;
  fetch csr_party_id into l_party_id;
  hr_utility.set_location(l_proc,20);
  if csr_party_id%NOTFOUND then
    close csr_party_id;
    fnd_message.set_name('PER','IRC_412008_BAD_PARTY_PERSON_ID');
    fnd_message.raise_error;
  end if;
  close csr_party_id;
  hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
       'IRC_LINKED_CANDIDATES.PARTY_ID'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,40);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,50);
end chk_party_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_status >-------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_status
  (p_status           in   irc_linked_candidates.status%TYPE
  ,p_effective_date   in   date
  ) is
--
  l_proc        varchar2(72)  := g_package||'chk_status';
  l_not_exists  boolean;
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_status is not null then
    l_not_exists := hr_api.not_exists_in_hr_lookups
                    (p_effective_date
                    ,'IRC_CAND_LINK_STATUS'
                    ,p_status
                    );
    hr_utility.set_location(l_proc, 10);
      if (l_not_exists = true) then
        -- RAISE ERROR SAYING THAT THE STATUS IS INVALID
        fnd_message.set_name('PER','IRC_412628_INV_LINK_STATUS');
        fnd_message.raise_error;
      end if;
  end if;
  hr_utility.set_location('leaving:'||l_proc, 15);
end chk_status;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_cand_link >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_cand_link
  (p_party_id          in irc_linked_candidates.party_id%TYPE
  ,p_duplicate_set_id  in irc_linked_candidates.duplicate_set_id%TYPE
  ) is
--
  l_proc        varchar2(72)  := g_package||'chk_cand_link';
  l_cand_linked varchar2(1);
--
  cursor csr_cand_link is
    select null
    from irc_linked_candidates ilc
    where ilc.party_id = p_party_id
      and ilc.duplicate_set_id <> p_duplicate_set_id
      and ilc.status in ('CONFIRMED','POTENTIAL');
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  open csr_cand_link;
  fetch csr_cand_link into l_cand_linked;
  --
  hr_utility.set_location(l_proc,20);
  if csr_cand_link%FOUND then
    close csr_cand_link;
    fnd_message.set_name('PER','IRC_412629_ALREADY_LINKED');
    fnd_message.raise_error;
  end if;
  close csr_cand_link;
  hr_utility.set_location(' Leaving:'||l_proc,30);
  --
exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
       'IRC_LINKED_CANDIDATES.PARTY_ID'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,40);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,50);
--
end chk_cand_link;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_duplcate_set >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_duplcate_set
  (p_party_id          in irc_linked_candidates.party_id%TYPE
  ,p_duplicate_set_id  in irc_linked_candidates.duplicate_set_id%TYPE
  ) is
--
  l_proc        varchar2(72)  := g_package||'chk_duplcate_set';
  l_dup_set     varchar2(1);
--
  cursor csr_duplcate_set is
    select null
    from irc_linked_candidates ilc
    where ilc.party_id = p_party_id
      and ilc.duplicate_set_id = p_duplicate_set_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  open csr_duplcate_set;
  fetch csr_duplcate_set into l_dup_set;
  --
  hr_utility.set_location(l_proc,20);
  if csr_duplcate_set%FOUND then
    close csr_duplcate_set;
    fnd_message.set_name('PER','IRC_412630_PTY_MARKED_AS_DUP');
    fnd_message.raise_error;
  end if;
  close csr_duplcate_set;
  hr_utility.set_location(' Leaving:'||l_proc,30);
  --
exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
       'IRC_LINKED_CANDIDATES.PARTY_ID'
       ,p_associated_column2 =>
       'IRC_LINKED_CANDIDATES.DUPLICATE_SET_ID'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,40);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,50);
--
end chk_duplcate_set;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in irc_ilc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
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
  chk_party_id
  (p_party_id => p_rec.party_id
  ,p_effective_date   => p_effective_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  --
  if p_rec.target_party_id is not null then
  --
    chk_party_id
    (p_party_id => p_rec.target_party_id
    ,p_effective_date   => p_effective_date);
  --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
  --
  chk_status(p_status => p_rec.status
  ,p_effective_date   => p_effective_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
  if p_rec.status in ('CONFIRMED','POTENTIAL') then
  --
    chk_cand_link(p_party_id => p_rec.party_id
    ,p_duplicate_set_id   => p_rec.duplicate_set_id);
  --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
  --
  chk_duplcate_set(p_party_id => p_rec.party_id
  ,p_duplicate_set_id   => p_rec.duplicate_set_id
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 60);
  --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in irc_ilc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
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
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  --
  chk_party_id
  (p_party_id => p_rec.party_id
  ,p_effective_date   => p_effective_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
  --
  if p_rec.target_party_id is not null then
  --
    chk_party_id
    (p_party_id => p_rec.target_party_id
    ,p_effective_date   => p_effective_date);
  --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
  chk_status(p_status => p_rec.status
  ,p_effective_date   => p_effective_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
  --
  if p_rec.status in ('CONFIRMED','POTENTIAL') then
  --
    chk_cand_link(p_party_id => p_rec.party_id
    ,p_duplicate_set_id   => p_rec.duplicate_set_id);
  --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 60);
  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in irc_ilc_shd.g_rec_type
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
end irc_ilc_bus;

/
