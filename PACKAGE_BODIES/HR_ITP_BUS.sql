--------------------------------------------------------
--  DDL for Package Body HR_ITP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ITP_BUS" as
/* $Header: hritprhi.pkb 115.11 2003/12/03 07:01:45 adhunter noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_itp_bus.';  -- Global package name
--
-- The following two global variables are only to be used by the
-- return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_item_property_id            number         default null;
--
-- The following three global variables are only to be used by the
-- return_item_type function.
--
g_item_type                   varchar2(30)   default null;
g_form_item_id                number         default null;
g_template_item_id            number         default null;
g_template_item_context_id    number         default null;
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
  (p_item_property_id                     in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select tmp.legislation_code
      from hr_form_templates_b tmp
          ,hr_template_items_b tim
          ,hr_item_properties_b itp
     where tmp.form_template_id = tim.form_template_id
       and tim.template_item_id = itp.template_item_id
       and itp.item_property_id = p_item_property_id
     union
    select tmp.legislation_code
      from hr_form_templates_b tmp
          ,hr_template_items_b tim
          ,hr_template_item_contexts_b tic
          ,hr_item_properties_b itp
     where tmp.form_template_id = tim.form_template_id
       and tim.template_item_id = tic.template_item_id
       and tic.template_item_context_id = itp.template_item_context_id
       and itp.item_property_id = p_item_property_id;
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
    ,p_argument           => 'item_property_id'
    ,p_argument_value     => p_item_property_id
    );
  --
  if ( nvl(hr_itp_bus.g_item_property_id, hr_api.g_number)
       = p_item_property_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := hr_itp_bus.g_legislation_code;
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
      -- Legislation code not found, which may be correct for certain item
      -- properties.
      --
      l_legislation_code := null;
    end if;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    hr_itp_bus.g_item_property_id := p_item_property_id;
    hr_itp_bus.g_legislation_code := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_prev_and_next_nav_item >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_prev_and_next_nav_item
  (p_effective_date                       in date
  ,p_item_property_id                     in number
  ,p_form_item_id                         in number
  ,p_template_item_id                     in number
  ,p_template_item_context_id             in number
  ,p_previous_navigation_item_id          in number
  ,p_next_navigation_item_id              in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_prev_and_next_nav_item';
  --
  CURSOR cur_form
  IS
  SELECT form_id
  FROM hr_form_items_b
  WHERE form_item_id = p_form_item_id
  AND p_form_item_id is not null
  AND p_template_item_id is null
  AND p_template_item_context_id is null
  UNION
  SELECT form_id
  FROM hr_template_items_b hti
       , hr_form_items_b hfi
  WHERE hti.template_item_id = p_template_item_id
  AND hti.form_item_id = hfi.form_item_id
  AND p_template_item_id is not null
  AND p_form_item_id is null
  AND p_template_item_context_id is null
  UNION
  SELECT form_id
  FROM hr_template_item_contexts_b tic
       , hr_template_items_b hti
       , hr_form_items_b hfi
  WHERE tic.template_item_context_id = p_template_item_context_id
  AND hti.template_item_id = tic.template_item_id
  AND hti.form_item_id = hfi.form_item_id
  AND p_template_item_context_id is not null
  AND p_template_item_id is null
  AND p_form_item_id is null;

  CURSOR cur_item(l_item_id number)
  IS
  SELECT form_id
  FROM hr_form_items_b
  WHERE form_item_id = l_item_id;

  l_form_id  number(15);
  l_prev_form_id number(15);
  l_next_form_id number(15);
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);

  IF (p_item_property_id is not null
  and ((p_previous_navigation_item_id is not null and
       (nvl(hr_itp_shd.g_old_rec.previous_navigation_item_id,hr_api.g_number)
           <> nvl(p_previous_navigation_item_id,hr_api.g_number)))
  or (p_next_navigation_item_id is not null and
       (nvl(hr_itp_shd.g_old_rec.next_navigation_item_id,hr_api.g_number)
           <> nvl(p_next_navigation_item_id,hr_api.g_number)))))
  or ( p_item_property_id is null and
     ( p_previous_navigation_item_id is not null
      or p_next_navigation_item_id is not null )) THEN

    OPEN cur_form;
    FETCH cur_form INTO l_form_id;
    IF cur_form%NOTFOUND THEN
      CLOSE cur_form;
      IF p_template_item_id is not null THEN
        -- error message - invalid template item id
        fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE ', l_proc);
        fnd_message.set_token('STEP ', '10');
        fnd_message.raise_error;
      ELSIF p_form_item_id is not null THEN
        -- error message - invalid form item id
        fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE ', l_proc);
        fnd_message.set_token('STEP ', '20');
        fnd_message.raise_error;
      ELSIF p_template_item_context_id is not null THEN
        -- error message - invalid template item context id
        fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE ', l_proc);
        fnd_message.set_token('STEP ', '30');
        fnd_message.raise_error;
      END IF;
    END IF;
    CLOSE cur_form;
  END IF;

  if (p_item_property_id is not null
      and (p_previous_navigation_item_id is not null and
       (nvl(hr_itp_shd.g_old_rec.previous_navigation_item_id,hr_api.g_number)
           <> nvl(p_previous_navigation_item_id,hr_api.g_number))))
  or (p_item_property_id is null
      and p_previous_navigation_item_id is not null) then

    OPEN cur_item(p_previous_navigation_item_id);
    FETCH cur_item into l_prev_form_id;
    IF cur_item%NOTFOUND THEN
      CLOSE cur_item;
      -- error message - invalid previous navigation item id
      fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE ', l_proc);
      fnd_message.set_token('STEP ', '40');
      fnd_message.raise_error;
    END IF;
    CLOSE cur_item;

    IF l_prev_form_id <> l_form_id THEN
      -- error message - previous navigation item id is not on the same form
      -- as the item for which the item property is being created/amended
      fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE ', l_proc);
      fnd_message.set_token('STEP ', '50');
      fnd_message.raise_error;
    END IF;

  end if;

  hr_utility.set_location('Leaving:'||l_proc, 20);

  if (p_item_property_id is not null and
      (p_next_navigation_item_id is not null and
       (nvl(hr_itp_shd.g_old_rec.next_navigation_item_id,hr_api.g_number)
           <> nvl(p_next_navigation_item_id,hr_api.g_number))))
  or (p_item_property_id is null and p_next_navigation_item_id is not null)
  then

    OPEN cur_item(p_next_navigation_item_id);
    FETCH cur_item into l_next_form_id;
    IF cur_item%NOTFOUND THEN
      CLOSE cur_item;
      -- error message - invalid next navigation item id
      fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE ', l_proc);
      fnd_message.set_token('STEP ', '60');
      fnd_message.raise_error;
    END IF;
    CLOSE cur_item;

    IF l_next_form_id <> l_form_id THEN
      -- error message -  next item id is not on the same form
      -- as the item for which the item property is being created/amended
      fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE ', l_proc);
      fnd_message.set_token('STEP ', '70');
      fnd_message.raise_error;
    END IF;

  end if;
  --
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_prev_and_next_nav_item;
--
--
-- ---------------------------------------------------------------------------
-- |---------------------------< return_item_type >--------------------------|
-- ---------------------------------------------------------------------------
FUNCTION return_item_type
  (p_form_item_id                         in     number default hr_api.g_number
  ,p_template_item_id                     in     number default hr_api.g_number
  ,p_template_item_context_id             in     number default hr_api.g_number
  ) RETURN varchar2 is
  --
  -- Declare cursors
  --
  cursor csr_form_item is
    select fim.item_type
      from hr_form_items_b fim
     where fim.form_item_id = p_form_item_id;
  --
  cursor csr_template_item is
    select fim.item_type
      from hr_form_items_b fim
          ,hr_template_items_b tim
     where fim.form_item_id = tim.form_item_id
       and tim.template_item_id = p_template_item_id;
  --
  cursor csr_template_item_context is
    select fim.item_type
      from hr_form_items_b fim
          ,hr_template_items_b tim
          ,hr_template_item_contexts_b tic
     where fim.form_item_id = tim.form_item_id
       and tim.template_item_id = tic.template_item_id
       and tic.template_item_context_id = p_template_item_context_id;
  --
  -- Declare local variables
  --
  l_item_type         varchar2(30);
  l_proc              varchar2(72) :=  g_package||'return_canvas_type';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if (   nvl(hr_itp_bus.g_form_item_id, hr_api.g_number) = nvl(p_form_item_id, hr_api.g_number)
     and nvl(hr_itp_bus.g_template_item_id, hr_api.g_number) = nvl(p_template_item_id, hr_api.g_number)
     and nvl(hr_itp_bus.g_template_item_context_id, hr_api.g_number) = nvl(p_template_item_context_id, hr_api.g_number)
     ) then
    --
    -- The item has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_item_type := hr_itp_bus.g_item_type;
    hr_utility.set_location(l_proc, 20);
  else
   --
    -- The IDs are different to the last call to this function
    -- or this is the first call to this function.
    --
    if    (nvl(p_form_item_id, hr_api.g_number) <> hr_api.g_number) then
      --
      open csr_form_item;
      fetch csr_form_item into l_item_type;
      --
      if csr_form_item%notfound then
        --
        -- The form item id is invalid therefore we must error
        --
        close csr_form_item;
        fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE ', l_proc);
        fnd_message.set_token('STEP ', '10');
        fnd_message.raise_error;
      end if;
      hr_utility.set_location(l_proc,30);
      close csr_form_item;
    --
    elsif (nvl(p_template_item_id, hr_api.g_number) <> hr_api.g_number) then
      --
      open csr_template_item;
      fetch csr_template_item into l_item_type;
      --
      if csr_template_item%notfound then
        --
        -- The template item id is invalid therefore we must error
        --
        close csr_template_item;
        fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE ', l_proc);
        fnd_message.set_token('STEP ', '20');
        fnd_message.raise_error;
      end if;
      hr_utility.set_location(l_proc,40);
      close csr_template_item;
    --
    elsif (nvl(p_template_item_context_id, hr_api.g_number) <> hr_api.g_number) then
      --
      open csr_template_item_context;
      fetch csr_template_item_context into l_item_type;
      --
      if csr_template_item_context%notfound then
        --
        -- The template item context id is invalid therefore we must error
        --
        close csr_template_item_context;
        fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE ', l_proc);
        fnd_message.set_token('STEP ', '30');
        fnd_message.raise_error;
      end if;
      hr_utility.set_location(l_proc,50);
      close csr_template_item_context;
    --
    end if;
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    hr_itp_bus.g_form_item_id             := p_form_item_id;
    hr_itp_bus.g_template_item_id         := p_template_item_id;
    hr_itp_bus.g_template_item_context_id := p_template_item_context_id;
    hr_itp_bus.g_item_type                := l_item_type;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 50);
  return l_item_type;
End return_item_type;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_ddf >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Developer Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Developer Descriptive Flexfield structure column and data values
--   are all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Developer Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_ddf
  (p_rec in hr_itp_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.item_property_id is not null)  and (
    nvl(hr_itp_shd.g_old_rec.information_formula_id, hr_api.g_number) <>
    nvl(p_rec.information_formula_id, hr_api.g_number)  or
    nvl(hr_itp_shd.g_old_rec.information_parameter_item_id1, hr_api.g_number)
<>
    nvl(p_rec.information_parameter_item_id1, hr_api.g_number)  or
    nvl(hr_itp_shd.g_old_rec.information_parameter_item_id2, hr_api.g_number)
<>
    nvl(p_rec.information_parameter_item_id2, hr_api.g_number)  or
    nvl(hr_itp_shd.g_old_rec.information_parameter_item_id3, hr_api.g_number)
<>
    nvl(p_rec.information_parameter_item_id3, hr_api.g_number)  or
    nvl(hr_itp_shd.g_old_rec.information_parameter_item_id4, hr_api.g_number)
<>
    nvl(p_rec.information_parameter_item_id4, hr_api.g_number)  or
    nvl(hr_itp_shd.g_old_rec.information_parameter_item_id5, hr_api.g_number)
<>
    nvl(p_rec.information_parameter_item_id5, hr_api.g_number)  or
    nvl(hr_itp_shd.g_old_rec.information_category, hr_api.g_varchar2) <>
    nvl(p_rec.information_category, hr_api.g_varchar2)  or
    nvl(hr_itp_shd.g_old_rec.information1, hr_api.g_varchar2) <>
    nvl(p_rec.information1, hr_api.g_varchar2)  or
    nvl(hr_itp_shd.g_old_rec.information2, hr_api.g_varchar2) <>
    nvl(p_rec.information2, hr_api.g_varchar2)  or
    nvl(hr_itp_shd.g_old_rec.information3, hr_api.g_varchar2) <>
    nvl(p_rec.information3, hr_api.g_varchar2)  or
    nvl(hr_itp_shd.g_old_rec.information4, hr_api.g_varchar2) <>
    nvl(p_rec.information4, hr_api.g_varchar2)  or
    nvl(hr_itp_shd.g_old_rec.information5, hr_api.g_varchar2) <>
    nvl(p_rec.information5, hr_api.g_varchar2)  or
    nvl(hr_itp_shd.g_old_rec.information6, hr_api.g_varchar2) <>
    nvl(p_rec.information6, hr_api.g_varchar2)  or
    nvl(hr_itp_shd.g_old_rec.information7, hr_api.g_varchar2) <>
    nvl(p_rec.information7, hr_api.g_varchar2)  or
    nvl(hr_itp_shd.g_old_rec.information8, hr_api.g_varchar2) <>
    nvl(p_rec.information8, hr_api.g_varchar2)  or
    nvl(hr_itp_shd.g_old_rec.information9, hr_api.g_varchar2) <>
    nvl(p_rec.information9, hr_api.g_varchar2)  or
    nvl(hr_itp_shd.g_old_rec.information10, hr_api.g_varchar2) <>
    nvl(p_rec.information10, hr_api.g_varchar2)  or
    nvl(hr_itp_shd.g_old_rec.information11, hr_api.g_varchar2) <>
    nvl(p_rec.information11, hr_api.g_varchar2)  or
    nvl(hr_itp_shd.g_old_rec.information12, hr_api.g_varchar2) <>
    nvl(p_rec.information12, hr_api.g_varchar2)  or
    nvl(hr_itp_shd.g_old_rec.information13, hr_api.g_varchar2) <>
    nvl(p_rec.information13, hr_api.g_varchar2)  or
    nvl(hr_itp_shd.g_old_rec.information14, hr_api.g_varchar2) <>
    nvl(p_rec.information14, hr_api.g_varchar2)  or
    nvl(hr_itp_shd.g_old_rec.information15, hr_api.g_varchar2) <>
    nvl(p_rec.information15, hr_api.g_varchar2)  or
    nvl(hr_itp_shd.g_old_rec.information16, hr_api.g_varchar2) <>
    nvl(p_rec.information16, hr_api.g_varchar2)  or
    nvl(hr_itp_shd.g_old_rec.information17, hr_api.g_varchar2) <>
    nvl(p_rec.information17, hr_api.g_varchar2)  or
    nvl(hr_itp_shd.g_old_rec.information18, hr_api.g_varchar2) <>
    nvl(p_rec.information18, hr_api.g_varchar2)  or
    nvl(hr_itp_shd.g_old_rec.information19, hr_api.g_varchar2) <>
    nvl(p_rec.information19, hr_api.g_varchar2)  or
    nvl(hr_itp_shd.g_old_rec.information20, hr_api.g_varchar2) <>
    nvl(p_rec.information20, hr_api.g_varchar2)  or
    nvl(hr_itp_shd.g_old_rec.information21, hr_api.g_varchar2) <>
    nvl(p_rec.information21, hr_api.g_varchar2)  or
    nvl(hr_itp_shd.g_old_rec.information22, hr_api.g_varchar2) <>
    nvl(p_rec.information22, hr_api.g_varchar2)  or
    nvl(hr_itp_shd.g_old_rec.information23, hr_api.g_varchar2) <>
    nvl(p_rec.information23, hr_api.g_varchar2)  or
    nvl(hr_itp_shd.g_old_rec.information24, hr_api.g_varchar2) <>
    nvl(p_rec.information24, hr_api.g_varchar2)  or
    nvl(hr_itp_shd.g_old_rec.information25, hr_api.g_varchar2) <>
    nvl(p_rec.information25, hr_api.g_varchar2)  or
    nvl(hr_itp_shd.g_old_rec.information26, hr_api.g_varchar2) <>
    nvl(p_rec.information26, hr_api.g_varchar2)  or
    nvl(hr_itp_shd.g_old_rec.information27, hr_api.g_varchar2) <>
    nvl(p_rec.information27, hr_api.g_varchar2)  or
    nvl(hr_itp_shd.g_old_rec.information28, hr_api.g_varchar2) <>
    nvl(p_rec.information28, hr_api.g_varchar2)  or
    nvl(hr_itp_shd.g_old_rec.information29, hr_api.g_varchar2) <>
    nvl(p_rec.information29, hr_api.g_varchar2)  or
    nvl(hr_itp_shd.g_old_rec.information30, hr_api.g_varchar2) <>
    nvl(p_rec.information30, hr_api.g_varchar2) )
    or (p_rec.item_property_id is null) ) then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'HR_ITEM_PROPERTIES'
      ,p_attribute_category              => p_rec.information_category
      ,p_attribute1_name                 => 'INFORMATION1'
      ,p_attribute1_value                => p_rec.information1
      ,p_attribute2_name                 => 'INFORMATION2'
      ,p_attribute2_value                => p_rec.information2
      ,p_attribute3_name                 => 'INFORMATION3'
      ,p_attribute3_value                => p_rec.information3
      ,p_attribute4_name                 => 'INFORMATION4'
      ,p_attribute4_value                => p_rec.information4
      ,p_attribute5_name                 => 'INFORMATION5'
      ,p_attribute5_value                => p_rec.information5
      ,p_attribute6_name                 => 'INFORMATION6'
      ,p_attribute6_value                => p_rec.information6
      ,p_attribute7_name                 => 'INFORMATION7'
      ,p_attribute7_value                => p_rec.information7
      ,p_attribute8_name                 => 'INFORMATION8'
      ,p_attribute8_value                => p_rec.information8
      ,p_attribute9_name                 => 'INFORMATION9'
      ,p_attribute9_value                => p_rec.information9
      ,p_attribute10_name                => 'INFORMATION10'
      ,p_attribute10_value               => p_rec.information10
      ,p_attribute11_name                => 'INFORMATION11'
      ,p_attribute11_value               => p_rec.information11
      ,p_attribute12_name                => 'INFORMATION12'
      ,p_attribute12_value               => p_rec.information12
      ,p_attribute13_name                => 'INFORMATION13'
      ,p_attribute13_value               => p_rec.information13
      ,p_attribute14_name                => 'INFORMATION14'
      ,p_attribute14_value               => p_rec.information14
      ,p_attribute15_name                => 'INFORMATION15'
      ,p_attribute15_value               => p_rec.information15
      ,p_attribute16_name                => 'INFORMATION16'
      ,p_attribute16_value               => p_rec.information16
      ,p_attribute17_name                => 'INFORMATION17'
      ,p_attribute17_value               => p_rec.information17
      ,p_attribute18_name                => 'INFORMATION18'
      ,p_attribute18_value               => p_rec.information18
      ,p_attribute19_name                => 'INFORMATION19'
      ,p_attribute19_value               => p_rec.information19
      ,p_attribute20_name                => 'INFORMATION20'
      ,p_attribute20_value               => p_rec.information20
      ,p_attribute21_name                => 'INFORMATION21'
      ,p_attribute21_value               => p_rec.information21
      ,p_attribute22_name                => 'INFORMATION22'
      ,p_attribute22_value               => p_rec.information22
      ,p_attribute23_name                => 'INFORMATION23'
      ,p_attribute23_value               => p_rec.information23
      ,p_attribute24_name                => 'INFORMATION24'
      ,p_attribute24_value               => p_rec.information24
      ,p_attribute25_name                => 'INFORMATION25'
      ,p_attribute25_value               => p_rec.information25
      ,p_attribute26_name                => 'INFORMATION26'
      ,p_attribute26_value               => p_rec.information26
      ,p_attribute27_name                => 'INFORMATION27'
      ,p_attribute27_value               => p_rec.information27
      ,p_attribute28_name                => 'INFORMATION28'
      ,p_attribute28_value               => p_rec.information28
      ,p_attribute29_name                => 'INFORMATION29'
      ,p_attribute29_value               => p_rec.information29
      ,p_attribute30_name                => 'INFORMATION30'
      ,p_attribute30_value               => p_rec.information30
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
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
  ,p_rec in hr_itp_shd.g_rec_type
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
  IF NOT hr_itp_shd.api_updating
      (p_item_property_id                     => p_rec.item_property_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  IF (nvl(p_rec.form_item_id,hr_api.g_number) <>
      nvl(hr_itp_shd.g_old_rec.form_item_id,hr_api.g_number)
     ) THEN
     l_argument := 'form_item_id';
     RAISE l_error;
  END IF;
  --
  IF (nvl(p_rec.template_item_id,hr_api.g_number) <>
      nvl(hr_itp_shd.g_old_rec.template_item_id,hr_api.g_number)
     ) THEN
     l_argument := 'template_item_id';
     RAISE l_error;
  END IF;
  --
  IF (nvl(p_rec.template_item_context_id,hr_api.g_number) <>
      nvl(hr_itp_shd.g_old_rec.template_item_context_id,hr_api.g_number)
     ) THEN
     l_argument := 'template_item_context_id';
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
-- |--------------------< chk_form_template_and_context >---------------------|
-- ----------------------------------------------------------------------------
Procedure chk_form_template_and_context
  (p_effective_date                       in date
  ,p_item_property_id                     in number
  ,p_form_item_id                         in number
  ,p_template_item_id                     in number
  ,p_template_item_context_id             in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_form_template_and_context';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- One and only one of form_item_id, template_item_id and
  -- template_item_context_id must be given
  --
  if not (  (   p_form_item_id is not null
            and p_template_item_id is null
            and p_template_item_context_id is null)
         or (   p_form_item_id is null
            and p_template_item_id is not null
            and p_template_item_context_id is null)
         or (   p_form_item_id is null
            and p_template_item_id is null
            and p_template_item_context_id is not null)) then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_form_template_and_context;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_form_item_id >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_form_item_id
  (p_effective_date                       in date
  ,p_item_property_id                     in number
  ,p_form_item_id                         in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_form_item_id';
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
End chk_form_item_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_template_item_id >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_template_item_id
  (p_effective_date                       in date
  ,p_item_property_id                     in number
  ,p_template_item_id                     in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_template_item_id';
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
End chk_template_item_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_template_item_context_id >---------------------|
-- ----------------------------------------------------------------------------
Procedure chk_template_item_context_id
  (p_effective_date                       in date
  ,p_item_property_id                     in number
  ,p_template_item_context_id             in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_template_item_context_id';
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
End chk_template_item_context_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_alignment >-----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_alignment
  (p_effective_date                       in date
  ,p_object_version_number                in number
  ,p_item_property_id                     in number
  ,p_alignment                            in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_alignment';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory arguments have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'effective_date'
    ,p_argument_value               => p_effective_date
    );
  --
  l_api_updating := hr_itp_shd.api_updating
    (p_item_property_id             => p_item_property_id
    ,p_object_version_number        => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and nvl(hr_itp_shd.g_old_rec.alignment,hr_api.g_number) <>
            nvl(p_alignment,hr_api.g_number))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,30);
    --
    if (p_alignment is not null) then
      --
      hr_utility.set_location(l_proc,40);
      --
      -- Must exist in hr_standard_lookups where lookup_type is
      -- ALIGNMENTS
      --
      if hr_api.not_exists_in_hrstanlookups
        (p_effective_date               => p_effective_date
        ,p_lookup_type                  => 'ALIGNMENTS'
        ,p_lookup_code                  => p_alignment
        ) then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','10');
        fnd_message.raise_error;
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_alignment;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_bevel >-------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_bevel
  (p_effective_date                       in date
  ,p_object_version_number                in number
  ,p_item_property_id                     in number
  ,p_bevel                                in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_bevel';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory arguments have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'effective_date'
    ,p_argument_value               => p_effective_date
    );
  --
  l_api_updating := hr_itp_shd.api_updating
    (p_item_property_id             => p_item_property_id
    ,p_object_version_number        => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and nvl(hr_itp_shd.g_old_rec.bevel,hr_api.g_number) <>
            nvl(p_bevel,hr_api.g_number))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,30);
    --
    if (p_bevel is not null) then
      --
      hr_utility.set_location(l_proc,40);
      --
      -- Must exist in hr_standard_lookups where lookup_type is
      -- BORDER_BEVELS
      --
      if hr_api.not_exists_in_hrstanlookups
        (p_effective_date               => p_effective_date
        ,p_lookup_type                  => 'BORDER_BEVELS'
        ,p_lookup_code                  => p_bevel
        ) then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','10');
        fnd_message.raise_error;
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_bevel;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_case_restriction >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_case_restriction
  (p_effective_date                       in date
  ,p_object_version_number                in number
  ,p_item_property_id                     in number
  ,p_case_restriction                     in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_case_restriction';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory arguments have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'effective_date'
    ,p_argument_value               => p_effective_date
    );
  --
  l_api_updating := hr_itp_shd.api_updating
    (p_item_property_id             => p_item_property_id
    ,p_object_version_number        => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and nvl(hr_itp_shd.g_old_rec.case_restriction,hr_api.g_number) <>
            nvl(p_case_restriction,hr_api.g_number))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,30);
    --
    if (p_case_restriction is not null) then
      --
      hr_utility.set_location(l_proc,40);
      --
      -- Must exist in hr_standard_lookups where lookup_type is
      -- CASE_RESTRICTIONS
      --
      if hr_api.not_exists_in_hrstanlookups
        (p_effective_date               => p_effective_date
        ,p_lookup_type                  => 'CASE_RESTRICTIONS'
        ,p_lookup_code                  => p_case_restriction
        ) then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','10');
        fnd_message.raise_error;
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_case_restriction;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_enabled >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_enabled
  (p_effective_date                       in date
  ,p_object_version_number                in number
  ,p_item_property_id                     in number
  ,p_enabled                              in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_enabled';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory arguments have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'effective_date'
    ,p_argument_value               => p_effective_date
    );
  --
  l_api_updating := hr_itp_shd.api_updating
    (p_item_property_id             => p_item_property_id
    ,p_object_version_number        => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and nvl(hr_itp_shd.g_old_rec.enabled,hr_api.g_number) <>
            nvl(p_enabled,hr_api.g_number))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,30);
    --
    if (p_enabled is not null) then
      --
      hr_utility.set_location(l_proc,40);
      --
      -- Must exist in hr_standard_lookups where lookup_type is
      -- PROPERTY_TRUE_OR_FALSE
      --
      if hr_api.not_exists_in_hrstanlookups
        (p_effective_date               => p_effective_date
        ,p_lookup_type                  => 'PROPERTY_TRUE_OR_FALSE'
        ,p_lookup_code                  => p_enabled
        ) then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','10');
        fnd_message.raise_error;
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_enabled;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_format_mask >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_format_mask
  (p_effective_date                       in date
  ,p_item_property_id                     in number
  ,p_format_mask                          in varchar2
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_format_mask';
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
End chk_format_mask;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_height >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_height
  (p_effective_date               in date
  ,p_item_property_id             in number
  ,p_height                       in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_height';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Height must be greater than or equal to zero, if given
  --
  if (p_height is not null) then
    --
    hr_utility.set_location(l_proc,30);
    --
    if (p_height < 0) then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_height;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_information_formula_id >----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_information_formula_id
  (p_effective_date               in date
  ,p_object_version_number        in number
  ,p_item_property_id             in number
  ,p_information_formula_id       in number
  ) is
  --
  cursor csr_formula is
    select fft.formula_type_name
      from ff_formula_types fft
          ,ff_formulas fml
     where fft.formula_type_id = fml.formula_type_id
       and fml.formula_id = p_information_formula_id;
  --
  l_proc                         varchar2(72) := g_package || 'chk_information_formula_id';
  l_api_updating                 boolean;
  l_formula_type_name            varchar2(80);
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  l_api_updating := hr_itp_shd.api_updating
    (p_item_property_id             => p_item_property_id
     ,p_object_version_number       => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and nvl(hr_itp_shd.g_old_rec.information_formula_id,hr_api.g_number) <>
            nvl(p_information_formula_id,hr_api.g_number))
     or (NOT l_api_updating)) then
    --
    if p_information_formula_id is not null then
      --
      -- Check formula exists
      --
      open csr_formula;
      fetch csr_formula into l_formula_type_name;
      if csr_formula%notfound then
        close csr_formula;
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','10');
        fnd_message.raise_error;
      end if;
      close csr_formula;
      --
      -- Check formula is of type 'Template Information' if specified
      --
      if nvl(l_formula_type_name,hr_api.g_varchar2) <> 'Template Information' then
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
End chk_information_formula_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_information_param_item_ids >--------------------|
-- ----------------------------------------------------------------------------
Procedure chk_information_param_item_ids
  (p_effective_date               in date
  ,p_item_property_id             in number
  ,p_information_formula_id       in number
  ,p_information_param_item_id1   in number
  ,p_information_param_item_id2   in number
  ,p_information_param_item_id3   in number
  ,p_information_param_item_id4   in number
  ,p_information_param_item_id5   in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_information_param_item_ids';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check item ids have only been specified if the formula has
  --
  if p_information_formula_id is null then
    if (  p_information_param_item_id1 is not null
       or p_information_param_item_id2 is not null
       or p_information_param_item_id3 is not null
       or p_information_param_item_id4 is not null
       or p_information_param_item_id5 is not null) then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_information_param_item_ids;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_insert_allowed >--------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_insert_allowed
  (p_effective_date                       in date
  ,p_object_version_number                in number
  ,p_item_property_id                     in number
  ,p_insert_allowed                       in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_insert_allowed';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory arguments have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'effective_date'
    ,p_argument_value               => p_effective_date
    );
  --
  l_api_updating := hr_itp_shd.api_updating
    (p_item_property_id             => p_item_property_id
    ,p_object_version_number        => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and nvl(hr_itp_shd.g_old_rec.insert_allowed,hr_api.g_number) <>
            nvl(p_insert_allowed,hr_api.g_number))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,30);
    --
    if (p_insert_allowed is not null) then
      --
      hr_utility.set_location(l_proc,40);
      --
      -- Must exist in hr_standard_lookups where lookup_type is
      -- PROPERTY_TRUE_OR_FALSE
      --
      if hr_api.not_exists_in_hrstanlookups
        (p_effective_date               => p_effective_date
        ,p_lookup_type                  => 'PROPERTY_TRUE_OR_FALSE'
        ,p_lookup_code                  => p_insert_allowed
        ) then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','10');
        fnd_message.raise_error;
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_insert_allowed;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_prompt_alignment_offset >----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_prompt_alignment_offset
  (p_effective_date               in date
  ,p_item_property_id             in number
  ,p_prompt_alignment_offset      in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_prompt_alignment_offset';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_prompt_alignment_offset;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_prompt_display_style >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_prompt_display_style
  (p_effective_date                       in date
  ,p_object_version_number                in number
  ,p_item_property_id                     in number
  ,p_prompt_display_style                 in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_prompt_display_style';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory arguments have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'effective_date'
    ,p_argument_value               => p_effective_date
    );
  --
  l_api_updating := hr_itp_shd.api_updating
    (p_item_property_id             => p_item_property_id
    ,p_object_version_number        => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and nvl(hr_itp_shd.g_old_rec.prompt_display_style,hr_api.g_number) <>
            nvl(p_prompt_display_style,hr_api.g_number))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,30);
    --
    if (p_prompt_display_style is not null) then
      --
      hr_utility.set_location(l_proc,40);
      --
      -- Must exist in hr_standard_lookups where lookup_type is
      -- PROMTP_DISPLAY_STYLES
      --
      if hr_api.not_exists_in_hrstanlookups
        (p_effective_date               => p_effective_date
        ,p_lookup_type                  => 'PROMPT_DISPLAY_STYLES'
        ,p_lookup_code                  => p_prompt_display_style
        ) then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','10');
        fnd_message.raise_error;
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_prompt_display_style;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_prompt_edge >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_prompt_edge
  (p_effective_date                       in date
  ,p_object_version_number                in number
  ,p_item_property_id                     in number
  ,p_prompt_edge                          in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_prompt_edge';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory arguments have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'effective_date'
    ,p_argument_value               => p_effective_date
    );
  --
  l_api_updating := hr_itp_shd.api_updating
    (p_item_property_id             => p_item_property_id
    ,p_object_version_number        => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and nvl(hr_itp_shd.g_old_rec.prompt_edge,hr_api.g_number) <>
            nvl(p_prompt_edge,hr_api.g_number))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,30);
    --
    if (p_prompt_edge is not null) then
      --
      hr_utility.set_location(l_proc,40);
      --
      -- Must exist in hr_standard_lookups where lookup_type is
      -- PROMPT_EDGES
      --
      if hr_api.not_exists_in_hrstanlookups
        (p_effective_date               => p_effective_date
        ,p_lookup_type                  => 'PROMPT_EDGES'
        ,p_lookup_code                  => p_prompt_edge
        ) then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','10');
        fnd_message.raise_error;
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_prompt_edge;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_prompt_edge_alignment >----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_prompt_edge_alignment
  (p_effective_date                       in date
  ,p_object_version_number                in number
  ,p_item_property_id                     in number
  ,p_prompt_edge_alignment                in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_prompt_edge_alignment';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory arguments have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'effective_date'
    ,p_argument_value               => p_effective_date
    );
  --
  l_api_updating := hr_itp_shd.api_updating
    (p_item_property_id             => p_item_property_id
    ,p_object_version_number        => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and nvl(hr_itp_shd.g_old_rec.prompt_edge_alignment,hr_api.g_number) <>
            nvl(p_prompt_edge_alignment,hr_api.g_number))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,30);
    --
    if (p_prompt_edge_alignment is not null) then
      --
      hr_utility.set_location(l_proc,40);
      --
      -- Must exist in hr_standard_lookups where lookup_type is
      -- PROMPT_EDGE_ALIGNMENTS
      --
      if hr_api.not_exists_in_hrstanlookups
        (p_effective_date               => p_effective_date
        ,p_lookup_type                  => 'PROMPT_EDGE_ALIGNMENTS'
        ,p_lookup_code                  => p_prompt_edge_alignment
        ) then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','10');
        fnd_message.raise_error;
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_prompt_edge_alignment;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_prompt_edge_offset >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_prompt_edge_offset
  (p_effective_date               in date
  ,p_item_property_id             in number
  ,p_prompt_edge_offset           in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_prompt_edge_offset';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_prompt_edge_offset;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_prompt_text_alignment >----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_prompt_text_alignment
  (p_effective_date                       in date
  ,p_object_version_number                in number
  ,p_item_property_id                     in number
  ,p_prompt_text_alignment                in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_prompt_text_alignment';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory arguments have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'effective_date'
    ,p_argument_value               => p_effective_date
    );
  --
  l_api_updating := hr_itp_shd.api_updating
    (p_item_property_id             => p_item_property_id
    ,p_object_version_number        => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and nvl(hr_itp_shd.g_old_rec.prompt_text_alignment,hr_api.g_number) <>
            nvl(p_prompt_text_alignment,hr_api.g_number))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,30);
    --
    if (p_prompt_text_alignment is not null) then
      --
      hr_utility.set_location(l_proc,40);
      --
      -- Must exist in hr_standard_lookups where lookup_type is
      -- PROMPT_TEXT_ALIGNMENTS
      --
      if hr_api.not_exists_in_hrstanlookups
        (p_effective_date               => p_effective_date
        ,p_lookup_type                  => 'PROMPT_TEXT_ALIGNMENTS'
        ,p_lookup_code                  => p_prompt_text_alignment
        ) then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','10');
        fnd_message.raise_error;
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_prompt_text_alignment;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_query_allowed >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_query_allowed
  (p_effective_date                       in date
  ,p_object_version_number                in number
  ,p_item_property_id                     in number
  ,p_query_allowed                        in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_query_allowed';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory arguments have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'effective_date'
    ,p_argument_value               => p_effective_date
    );
  --
  l_api_updating := hr_itp_shd.api_updating
    (p_item_property_id             => p_item_property_id
    ,p_object_version_number        => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and nvl(hr_itp_shd.g_old_rec.query_allowed,hr_api.g_number) <>
            nvl(p_query_allowed,hr_api.g_number))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,30);
    --
    if (p_query_allowed is not null) then
      --
      hr_utility.set_location(l_proc,40);
      --
      -- Must exist in hr_standard_lookups where lookup_type is
      -- PROPERTY_TRUE_OR_FALSE
      --
      if hr_api.not_exists_in_hrstanlookups
        (p_effective_date               => p_effective_date
        ,p_lookup_type                  => 'PROPERTY_TRUE_OR_FALSE'
        ,p_lookup_code                  => p_query_allowed
        ) then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','10');
        fnd_message.raise_error;
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_query_allowed;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_required >-----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_required
  (p_effective_date                       in date
  ,p_object_version_number                in number
  ,p_item_property_id                     in number
  ,p_required                             in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_required';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory arguments have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'effective_date'
    ,p_argument_value               => p_effective_date
    );
  --
  l_api_updating := hr_itp_shd.api_updating
    (p_item_property_id             => p_item_property_id
    ,p_object_version_number        => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and nvl(hr_itp_shd.g_old_rec.required,hr_api.g_number) <>
            nvl(p_required,hr_api.g_number))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,30);
    --
    if (p_required is not null) then
      --
      hr_utility.set_location(l_proc,40);
      --
      -- Must exist in hr_standard_lookups where lookup_type is
      -- PROPERTY_TRUE_OR_FALSE
      --
      if hr_api.not_exists_in_hrstanlookups
        (p_effective_date               => p_effective_date
        ,p_lookup_type                  => 'PROPERTY_TRUE_OR_FALSE'
        ,p_lookup_code                  => p_required
        ) then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','10');
        fnd_message.raise_error;
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_required;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_update_allowed >--------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_update_allowed
  (p_effective_date                       in date
  ,p_object_version_number                in number
  ,p_item_property_id                     in number
  ,p_update_allowed                       in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_update_allowed';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory arguments have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'effective_date'
    ,p_argument_value               => p_effective_date
    );
  --
  l_api_updating := hr_itp_shd.api_updating
    (p_item_property_id             => p_item_property_id
    ,p_object_version_number        => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and nvl(hr_itp_shd.g_old_rec.update_allowed,hr_api.g_number) <>
            nvl(p_update_allowed,hr_api.g_number))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,30);
    --
    if (p_update_allowed is not null) then
      --
      hr_utility.set_location(l_proc,40);
      --
      -- Must exist in hr_standard_lookups where lookup_type is
      -- PROPERTY_TRUE_OR_FALSE
      --
      if hr_api.not_exists_in_hrstanlookups
        (p_effective_date               => p_effective_date
        ,p_lookup_type                  => 'PROPERTY_TRUE_OR_FALSE'
        ,p_lookup_code                  => p_update_allowed
        ) then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','10');
        fnd_message.raise_error;
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_update_allowed;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_validation_formula_id >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_validation_formula_id
  (p_effective_date               in date
  ,p_object_version_number        in number
  ,p_item_property_id             in number
  ,p_validation_formula_id        in number
  ) is
  --
  cursor csr_formula is
    select fft.formula_type_name
      from ff_formula_types fft
          ,ff_formulas fml
     where fft.formula_type_id = fml.formula_type_id
       and fml.formula_id = p_validation_formula_id;
  --
  l_proc                         varchar2(72) := g_package || 'chk_validation_formula_id';
  l_api_updating                 boolean;
  l_formula_type_name            varchar2(80);
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  l_api_updating := hr_itp_shd.api_updating
    (p_item_property_id             => p_item_property_id
    ,p_object_version_number        => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and nvl(hr_itp_shd.g_old_rec.validation_formula_id,hr_api.g_number) <>
            nvl(p_validation_formula_id,hr_api.g_number))
     or (NOT l_api_updating)) then
    --
    if p_validation_formula_id is not null then
      --
      -- Check formula exists
      --
      open csr_formula;
      fetch csr_formula into l_formula_type_name;
      if csr_formula%notfound then
        close csr_formula;
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','10');
        fnd_message.raise_error;
      end if;
      close csr_formula;
      --
      -- Check formula is of type 'Template Validation' if specified
      --
      if nvl(l_formula_type_name,hr_api.g_varchar2) <> 'Template Validation' then
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
End chk_validation_formula_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_validation_param_item_ids >---------------------|
-- ----------------------------------------------------------------------------
Procedure chk_validation_param_item_ids
  (p_effective_date               in date
  ,p_item_property_id             in number
  ,p_validation_formula_id        in number
  ,p_validation_param_item_id1    in number
  ,p_validation_param_item_id2    in number
  ,p_validation_param_item_id3    in number
  ,p_validation_param_item_id4    in number
  ,p_validation_param_item_id5    in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_validation_param_item_ids';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check item ids have only been specified if the formula has
  --
  if p_validation_formula_id is null then
    if (  p_validation_param_item_id1 is not null
       or p_validation_param_item_id2 is not null
       or p_validation_param_item_id3 is not null
       or p_validation_param_item_id4 is not null
       or p_validation_param_item_id5 is not null) then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_validation_param_item_ids;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_visible >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_visible
  (p_effective_date                       in date
  ,p_object_version_number                in number
  ,p_item_property_id                     in number
  ,p_visible                              in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_visible';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory arguments have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'effective_date'
    ,p_argument_value               => p_effective_date
    );
  --
  l_api_updating := hr_itp_shd.api_updating
    (p_item_property_id             => p_item_property_id
    ,p_object_version_number        => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and nvl(hr_itp_shd.g_old_rec.visible,hr_api.g_number) <>
            nvl(p_visible,hr_api.g_number))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,30);
    --
    if (p_visible is not null) then
      --
      hr_utility.set_location(l_proc,40);
      --
      -- Must exist in hr_standard_lookups where lookup_type is
      -- PROPERTY_TRUE_OR_FALSE
      --
      if hr_api.not_exists_in_hrstanlookups
        (p_effective_date               => p_effective_date
        ,p_lookup_type                  => 'PROPERTY_TRUE_OR_FALSE'
        ,p_lookup_code                  => p_visible
        ) then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','10');
        fnd_message.raise_error;
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_visible;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_width >-------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_width
  (p_effective_date               in date
  ,p_item_property_id             in number
  ,p_width                        in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_width';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Width must be greater than or equal to zero, if given
  --
  if (p_width is not null) then
    --
    hr_utility.set_location(l_proc,30);
    --
    if (p_width < 0) then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_width;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_x_position >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_x_position
  (p_effective_date               in date
  ,p_item_property_id             in number
  ,p_x_position                   in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_x_position';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- X position must be greater than or equal to zero,if given
  --
  if (p_x_position is not null) then
    --
    hr_utility.set_location(l_proc,30);
    --
    if (p_x_position < 0) then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_x_position;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_y_position >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_y_position
  (p_effective_date               in date
  ,p_item_property_id             in number
  ,p_y_position                   in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_y_position';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Y position must be greater than or equal to zero, if given
  --
  if (p_y_position is not null) then
    --
    hr_utility.set_location(l_proc,30);
    --
    if (p_y_position < 0) then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_y_position;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_item_type_dependencies >----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_item_type_dependencies
  (p_effective_date               in date
  ,p_rec                          in hr_itp_shd.g_rec_type
  ) is
  --
  l_proc                         varchar2(72) := g_package||'chk_item_type_dependencies';
  l_api_updating                 boolean;
  l_item_type                    varchar2(30);
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  l_item_type := return_item_type
    (p_form_item_id                 => p_rec.form_item_id
    ,p_template_item_id             => p_rec.template_item_id
    ,p_template_item_context_id     => p_rec.template_item_context_id
    );
  hr_utility.set_location(l_proc,20);
  --
  if p_rec.alignment is not null then
    if l_item_type not in ('DISPLAY_ITEM','TEXT_ITEM') then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(l_proc,30);
  --
  if p_rec.bevel is not null then
    if l_item_type not in ('CHART_ITEM','USER_AREA','IMAGE','TEXT_ITEM') then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','20');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(l_proc,40);
  --
  if p_rec.case_restriction is not null then
    if l_item_type not in ('TEXT_ITEM') then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','30');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(l_proc,50);
  --
  if p_rec.enabled is not null then
    if l_item_type not in ('BUTTON','CHECKBOX','IMAGE','LIST','OLE_OBJECT','RADIO_BUTTON','TEXT_ITEM','USER_AREA','VBX_CONTROL') then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','40');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(l_proc,60);
  --
  if p_rec.format_mask is not null then
    if l_item_type not in ('TEXT_ITEM') then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','50');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(l_proc,70);
  --
  if p_rec.height is not null then
    if l_item_type not in ('BUTTON','CHART_ITEM','CHECKBOX','DISPLAY_ITEM','IMAGE','LIST','OLE_OBJECT','RADIO_BUTTON','TEXT_ITEM','USER_AREA','VBX_CONTROL') then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','53');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(l_proc,73);
  --
  if p_rec.information_formula_id is not null then
    if l_item_type not in ('BUTTON','CHART_ITEM','CHECKBOX','DISPLAY_ITEM','IMAGE','LIST','OLE_OBJECT','RADIO_BUTTON','TEXT_ITEM','USER_AREA','VBX_CONTROL') then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','56');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(l_proc,76);
  --
  if p_rec.insert_allowed is not null then
    if l_item_type not in ('CHECKBOX','IMAGE','LIST','RADIO_BUTTON','TEXT_ITEM') then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','60');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(l_proc,80);
  --
  if p_rec.next_navigation_item_id is not null then
    if l_item_type not in ('BUTTON','CHECKBOX','IMAGE','LIST','OLE_OBJECT','RADIO_BUTTON','TEXT_ITEM','USER_AREA','VBX_CONTROL') then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','61');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(l_proc,81);
  --
  if p_rec.previous_navigation_item_id is not null then
    if l_item_type not in ('BUTTON','CHECKBOX','IMAGE','LIST','OLE_OBJECT','RADIO_BUTTON','TEXT_ITEM','USER_AREA','VBX_CONTROL') then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','62');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(l_proc,82);
  --
  if p_rec.prompt_alignment_offset is not null then
    if l_item_type not in ('BUTTON','CHART_ITEM','CHECKBOX','DISPLAY_ITEM','IMAGE','LIST','OLE_OBJECT','RADIO_BUTTON','TEXT_ITEM','USER_AREA','VBX_CONTROL') then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','63');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(l_proc,83);
  --
  if p_rec.prompt_display_style is not null then
    if l_item_type not in ('BUTTON','CHART_ITEM','CHECKBOX','DISPLAY_ITEM','IMAGE','LIST','OLE_OBJECT','RADIO_BUTTON','TEXT_ITEM','USER_AREA','VBX_CONTROL') then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','64');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(l_proc,84);
  --
  if p_rec.prompt_edge is not null then
    if l_item_type not in ('BUTTON','CHART_ITEM','CHECKBOX','DISPLAY_ITEM','IMAGE','LIST','OLE_OBJECT','RADIO_BUTTON','TEXT_ITEM','USER_AREA','VBX_CONTROL') then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','65');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(l_proc,85);
  --
  if p_rec.prompt_edge_alignment is not null then
    if l_item_type not in ('BUTTON','CHART_ITEM','CHECKBOX','DISPLAY_ITEM','IMAGE','LIST','OLE_OBJECT','RADIO_BUTTON','TEXT_ITEM','USER_AREA','VBX_CONTROL') then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','66');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(l_proc,86);
  --
  if p_rec.prompt_edge_offset is not null then
    if l_item_type not in ('BUTTON','CHART_ITEM','CHECKBOX','DISPLAY_ITEM','IMAGE','LIST','OLE_OBJECT','RADIO_BUTTON','TEXT_ITEM','USER_AREA','VBX_CONTROL') then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','67');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(l_proc,87);
  --
  if p_rec.prompt_text_alignment is not null then
    if l_item_type not in ('BUTTON','CHART_ITEM','CHECKBOX','DISPLAY_ITEM','IMAGE','LIST','OLE_OBJECT','RADIO_BUTTON','TEXT_ITEM','USER_AREA','VBX_CONTROL') then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','68');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(l_proc,88);
  --
  if p_rec.query_allowed is not null then
    if l_item_type not in ('CHECKBOX','DISPLAY_ITEM','LIST','OLE_OBJECT','RADIO_BUTTON','TEXT_ITEM','USER_AREA','VBX_CONTROL') then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','70');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(l_proc,90);
  --
  if p_rec.required is not null then
    if l_item_type not in ('CHECKBOX','LIST','TEXT_ITEM') then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','80');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(l_proc,100);
  --
  if p_rec.update_allowed is not null then
    if l_item_type not in ('CHECKBOX','DISPLAY_ITEM','LIST','OLE_OBJECT','RADIO_BUTTON','TEXT_ITEM','USER_AREA','VBX_CONTROL') then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','90');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(l_proc,110);
  --
  if p_rec.validation_formula_id is not null then
    if l_item_type not in ('CHECKBOX','DISPLAY_ITEM','LIST','OLE_OBJECT','RADIO_BUTTON','TEXT_ITEM','USER_AREA','VBX_CONTROL') then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','100');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(l_proc,120);
  --
  if p_rec.visible is not null then
    if l_item_type not in ('BUTTON','CHART_ITEM','CHECKBOX','DISPLAY_ITEM','IMAGE','LIST','OLE_OBJECT','RADIO_BUTTON','TEXT_ITEM','USER_AREA','VBX_CONTROL') then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','110');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(l_proc,130);
  --
  if p_rec.width is not null then
    if l_item_type not in ('BUTTON','CHART_ITEM','CHECKBOX','DISPLAY_ITEM','IMAGE','LIST','OLE_OBJECT','RADIO_BUTTON','TEXT_ITEM','USER_AREA','VBX_CONTROL') then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','120');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(l_proc,140);
  --
  if p_rec.x_position is not null then
    if l_item_type not in ('BUTTON','CHART_ITEM','CHECKBOX','DISPLAY_ITEM','IMAGE','LIST','OLE_OBJECT','RADIO_BUTTON','SCROLLBAR','TEXT_ITEM','USER_AREA','VBX_CONTROL') then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','130');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(l_proc,150);
  --
  if p_rec.y_position is not null then
    if l_item_type not in ('BUTTON','CHART_ITEM','CHECKBOX','DISPLAY_ITEM','IMAGE','LIST','OLE_OBJECT','RADIO_BUTTON','SCROLLBAR','TEXT_ITEM','USER_AREA','VBX_CONTROL') then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','140');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(l_proc,160);
  --
  hr_utility.set_location('Leaving:'||l_proc, 1000);
End chk_item_type_dependencies;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_delete >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (p_rec                          in hr_itp_shd.g_rec_type
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
  (p_effective_date               in date
  ,p_rec                          in hr_itp_shd.g_rec_type
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
  chk_form_template_and_context
    (p_effective_date               => p_effective_date
    ,p_item_property_id             => p_rec.item_property_id
    ,p_form_item_id                 => p_rec.form_item_id
    ,p_template_item_id             => p_rec.template_item_id
    ,p_template_item_context_id     => p_rec.template_item_context_id
    );
  --
  chk_form_item_id
    (p_effective_date               => p_effective_date
    ,p_item_property_id             => p_rec.item_property_id
    ,p_form_item_id                 => p_rec.form_item_id
    );
  --
  chk_template_item_id
    (p_effective_date               => p_effective_date
    ,p_item_property_id             => p_rec.item_property_id
    ,p_template_item_id             => p_rec.template_item_id
    );
  --
  chk_template_item_context_id
    (p_effective_date               => p_effective_date
    ,p_item_property_id             => p_rec.item_property_id
    ,p_template_item_context_id     => p_rec.template_item_context_id
    );
  --
  chk_alignment
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_property_id             => p_rec.item_property_id
    ,p_alignment                    => p_rec.alignment
    );
  --
  chk_bevel
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_property_id             => p_rec.item_property_id
    ,p_bevel                        => p_rec.bevel
    );
  --
  chk_case_restriction
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_property_id             => p_rec.item_property_id
    ,p_case_restriction             => p_rec.case_restriction
    );
  --
  chk_enabled
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_property_id             => p_rec.item_property_id
    ,p_enabled                      => p_rec.enabled
    );
  --
  chk_format_mask
    (p_effective_date               => p_effective_date
    ,p_item_property_id             => p_rec.item_property_id
    ,p_format_mask                  => p_rec.format_mask
    );
  --
  chk_height
    (p_effective_date               => p_effective_date
    ,p_item_property_id             => p_rec.item_property_id
    ,p_height                       => p_rec.height
    );
  --
  chk_information_formula_id
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_property_id             => p_rec.item_property_id
    ,p_information_formula_id       => p_rec.information_formula_id
    );
  --
  chk_information_param_item_ids
    (p_effective_date               => p_effective_date
    ,p_item_property_id             => p_rec.item_property_id
    ,p_information_formula_id       => p_rec.information_formula_id
    ,p_information_param_item_id1   => p_rec.information_parameter_item_id1
    ,p_information_param_item_id2   => p_rec.information_parameter_item_id2
    ,p_information_param_item_id3   => p_rec.information_parameter_item_id3
    ,p_information_param_item_id4   => p_rec.information_parameter_item_id4
    ,p_information_param_item_id5   => p_rec.information_parameter_item_id5
    );
  --
  chk_insert_allowed
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_property_id             => p_rec.item_property_id
    ,p_insert_allowed               => p_rec.insert_allowed
    );
  --
  chk_prompt_alignment_offset
    (p_effective_date               => p_effective_date
    ,p_item_property_id             => p_rec.item_property_id
    ,p_prompt_alignment_offset      => p_rec.prompt_alignment_offset
    );
  --
  chk_prompt_display_style
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_property_id             => p_rec.item_property_id
    ,p_prompt_display_style         => p_rec.prompt_display_style
    );
  --
  chk_prompt_edge
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_property_id             => p_rec.item_property_id
    ,p_prompt_edge                  => p_rec.prompt_edge
    );
  --
  chk_prompt_edge_alignment
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_property_id             => p_rec.item_property_id
    ,p_prompt_edge_alignment        => p_rec.prompt_edge_alignment
    );
  --
  chk_prompt_edge_offset
    (p_effective_date               => p_effective_date
    ,p_item_property_id             => p_rec.item_property_id
    ,p_prompt_edge_offset           => p_rec.prompt_edge_offset
    );
  --
  chk_prompt_text_alignment
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_property_id             => p_rec.item_property_id
    ,p_prompt_text_alignment        => p_rec.prompt_text_alignment
    );
  --
  chk_query_allowed
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_property_id             => p_rec.item_property_id
    ,p_query_allowed                => p_rec.query_allowed
    );
  --
  chk_required
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_property_id             => p_rec.item_property_id
    ,p_required                     => p_rec.required
    );
  --
  chk_update_allowed
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_property_id             => p_rec.item_property_id
    ,p_update_allowed               => p_rec.update_allowed
    );
  --
  chk_validation_formula_id
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_property_id             => p_rec.item_property_id
    ,p_validation_formula_id        => p_rec.validation_formula_id
    );
  --
  chk_validation_param_item_ids
    (p_effective_date               => p_effective_date
    ,p_item_property_id             => p_rec.item_property_id
    ,p_validation_formula_id        => p_rec.validation_formula_id
    ,p_validation_param_item_id1    => p_rec.validation_parameter_item_id1
    ,p_validation_param_item_id2    => p_rec.validation_parameter_item_id2
    ,p_validation_param_item_id3    => p_rec.validation_parameter_item_id3
    ,p_validation_param_item_id4    => p_rec.validation_parameter_item_id4
    ,p_validation_param_item_id5    => p_rec.validation_parameter_item_id5
    );
  --
  chk_visible
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_property_id             => p_rec.item_property_id
    ,p_visible                      => p_rec.visible
    );
  --
  chk_width
    (p_effective_date               => p_effective_date
    ,p_item_property_id             => p_rec.item_property_id
    ,p_width                        => p_rec.width
    );
  --
  chk_x_position
    (p_effective_date               => p_effective_date
    ,p_item_property_id             => p_rec.item_property_id
    ,p_x_position                   => p_rec.x_position
    );
  --
  chk_y_position
    (p_effective_date               => p_effective_date
    ,p_item_property_id             => p_rec.item_property_id
    ,p_y_position                   => p_rec.y_position
    );
  --
  chk_item_type_dependencies
    (p_effective_date               => p_effective_date
    ,p_rec                          => p_rec
    );
  --
  chk_prev_and_next_nav_item
    (p_effective_date               => p_effective_date
    ,p_item_property_id             => p_rec.item_property_id
    ,p_form_item_id                 => p_rec.form_item_id
    ,p_template_item_id             => p_rec.template_item_id
    ,p_template_item_context_id     => p_rec.template_item_context_id
    ,p_previous_navigation_item_id  => p_rec.previous_navigation_item_id
    ,p_next_navigation_item_id      => p_rec.next_navigation_item_id
    );
  --
  chk_ddf
    (p_rec                          => p_rec
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in hr_itp_shd.g_rec_type
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
    (p_effective_date               => p_effective_date
    ,p_rec                          => p_rec
    );
  --
  chk_form_template_and_context
    (p_effective_date               => p_effective_date
    ,p_item_property_id             => p_rec.item_property_id
    ,p_form_item_id                 => p_rec.form_item_id
    ,p_template_item_id             => p_rec.template_item_id
    ,p_template_item_context_id     => p_rec.template_item_context_id
    );
  --
  chk_form_item_id
    (p_effective_date               => p_effective_date
    ,p_item_property_id             => p_rec.item_property_id
    ,p_form_item_id                 => p_rec.form_item_id
    );
  --
  chk_template_item_id
    (p_effective_date               => p_effective_date
    ,p_item_property_id             => p_rec.item_property_id
    ,p_template_item_id             => p_rec.template_item_id
    );
  --
  chk_template_item_context_id
    (p_effective_date               => p_effective_date
    ,p_item_property_id             => p_rec.item_property_id
    ,p_template_item_context_id     => p_rec.template_item_context_id
    );
  --
  chk_alignment
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_property_id             => p_rec.item_property_id
    ,p_alignment                    => p_rec.alignment
    );
  --
  chk_bevel
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_property_id             => p_rec.item_property_id
    ,p_bevel                        => p_rec.bevel
    );
  --
  chk_case_restriction
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_property_id             => p_rec.item_property_id
    ,p_case_restriction             => p_rec.case_restriction
    );
  --
  chk_enabled
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_property_id             => p_rec.item_property_id
    ,p_enabled                      => p_rec.enabled
    );
  --
  chk_format_mask
    (p_effective_date               => p_effective_date
    ,p_item_property_id             => p_rec.item_property_id
    ,p_format_mask                  => p_rec.format_mask
    );
  --
  chk_height
    (p_effective_date               => p_effective_date
    ,p_item_property_id             => p_rec.item_property_id
    ,p_height                       => p_rec.height
    );
  --
  chk_information_formula_id
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_property_id             => p_rec.item_property_id
    ,p_information_formula_id       => p_rec.information_formula_id
    );
  --
  chk_information_param_item_ids
    (p_effective_date               => p_effective_date
    ,p_item_property_id             => p_rec.item_property_id
    ,p_information_formula_id       => p_rec.information_formula_id
    ,p_information_param_item_id1   => p_rec.information_parameter_item_id1
    ,p_information_param_item_id2   => p_rec.information_parameter_item_id2
    ,p_information_param_item_id3   => p_rec.information_parameter_item_id3
    ,p_information_param_item_id4   => p_rec.information_parameter_item_id4
    ,p_information_param_item_id5   => p_rec.information_parameter_item_id5
    );
  --
  chk_insert_allowed
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_property_id             => p_rec.item_property_id
    ,p_insert_allowed               => p_rec.insert_allowed
    );
  --
  chk_prompt_alignment_offset
    (p_effective_date               => p_effective_date
    ,p_item_property_id             => p_rec.item_property_id
    ,p_prompt_alignment_offset      => p_rec.prompt_alignment_offset
    );
  --
  chk_prompt_display_style
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_property_id             => p_rec.item_property_id
    ,p_prompt_display_style         => p_rec.prompt_display_style
    );
  --
  chk_prompt_edge
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_property_id             => p_rec.item_property_id
    ,p_prompt_edge                  => p_rec.prompt_edge
    );
  --
  chk_prompt_edge_alignment
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_property_id             => p_rec.item_property_id
    ,p_prompt_edge_alignment        => p_rec.prompt_edge_alignment
    );
  --
  chk_prompt_edge_offset
    (p_effective_date               => p_effective_date
    ,p_item_property_id             => p_rec.item_property_id
    ,p_prompt_edge_offset           => p_rec.prompt_edge_offset
    );
  --
  chk_prompt_text_alignment
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_property_id             => p_rec.item_property_id
    ,p_prompt_text_alignment        => p_rec.prompt_text_alignment
    );
  --
  chk_query_allowed
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_property_id             => p_rec.item_property_id
    ,p_query_allowed                => p_rec.query_allowed
    );
  --
  chk_required
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_property_id             => p_rec.item_property_id
    ,p_required                     => p_rec.required
    );
  --
  chk_update_allowed
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_property_id             => p_rec.item_property_id
    ,p_update_allowed               => p_rec.update_allowed
    );
  --
  chk_validation_formula_id
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_property_id             => p_rec.item_property_id
    ,p_validation_formula_id        => p_rec.validation_formula_id
    );
  --
  chk_validation_param_item_ids
    (p_effective_date               => p_effective_date
    ,p_item_property_id             => p_rec.item_property_id
    ,p_validation_formula_id        => p_rec.validation_formula_id
    ,p_validation_param_item_id1    => p_rec.validation_parameter_item_id1
    ,p_validation_param_item_id2    => p_rec.validation_parameter_item_id2
    ,p_validation_param_item_id3    => p_rec.validation_parameter_item_id3
    ,p_validation_param_item_id4    => p_rec.validation_parameter_item_id4
    ,p_validation_param_item_id5    => p_rec.validation_parameter_item_id5
    );
  --
  chk_visible
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_property_id             => p_rec.item_property_id
    ,p_visible                      => p_rec.visible
    );
  --
  chk_width
    (p_effective_date               => p_effective_date
    ,p_item_property_id             => p_rec.item_property_id
    ,p_width                        => p_rec.width
    );
  --
  chk_x_position
    (p_effective_date               => p_effective_date
    ,p_item_property_id             => p_rec.item_property_id
    ,p_x_position                   => p_rec.x_position
    );
  --
  chk_y_position
    (p_effective_date               => p_effective_date
    ,p_item_property_id             => p_rec.item_property_id
    ,p_y_position                   => p_rec.y_position
    );
  --
  chk_item_type_dependencies
    (p_effective_date               => p_effective_date
    ,p_rec                          => p_rec
    );
  --
  chk_prev_and_next_nav_item
    (p_effective_date               => p_effective_date
    ,p_item_property_id             => p_rec.item_property_id
    ,p_form_item_id                 => p_rec.form_item_id
    ,p_template_item_id             => p_rec.template_item_id
    ,p_template_item_context_id     => p_rec.template_item_context_id
    ,p_previous_navigation_item_id  => p_rec.previous_navigation_item_id
    ,p_next_navigation_item_id      => p_rec.next_navigation_item_id
    );
  --
  chk_ddf
    (p_rec                          => p_rec
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hr_itp_shd.g_rec_type
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
end hr_itp_bus;

/
