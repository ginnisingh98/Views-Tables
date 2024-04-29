--------------------------------------------------------
--  DDL for Package Body HR_TMT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TMT_BUS" as
/* $Header: hrtmtrhi.pkb 115.4 2002/12/03 12:10:08 raranjan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_tmt_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_form_template_id            number         default null;
g_language                    varchar2(4)    default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_form_template_id                     in number
  ) is
  --
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  hr_tmp_bus.set_security_group_id
    (p_form_template_id             => p_form_template_id
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
  (p_form_template_id                     in     number
  ,p_language                             in     varchar2
  )
  Return Varchar2 Is
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_legislation_code := hr_tmp_bus.return_legislation_code
    (p_form_template_id             => p_form_template_id
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
  (p_rec in hr_tmt_shd.g_rec_type
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
  IF NOT hr_tmt_shd.api_updating
      (p_form_template_id                     => p_rec.form_template_id
      ,p_language                             => p_rec.language
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- No non-updateable arguments
  --
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
-- |---------------------------< chk_source_lang >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_source_lang
  (p_form_template_id             in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ) is
  --
  cursor csr_language is
    select l.installed_flag
      from fnd_languages l
     where l.language_code = p_source_lang;
  --
  l_proc                         varchar2(72) := g_package || 'chk_source_lang';
  l_api_updating                 boolean;
  l_installed_flag               varchar2(30);
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  l_api_updating := hr_tmt_shd.api_updating
    (p_form_template_id             => p_form_template_id
    ,p_language                     => p_language
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and nvl(hr_tmt_shd.g_old_rec.source_lang,hr_api.g_varchar2) <>
            nvl(p_source_lang,hr_api.g_varchar2))
     or (NOT l_api_updating)) then
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
/* 1653358: Not necessary
    if nvl(l_installed_flag,hr_api.g_varchar2) not in ('I','B') then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','20');
      fnd_message.raise_error;
    end if;
*/
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_source_lang;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_user_template_name >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_user_template_name
  (p_form_template_id             in number
  ,p_language                     in varchar2
  ,p_user_template_name           in varchar2
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_user_template_name';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check value has been passed
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'user_template_name'
    ,p_argument_value               => p_user_template_name
    );
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_user_template_name;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_description >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_description
  (p_form_template_id             in number
  ,p_language                     in varchar2
  ,p_description                  in varchar2
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_description';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- No additional validation required
  --
  null;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_description;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_delete >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (p_rec                          in hr_tmt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- No additional validation required
  --
  null;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End chk_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in hr_tmt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  -- No business group context.  HR_STANDARD_LOOKUPS used for validation.
  --
  chk_source_lang
    (p_form_template_id             => p_rec.form_template_id
    ,p_language                     => p_rec.language
    ,p_source_lang                  => p_rec.source_lang
    );
  --
  chk_user_template_name
    (p_form_template_id             => p_rec.form_template_id
    ,p_language                     => p_rec.language
    ,p_user_template_name           => p_rec.user_template_name
    );
  --
  chk_description
    (p_form_template_id             => p_rec.form_template_id
    ,p_language                     => p_rec.language
    ,p_description                  => p_rec.description
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in hr_tmt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  -- No business group context.  HR_STANDARD_LOOKUPS used for validation.
  --
  chk_non_updateable_args
    (p_rec                          => p_rec
    );
  --
  chk_source_lang
    (p_form_template_id             => p_rec.form_template_id
    ,p_language                     => p_rec.language
    ,p_source_lang                  => p_rec.source_lang
    );
  --
  chk_user_template_name
    (p_form_template_id             => p_rec.form_template_id
    ,p_language                     => p_rec.language
    ,p_user_template_name           => p_rec.user_template_name
    );
  --
  chk_description
    (p_form_template_id             => p_rec.form_template_id
    ,p_language                     => p_rec.language
    ,p_description                  => p_rec.description
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hr_tmt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_delete
    (p_rec                          => p_rec
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end hr_tmt_bus;

/
