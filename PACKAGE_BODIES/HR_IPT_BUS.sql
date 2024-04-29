--------------------------------------------------------
--  DDL for Package Body HR_IPT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_IPT_BUS" as
/* $Header: hriptrhi.pkb 115.9 2003/05/06 17:43:05 adhunter noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_ipt_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_item_property_id            number         default null;
g_language                    varchar2(4)    default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_item_property_id                     in number
  ) is
  --
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  hr_itp_bus.set_security_group_id
    (p_item_property_id                     => p_item_property_id
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
  (p_item_property_id                     in     number
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
  l_legislation_code := hr_itp_bus.return_legislation_code
    (p_item_property_id                     => p_item_property_id
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
  (p_rec in hr_ipt_shd.g_rec_type
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
  IF NOT hr_ipt_shd.api_updating
      (p_item_property_id                     => p_rec.item_property_id
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
  (p_item_property_id             in number
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
  l_api_updating := hr_ipt_shd.api_updating
    (p_item_property_id             => p_item_property_id
    ,p_language                     => p_language
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and nvl(hr_ipt_shd.g_old_rec.source_lang,hr_api.g_varchar2) <>
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
-- |------------------------------< chk_default_value >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_default_value
  (p_item_property_id             in number
  ,p_language                     in varchar2
  ,p_default_value                in varchar2
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_default_value';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_default_value;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_information_prompt >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_information_prompt
  (p_item_property_id             in number
  ,p_language                     in varchar2
  ,p_information_prompt           in varchar2
  ) is
  --
  cursor csr_item_property is
    select itp.information_formula_id
      from hr_item_properties_b itp
     where itp.item_property_id = p_item_property_id;
  --
  l_proc                         varchar2(72) := g_package || 'chk_information_prompt';
  l_api_updating                 boolean;
  l_information_formula_id       number;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and nvl(hr_ipt_shd.g_old_rec.information_prompt,hr_api.g_varchar2) <>
            nvl(p_information_prompt,hr_api.g_varchar2))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,30);
    --
    open csr_item_property;
    fetch csr_item_property into l_information_formula_id;
    if csr_item_property%notfound then
      close csr_item_property;
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    end if;
    close csr_item_property;
    --
    -- Check information prompt has been specified if information formula has,
    -- and has not been specified if information formula has not
    --
    if    l_information_formula_id is null then
      if p_information_prompt is not null then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','20');
        fnd_message.raise_error;
      end if;
    elsif l_information_formula_id is not null then
      if p_information_prompt is null then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','30');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_information_prompt;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< chk_label >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_label
  (p_item_property_id             in number
  ,p_language                     in varchar2
  ,p_label                        in varchar2
  ,p_item_property_id_actual      in varchar2
  ) is
  --
  cursor csr_item_property is
    select itp.form_item_id
          ,itp.template_item_id
          ,itp.template_item_context_id
      from hr_item_properties_b itp
     where itp.item_property_id = p_item_property_id_actual;
  --
  l_proc                         varchar2(72) := g_package || 'chk_label';
  l_api_updating                 boolean;
  l_form_item_id                 number;
  l_template_item_id             number;
  l_template_item_context_id     number;
  l_item_type                    varchar2(30);
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  l_api_updating := hr_ipt_shd.api_updating
    (p_item_property_id             => p_item_property_id
    ,p_language                     => p_language
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and nvl(hr_ipt_shd.g_old_rec.label,hr_api.g_varchar2) <>
            nvl(p_label,hr_api.g_varchar2))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,30);
    --
    -- Check item is of appropriate type if label is specified
    --
    if p_label is not null then
      --
      open csr_item_property;
      fetch csr_item_property into l_form_item_id, l_template_item_id, l_template_item_context_id;
      if csr_item_property%notfound then
        close csr_item_property;
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc||' '||to_char(p_item_property_id));
        fnd_message.set_token('STEP','10');
        fnd_message.raise_error;
      end if;
      close csr_item_property;
      --
      l_item_type := hr_itp_bus.return_item_type
        (p_form_item_id                 => l_form_item_id
        ,p_template_item_id             => l_template_item_id
        ,p_template_item_context_id     => l_template_item_context_id
        );
      if nvl(l_item_type,hr_api.g_varchar2) not in ('BUTTON','CHECKBOX','RADIO_BUTTON') then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','20');
        fnd_message.raise_error;
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_label;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_prompt_text >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_prompt_text
  (p_item_property_id             in number
  ,p_language                     in varchar2
  ,p_prompt_text                  in varchar2
  ,p_item_property_id_actual      in varchar2
  ) is
  --
  cursor csr_item_property is
    select itp.form_item_id
          ,itp.template_item_id
          ,itp.template_item_context_id
      from hr_item_properties_b itp
     where itp.item_property_id = p_item_property_id_actual;
  --
  l_proc                         varchar2(72) := g_package || 'chk_prompt_text';
  l_api_updating                 boolean;
  l_form_item_id                 number;
  l_template_item_id             number;
  l_template_item_context_id     number;
  l_item_type                    varchar2(30);
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  l_api_updating := hr_ipt_shd.api_updating
    (p_item_property_id             => p_item_property_id
    ,p_language                     => p_language
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and nvl(hr_ipt_shd.g_old_rec.prompt_text,hr_api.g_varchar2) <>
            nvl(p_prompt_text,hr_api.g_varchar2))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,30);
    --
    if p_prompt_text is not null then
      --
      hr_utility.set_location(l_proc,40);
      --
      open csr_item_property;
      fetch csr_item_property into l_form_item_id, l_template_item_id, l_template_item_context_id;
      if csr_item_property%notfound then
        close csr_item_property;
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc||' '||to_char(p_item_property_id));
        fnd_message.set_token('STEP','10');
        fnd_message.raise_error;
      end if;
      close csr_item_property;
      --
      l_item_type := hr_itp_bus.return_item_type
        (p_form_item_id                 => l_form_item_id
        ,p_template_item_id             => l_template_item_id
        ,p_template_item_context_id     => l_template_item_context_id
        );
      if nvl(l_item_type,hr_api.g_varchar2) not in ('BUTTON','CHART_ITEM','CHECKBOX','DISPLAY_ITEM','IMAGE','LIST','OLE_OBJECT','RADIO_BUTTON','TEXT_ITEM','USER_AREA','VBX_CONTROL') then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','20');
        fnd_message.raise_error;
      end if;
    --
    end if;
  --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_prompt_text;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_tooltip_text >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_tooltip_text
  (p_item_property_id             in number
  ,p_language                     in varchar2
  ,p_tooltip_text                 in varchar2
  ,p_item_property_id_actual      in varchar2
  ) is
  --
  cursor csr_item_property is
    select itp.form_item_id
          ,itp.template_item_id
          ,itp.template_item_context_id
      from hr_item_properties_b itp
     where itp.item_property_id = p_item_property_id_actual;
  --
  l_proc                         varchar2(72) := g_package || 'chk_tooltip_text';
  l_api_updating                 boolean;
  l_form_item_id                 number;
  l_template_item_id             number;
  l_template_item_context_id     number;
  l_item_type                    varchar2(30);
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  l_api_updating := hr_ipt_shd.api_updating
    (p_item_property_id             => p_item_property_id
    ,p_language                     => p_language
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and nvl(hr_ipt_shd.g_old_rec.tooltip_text,hr_api.g_varchar2) <>
            nvl(p_tooltip_text,hr_api.g_varchar2))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,30);
    --
    if p_tooltip_text is not null then
      --
      hr_utility.set_location(l_proc,40);
      --
      open csr_item_property;
      fetch csr_item_property into l_form_item_id, l_template_item_id, l_template_item_context_id;
      if csr_item_property%notfound then
        close csr_item_property;
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc||' '||to_char(p_item_property_id));
        fnd_message.set_token('STEP','10');
        fnd_message.raise_error;
      end if;
      close csr_item_property;
      --
      l_item_type := hr_itp_bus.return_item_type
        (p_form_item_id                 => l_form_item_id
        ,p_template_item_id             => l_template_item_id
        ,p_template_item_context_id     => l_template_item_context_id
        );
      if nvl(l_item_type,hr_api.g_varchar2) not in ('BUTTON','CHART_ITEM','CHECKBOX','DISPLAY_ITEM','IMAGE','LIST','OLE_OBJECT','RADIO_BUTTON','TEXT_ITEM','USER_AREA','VBX_CONTROL') then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','20');
        fnd_message.raise_error;
      end if;
    --
    end if;
  --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_tooltip_text;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_delete >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (p_rec                          in hr_ipt_shd.g_rec_type
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
  (p_rec                          in hr_ipt_shd.g_rec_type
  ,p_item_property_id             in number
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
    (p_item_property_id             => p_rec.item_property_id
    ,p_language                     => p_rec.language
    ,p_source_lang                  => p_rec.source_lang
    );
  --
  chk_default_value
    (p_item_property_id             => p_rec.item_property_id
    ,p_language                     => p_rec.language
    ,p_default_value                => p_rec.default_value
    );
  --
  chk_information_prompt
    (p_item_property_id             => p_rec.item_property_id
    ,p_language                     => p_rec.language
    ,p_information_prompt           => p_rec.information_prompt
    );
  --
  chk_label
    (p_item_property_id             => p_rec.item_property_id
    ,p_language                     => p_rec.language
    ,p_label                        => p_rec.label
    ,p_item_property_id_actual      => p_item_property_id
    );
  --
  chk_prompt_text
    (p_item_property_id             => p_rec.item_property_id
    ,p_language                     => p_rec.language
    ,p_prompt_text                  => p_rec.prompt_text
    ,p_item_property_id_actual      => p_item_property_id
    );
  --
  chk_tooltip_text
    (p_item_property_id             => p_rec.item_property_id
    ,p_language                     => p_rec.language
    ,p_tooltip_text                 => p_rec.tooltip_text
    ,p_item_property_id_actual      => p_item_property_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in hr_ipt_shd.g_rec_type
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
    (p_item_property_id             => p_rec.item_property_id
    ,p_language                     => p_rec.language
    ,p_source_lang                  => p_rec.source_lang
    );
  --
  chk_default_value
    (p_item_property_id             => p_rec.item_property_id
    ,p_language                     => p_rec.language
    ,p_default_value                => p_rec.default_value
    );
  --
  chk_information_prompt
    (p_item_property_id             => p_rec.item_property_id
    ,p_language                     => p_rec.language
    ,p_information_prompt           => p_rec.information_prompt
    );
  --
  chk_label
    (p_item_property_id             => p_rec.item_property_id
    ,p_language                     => p_rec.language
    ,p_label                        => p_rec.label
    ,p_item_property_id_actual      => p_rec.item_property_id
    );
  --
  chk_prompt_text
    (p_item_property_id             => p_rec.item_property_id
    ,p_language                     => p_rec.language
    ,p_prompt_text                  => p_rec.prompt_text
    ,p_item_property_id_actual      => p_rec.item_property_id
    );
  --
  chk_tooltip_text
    (p_item_property_id             => p_rec.item_property_id
    ,p_language                     => p_rec.language
    ,p_tooltip_text                 => p_rec.tooltip_text
    ,p_item_property_id_actual      => p_rec.item_property_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hr_ipt_shd.g_rec_type
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
end hr_ipt_bus;

/
