--------------------------------------------------------
--  DDL for Package Body IRC_IRT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IRT_BUS" as
/* $Header: irirtrhi.pkb 120.0 2005/07/26 15:10 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_irt_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_recruiting_site_id          number         default null;
g_language                    varchar2(4)    default null;
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
  (p_rec in irc_irt_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT irc_irt_shd.api_updating
      (p_recruiting_site_id                => p_rec.recruiting_site_id
      ,p_language                          => p_rec.language
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
-- |---------------------------< chk_source_lang >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_source_lang
  (p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ) is
  --
  cursor csr_language is
    select l.installed_flag
      from fnd_languages l
     where l.language_code = p_source_lang;
  --
  l_proc                         varchar2(72) := g_package || 'chk_source_lang';
  l_installed_flag               varchar2(30);
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --

  if ((irc_irt_shd.g_old_rec.recruiting_site_id is null and p_language is not null)
  or (irc_irt_shd.g_old_rec.recruiting_site_id is not null
  and nvl(irc_irt_shd.g_old_rec.language, hr_api.g_varchar2)
                         <> nvl(p_language, hr_api.g_varchar2))) then
    --
    hr_utility.set_location(l_proc,30);
    --
    -- Check value has been passed
    --
    hr_api.mandatory_arg_error
      (p_api_name                     => l_proc
      ,p_argument                     => 'source_lang'
      ,p_argument_value               => p_source_lang
      );
    --
    hr_utility.set_location(l_proc,40);
    --
    -- Check source language exists and is base or installed language
    --
    open csr_language;
    fetch csr_language into l_installed_flag;
    if csr_language%notfound then
      close csr_language;
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    end if;
    close csr_language;
    --
    if nvl(l_installed_flag,hr_api.g_varchar2) not in ('I','B') then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','20');
      fnd_message.raise_error;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_source_lang;
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_site_name>-----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures a valid Site name is entered
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_site_name
--   p_language
-- Post Success:
--   Processing continues if site name is not null and unique
--
-- Post Failure:
--   An application error is raised if site name is null or exists already
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_site_name
  (p_site_name     in irc_all_recruiting_sites_tl.site_name%TYPE
  ,p_language in irc_all_recruiting_sites_tl.language%TYPE
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_site_name';
  l_name     varchar2(1);
  cursor csr_name is
         select null
           from irc_all_recruiting_sites_tl
          where site_name     = p_site_name
            and language = p_language;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
  if (p_site_name is null)
  then
    fnd_message.set_name('PER','IRC_412104_RSE_NAME_NULL');
    fnd_message.raise_error;
  end if;
  hr_utility.set_location('Entering:'||l_proc,20);
  if ((irc_irt_shd.g_old_rec.recruiting_site_id is
                   null)
    or (irc_irt_shd.g_old_rec.recruiting_site_id is not null
    and irc_irt_shd.g_old_rec.site_name <> p_site_name)) then
    open csr_name;
    fetch csr_name into l_name;
    hr_utility.set_location('Entering:'||l_proc,30);
    if (csr_name%found)
    then
      close csr_name;
      fnd_message.set_name('PER','IRC_412105_RSE_NAME_EXIST');
      fnd_message.raise_error;
    end if;
    close csr_name;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,35);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 => 'irc_all_recruiting_sites_tl.site_name'
    )then
      hr_utility.set_location(' Leaving:'||l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,50);
End chk_site_name;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_redirection_url >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that REDIRECTION_URL is null if THIRD_PARTY = 'Y'
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_redirection_url
--  p_recruiting_site_id
--
-- Post Success:
--   Processing continues if redirection_url is valid.
--
-- Post Failure:
--   An application error is raised if redirection_url is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_redirection_url
  (p_redirection_url       in varchar2
  ,p_recruiting_site_id    in irc_all_recruiting_sites_tl.recruiting_site_id%TYPE
  ) IS
--
  l_proc         varchar2(72) := g_package || 'chk_redirection_url';
  --
  l_third_party     irc_all_recruiting_sites.third_party%TYPE;
  cursor csr_third_party
      is select third_party
           from irc_all_recruiting_sites
          where recruiting_site_id = p_recruiting_site_id;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Continue  if updating and either the third party or redirection_url fields
  -- have been updated, or if inserting.
  --
  hr_utility.set_location(l_proc,20);
  --
   if ((irc_irt_shd.g_old_rec.recruiting_site_id is
                   null)
    or (irc_irt_shd.g_old_rec.recruiting_site_id is not null
    and nvl(irc_irt_shd.g_old_rec.redirection_url,hr_api.g_varchar2)
        <> nvl(p_redirection_url,hr_api.g_varchar2)))
    then
      hr_utility.set_location(l_proc,25);
      open csr_third_party;
      fetch csr_third_party into l_third_party;
      close csr_third_party;
    --
    if (l_third_party = 'Y'
        and p_redirection_url is not null)  then
      hr_utility.set_location(l_proc,60);
      fnd_message.set_name('PER','IRC_412096_BAD_TP_REDIR_URL');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
       'IRC_ALL_RECRUITING_SITES_TL.REDIRECTION_URL'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,80);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,90);
end chk_redirection_url;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_posting_url >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that POSTING_URL is null if THIRD_PARTY = 'N'
--   and not null if THIRD_PARTY = 'Y'
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_posting_url
--  p_recruiting_site_id
--
-- Post Success:
--   Processing continues if redirection_url is valid.
--
-- Post Failure:
--   An application error is raised if redirection_url is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_posting_url
  (p_posting_url       in varchar2
  ,p_recruiting_site_id    in irc_all_recruiting_sites_tl.recruiting_site_id%TYPE
  ) IS
--
  l_proc         varchar2(72) := g_package || 'chk_posting_url';
  --
  l_third_party     irc_all_recruiting_sites.third_party%TYPE;
  cursor csr_third_party
      is select third_party
           from irc_all_recruiting_sites
          where recruiting_site_id = p_recruiting_site_id;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Continue  if updating and either the third party or redirection_url fields
  -- have been updated, or if inserting.
  --
  hr_utility.set_location(l_proc,20);
  --
 if ((irc_irt_shd.g_old_rec.recruiting_site_id is
                   null)
    or (irc_irt_shd.g_old_rec.recruiting_site_id is not null
    and nvl(irc_irt_shd.g_old_rec.posting_url,hr_api.g_varchar2)
    <> nvl(p_posting_url,hr_api.g_varchar2)))
    then
      hr_utility.set_location(l_proc,25);
      open csr_third_party;
      fetch csr_third_party into l_third_party;
      close csr_third_party;
      --
      if (  ( l_third_party = 'N'
          and p_posting_url is not null)
       or ( l_third_party = 'Y'
          and p_posting_url is null)
       )
      then
        hr_utility.set_location(l_proc,60);
        fnd_message.set_name('PER','IRC_412097_BAD_TP_POSTING_URL');
        fnd_message.raise_error;
      end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
       'IRC_ALL_RECRUITING_SITES_TL.POSTING_URL'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,80);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,90);
end chk_posting_url;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in irc_irt_shd.g_rec_type
  ,p_recruiting_site_id in irc_all_recruiting_sites_tl.RECRUITING_SITE_ID%type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  irc_irt_bus.chk_source_lang
               (
                p_language => p_rec.language
               ,p_source_lang => p_rec.source_lang
               );
  hr_utility.set_location(l_proc, 10);
  irc_irt_bus.chk_site_name(
                p_site_name => p_rec.site_name
               ,p_language => p_rec.language
               );
  hr_utility.set_location(l_proc, 20);
  irc_irt_bus.chk_redirection_url
               (
                p_redirection_url => p_rec.redirection_url
               ,p_recruiting_site_id => p_recruiting_site_id
               );
  hr_utility.set_location(l_proc, 30);
  irc_irt_bus.chk_posting_url
               (
                p_posting_url => p_rec.posting_url
               ,p_recruiting_site_id => p_recruiting_site_id
               );
  hr_utility.set_location(l_proc, 40);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in irc_irt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  irc_irt_bus.chk_source_lang
               (
                p_language => p_rec.language
               ,p_source_lang => p_rec.source_lang
               );
  hr_utility.set_location(l_proc, 10);
  irc_irt_bus.chk_site_name(
                p_site_name => p_rec.site_name
               ,p_language => p_rec.language
               );
  hr_utility.set_location(l_proc, 20);
  irc_irt_bus.chk_redirection_url
               (
                p_redirection_url => p_rec.redirection_url
               ,p_recruiting_site_id => p_rec.recruiting_site_id
               );
  hr_utility.set_location(l_proc, 30);
  irc_irt_bus.chk_posting_url
               (
                p_posting_url => p_rec.posting_url
               ,p_recruiting_site_id => p_rec.recruiting_site_id
               );
  hr_utility.set_location(l_proc, 40);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in irc_irt_shd.g_rec_type
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
end irc_irt_bus;

/
