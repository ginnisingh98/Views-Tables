--------------------------------------------------------
--  DDL for Package Body IRC_IPT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IPT_BUS" as
/* $Header: iriptrhi.pkb 120.0 2005/07/26 15:10:09 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_ipt_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_posting_content_id          number         default null;
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
  (p_rec in irc_ipt_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT irc_ipt_shd.api_updating
      (p_posting_content_id                   => p_rec.posting_content_id
      ,p_language                             => p_rec.language
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
-- |-----------------------< chk_name>------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures a valid name is entered
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_name
--   p_language
-- Post Success:
--   Processing continues if name is not null and unique
--
-- Post Failure:
--   An application error is raised if name is null or exists already
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_name
  (p_name     in irc_posting_contents_tl.name%TYPE
  ,p_language in irc_posting_contents_tl.language%TYPE
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_name';
  l_name     varchar2(1);
  cursor csr_name is
         select null
           from irc_posting_contents_tl
          where name     = p_name
            and language = p_language;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
  if (p_name is null)
  then
    fnd_message.set_name('PER','IRC_412029_IPT_NAME_MND');
    fnd_message.raise_error;
  end if;
  hr_utility.set_location('Entering:'||l_proc,20);
  if ((irc_ipt_shd.g_old_rec.posting_content_id is
                   null)
    or (irc_ipt_shd.g_old_rec.posting_content_id is not null
    and irc_ipt_shd.g_old_rec.name <> p_name)) then
    open csr_name;
    fetch csr_name into l_name;
    hr_utility.set_location('Entering:'||l_proc,30);
    if (csr_name%found)
    then
      close csr_name;
      fnd_message.set_name('PER','IRC_412122_DUPLICATE_POST_NAME');
      fnd_message.raise_error;
    end if;
    close csr_name;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,35);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 => 'IRC_POSTING_CONTENTS_TL.POSTING_CONTENT_ID'
    )then
      hr_utility.set_location(' Leaving:'||l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,50);
End chk_name;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_source_lang >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_source_lang
  (p_language in irc_posting_contents_tl.language%TYPE
  ,p_source_lang in irc_posting_contents_tl.source_language%TYPE
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
  hr_api.mandatory_arg_error
        (p_api_name                     => l_proc
        ,p_argument                     => 'source_lang'
        ,p_argument_value               => p_source_lang
        );
      --
  hr_utility.set_location(l_proc,20);
  if ((irc_ipt_shd.g_old_rec.posting_content_id is
    null and p_language is not null)
  or (irc_ipt_shd.g_old_rec.posting_content_id is not null
  and nvl(irc_ipt_shd.g_old_rec.language, hr_api.g_varchar2)
    <> nvl(p_language, hr_api.g_varchar2))) then
    --
    hr_utility.set_location(l_proc,30);
    --
    -- Check value has been passed
    --
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
    hr_utility.set_location('Leaving:'||l_proc,40);
    if nvl(l_installed_flag,hr_api.g_varchar2) not in ('I','B') then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','20');
      fnd_message.raise_error;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 50);
End chk_source_lang;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in irc_ipt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  hr_utility.set_location(l_proc, 10);
  irc_ipt_bus.chk_source_lang
  (
   p_language    => p_rec.language
  ,p_source_lang => p_rec.source_language
  );
  hr_utility.set_location(l_proc, 20);
  irc_ipt_bus.chk_name
  (
   p_name      => p_rec.name
  ,p_language  => p_rec.language
  );
  hr_utility.set_location(' Leaving:'||l_proc, 30);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in irc_ipt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  chk_non_updateable_args
  (p_rec              => p_rec
  );
  hr_utility.set_location(l_proc, 10);
  irc_ipt_bus.chk_source_lang
  (
   p_language    => p_rec.language
  ,p_source_lang => p_rec.source_language
  );
  hr_utility.set_location(l_proc, 20);
  irc_ipt_bus.chk_name
  (
   p_name      => p_rec.name
  ,p_language  => p_rec.language
  );
  hr_utility.set_location(' Leaving:'||l_proc, 30);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in irc_ipt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end irc_ipt_bus;

/
