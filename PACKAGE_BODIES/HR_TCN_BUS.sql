--------------------------------------------------------
--  DDL for Package Body HR_TCN_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TCN_BUS" as
/* $Header: hrtcnrhi.pkb 115.5 2002/12/03 10:00:59 raranjan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_tcn_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_template_canvas_id          number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_template_canvas_id                   in number
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
  (p_template_canvas_id                   in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select tmp.legislation_code
      from hr_form_templates_b tmp
          ,hr_template_windows_b twn
          ,hr_template_canvases_b tcn
     where tmp.form_template_id = twn.form_template_id
       and twn.template_window_id = tcn.template_window_id
       and tcn.template_canvas_id = p_template_canvas_id;
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
    ,p_argument           => 'template_canvas_id'
    ,p_argument_value     => p_template_canvas_id
    );
  --
  if ( nvl(hr_tcn_bus.g_template_canvas_id, hr_api.g_number)
       = p_template_canvas_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := hr_tcn_bus.g_legislation_code;
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
    hr_tcn_bus.g_template_canvas_id:= p_template_canvas_id;
    hr_tcn_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in hr_tcn_shd.g_rec_type
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
  IF NOT hr_tcn_shd.api_updating
      (p_template_canvas_id                   => p_rec.template_canvas_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  IF (nvl(p_rec.form_canvas_id,hr_api.g_number) <>
      nvl(hr_tcn_shd.g_old_rec.form_canvas_id,hr_api.g_number)
     ) THEN
     l_argument := 'form_canvas_id';
     RAISE l_error;
  END IF;
  --
  IF (nvl(p_rec.template_window_id,hr_api.g_number) <>
      nvl(hr_tcn_shd.g_old_rec.template_window_id,hr_api.g_number)
     ) THEN
     l_argument := 'template_window_id';
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
-- |--------------------------< chk_form_canvas_id >--------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_form_canvas_id
  (p_template_canvas_id           in     number
  ,p_object_version_number        in     number
  ,p_form_canvas_id               in     number
  ) is
  --
  cursor csr_form_canvas is
    select fcn.canvas_type
      from hr_form_canvases_b fcn
     where fcn.form_canvas_id = p_form_canvas_id;
  --
  l_proc                         varchar2(72) := g_package || 'chk_form_canvas_id';
  l_api_updating                 boolean;
  l_canvas_type                  varchar2(30);
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  l_api_updating := hr_tcn_shd.api_updating
    (p_template_canvas_id           => p_template_canvas_id
    ,p_object_version_number        => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and nvl(hr_fcn_shd.g_old_rec.form_canvas_id,hr_api.g_number) <>
            nvl(p_form_canvas_id,hr_api.g_number))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,30);
    --
    -- Check value has been passed
    --
    hr_api.mandatory_arg_error
      (p_api_name                     => l_proc
      ,p_argument                     => 'form_canvas_id'
      ,p_argument_value               => p_form_canvas_id
      );
    --
    -- Check canvas is of type CONTENT or TAB
    --
    open csr_form_canvas;
    fetch csr_form_canvas into l_canvas_type;
    if csr_form_canvas%notfound then
      close csr_form_canvas;
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    end if;
    close csr_form_canvas;
    --
/*
    if l_canvas_type not in ('CONTENT','TAB') then
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
End chk_form_canvas_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_template_window_id >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_template_window_id
  (p_template_canvas_id           in     number
  ,p_object_version_number        in     number
  ,p_template_window_id           in     number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_template_window_id';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check value has been passed
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'template_window_id'
    ,p_argument_value               => p_template_window_id
    );
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_template_window_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_canvas_and_window >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_canvas_and_window
  (p_template_canvas_id           in     number
  ,p_object_version_number        in     number
  ,p_form_canvas_id               in     number
  ,p_template_window_id           in     number
  ) is
  --
  cursor csr_form_canvas is
    select fcn.form_window_id
      from hr_form_canvases_b fcn
     where fcn.form_canvas_id = p_form_canvas_id;
  --
  cursor csr_template_window is
    select twn.form_window_id
      from hr_template_windows_b twn
     where twn.template_window_id = p_template_window_id;
  --
  l_proc                         varchar2(72) := g_package || 'chk_canvas_and_window';
  l_api_updating                 boolean;
  l_canvas_window_id             number;
  l_window_window_id             number;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  l_api_updating := hr_tcn_shd.api_updating
    (p_template_canvas_id           => p_template_canvas_id
    ,p_object_version_number        => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and (  nvl(hr_tcn_shd.g_old_rec.form_canvas_id,hr_api.g_number) <>
               nvl(p_form_canvas_id,hr_api.g_number)
            or nvl(hr_tcn_shd.g_old_rec.template_window_id,hr_api.g_number) <>
               nvl(p_template_window_id,hr_api.g_number)))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,30);
    --
    -- Check form canvas and template window reference the same form window
    --
    open csr_form_canvas;
    fetch csr_form_canvas into l_canvas_window_id;
    if csr_form_canvas%notfound then
      close csr_form_canvas;
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    end if;
    close csr_form_canvas;
    --
    open csr_template_window;
    fetch csr_template_window into l_window_window_id;
    if csr_template_window%notfound then
      close csr_template_window;
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','20');
      fnd_message.raise_error;
    end if;
    close csr_template_window;
    --
    hr_utility.set_location(l_proc,40);
    --
    if nvl(l_canvas_window_id,hr_api.g_number) <>
       nvl(l_window_window_id,hr_api.g_number) then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','30');
      fnd_message.raise_error;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_canvas_and_window;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_delete >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (p_rec                          in hr_tcn_shd.g_rec_type
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
  (p_rec                          in hr_tcn_shd.g_rec_type
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
  chk_form_canvas_id
    (p_template_canvas_id           => p_rec.template_canvas_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_canvas_id               => p_rec.form_canvas_id
    );
  --
  chk_template_window_id
    (p_template_canvas_id           => p_rec.template_canvas_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_template_window_id           => p_rec.template_window_id
    );
  --
  chk_canvas_and_window
    (p_template_canvas_id           => p_rec.template_canvas_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_canvas_id               => p_rec.form_canvas_id
    ,p_template_window_id           => p_rec.template_window_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in hr_tcn_shd.g_rec_type
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
  chk_form_canvas_id
    (p_template_canvas_id           => p_rec.template_canvas_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_canvas_id               => p_rec.form_canvas_id
    );
  --
  chk_template_window_id
    (p_template_canvas_id           => p_rec.template_canvas_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_template_window_id           => p_rec.template_window_id
    );
  --
  chk_canvas_and_window
    (p_template_canvas_id           => p_rec.template_canvas_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_canvas_id               => p_rec.form_canvas_id
    ,p_template_window_id           => p_rec.template_window_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hr_tcn_shd.g_rec_type
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
end hr_tcn_bus;

/
