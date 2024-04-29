--------------------------------------------------------
--  DDL for Package Body HR_TDG_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TDG_BUS" as
/* $Header: hrtdgrhi.pkb 115.3 2002/12/03 10:33:25 raranjan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_tdg_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_template_data_group_id      number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_template_data_group_id               in number
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
  (p_template_data_group_id               in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select tmp.legislation_code
      from hr_form_templates_b tmp
          ,hr_template_data_groups tdg
     where tmp.form_template_id = tdg.form_template_id
       and tdg.template_data_group_id = p_template_data_group_id;
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
    ,p_argument           => 'template_data_group_id'
    ,p_argument_value     => p_template_data_group_id
    );
  --
  if ( nvl(hr_tdg_bus.g_template_data_group_id, hr_api.g_number)
       = p_template_data_group_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := hr_tdg_bus.g_legislation_code;
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
    hr_tdg_bus.g_template_data_group_id := p_template_data_group_id;
    hr_tdg_bus.g_legislation_code := l_legislation_code;
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
  (p_rec in hr_tdg_shd.g_rec_type
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
  IF NOT hr_tdg_shd.api_updating
      (p_template_data_group_id               => p_rec.template_data_group_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  IF (nvl(p_rec.form_data_group_id,hr_api.g_number) <>
      nvl(hr_tdg_shd.g_old_rec.form_data_group_id,hr_api.g_number)
     ) THEN
     l_argument := 'form_data_group_id';
     RAISE l_error;
  END IF;
  --
  IF (nvl(p_rec.form_template_id,hr_api.g_number) <>
      nvl(hr_tdg_shd.g_old_rec.form_template_id,hr_api.g_number)
     ) THEN
     l_argument := 'form_template_id';
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
-- |------------------------< chk_form_data_group_id >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_form_data_group_id
  (p_template_data_group_id       in     number
  ,p_object_version_number        in     number
  ,p_form_data_group_id           in     number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_form_data_group_id';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check value has been passed
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'form_data_group_id'
    ,p_argument_value               => p_form_data_group_id
    );
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_form_data_group_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_form_template_id >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_form_template_id
  (p_template_data_group_id       in     number
  ,p_object_version_number        in     number
  ,p_form_template_id             in     number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_form_template_id';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check value has been passed
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'form_template_id'
    ,p_argument_value               => p_form_template_id
    );
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_form_template_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_data_group_and_template >----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_data_group_and_template
  (p_template_data_group_id       in     number
  ,p_object_version_number        in     number
  ,p_form_data_group_id           in     number
  ,p_form_template_id             in     number
  ) is
  --
  cursor csr_form_data_group is
    select fdg.application_id
          ,fdg.form_id
      from hr_form_data_groups_b fdg
     where fdg.form_data_group_id = p_form_data_group_id;
  --
  cursor csr_form_template is
    select tmp.application_id
          ,tmp.form_id
      from hr_form_templates_b tmp
     where tmp.form_template_id = p_form_template_id;
  --
  l_proc                         varchar2(72) := g_package || 'chk_data_group_and_template';
  l_api_updating                 boolean;
  l_data_group_application_id    number;
  l_data_group_form_id           number;
  l_template_application_id      number;
  l_template_form_id             number;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  l_api_updating := hr_tdg_shd.api_updating
    (p_template_data_group_id       => p_template_data_group_id
    ,p_object_version_number        => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and (  nvl(hr_tdg_shd.g_old_rec.form_data_group_id,hr_api.g_number) <>
               nvl(p_form_data_group_id,hr_api.g_number)
            or nvl(hr_tdg_shd.g_old_rec.form_template_id,hr_api.g_number) <>
               nvl(p_form_template_id,hr_api.g_number)))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,30);
    --
    -- Check data group and template reference the same form
    --
    open csr_form_data_group;
    fetch csr_form_data_group into l_data_group_application_id, l_data_group_form_id;
    if csr_form_data_group%notfound then
      close csr_form_data_group;
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    end if;
    close csr_form_data_group;
    --
    open csr_form_template;
    fetch csr_form_template into l_template_application_id, l_template_form_id;
    if csr_form_template%notfound then
      close csr_form_template;
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','20');
      fnd_message.raise_error;
    end if;
    close csr_form_template;
    --
    hr_utility.set_location(l_proc,40);
    --
    if   nvl(l_data_group_application_id,hr_api.g_number) <>
         nvl(l_template_application_id,hr_api.g_number)
      or nvl(l_data_group_form_id,hr_api.g_number) <>
         nvl(l_template_form_id,hr_api.g_number) then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','30');
      fnd_message.raise_error;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_data_group_and_template;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_delete >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (p_rec                          in hr_tdg_shd.g_rec_type
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
  (p_rec                          in hr_tdg_shd.g_rec_type
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
  chk_form_data_group_id
    (p_template_data_group_id       => p_rec.template_data_group_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_data_group_id           => p_rec.form_data_group_id
    );
  --
  chk_form_template_id
    (p_template_data_group_id       => p_rec.template_data_group_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_template_id             => p_rec.form_template_id
    );
  --
  chk_data_group_and_template
    (p_template_data_group_id       => p_rec.template_data_group_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_data_group_id           => p_rec.form_data_group_id
    ,p_form_template_id             => p_rec.form_template_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in hr_tdg_shd.g_rec_type
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
  chk_form_data_group_id
    (p_template_data_group_id       => p_rec.template_data_group_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_data_group_id           => p_rec.form_data_group_id
    );
  --
  chk_form_template_id
    (p_template_data_group_id       => p_rec.template_data_group_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_template_id             => p_rec.form_template_id
    );
  --
  chk_data_group_and_template
    (p_template_data_group_id       => p_rec.template_data_group_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_data_group_id           => p_rec.form_data_group_id
    ,p_form_template_id             => p_rec.form_template_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hr_tdg_shd.g_rec_type
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
end hr_tdg_bus;

/
