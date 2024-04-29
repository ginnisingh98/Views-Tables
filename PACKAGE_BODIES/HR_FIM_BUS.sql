--------------------------------------------------------
--  DDL for Package Body HR_FIM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FIM_BUS" as
/* $Header: hrfimrhi.pkb 115.5 2002/12/03 11:18:58 hjonnala noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_fim_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_form_item_id                number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_form_item_id                         in number
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
  (p_form_item_id                         in     number
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
  -- Legislation code not available for form items
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
  (p_effective_date               in date
  ,p_rec in hr_fim_shd.g_rec_type
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
  IF NOT hr_fim_shd.api_updating
      (p_form_item_id                         => p_rec.form_item_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  IF (nvl(p_rec.application_id,hr_api.g_number) <>
      nvl(hr_fim_shd.g_old_rec.application_id,hr_api.g_number)
     ) THEN
     l_argument := 'application_id';
     RAISE l_error;
  END IF;
  --
  IF (nvl(p_rec.form_id,hr_api.g_number) <>
      nvl(hr_fim_shd.g_old_rec.form_id,hr_api.g_number)
     ) THEN
     l_argument := 'form_id';
     RAISE l_error;
  END IF;
  --
  IF (nvl(p_rec.form_canvas_id,hr_api.g_number) <>
      nvl(hr_fim_shd.g_old_rec.form_canvas_id,hr_api.g_number)
     ) THEN
     l_argument := 'form_canvas_id';
     RAISE l_error;
  END IF;
  --
  IF (nvl(p_rec.form_tab_page_id,hr_api.g_number) <>
      nvl(hr_fim_shd.g_old_rec.form_tab_page_id,hr_api.g_number)
     ) THEN
     l_argument := 'form_tab_page_id';
     RAISE l_error;
  END IF;
  --
  IF (nvl(p_rec.item_type,hr_api.g_varchar2) <>
      nvl(hr_fim_shd.g_old_rec.item_type,hr_api.g_varchar2)
     ) THEN
     l_argument := 'item_type';
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
-- |--------------------------< chk_application_id >--------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_application_id
  (p_effective_date               in date
  ,p_form_item_id                 in number
  ,p_object_version_number        in number
  ,p_application_id               in number
  ) is
  l_check number;
  CURSOR cur_chk_app_id
  IS
  SELECT 1
  FROM fnd_application
  WHERE application_id = p_application_id;
  --
  l_proc                         varchar2(72) := g_package || 'chk_application_id';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check value has been passed
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'application_id'
    ,p_argument_value     => p_application_id
    );
  --
  OPEN cur_chk_app_id;
  FETCH cur_chk_app_id INTO l_check;
  IF cur_chk_app_id%NOTFOUND THEN
    CLOSE cur_chk_app_id;
-- error message
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  END IF;
  CLOSE cur_chk_app_id;

  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_application_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_form_id >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_form_id
  (p_effective_date               in date
  ,p_form_item_id                 in number
  ,p_object_version_number        in number
  ,p_form_id                      in number
  ,p_application_id               in number
  ) is
  l_check number;
  CURSOR cur_chk_form_id
  IS
  SELECT 1
  FROM fnd_form
  WHERE form_id = p_form_id
  AND application_id = p_application_id;
  --
  l_proc                         varchar2(72) := g_package || 'chk_form_id';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check value has been passed
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'form_id'
    ,p_argument_value     => p_form_id
    );
  --
  OPEN cur_chk_form_id;
  FETCH cur_chk_form_id INTO l_check;
  IF cur_chk_form_id%NOTFOUND THEN
    CLOSE cur_chk_form_id;
-- error message
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  END IF;
  CLOSE cur_chk_form_id;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_form_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_form_canvas_id >--------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_form_canvas_id
  (p_effective_date               in date
  ,p_form_item_id                 in number
  ,p_object_version_number        in number
  ,p_form_canvas_id               in number
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
  l_api_updating := hr_fim_shd.api_updating
    (p_form_item_id                 => p_form_item_id
    ,p_object_version_number        => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and nvl(hr_fim_shd.g_old_rec.form_canvas_id,hr_api.g_number) <>
            nvl(p_form_canvas_id,hr_api.g_number))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,30);
    --
    -- Check value has been passed
    --
    hr_api.mandatory_arg_error
      (p_api_name           => l_proc
      ,p_argument           => 'form_canvas_id'
      ,p_argument_value     => p_form_canvas_id
      );
    --
    hr_utility.set_location(l_proc,40);
    --
    -- Check form canvas exists and is of type CONTENT or TAB
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
    hr_utility.set_location(l_proc,50);
    --
    if nvl(l_canvas_type,hr_api.g_varchar2) not in ('CONTENT','TAB','STACKED') then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','20');
      fnd_message.raise_error;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_form_canvas_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_form_tab_page_id >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_form_tab_page_id
  (p_effective_date               in date
  ,p_form_item_id                 in number
  ,p_object_version_number        in number
  ,p_form_tab_page_id             in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_form_tab_page_id';
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
End chk_form_tab_page_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_full_item_name >--------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_full_item_name
  (p_effective_date               in date
  ,p_form_item_id                 in number
  ,p_object_version_number        in number
  ,p_full_item_name               in varchar2
  ,p_item_type                    in varchar2
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_full_item_name';
  l_api_updating                 boolean;
  l_period_pos                   number;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check value has been passed
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'full_item_name'
    ,p_argument_value     => p_full_item_name
    );
  --
  -- Check value is in uppercase
  --
  if p_full_item_name <> upper(p_full_item_name) then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc,20);
  --
  -- Check value is of the form <data_block>.<item>
  --
  l_period_pos := instrb(p_full_item_name,'.',1,1);
  if p_item_type = 'SCROLLBAR' then
    if l_period_pos <> 0 then
      -- Full item name (block name) contains a period
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','30');
      fnd_message.raise_error;
    end if;
  else
    if    l_period_pos = 0 then
      -- Full item name does not contain period
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','20');
      fnd_message.raise_error;
    elsif l_period_pos = 1 then
      -- Full item name does not contain data block name
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','30');
      fnd_message.raise_error;
    elsif l_period_pos = length(p_full_item_name) then
      -- Full item name does not contain item name
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','40');
      fnd_message.raise_error;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
End chk_full_item_name;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_item_type >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_item_type
  (p_effective_date               in date
  ,p_form_item_id                 in number
  ,p_object_version_number        in number
  ,p_item_type                    in varchar2
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_item_type';
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
  l_api_updating := hr_fim_shd.api_updating
    (p_form_item_id                 => p_form_item_id
    ,p_object_version_number        => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and nvl(hr_fim_shd.g_old_rec.item_type,hr_api.g_varchar2) <>
            nvl(p_item_type,hr_api.g_varchar2))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,30);
    --
    -- Check value has been passed
    --
    hr_api.mandatory_arg_error
      (p_api_name                     => l_proc
      ,p_argument                     => 'item_type'
      ,p_argument_value               => p_item_type
      );
    --
    hr_utility.set_location(l_proc,40);
    --
    -- Must exist in hr_standard_lookups where lookup_type is ITEM_TYPES
    --
    if hr_api.not_exists_in_hrstanlookups
      (p_effective_date               => p_effective_date
      ,p_lookup_type                  => 'ITEM_TYPES'
      ,p_lookup_code                  => p_item_type
      ) then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_item_type;
--
-- -----------------------------------------------------------------------------
-- |--------------------------< chk_radio_button_name >------------------------|
-- -----------------------------------------------------------------------------
Procedure chk_radio_button_name
  (p_effective_date               in date
  ,p_form_item_id                 in number
  ,p_object_version_number        in number
  ,p_radio_button_name            in varchar2
  ,p_item_type                    in varchar2
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_radio_button_name';
  l_api_updating                 boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if    (   (p_item_type = 'RADIO_BUTTON')
        and (p_radio_button_name is null) ) then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  elsif (   (p_item_type <> 'RADIO_BUTTON')
        and (p_radio_button_name is not null) ) then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
  end if;
  --
  if (p_radio_button_name <> upper(p_radio_button_name)) then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','30');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_radio_button_name;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_form_tab_page_id_override >--------------------|
-- ----------------------------------------------------------------------------
Procedure chk_form_tab_page_id_override
  (p_effective_date               in date
  ,p_form_item_id                 in number
  ,p_object_version_number        in number
  ,p_form_tab_page_id_override    in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_form_tab_page_id_override';
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
End chk_form_tab_page_id_override;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_required_override >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_required_override
  (p_effective_date               in date
  ,p_form_item_id                 in number
  ,p_object_version_number        in number
  ,p_required_override            in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_required_override';
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
  l_api_updating := hr_fim_shd.api_updating
    (p_form_item_id                 => p_form_item_id
    ,p_object_version_number        => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and nvl(hr_fim_shd.g_old_rec.required_override,hr_api.g_number) <>
            nvl(p_required_override,hr_api.g_number))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,30);
    --
    if (p_required_override is not null) then
      --
      hr_utility.set_location(l_proc,40);
      --
      -- Must exist in hr_standard_lookups where lookup_type is
      -- PROPERTY_TRUE_OR_FALSE
      --
      if hr_api.not_exists_in_hrstanlookups
        (p_effective_date               => p_effective_date
        ,p_lookup_type                  => 'PROPERTY_TRUE_OR_FALSE'
        ,p_lookup_code                  => p_required_override
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
End chk_required_override;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_visible_override >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_visible_override
  (p_effective_date               in date
  ,p_form_item_id                 in number
  ,p_object_version_number        in number
  ,p_visible_override             in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_visible_override';
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
  l_api_updating := hr_fim_shd.api_updating
    (p_form_item_id                 => p_form_item_id
    ,p_object_version_number        => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and nvl(hr_fim_shd.g_old_rec.visible_override,hr_api.g_number) <>
            nvl(p_visible_override,hr_api.g_number))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,30);
    --
    if (p_visible_override is not null) then
      --
      hr_utility.set_location(l_proc,40);
      --
      -- Must exist in hr_standard_lookups where lookup_type is
      -- PROPERTY_TRUE_OR_FALSE
      --
      if hr_api.not_exists_in_hrstanlookups
        (p_effective_date               => p_effective_date
        ,p_lookup_type                  => 'PROPERTY_TRUE_OR_FALSE'
        ,p_lookup_code                  => p_visible_override
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
End chk_visible_override;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_appl_form_and_canvas >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_appl_form_and_canvas
  (p_effective_date               in date
  ,p_form_item_id                 in number
  ,p_object_version_number        in number
  ,p_application_id               in number
  ,p_form_id                      in number
  ,p_form_canvas_id               in number
  ) is
  --
  cursor csr_form_canvas is
    select fwn.application_id
          ,fwn.form_id
      from hr_form_windows_b fwn
          ,hr_form_canvases_b fcn
     where fwn.form_window_id = fcn.form_window_id
       and fcn.form_canvas_id = p_form_canvas_id;
  --
  l_proc                         varchar2(72) := g_package || 'chk_appl_form_and_canvas';
  l_api_updating                 boolean;
  l_application_id               number;
  l_form_id                      number;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  l_api_updating := hr_fim_shd.api_updating
    (p_form_item_id                 => p_form_item_id
    ,p_object_version_number        => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and (  (nvl(hr_fim_shd.g_old_rec.application_id,hr_api.g_number) <>
                nvl(p_application_id,hr_api.g_number))
            or (nvl(hr_fim_shd.g_old_rec.form_id,hr_api.g_number) <>
                nvl(p_form_id,hr_api.g_number))
            or (nvl(hr_fim_shd.g_old_rec.form_canvas_id,hr_api.g_number) <>
                nvl(p_form_canvas_id,hr_api.g_number))))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,30);
    --
    -- Check canvas exists and that it references the same form as the item
    --
    open csr_form_canvas;
    fetch csr_form_canvas into l_application_id,l_form_id;
    if csr_form_canvas%notfound then
      close csr_form_canvas;
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    end if;
    close csr_form_canvas;
    --
    hr_utility.set_location(l_proc,40);
    --
    if (  (nvl(p_application_id,hr_api.g_number) <> nvl(l_application_id,hr_api.g_number))
       or (nvl(p_form_id,hr_api.g_number) <> nvl(l_form_id,hr_api.g_number))) then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
--
end chk_appl_form_and_canvas;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_canvas_and_tab_pages >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_canvas_and_tab_pages
  (p_effective_date               in date
  ,p_form_item_id                 in number
  ,p_object_version_number        in number
  ,p_form_canvas_id               in number
  ,p_form_tab_page_id             in number
  ,p_form_tab_page_id_override    in number
  ) is
  --
  cursor csr_form_canvas is
    select fcn.canvas_type
      from hr_form_canvases_b fcn
     where fcn.form_canvas_id = p_form_canvas_id;
  --
  cursor csr_form_tab_page is
    select ftp.form_canvas_id
      from hr_form_tab_pages_b ftp
     where ftp.form_tab_page_id = p_form_tab_page_id;
  --
  l_proc                         varchar2(72) := g_package || 'chk_canvas_and_tab_pages';
  l_api_updating                 boolean;
  l_canvas_type                  varchar2(30);
  l_form_canvas_id               number;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  l_api_updating := hr_fim_shd.api_updating
    (p_form_item_id                 => p_form_item_id
    ,p_object_version_number        => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and (  (nvl(hr_fim_shd.g_old_rec.form_canvas_id,hr_api.g_number) <>
                nvl(p_form_canvas_id,hr_api.g_number))
            or (nvl(hr_fim_shd.g_old_rec.form_tab_page_id,hr_api.g_number) <>
                nvl(p_form_tab_page_id,hr_api.g_number))
            or (nvl(hr_fim_shd.g_old_rec.form_tab_page_id_override,hr_api.g_number) <>
                nvl(p_form_tab_page_id_override,hr_api.g_number))))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,30);
    --
    -- Check canvas exists
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
    hr_utility.set_location(l_proc,40);
    --
    -- Check tab page has been specified for items on tab canvases and the tab
    -- page references the same canvas as the canvas specified for the item.
    --
    if nvl(l_canvas_type,hr_api.g_varchar2) = 'TAB' then
      --
      hr_utility.set_location(l_proc,50);
      --
      if p_form_tab_page_id is null then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','20');
        fnd_message.raise_error;
      end if;
      --
      hr_utility.set_location(l_proc,60);
      --
      open csr_form_tab_page;
      fetch csr_form_tab_page into l_form_canvas_id;
      if csr_form_tab_page%notfound then
        close csr_form_tab_page;
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','30');
        fnd_message.raise_error;
      end if;
      close csr_form_tab_page;
      --
      hr_utility.set_location(l_proc,70);
      --
      if nvl(p_form_canvas_id,hr_api.g_number) <>
         nvl(l_form_canvas_id,hr_api.g_number) then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','40');
        fnd_message.raise_error;
      end if;
      --
    else
      --
      hr_utility.set_location(l_proc,80);
      --
      if p_form_tab_page_id is not null then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','50');
        fnd_message.raise_error;
      end if;
      --
    end if;
    --
    hr_utility.set_location(l_proc,90);
    --
    -- Check the override tab page is the same as the standard tab page if
    -- specified
    --
    if p_form_tab_page_id_override is not null then
      if p_form_tab_page_id_override <> nvl(p_form_tab_page_id,hr_api.g_number) then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','60');
        fnd_message.raise_error;
      end if;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
--
end chk_canvas_and_tab_pages;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_delete >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (p_rec                          in hr_fim_shd.g_rec_type
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
  ,p_rec                          in hr_fim_shd.g_rec_type
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
  chk_application_id
    (p_effective_date               => p_effective_date
    ,p_form_item_id                 => p_rec.form_item_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_application_id               => p_rec.application_id
    );
  --
  chk_form_id
    (p_effective_date               => p_effective_date
    ,p_form_item_id                 => p_rec.form_item_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_id                      => p_rec.form_id
    ,p_application_id               => p_rec.application_id
    );
  --
  chk_form_canvas_id
    (p_effective_date               => p_effective_date
    ,p_form_item_id                 => p_rec.form_item_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_canvas_id               => p_rec.form_canvas_id
    );
  --
  chk_form_tab_page_id
    (p_effective_date               => p_effective_date
    ,p_form_item_id                 => p_rec.form_item_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_tab_page_id             => p_rec.form_tab_page_id
    );
  --
  chk_full_item_name
    (p_effective_date               => p_effective_date
    ,p_form_item_id                 => p_rec.form_item_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_full_item_name               => p_rec.full_item_name
    ,p_item_type                    => p_rec.item_type
    );
  --
  chk_item_type
    (p_effective_date               => p_effective_date
    ,p_form_item_id                 => p_rec.form_item_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_type                    => p_rec.item_type
    );
  --
  chk_radio_button_name
    (p_effective_date               => p_effective_date
    ,p_form_item_id                 => p_rec.form_item_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_radio_button_name            => p_rec.radio_button_name
    ,p_item_type                    => p_rec.item_type
    );
  --
  chk_form_tab_page_id_override
    (p_effective_date               => p_effective_date
    ,p_form_item_id                 => p_rec.form_item_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_tab_page_id_override    => p_rec.form_tab_page_id_override
    );
  --
  chk_required_override
    (p_effective_date               => p_effective_date
    ,p_form_item_id                 => p_rec.form_item_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_required_override            => p_rec.required_override
    );
  --
  chk_visible_override
    (p_effective_date               => p_effective_date
    ,p_form_item_id                 => p_rec.form_item_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_visible_override             => p_rec.visible_override
    );
  --
  chk_appl_form_and_canvas
    (p_effective_date               => p_effective_date
    ,p_form_item_id                 => p_rec.form_item_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_application_id               => p_rec.application_id
    ,p_form_id                      => p_rec.form_id
    ,p_form_canvas_id               => p_rec.form_canvas_id
    );
  --
  chk_canvas_and_tab_pages
    (p_effective_date               => p_effective_date
    ,p_form_item_id                 => p_rec.form_item_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_canvas_id               => p_rec.form_canvas_id
    ,p_form_tab_page_id             => p_rec.form_tab_page_id
    ,p_form_tab_page_id_override    => p_rec.form_tab_page_id_override
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
  ,p_rec                          in hr_fim_shd.g_rec_type
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
  chk_application_id
    (p_effective_date               => p_effective_date
    ,p_form_item_id                 => p_rec.form_item_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_application_id               => p_rec.application_id
    );
  --
  chk_form_id
    (p_effective_date               => p_effective_date
    ,p_form_item_id                 => p_rec.form_item_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_id                      => p_rec.form_id
    ,p_application_id               => p_rec.application_id
    );
  --
  chk_form_canvas_id
    (p_effective_date               => p_effective_date
    ,p_form_item_id                 => p_rec.form_item_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_canvas_id               => p_rec.form_canvas_id
    );
  --
  chk_form_tab_page_id
    (p_effective_date               => p_effective_date
    ,p_form_item_id                 => p_rec.form_item_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_tab_page_id             => p_rec.form_tab_page_id
    );
  --
  chk_full_item_name
    (p_effective_date               => p_effective_date
    ,p_form_item_id                 => p_rec.form_item_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_full_item_name               => p_rec.full_item_name
    ,p_item_type                    => p_rec.item_type
    );
  --
  chk_item_type
    (p_effective_date               => p_effective_date
    ,p_form_item_id                 => p_rec.form_item_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_item_type                    => p_rec.item_type
    );
  --
  chk_radio_button_name
    (p_effective_date               => p_effective_date
    ,p_form_item_id                 => p_rec.form_item_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_radio_button_name            => p_rec.radio_button_name
    ,p_item_type                    => p_rec.item_type
    );
  --
  chk_form_tab_page_id_override
    (p_effective_date               => p_effective_date
    ,p_form_item_id                 => p_rec.form_item_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_tab_page_id_override    => p_rec.form_tab_page_id_override
    );
  --
  chk_required_override
    (p_effective_date               => p_effective_date
    ,p_form_item_id                 => p_rec.form_item_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_required_override            => p_rec.required_override
    );
  --
  chk_visible_override
    (p_effective_date               => p_effective_date
    ,p_form_item_id                 => p_rec.form_item_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_visible_override             => p_rec.visible_override
    );
  --
  chk_appl_form_and_canvas
    (p_effective_date               => p_effective_date
    ,p_form_item_id                 => p_rec.form_item_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_application_id               => p_rec.application_id
    ,p_form_id                      => p_rec.form_id
    ,p_form_canvas_id               => p_rec.form_canvas_id
    );
  --
  chk_canvas_and_tab_pages
    (p_effective_date               => p_effective_date
    ,p_form_item_id                 => p_rec.form_item_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_canvas_id               => p_rec.form_canvas_id
    ,p_form_tab_page_id             => p_rec.form_tab_page_id
    ,p_form_tab_page_id_override    => p_rec.form_tab_page_id_override
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hr_fim_shd.g_rec_type
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
end hr_fim_bus;

/
