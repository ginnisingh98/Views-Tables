--------------------------------------------------------
--  DDL for Package Body HR_TPP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TPP_BUS" as
/* $Header: hrtpprhi.pkb 115.5 2003/10/23 01:45:13 bsubrama noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_tpp_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_tab_page_property_id        number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_tab_page_property_id                 in number
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
  (p_tab_page_property_id                 in     number
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
          ,hr_template_tab_pages_b ttp
          ,hr_tab_page_properties_b tpp
     where tmp.form_template_id = twn.form_template_id
       and twn.template_window_id = tcn.template_window_id
       and tcn.template_canvas_id = ttp.template_canvas_id
       and ttp.template_tab_page_id = tpp.template_tab_page_id
       and tpp.tab_page_property_id = p_tab_page_property_id;
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
    ,p_argument           => 'tab_page_property_id'
    ,p_argument_value     => p_tab_page_property_id
    );
  --
  if ( nvl(hr_tpp_bus.g_tab_page_property_id, hr_api.g_number)
       = p_tab_page_property_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := hr_tpp_bus.g_legislation_code;
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
      -- Legislation code not found, which may be correct for certain tab page
      -- properties
      --
      l_legislation_code := null;
    end if;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    hr_tpp_bus.g_tab_page_property_id := p_tab_page_property_id;
    hr_tpp_bus.g_legislation_code := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
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
  (p_rec in hr_tpp_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.tab_page_property_id is not null)  and (
    nvl(hr_tpp_shd.g_old_rec.information_category, hr_api.g_varchar2) <>
    nvl(p_rec.information_category, hr_api.g_varchar2)  or
    nvl(hr_tpp_shd.g_old_rec.information1, hr_api.g_varchar2) <>
    nvl(p_rec.information1, hr_api.g_varchar2)  or
    nvl(hr_tpp_shd.g_old_rec.information2, hr_api.g_varchar2) <>
    nvl(p_rec.information2, hr_api.g_varchar2)  or
    nvl(hr_tpp_shd.g_old_rec.information3, hr_api.g_varchar2) <>
    nvl(p_rec.information3, hr_api.g_varchar2)  or
    nvl(hr_tpp_shd.g_old_rec.information4, hr_api.g_varchar2) <>
    nvl(p_rec.information4, hr_api.g_varchar2)  or
    nvl(hr_tpp_shd.g_old_rec.information5, hr_api.g_varchar2) <>
    nvl(p_rec.information5, hr_api.g_varchar2)  or
    nvl(hr_tpp_shd.g_old_rec.information6, hr_api.g_varchar2) <>
    nvl(p_rec.information6, hr_api.g_varchar2)  or
    nvl(hr_tpp_shd.g_old_rec.information7, hr_api.g_varchar2) <>
    nvl(p_rec.information7, hr_api.g_varchar2)  or
    nvl(hr_tpp_shd.g_old_rec.information8, hr_api.g_varchar2) <>
    nvl(p_rec.information8, hr_api.g_varchar2)  or
    nvl(hr_tpp_shd.g_old_rec.information9, hr_api.g_varchar2) <>
    nvl(p_rec.information9, hr_api.g_varchar2)  or
    nvl(hr_tpp_shd.g_old_rec.information10, hr_api.g_varchar2) <>
    nvl(p_rec.information10, hr_api.g_varchar2)  or
    nvl(hr_tpp_shd.g_old_rec.information11, hr_api.g_varchar2) <>
    nvl(p_rec.information11, hr_api.g_varchar2)  or
    nvl(hr_tpp_shd.g_old_rec.information12, hr_api.g_varchar2) <>
    nvl(p_rec.information12, hr_api.g_varchar2)  or
    nvl(hr_tpp_shd.g_old_rec.information13, hr_api.g_varchar2) <>
    nvl(p_rec.information13, hr_api.g_varchar2)  or
    nvl(hr_tpp_shd.g_old_rec.information14, hr_api.g_varchar2) <>
    nvl(p_rec.information14, hr_api.g_varchar2)  or
    nvl(hr_tpp_shd.g_old_rec.information15, hr_api.g_varchar2) <>
    nvl(p_rec.information15, hr_api.g_varchar2)  or
    nvl(hr_tpp_shd.g_old_rec.information16, hr_api.g_varchar2) <>
    nvl(p_rec.information16, hr_api.g_varchar2)  or
    nvl(hr_tpp_shd.g_old_rec.information17, hr_api.g_varchar2) <>
    nvl(p_rec.information17, hr_api.g_varchar2)  or
    nvl(hr_tpp_shd.g_old_rec.information18, hr_api.g_varchar2) <>
    nvl(p_rec.information18, hr_api.g_varchar2)  or
    nvl(hr_tpp_shd.g_old_rec.information19, hr_api.g_varchar2) <>
    nvl(p_rec.information19, hr_api.g_varchar2)  or
    nvl(hr_tpp_shd.g_old_rec.information20, hr_api.g_varchar2) <>
    nvl(p_rec.information20, hr_api.g_varchar2)  or
    nvl(hr_tpp_shd.g_old_rec.information21, hr_api.g_varchar2) <>
    nvl(p_rec.information21, hr_api.g_varchar2)  or
    nvl(hr_tpp_shd.g_old_rec.information22, hr_api.g_varchar2) <>
    nvl(p_rec.information22, hr_api.g_varchar2)  or
    nvl(hr_tpp_shd.g_old_rec.information23, hr_api.g_varchar2) <>
    nvl(p_rec.information23, hr_api.g_varchar2)  or
    nvl(hr_tpp_shd.g_old_rec.information24, hr_api.g_varchar2) <>
    nvl(p_rec.information24, hr_api.g_varchar2)  or
    nvl(hr_tpp_shd.g_old_rec.information25, hr_api.g_varchar2) <>
    nvl(p_rec.information25, hr_api.g_varchar2)  or
    nvl(hr_tpp_shd.g_old_rec.information26, hr_api.g_varchar2) <>
    nvl(p_rec.information26, hr_api.g_varchar2)  or
    nvl(hr_tpp_shd.g_old_rec.information27, hr_api.g_varchar2) <>
    nvl(p_rec.information27, hr_api.g_varchar2)  or
    nvl(hr_tpp_shd.g_old_rec.information28, hr_api.g_varchar2) <>
    nvl(p_rec.information28, hr_api.g_varchar2)  or
    nvl(hr_tpp_shd.g_old_rec.information29, hr_api.g_varchar2) <>
    nvl(p_rec.information29, hr_api.g_varchar2)  or
    nvl(hr_tpp_shd.g_old_rec.information30, hr_api.g_varchar2) <>
    nvl(p_rec.information30, hr_api.g_varchar2) )
    or (p_rec.tab_page_property_id is null) ) then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'HR_TAB_PAGE_PROPERTIES'
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
  ,p_rec in hr_tpp_shd.g_rec_type
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
  IF NOT hr_tpp_shd.api_updating
      (p_tab_page_property_id                 => p_rec.tab_page_property_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  IF (nvl(p_rec.form_tab_page_id,hr_api.g_number) <>
      nvl(hr_tpp_shd.g_old_rec.form_tab_page_id,hr_api.g_number)
     ) THEN
     l_argument := 'form_tab_page_id';
     RAISE l_error;
  END IF;
  --
  IF (nvl(p_rec.template_tab_page_id,hr_api.g_number) <>
      nvl(hr_tpp_shd.g_old_rec.template_tab_page_id,hr_api.g_number)
     ) THEN
     l_argument := 'template_tab_page_id';
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
-- |--------------------< chk_form_and_template_tab_page >--------------------|
-- ----------------------------------------------------------------------------
Procedure chk_form_and_template_tab_page
  (p_effective_date               in date
  ,p_tab_page_property_id         in number
  ,p_form_tab_page_id             in number
  ,p_template_tab_page_id         in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_form_and_template_tab_page';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- One and only one of form_tab_page_id and template_tab_page_id must be given
  --
  if not (  (   p_form_tab_page_id is not null
            and p_template_tab_page_id is null)
         or (   p_form_tab_page_id is null
            and p_template_tab_page_id is not null)) then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_form_and_template_tab_page;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_form_tab_page_id >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_form_tab_page_id
  (p_effective_date               in date
  ,p_tab_page_property_id         in number
  ,p_form_tab_page_id             in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_form_tab_page_id';
  l_api_updating                 boolean;
  l_canvas_type                  varchar2(30);
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
-- |-----------------------< chk_template_tab_page_id >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_template_tab_page_id
  (p_effective_date               in date
  ,p_tab_page_property_id         in number
  ,p_template_tab_page_id         in number
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_template_tab_page_id';
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
End chk_template_tab_page_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_navigation_direction >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_navigation_direction
  (p_effective_date               in date
  ,p_object_version_number        in number
  ,p_tab_page_property_id         in number
  ,p_navigation_direction         in varchar2
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_navigation_direction';
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
  l_api_updating := hr_tpp_shd.api_updating
    (p_tab_page_property_id        => p_tab_page_property_id
    ,p_object_version_number       => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and nvl(hr_tpp_shd.g_old_rec.navigation_direction,hr_api.g_varchar2) <>
            nvl(p_navigation_direction,hr_api.g_varchar2))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,30);
    --
    if (p_navigation_direction is not null) then
      --
      hr_utility.set_location(l_proc,40);
      --
      -- Must exist in hr_standard_lookups where lookup_type is
      -- NAVIGATION_DIRECTION
      --
      if hr_api.not_exists_in_hrstanlookups
        (p_effective_date               => p_effective_date
        ,p_lookup_type                  => 'NAVIGATION_DIRECTION'
        ,p_lookup_code                  => p_navigation_direction
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
End chk_navigation_direction;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_visible >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_visible
  (p_effective_date               in date
  ,p_object_version_number        in number
  ,p_tab_page_property_id         in number
  ,p_visible                      in number
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
  l_api_updating := hr_tpp_shd.api_updating
    (p_tab_page_property_id           => p_tab_page_property_id
    ,p_object_version_number          => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and nvl(hr_tpp_shd.g_old_rec.visible,hr_api.g_number) <>
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
-- |------------------------------< chk_delete >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (p_rec                          in hr_tpp_shd.g_rec_type
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
  ,p_rec                          in hr_tpp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check mandatory arguments have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'effective_date'
    ,p_argument_value               => p_effective_date
    );
  --
  -- Call all supporting business operations
  -- No business group context.  HR_STANDARD_LOOKUPS used for validation.
  --
  chk_form_and_template_tab_page
    (p_effective_date               => p_effective_date
    ,p_tab_page_property_id         => p_rec.tab_page_property_id
    ,p_form_tab_page_id             => p_rec.form_tab_page_id
    ,p_template_tab_page_id         => p_rec.template_tab_page_id
    );
  --
  chk_form_tab_page_id
    (p_effective_date               => p_effective_date
    ,p_tab_page_property_id         => p_rec.tab_page_property_id
    ,p_form_tab_page_id             => p_rec.form_tab_page_id
    );
  --
  chk_template_tab_page_id
    (p_effective_date               => p_effective_date
    ,p_tab_page_property_id         => p_rec.tab_page_property_id
    ,p_template_tab_page_id         => p_rec.template_tab_page_id
    );
  --
  chk_navigation_direction
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_tab_page_property_id         => p_rec.tab_page_property_id
    ,p_navigation_direction         => p_rec.navigation_direction
    );
  --
  chk_visible
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_tab_page_property_id         => p_rec.tab_page_property_id
    ,p_visible                      => p_rec.visible
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
  ,p_rec                          in hr_tpp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check mandatory arguments have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'effective_date'
    ,p_argument_value               => p_effective_date
    );
  --
  -- Call all supporting business operations
  -- No business group context.  HR_STANDARD_LOOKUPS used for validation.
  --
  chk_non_updateable_args
    (p_effective_date               => p_effective_date
    ,p_rec                          => p_rec
    );
  --
  chk_form_and_template_tab_page
    (p_effective_date               => p_effective_date
    ,p_tab_page_property_id         => p_rec.tab_page_property_id
    ,p_form_tab_page_id             => p_rec.form_tab_page_id
    ,p_template_tab_page_id         => p_rec.template_tab_page_id
    );
  --
  chk_form_tab_page_id
    (p_effective_date               => p_effective_date
    ,p_tab_page_property_id         => p_rec.tab_page_property_id
    ,p_form_tab_page_id             => p_rec.form_tab_page_id
    );
  --
  chk_template_tab_page_id
    (p_effective_date               => p_effective_date
    ,p_tab_page_property_id         => p_rec.tab_page_property_id
    ,p_template_tab_page_id         => p_rec.template_tab_page_id
    );
  --
  chk_navigation_direction
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_tab_page_property_id         => p_rec.tab_page_property_id
    ,p_navigation_direction         => p_rec.navigation_direction
    );
  --
  chk_visible
    (p_effective_date               => p_effective_date
    ,p_object_version_number        => p_rec.object_version_number
    ,p_tab_page_property_id         => p_rec.tab_page_property_id
    ,p_visible                      => p_rec.visible
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
  (p_rec                          in hr_tpp_shd.g_rec_type
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
end hr_tpp_bus;

/
