--------------------------------------------------------
--  DDL for Package Body HR_TIC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TIC_BUS" as
/* $Header: hrticrhi.pkb 115.6 2002/12/03 10:59:58 raranjan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_tic_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_template_item_context_id    number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_template_item_context_id             in number
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
  (p_template_item_context_id             in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select tmp.legislation_code
      from hr_form_templates_b tmp
          ,hr_template_items_b tim
          ,hr_template_item_contexts_b tic
     where tmp.form_template_id = tim.form_template_id
       and tim.template_item_id = tic.template_item_id
       and tic.template_item_context_id = p_template_item_context_id;
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
    ,p_argument           => 'template_item_context_id'
    ,p_argument_value     => p_template_item_context_id
    );
  --
  if ( nvl(hr_tic_bus.g_template_item_context_id, hr_api.g_number)
       = p_template_item_context_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := hr_tic_bus.g_legislation_code;
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
    hr_tic_bus.g_template_item_context_id := p_template_item_context_id;
    hr_tic_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in hr_tic_shd.g_rec_type
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
  IF NOT hr_tic_shd.api_updating
      (p_template_item_context_id             => p_rec.template_item_context_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  IF (nvl(p_rec.template_item_id,hr_api.g_number) <>
      nvl(hr_tic_shd.g_old_rec.template_item_id,hr_api.g_number)
     ) THEN
     l_argument := 'template_item_id';
     RAISE l_error;
  END IF;
  --
  IF (nvl(p_rec.context_type,hr_api.g_varchar2) <>
      nvl(hr_tic_shd.g_old_rec.context_type,hr_api.g_varchar2)
     ) THEN
     l_argument := 'context_type';
     RAISE l_error;
  END IF;
  --
  IF (nvl(p_rec.item_context_id,hr_api.g_number) <>
      nvl(hr_tic_shd.g_old_rec.item_context_id,hr_api.g_number)
     ) THEN
     l_argument := 'item_context_id';
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
-- |-------------------------< chk_template_item_id >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_template_item_id
  (p_template_item_context_id     in     number
  ,p_object_version_number        in     number
  ,p_template_item_id             in     number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_template_item_id';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check value has been passed
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'template_item_id'
    ,p_argument_value               => p_template_item_id
    );
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_template_item_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_context_type >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_context_type
  (p_template_item_context_id     in     number
  ,p_object_version_number        in     number
  ,p_context_type                 in     varchar2
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_context_type';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check value has been passed
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'context_type'
    ,p_argument_value               => p_context_type
    );
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_context_type;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_item_context_id >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_item_context_id
  (p_template_item_context_id     in     number
  ,p_object_version_number        in     number
  ,p_item_context_id              in     number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_item_context_id';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check value has been passed
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'item_context_id'
    ,p_argument_value               => p_item_context_id
    );
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_item_context_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_item_and_context >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_item_and_context
  (p_template_item_context_id     in number
  ,p_object_version_number        in number
  ,p_template_item_id             in number
  ,p_item_context_id              in number
  ) is
  --
  CURSOR csr_item_contexts
    (p_item_context_id              in number
    )
  IS
    SELECT ifs.id_flex_structure_code
          ,icx.segment1
          ,icx.segment2
      FROM fnd_id_flex_structures ifs
          ,hr_item_contexts icx
     WHERE ifs.application_id = 800
       AND ifs.id_flex_code = 'ICX'
       AND ifs.id_flex_num = icx.id_flex_num
       AND icx.item_context_id = p_item_context_id;
  l_item_context                 csr_item_contexts%rowtype;
  --
  CURSOR csr_template_item_contexts
    (p_template_item_id             in number
    ,p_template_item_context_id     in number
    )
  IS
    SELECT ifs.id_flex_structure_code
          ,icx.segment1
          ,icx.segment2
      FROM fnd_id_flex_structures ifs
          ,hr_item_contexts icx
          ,hr_template_item_contexts_b tic
     WHERE ifs.application_id = 800
       AND ifs.id_flex_code = 'ICX'
       AND ifs.id_flex_num = icx.id_flex_num
       AND icx.item_context_id = tic.item_context_id
       AND tic.template_item_id = p_template_item_id
       AND (  p_template_item_context_id IS NULL
           OR tic.template_item_context_id <> p_template_item_context_id);
  --
  l_proc                         varchar2(71) := g_package || 'chk_item_and_context';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Retrieve context for specific item context
  --
  OPEN csr_item_contexts
    (p_item_context_id => p_item_context_id
    );
  FETCH csr_item_contexts INTO l_item_context;
  CLOSE csr_item_contexts;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Compare with contexts already defined for the same item
  --
  FOR l_template_item_context IN csr_template_item_contexts
    (p_template_item_id         => p_template_item_id
    ,p_template_item_context_id => p_template_item_context_id
    )
  LOOP
    IF    (l_template_item_context.id_flex_structure_code <> l_item_context.id_flex_structure_code)
    THEN
      fnd_message.set_name('PER', 'HR_52650_TIC_DIFFERENT_CONTEXT');
      fnd_message.raise_error;
    ELSIF (l_template_item_context.id_flex_structure_code IN ('DFLEX','KFLEX'))
    THEN
      IF (  (l_template_item_context.segment1 <> l_item_context.segment1)
         OR (l_template_item_context.segment2 <> l_item_context.segment2) )
      THEN
        fnd_message.set_name('PER', 'HR_52650_TIC_DIFFERENT_CONTEXT');
        fnd_message.raise_error;
      END IF;
    END IF;
  END LOOP;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_item_and_context;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_delete >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (p_rec                          in hr_tic_shd.g_rec_type
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
  (p_rec                          in hr_tic_shd.g_rec_type
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
  chk_template_item_id
    (p_template_item_context_id     => p_rec.template_item_context_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_template_item_id             => p_rec.template_item_id
    );
  --
  chk_context_type
    (p_template_item_context_id     => p_rec.template_item_context_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_context_type                 => p_rec.context_type
    );
  --
  chk_item_context_id
    (p_template_item_context_id     => p_rec.template_item_context_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_context_id              => p_rec.item_context_id
    );
  --
  chk_item_and_context
    (p_template_item_context_id     => p_rec.template_item_context_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_context_id              => p_rec.item_context_id
    ,p_template_item_id             => p_rec.template_item_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in hr_tic_shd.g_rec_type
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
  chk_template_item_id
    (p_template_item_context_id     => p_rec.template_item_context_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_template_item_id             => p_rec.template_item_id
    );
  --
  chk_context_type
    (p_template_item_context_id     => p_rec.template_item_context_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_context_type                 => p_rec.context_type
    );
  --
  chk_item_context_id
    (p_template_item_context_id     => p_rec.template_item_context_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_context_id              => p_rec.item_context_id
    );
  --
  chk_item_and_context
    (p_template_item_context_id     => p_rec.template_item_context_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_context_id              => p_rec.item_context_id
    ,p_template_item_id             => p_rec.template_item_id
    );
   --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hr_tic_shd.g_rec_type
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
end hr_tic_bus;

/
