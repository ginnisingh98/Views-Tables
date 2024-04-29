--------------------------------------------------------
--  DDL for Package Body HR_SFT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SFT_BUS" as
/* $Header: hrsftrhi.pkb 115.4 2003/10/23 01:45:00 bsubrama noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_sft_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_source_form_template_id     number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_source_form_template_id              in number
  ) is
  --
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- No business group context. Security group is not applicable.
  --
  null;
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
  (p_source_form_template_id              in     number
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
  -- Legislation code not available for source form templates
  --
  l_legislation_code := null;
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
  (p_rec in hr_sft_shd.g_rec_type
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
  IF NOT hr_sft_shd.api_updating
      (p_source_form_template_id              => p_rec.source_form_template_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  IF (nvl(p_rec.form_template_id_from,hr_api.g_number) <>
      nvl(hr_sft_shd.g_old_rec.form_template_id_from,hr_api.g_number)
     ) THEN
     l_argument := 'form_template_id_from';
     RAISE l_error;
  END IF;
  --
  IF (nvl(p_rec.form_template_id_to,hr_api.g_number) <>
      nvl(hr_sft_shd.g_old_rec.form_template_id_to,hr_api.g_number)
     ) THEN
     l_argument := 'form_template_id_to';
     RAISE l_error;
  END IF;
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
-- |----------------------< chk_form_template_id_from >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_form_template_id_from
  (p_source_form_template_id      in number
  ,p_form_template_id_from        in number
  ) is
--
  l_proc                         varchar2(72) := g_package || 'chk_form_template_id_from';
  l_api_updating                 boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- No additional validation required
  --
  null;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End chk_form_template_id_from;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_form_template_id_to >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_form_template_id_to
  (p_source_form_template_id      in number
  ,p_form_template_id_to          in number
  ) is
--
  l_proc                         varchar2(72) := g_package || 'chk_form_template_id_to';
  l_api_updating                 boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check value has been passed
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'form_template_id_to'
    ,p_argument_value     => p_form_template_id_to
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End chk_form_template_id_to;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_form_templates >--------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_form_templates
  (p_source_form_template_id      in number
  ,p_object_version_number        in number
  ,p_form_template_id_from        in number
  ,p_form_template_id_to          in number
  ) is
--
  cursor csr_form_template
    (p_form_template_id             in number
    ) is
    select tmp.application_id
          ,tmp.form_id
      from hr_form_templates_b tmp
     where tmp.form_template_id = p_form_template_id;
--
  l_proc                         varchar2(72) := g_package || 'chk_form_templates';
  l_api_updating                 boolean;
  l_from_application_id          number;
  l_from_form_id                 number;
  l_to_application_id            number;
  l_to_form_id                   number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := hr_sft_shd.api_updating
    (p_source_form_template_id      => p_source_form_template_id
    ,p_object_version_number        => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and (  nvl(hr_sft_shd.g_old_rec.form_template_id_from,hr_api.g_number) <>
               nvl(p_form_template_id_from,hr_api.g_number)
            or nvl(hr_sft_shd.g_old_rec.form_template_id_to,hr_api.g_number) <>
               nvl(p_form_template_id_to,hr_api.g_number)))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,30);
    --
    -- From and to templates must not be equal
    --
    if nvl(p_form_template_id_from,hr_api.g_number) = nvl(p_form_template_id_to,hr_api.g_number) then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    end if;
    --
    -- If both templates are specified they must reference the same form
    --
    if p_form_template_id_from is not null and p_form_template_id_to is not null then
      --
      open csr_form_template(p_form_template_id_from);
      fetch csr_form_template into l_from_application_id, l_from_form_id;
      if csr_form_template%notfound then
        close csr_form_template;
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','20');
        fnd_message.raise_error;
      end if;
      close csr_form_template;
      --
      open csr_form_template(p_form_template_id_to);
      fetch csr_form_template into l_to_application_id, l_to_form_id;
      if csr_form_template%notfound then
        close csr_form_template;
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','30');
        fnd_message.raise_error;
      end if;
      close csr_form_template;
      --
      if   nvl(l_from_application_id,hr_api.g_number) <> nvl(l_to_application_id,hr_api.g_number)
        or nvl(l_from_form_id,hr_api.g_number) <> nvl(l_to_form_id,hr_api.g_number) then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','40');
        fnd_message.raise_error;
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End chk_form_templates;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_delete >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (p_rec                          in hr_sft_shd.g_rec_type
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
  (p_rec                          in hr_sft_shd.g_rec_type
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
  chk_form_template_id_from
    (p_source_form_template_id      => p_rec.source_form_template_id
    ,p_form_template_id_from        => p_rec.form_template_id_from
    );
  --
  chk_form_template_id_to
    (p_source_form_template_id      => p_rec.source_form_template_id
    ,p_form_template_id_to          => p_rec.form_template_id_to
    );
  --
  chk_form_templates
    (p_source_form_template_id      => p_rec.source_form_template_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_template_id_from        => p_rec.form_template_id_from
    ,p_form_template_id_to          => p_rec.form_template_id_to
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in hr_sft_shd.g_rec_type
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
  chk_form_template_id_from
    (p_source_form_template_id      => p_rec.source_form_template_id
    ,p_form_template_id_from        => p_rec.form_template_id_from
    );
  --
  chk_form_template_id_to
    (p_source_form_template_id      => p_rec.source_form_template_id
    ,p_form_template_id_to          => p_rec.form_template_id_to
    );
  --
  chk_form_templates
    (p_source_form_template_id      => p_rec.source_form_template_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_template_id_from        => p_rec.form_template_id_from
    ,p_form_template_id_to          => p_rec.form_template_id_to
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hr_sft_shd.g_rec_type
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
end hr_sft_bus;

/
