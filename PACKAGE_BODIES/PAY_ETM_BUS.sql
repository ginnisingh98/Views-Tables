--------------------------------------------------------
--  DDL for Package Body PAY_ETM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ETM_BUS" as
/* $Header: pyetmrhi.pkb 120.0 2005/05/29 04:42:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_etm_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
(p_rec in pay_etm_shd.g_rec_type
) is
--
  l_proc  varchar2(72) := g_package||'chk_non_updateable_args';
  l_error exception;
  l_api_updating boolean;
  l_argument     varchar2(30);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_etm_shd.api_updating
    (p_template_id           => p_rec.template_id
    ,p_object_version_number => p_rec.object_version_number
    );
  if not l_api_updating then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '10');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 15);
  --
  -- p_business_group_id
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(pay_etm_shd.g_old_rec.business_group_id, hr_api.g_number)
  then
    l_argument := 'p_business_group_id';
    raise l_error;
  end if;
  --
  -- p_legislation_code
  --
  if nvl(p_rec.legislation_code, hr_api.g_varchar2) <>
     nvl(pay_etm_shd.g_old_rec.legislation_code, hr_api.g_varchar2)
  then
    l_argument := 'p_legislation_code';
    raise l_error;
  end if;
  --
  -- p_template_name
  --
  if nvl(p_rec.template_name, hr_api.g_varchar2) <>
     nvl(pay_etm_shd.g_old_rec.template_name, hr_api.g_varchar2)
  then
    l_argument := 'p_template_name';
    raise l_error;
  end if;
  --
  -- p_template_type
  --
  if nvl(p_rec.template_type, hr_api.g_varchar2) <>
     nvl(pay_etm_shd.g_old_rec.template_type, hr_api.g_varchar2)
  then
    l_argument := 'p_template_type';
    raise l_error;
  end if;
  --
  -- p_base_name
  --
  if nvl(p_rec.base_name, hr_api.g_varchar2) <>
     nvl(pay_etm_shd.g_old_rec.base_name, hr_api.g_varchar2)
  then
    l_argument := 'p_base_name';
    raise l_error;
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 20);
exception
    when l_error then
       hr_utility.set_location('Leaving:'||l_proc, 25);
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    when others then
       hr_utility.set_location('Leaving:'||l_proc, 30);
       raise;
End chk_non_updateable_args;
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_busgrp_legcode >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_busgrp_legcode
  (p_business_group_id in     number
  ,p_legislation_code  in     varchar2
  ) is
  --
  -- Cursor to validate the legislation_code.
  --
  cursor csr_valid_leg_code is
  select null
  from   fnd_territories ft
  where  ft.territory_code = p_legislation_code;
--
  l_proc  varchar2(72) := g_package||'chk_busgrp_legcode';
  l_valid varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check that at least one of legislation_code and business_group_id
  -- is null.
  --
  if p_business_group_id is not null and p_legislation_code is not null
  then
    hr_utility.set_location(' Leaving:'||l_proc, 10);
    fnd_message.set_name('PAY', 'PAY_50069_ETM_LEG_BUS_NOT_NULL');
    fnd_message.raise_error;
  end if;
  --
  -- Validate business_group_id.
  --
  if p_business_group_id is not null then
    hr_api.validate_bus_grp_id( p_business_group_id );
  end if;
  --
  -- Validate legislation_code - if set and not International.
  --
  if (p_legislation_code is not null and
      p_legislation_code <> 'ZZ') then
    open csr_valid_leg_code;
    fetch csr_valid_leg_code into l_valid;
    if csr_valid_leg_code%notfound then
      hr_utility.set_location(' Leaving:'||l_proc, 15);
      close csr_valid_leg_code;
      fnd_message.set_name('PAY', 'PAY_50070_INVALID_LEG_CODE');
      fnd_message.raise_error;
    end if;
    close csr_valid_leg_code;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End chk_busgrp_legcode;
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_template_name >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_template_name
  (p_template_name     in     varchar2
  ,p_template_type     in     varchar2
  ,p_legislation_code  in     varchar2
  ,p_business_group_id in     number
  ) is
  --
  -- Cursor to check that the template name is unique within a legislation
  -- for all templates of template_type 'T'.
  --
  cursor csr_template_name_exists
    (p_template_name     in varchar2
    ,p_legislation_code  in varchar2
    ,p_business_group_id in number
    ) is
    select null
    from   pay_element_templates pet
    where  pet.template_type = 'T'
    and    upper(pet.template_name) = upper(p_template_name)
    and
    (
     (pet.legislation_code is null and pet.business_group_id is null) or
     (p_legislation_code is null and p_business_group_id is null) or
     (pet.legislation_code = p_legislation_code) or
     (pet.business_group_id = p_business_group_id) or
     (p_legislation_code = (select legislation_code from per_business_groups_perf
                            where business_group_id = pet.business_group_id))
    );
--
  l_proc  varchar2(72) := g_package||'chk_template_name';
  l_legislation_code varchar2(2000);
  l_exists           varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check that the name is not null.
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'p_template_name'
  ,p_argument_value => p_template_name
  );
  --
  -- Uniqueness check only applies to templates whose template_type is
  -- 'T'.
  --
  if p_template_type = 'T' then
    --
    -- Get the legislation_code for the new template.
    --
    if p_business_group_id is not null then
      l_legislation_code :=
      hr_api.return_legislation_code(p_business_group_id);
    else
      l_legislation_code := p_legislation_code;
    end if;
    --
    -- Check for uniqueness using the cursor.
    --
    open csr_template_name_exists
    (p_template_name     => p_template_name
    ,p_legislation_code  => l_legislation_code
    ,p_business_group_id => p_business_group_id
    );
    fetch csr_template_name_exists into l_exists;
    if csr_template_name_exists%found then
      close csr_template_name_exists;
      hr_utility.set_location(' Leaving:'||l_proc, 10);
      fnd_message.set_name('PAY', 'PAY_50071_ETM_NAME_EXISTS');
      fnd_message.set_token('TEMPLATE_NAME', p_template_name);
      fnd_message.raise_error;
    end if;
    close csr_template_name_exists;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
End chk_template_name;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_base_processing_priority >----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_base_processing_priority
(p_base_processing_priority in number
,p_template_id              in number
,p_template_type            in varchar2
,p_object_version_number    in number
) is
  --
  -- Cursor to check that the processing priority does cause overflow
  -- with any relative processing priority values from
  -- PAY_SHADOW_ELEMENT_TYPES.
  --
  cursor csr_priority_too_large is
  select null
  from   pay_shadow_element_types pset
  where  pset.template_id = p_template_id
  and    pset.relative_processing_priority + p_base_processing_priority >
         pay_etm_shd.g_max_processing_priority;
--
  l_proc  varchar2(72) := g_package||'chk_base_processing_priority';
  l_api_updating boolean;
  l_lower constant number := 0;
  l_upper constant number := pay_etm_shd.g_max_processing_priority;
  l_too_large varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_etm_shd.api_updating
    (p_template_id           => p_template_id
    ,p_object_version_number => p_object_version_number
    );
  --
  if (l_api_updating and
      nvl(pay_etm_shd.g_old_rec.base_processing_priority, hr_api.g_number) <>
      nvl(p_base_processing_priority, hr_api.g_number)) or
     not l_api_updating
  then
    --
    -- Check that an update is not being done for a template type of 'U'.
    --
    if l_api_updating and p_template_type = 'U' then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
      fnd_message.set_name('PAY', 'PAY_50072_ETM_PRIORITY_UPDATE');
      fnd_message.raise_error;
    end if;
    --
    -- Check that the priority is not null.
    --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_base_processing_priority'
    ,p_argument_value => p_base_processing_priority
    );
    --
    -- Check that the base processing priority is reasonable.
    --
    if p_base_processing_priority < l_lower or
       p_base_processing_priority > l_upper then
      hr_utility.set_location(' Leaving:'||l_proc, 15);
      fnd_message.set_name('PAY', 'PAY_50073_ETM_PRIORITY_RANGE');
      fnd_message.set_token('LOWER', l_lower);
      fnd_message.set_token('UPPER', l_upper);
      fnd_message.raise_error;
    end if;
    if l_api_updating then
      open csr_priority_too_large;
      fetch csr_priority_too_large into l_too_large;
      if csr_priority_too_large%found then
        hr_utility.set_location(' Leaving:'||l_proc, 20);
        fnd_message.set_name('PAY', 'PAY_50074_ETM_PRI_SUM_RANGE');
        fnd_message.set_token('LOWER', l_lower);
        fnd_message.set_token('UPPER', l_upper);
        fnd_message.raise_error;
      end if;
      close csr_priority_too_large;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 25);
End chk_base_processing_priority;
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_version >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_version_number
(p_version_number        in number
,p_template_id           in number
,p_template_type         in varchar2
,p_object_version_number in number
) is
--
  l_proc  varchar2(72) := g_package||'chk_version_number';
  l_api_updating boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_etm_shd.api_updating
    (p_template_id           => p_template_id
    ,p_object_version_number => p_object_version_number
    );
  --
  if (l_api_updating and
      nvl(pay_etm_shd.g_old_rec.version_number, hr_api.g_number) <>
      nvl(p_version_number, hr_api.g_number)) or
     not l_api_updating
  then
    --
    -- Check that the version number is not null.
    --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_version_number'
    ,p_argument_value => p_version_number
    );
    --
    -- Version number may not be updated for template type = 'U'.
    --
    if l_api_updating and p_template_type = 'U' then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
      fnd_message.set_name('PAY', 'PAY_50084_ETM_VERSION_NO_UPD');
      fnd_message.raise_error;
    end if;
    --
    -- Updated version number must not be less than the previous
    -- version number.
    --
    if l_api_updating and
       p_version_number < pay_etm_shd.g_old_rec.version_number then
      hr_utility.set_location(' Leaving:'||l_proc, 15);
      fnd_message.set_name('PAY', 'PAY_50083_ETM_LOWER_VERSION_NO');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End chk_version_number;
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_template_type >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_template_type
(p_effective_date    in date
,p_legislation_code  in varchar2
,p_business_group_id in number
,p_template_type     in varchar2
) is
--
  l_proc  varchar2(72) := g_package||'chk_template_type';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check that the template type is not null.
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'p_template_type'
  ,p_argument_value => p_template_type
  );
  --
  -- Validate against hr_lookups.
  --
  if p_template_type not in ('U','T') or
     hr_api.not_exists_in_hr_lookups
     (p_effective_date => p_effective_date
     ,p_lookup_type    => 'ELEMENT_TEMPLATE_TYPE'
     ,p_lookup_code    => p_template_type
     )
  then
    hr_utility.set_location(' Leaving:'||l_proc, 10);
    fnd_message.set_name('PAY', 'PAY_50082_ETM_BAD_TEMP_TYPE');
    fnd_message.set_token('TEMPLATE_TYPE', p_template_type);
    fnd_message.raise_error;
  end if;
  --
  -- The legislation_code must be null and the business_group_id
  -- not null if the template_type is 'U'.
  --
  if p_template_type = 'U' and
     (p_legislation_code is not null or p_business_group_id is null)
  then
    hr_utility.set_location(' Leaving:'||l_proc, 20);
    fnd_message.set_name('PAY', 'PAY_50081_ETM_BAD_BUS_GROUP');
    fnd_message.raise_error;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End chk_template_type;
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_max_base_name_length >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_max_base_name_length
(p_max_base_name_length  in number
,p_template_type         in varchar2
,p_template_id           in number
,p_object_version_number in number
) is
--
  l_proc  varchar2(72) := g_package||'chk_max_base_name_length';
  l_api_updating boolean;
  l_lower constant number := 1;
  l_upper constant number := 50;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_etm_shd.api_updating
    (p_template_id           => p_template_id
    ,p_object_version_number => p_object_version_number
    );
  --
  if (l_api_updating and
      nvl(pay_etm_shd.g_old_rec.max_base_name_length, hr_api.g_number) <>
      nvl(p_max_base_name_length, hr_api.g_number)) or
     not l_api_updating
  then
    --
    -- Check that the base name length is not null.
    --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_max_base_name_length'
    ,p_argument_value => p_max_base_name_length
    );
    --
    -- Maximum base name length may not be updated if the template type
    -- is 'U'
    --
    if l_api_updating and p_template_type = 'U' then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
      fnd_message.set_name('PAY', 'PAY_50080_ETM_UPD_BASE_NM_LEN');
      fnd_message.raise_error;
    end if;
    --
    -- Check that the length is within limits.
    --
    if p_max_base_name_length < l_lower or p_max_base_name_length > l_upper
    then
      hr_utility.set_location(' Leaving:'||l_proc, 15);
      fnd_message.set_name('PAY', 'PAY_50079_ETM_BASE_NAME_LENGTH');
      fnd_message.set_token('LOWER', l_lower);
      fnd_message.set_token('UPPER', l_upper);
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End chk_max_base_name_length;
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_base_name >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_base_name
(p_base_name            in varchar2
,p_template_type        in varchar2
,p_template_name        in varchar2
,p_max_base_name_length in number
,p_business_group_id    in number
) is
  --
  -- Cursor to check that the base name is unique within the scope of
  -- a business group.
  --
  cursor csr_base_name_exists is
  select null
  from   pay_element_templates pet
  where  pet.template_type = 'U'
  and    upper(pet.base_name) = upper(p_base_name)
  and    pet.business_group_id = p_business_group_id;
  --
  -- Cursor to check that the base name is unique for a particular template
  -- within the scope of a business group.
  --
  cursor csr_name_exists_for_template is
  select null
  from   pay_element_templates pet
  where  pet.template_type = 'U'
  and    upper(pet.base_name) = upper(p_base_name)
  and    pet.template_name    = p_template_name
  and    pet.business_group_id = p_business_group_id;
--
  l_proc  varchar2(72) := g_package||'chk_base_name';
  l_exists varchar2(1);
  l_value  varchar2(2000);
  l_output varchar2(2000);
  l_rgeflg varchar2(2000);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check that the base name is null if template type is 'T'.
  --
  if p_template_type = 'T' and p_base_name is not null then
    hr_utility.set_location(' Leaving:'||l_proc, 10);
    fnd_message.set_name('PAY', 'PAY_50078_ETM_BASE_NM_NOT_NULL');
    fnd_message.raise_error;
  end if;
  --
  -- Return if template type is 'T'.
  --
  if p_template_type = 'T' then
    hr_utility.set_location(' Leaving:'||l_proc, 15);
    return;
  end if;
  --
  -- Check that the base name is not null.
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'p_base_name'
  ,p_argument_value => p_base_name
  );
  --
  -- Check that the base name is not too long.
  --
  if lengthb(p_base_name) > p_max_base_name_length then
    hr_utility.set_location(' Leaving:'||l_proc, 20);
    fnd_message.set_name('PAY', 'PAY_50077_ETM_LONG_BASE_NAME');
    fnd_message.set_token('BASE_NAME', p_base_name);
    fnd_message.set_token('MAX_LENGTH', p_max_base_name_length);
    fnd_message.raise_error;
  end if;
  --
  -- Check that the base name format is correct (payroll name).
  --
  l_value := p_base_name;
  hr_chkfmt.checkformat
  (value   => l_value
  ,format  => 'PAY_NAME'
  ,output  => l_output
  ,minimum => null
  ,maximum => null
  ,nullok  => 'N'
  ,rgeflg  => l_rgeflg
  ,curcode => null
  );
  --
  -- Check that the base name is unique within its business groups.
  --
  if pay_etm_shd.g_allow_base_name_reuse then
    --
    -- If reuse allowed then avoid base name clash for any template,
    -- based upon the same source template, in the business group.
    --
    open csr_name_exists_for_template;
    fetch csr_name_exists_for_template into l_exists;
    if csr_name_exists_for_template%found then
      hr_utility.set_location(' Leaving:'||l_proc, 22);
      close csr_name_exists_for_template;
      fnd_message.set_name('PAY', 'PAY_50076_ETM_BASE_NAME_EXISTS');
      fnd_message.set_token('BASE_NAME', p_base_name);
      fnd_message.raise_error;
    end if;
    close csr_name_exists_for_template;
  else
    --
    -- If reuse not allowed then avoid base name clash for any
    -- template in the business group.
    --
    open csr_base_name_exists;
    fetch csr_base_name_exists into l_exists;
    if csr_base_name_exists%found then
      hr_utility.set_location(' Leaving:'||l_proc, 25);
      close csr_base_name_exists;
      fnd_message.set_name('PAY', 'PAY_50076_ETM_BASE_NAME_EXISTS');
      fnd_message.set_token('BASE_NAME', p_base_name);
      fnd_message.raise_error;
    end if;
    close csr_base_name_exists;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 30);
End chk_base_name;
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_delete >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (p_template_id in     number
  ) is
  --
  -- Cursors to check for rows referencing the template.
  --
  cursor csr_element_types is
  select null
  from   pay_shadow_element_types pset
  where  pset.template_id = p_template_id;
  --
  cursor csr_exclusion_rules is
  select null
  from   pay_template_exclusion_rules ter
  where  ter.template_id = p_template_id;
  --
  cursor csr_balance_types is
  select null
  from   pay_shadow_balance_types sbt
  where  sbt.template_id = p_template_id;
  --
  cursor csr_core_objects is
  select null
  from   pay_template_core_objects tco
  where  tco.template_id = p_template_id;
  --
  l_proc  varchar2(72) := g_package||'chk_delete';
  l_exists varchar2(1);
  l_error  exception;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open csr_element_types;
  fetch csr_element_types into l_exists;
  if csr_element_types%found then
    hr_utility.set_location(' Leaving:'||l_proc, 10);
    close csr_element_types;
    raise l_error;
  end if;
  close csr_element_types;
  --
  open csr_balance_types;
  fetch csr_balance_types into l_exists;
  if csr_balance_types%found then
    hr_utility.set_location(' Leaving:'||l_proc, 15);
    close csr_balance_types;
    raise l_error;
  end if;
  close csr_balance_types;
  --
  open csr_exclusion_rules;
  fetch csr_exclusion_rules into l_exists;
  if csr_exclusion_rules%found then
    hr_utility.set_location(' Leaving:'||l_proc, 20);
    close csr_exclusion_rules;
    raise l_error;
  end if;
  close csr_exclusion_rules;
  --
  open csr_core_objects;
  fetch csr_core_objects into l_exists;
  if csr_core_objects%found then
    hr_utility.set_location(' Leaving:'||l_proc, 25);
    close csr_core_objects;
    raise l_error;
  end if;
  close csr_core_objects;
  hr_utility.set_location(' Leaving:'||l_proc, 30);
exception
  when l_error then
    fnd_message.set_name('PAY', 'PAY_50075_ETM_INVALID_DELETE');
    fnd_message.raise_error;
  when others then
    hr_utility.set_location(' Leaving:'||l_proc, 35);
    raise;
End chk_delete;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date  in     date
  ,p_rec             in     pay_etm_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_busgrp_legcode
  (p_business_group_id => p_rec.business_group_id
  ,p_legislation_code  => p_rec.legislation_code
  );
  --
  chk_template_type
  (p_legislation_code  => p_rec.legislation_code
  ,p_business_group_id => p_rec.business_group_id
  ,p_effective_date    => p_effective_date
  ,p_template_type     => p_rec.template_type
  );
  --
  chk_template_name
  (p_template_name     => p_rec.template_name
  ,p_template_type     => p_rec.template_type
  ,p_business_group_id => p_rec.business_group_id
  ,p_legislation_code  => p_rec.legislation_code
  );
  --
  chk_max_base_name_length
  (p_max_base_name_length     => p_rec.max_base_name_length
  ,p_template_type            => p_rec.template_type
  ,p_template_id              => p_rec.template_id
  ,p_object_version_number    => p_rec.object_version_number
  );
  --
  chk_base_name
  (p_base_name            => p_rec.base_name
  ,p_template_type        => p_rec.template_type
  ,p_template_name        => p_rec.template_name
  ,p_max_base_name_length => p_rec.max_base_name_length
  ,p_business_group_id    => p_rec.business_group_id
  );
  --
  chk_base_processing_priority
  (p_base_processing_priority => p_rec.base_processing_priority
  ,p_template_id              => p_rec.template_id
  ,p_template_type            => p_rec.template_type
  ,p_object_version_number    => p_rec.object_version_number
  );
  --
  chk_version_number
  (p_version_number           => p_rec.version_number
  ,p_template_id              => p_rec.template_id
  ,p_template_type            => p_rec.template_type
  ,p_object_version_number    => p_rec.object_version_number
  );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date  in     date
  ,p_rec             in     pay_etm_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_non_updateable_args(p_rec => p_rec);
  --
  chk_max_base_name_length
  (p_max_base_name_length     => p_rec.max_base_name_length
  ,p_template_type            => p_rec.template_type
  ,p_template_id              => p_rec.template_id
  ,p_object_version_number    => p_rec.object_version_number
  );
  --
  chk_base_processing_priority
  (p_base_processing_priority => p_rec.base_processing_priority
  ,p_template_id              => p_rec.template_id
  ,p_template_type            => p_rec.template_type
  ,p_object_version_number    => p_rec.object_version_number
  );
  --
  chk_version_number
  (p_version_number           => p_rec.version_number
  ,p_template_id              => p_rec.template_id
  ,p_template_type            => p_rec.template_type
  ,p_object_version_number    => p_rec.object_version_number
  );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pay_etm_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_delete(p_rec.template_id);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_etm_bus;

/
