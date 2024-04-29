--------------------------------------------------------
--  DDL for Package Body HR_TIM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TIM_BUS" as
/* $Header: hrtimrhi.pkb 115.10 2003/10/29 02:53:14 jpthomas noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_tim_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_template_item_id            number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_template_item_id                     in number
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
  (p_template_item_id                     in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select tmp.legislation_code
      from hr_form_templates_b tmp
          ,hr_template_items_b tim
     where tmp.form_template_id = tim.form_template_id
       and tim.template_item_id = p_template_item_id;
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
    ,p_argument           => 'template_item_id'
    ,p_argument_value     => p_template_item_id
    );
  --
  if ( nvl(hr_tim_bus.g_template_item_id, hr_api.g_number)
       = p_template_item_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := hr_tim_bus.g_legislation_code;
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
    hr_tim_bus.g_template_item_id  := p_template_item_id;
    hr_tim_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in hr_tim_shd.g_rec_type
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
  IF NOT hr_tim_shd.api_updating
      (p_template_item_id                     => p_rec.template_item_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  IF (nvl(p_rec.form_item_id,hr_api.g_number) <>
      nvl(hr_tim_shd.g_old_rec.form_item_id,hr_api.g_number)
     ) THEN
     l_argument := 'form_item_id';
     RAISE l_error;
  END IF;
  --
  IF (nvl(p_rec.form_template_id,hr_api.g_number) <>
      nvl(hr_tim_shd.g_old_rec.form_template_id,hr_api.g_number)
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
-- |---------------------------< chk_form_item_id >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_form_item_id
  (p_template_item_id             in     number
  ,p_object_version_number        in     number
  ,p_form_item_id                 in     number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_form_item_id';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check value has been passed
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'form_item_id'
    ,p_argument_value               => p_form_item_id
    );
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_form_item_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_form_template_id >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_form_template_id
  (p_template_item_id             in     number
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
-- |------------------------< chk_item_and_template >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_item_and_template
  (p_template_item_id             in     number
  ,p_object_version_number        in     number
  ,p_form_item_id                 in     number
  ,p_form_template_id             in     number
  ) is
  --
  cursor csr_form_item is
    select fim.application_id
          ,fim.form_id
      from hr_form_items_b fim
     where fim.form_item_id = p_form_item_id;
  --
  cursor csr_form_template is
    select tmp.application_id
          ,tmp.form_id
      from hr_form_templates_b tmp
     where tmp.form_template_id = p_form_template_id;
  --
  l_proc                         varchar2(72) := g_package || 'chk_item_and_template';
  l_api_updating                 boolean;
  l_item_application_id          number;
  l_item_form_id                 number;
  l_template_application_id      number;
  l_template_form_id             number;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  l_api_updating := hr_tim_shd.api_updating
    (p_template_item_id             => p_template_item_id
    ,p_object_version_number        => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and (  nvl(hr_tim_shd.g_old_rec.form_item_id,hr_api.g_number) <>
               nvl(p_form_item_id,hr_api.g_number)
            or nvl(hr_tim_shd.g_old_rec.form_template_id,hr_api.g_number) <>
               nvl(p_form_template_id,hr_api.g_number)))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,30);
    --
    -- Check item and template reference the same form
    --
    open csr_form_item;
    fetch csr_form_item into l_item_application_id, l_item_form_id;
    if csr_form_item%notfound then
      close csr_form_item;
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    end if;
    close csr_form_item;
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
    if   nvl(l_item_application_id,hr_api.g_number) <>
         nvl(l_template_application_id,hr_api.g_number)
      or nvl(l_item_form_id,hr_api.g_number) <>
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
End chk_item_and_template;
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_no_flex_segment_comb >--------------------|
-- ----------------------------------------------------------------------------
Procedure chk_no_flex_segment_comb
  (p_form_template_id             in number
  ,p_object_version_number        in number
  ,p_form_item_id                 in number
  ) is
  --
  cursor csr_derive_item_name is
  select fim.full_item_name
  from   hr_form_items_b fim
  where  fim.form_item_id = p_form_item_id;
  --
  cursor csr_flex_on_template(p_block varchar2, p_flex_name varchar2) is
  select 1
  from hr_template_items_b tim, hr_form_items_b fim
  where tim.form_item_id = fim.form_item_id
  and   tim.form_template_id = p_form_template_id
  and   fim.full_item_name = p_block||'.'||p_flex_name;
  --
  cursor csr_segment_on_template(p_block varchar2, p_segment varchar2) is
  select 1
  from hr_template_items_b tim, hr_form_items_b fim
  where tim.form_item_id = fim.form_item_id
  and   tim.form_template_id = p_form_template_id
  and   fim.full_item_name like p_block||'.'||p_segment||'%';
  --
--
-- Bug 3163360 Start here
-- Description : Modified the cursor to exclude the no adrress informations such as
--               'COUNTRY_OF_BIRTH','REGION_OF_BIRTH', 'COUNTRYn_MEANING'
--
  cursor csr_address_segs_exist(p_block varchar2) is
  select 1
  from hr_template_items_b tim, hr_form_items_b fim
  where tim.form_item_id = fim.form_item_id
  and   tim.form_template_id = p_form_template_id
  and  ((fim.full_item_name like p_block||'.ADDRESS_LINE%'
     or fim.full_item_name like p_block||'.REGION_%'
     or fim.full_item_name like p_block||'.POSTAL_CODE%'
     or fim.full_item_name like p_block||'.TOWN_OR_CITY%'
     or fim.full_item_name like p_block||'.COUNTRY%'
     or fim.full_item_name like p_block||'.TELEPHONE_NUMBER_%'
     or fim.full_item_name like p_block||'.ADD_INFORMATION%')
    and fim.full_item_name not like p_block||'.%OF_BIRTH%'
    and fim.full_item_name not like p_block||'.COUNTRY%_MEANING');

--
--Bug 3163360 End here
--
  l_dummy1 varchar2(80);
  l_dummy2 varchar2(80);
  l_block varchar2(30);
  l_segment varchar2(80);
  l_flex_name varchar2(20);
  l_form_item_name varchar2(80);
  --
  l_proc                         varchar2(72) := g_package || 'chk_no_flex_segment_comb';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check value has been passed
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'form_item_id'
    ,p_argument_value     => p_form_item_id
    );
  --
  -- Check to omit validation when not adding a flex popup or a segment
  --
  open csr_derive_item_name;
  fetch csr_derive_item_name into l_form_item_name;
  close csr_derive_item_name;
  if not (   l_form_item_name like '%_SEGMENT%'
          or l_form_item_name like '%_ATTRIBUTE%'
          or l_form_item_name like '%_INFORMATION%'
          or l_form_item_name like '%ADDRESS_LINE%'
          or l_form_item_name like '%REGION_%'
          or l_form_item_name like '%POSTAL_CODE%'
          or l_form_item_name like '%TOWN_OR_CITY%'
          or l_form_item_name like '%COUNTRY%'
          or l_form_item_name like '%TELEPHONE_NUMBER_%'
          or l_form_item_name like '%ADD_INFORMATION%'
          or l_form_item_name like '%_DF'
          or l_form_item_name like '%_KF'
         )  then
    null;
  else
    --
    hr_utility.set_location(l_proc,20);
    --
    for j in 1..3 loop        -- loop around the blocks
    <<block>>
      if j=1 then
         l_block := 'MAINTAIN';
      elsif j=2 then
         l_block := 'SUMMARY';
      elsif j=3 then
         l_block := 'FIND_FOLDER';
      end if;
      --
      --
      -- Address Structure columns have differing names so require special treatment first
      --
      l_segment := 'ADD_INFORMATION';
      l_flex_name := 'ADDR_DF';
      open csr_flex_on_template(l_block, l_flex_name);
      fetch csr_flex_on_template into l_dummy1;
        if csr_flex_on_template%found then
           close csr_flex_on_template;
           open csr_address_segs_exist(l_block);
           fetch csr_address_segs_exist into l_dummy2;
           if csr_address_segs_exist%found then
              close csr_address_segs_exist;
              fnd_message.set_name('PER','PER_289203_INV_FLEX_SEG_COMB');
              fnd_message.set_token('FLEX_SEG',l_block||'.'||l_segment);
              fnd_message.raise_error;
           else
              close csr_address_segs_exist;
           end if;
        else
            close csr_flex_on_template;
        end if;
      --
      for i in 1..9 loop     -- Now loop around the other flexfield items
      <<prefix>>
      if i = 1 then
         l_segment := 'PER_INFORMATION';
         l_flex_name := 'PER_DF';
      elsif i = 2 then
         l_segment := 'PER_ATTRIBUTE';
         l_flex_name := 'PER_DETAILS_DF';
      elsif i = 3 then
         l_segment := 'ASS_ATTRIBUTE';
         l_flex_name := 'ASS_DF';
      elsif i = 4 then
         l_segment := 'APPL_ATTRIBUTE';
         l_flex_name := 'APPL_DF';
      elsif i = 5 then
         l_segment := 'ADDR_ATTRIBUTE';
         l_flex_name := 'ADDR_DETAILS_DF';
      elsif i = 6 then
         l_segment := 'PYP_ATTRIBUTE';
         l_flex_name := 'PYP_DF';
      elsif i = 7 then
         l_segment := 'DPF_ATTRIBUTE';
         l_flex_name := 'DPF_DF';
      elsif i = 8 then
         l_segment := 'PGP_SEGMENT';
         l_flex_name := 'PGP_KF';
      elsif i = 9 then
         l_segment := 'SCL_SEGMENT';
         l_flex_name := 'SCL_KF';
      end if;
      --
      open csr_flex_on_template(l_block, l_flex_name);
      fetch csr_flex_on_template into l_dummy1;
      if csr_flex_on_template%found then
         close csr_flex_on_template;
         open csr_segment_on_template(l_block, l_segment);
         fetch csr_segment_on_template into l_dummy2;
         if csr_segment_on_template%found then
            close csr_segment_on_template;
            fnd_message.set_name('PER','PER_289203_INV_FLEX_SEG_COMB');
            fnd_message.set_token('FLEX_SEG',l_block||'.'||l_segment);
            fnd_message.raise_error;
         else
           close csr_segment_on_template;
         end if;
      else
        close csr_flex_on_template;
      end if;
      --
      end loop prefix;
      --
    end loop block;
    --
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 100);
end chk_no_flex_segment_comb;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_delete >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (p_rec                          in hr_tim_shd.g_rec_type
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
  (p_rec                          in hr_tim_shd.g_rec_type
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
  chk_form_item_id
    (p_template_item_id             => p_rec.template_item_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_item_id                 => p_rec.form_item_id
    );
  --
  chk_form_template_id
    (p_template_item_id             => p_rec.template_item_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_template_id             => p_rec.form_template_id
    );
  --
  chk_item_and_template
    (p_template_item_id             => p_rec.template_item_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_item_id                 => p_rec.form_item_id
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
  (p_rec                          in hr_tim_shd.g_rec_type
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
  chk_form_item_id
    (p_template_item_id             => p_rec.template_item_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_item_id                 => p_rec.form_item_id
    );
  --
  chk_form_template_id
    (p_template_item_id             => p_rec.template_item_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_template_id             => p_rec.form_template_id
    );
  --
  chk_item_and_template
    (p_template_item_id             => p_rec.template_item_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_item_id                 => p_rec.form_item_id
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
  (p_rec                          in hr_tim_shd.g_rec_type
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
end hr_tim_bus;

/
