--------------------------------------------------------
--  DDL for Package Body PAY_SF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SF_BUS" as
/* $Header: pysfrhi.pkb 120.0 2005/05/29 02:17:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_sf_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
(p_rec in pay_sf_shd.g_rec_type
) is
  --
  -- Cursor to disallow update if a formula has been generated from
  -- this shadow formula.
  --
  cursor csr_disallow_update is
  select null
  from   pay_template_core_objects tco
  where  tco.core_object_type = pay_tco_shd.g_sf_lookup_type
  and    tco.shadow_object_id = p_rec.formula_id;
--
  l_proc  varchar2(72) := g_package||'chk_non_updateable_args';
  l_error exception;
  l_api_updating boolean;
  l_argument     varchar2(30);
  l_disallow     varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sf_shd.api_updating
    (p_formula_id            => p_rec.formula_id
    ,p_object_version_number => p_rec.object_version_number
    );
  if not l_api_updating then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '10');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Check that the update is actually allowed.
  --
  open csr_disallow_update;
  fetch csr_disallow_update into l_disallow;
  if csr_disallow_update%found then
    hr_utility.set_location(l_proc, 25);
    close csr_disallow_update;
    fnd_message.set_name('PAY', 'PAY_50101_SF_CORE_ROW_EXISTS');
    fnd_message.raise_error;
  end if;
  close csr_disallow_update;
  --
  -- Check the otherwise non-updateable arguments.
  --
  -- p_business_group_id
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(pay_sf_shd.g_old_rec.business_group_id, hr_api.g_number)
  then
    l_argument := 'p_business_group_id';
    raise l_error;
  end if;
  --
  -- p_legislation_code
  --
  if nvl(p_rec.legislation_code, hr_api.g_varchar2) <>
     nvl(pay_sf_shd.g_old_rec.legislation_code, hr_api.g_varchar2)
  then
    l_argument := 'p_legislation_code';
    raise l_error;
  end if;
  --
  -- p_template_type
  --
  if nvl(p_rec.template_type, hr_api.g_varchar2) <>
     nvl(pay_sf_shd.g_old_rec.template_type, hr_api.g_varchar2)
  then
    l_argument := 'p_template_type';
    raise l_error;
  end if;
  --
  -- p_formula_name
  --
  if nvl(p_rec.formula_name, hr_api.g_varchar2) <>
     nvl(pay_sf_shd.g_old_rec.formula_name, hr_api.g_varchar2)
  then
    l_argument := 'p_formula_name';
    raise l_error;
  end if;

  hr_utility.set_location('Leaving:'||l_proc, 25);
exception
    when l_error then
       hr_utility.set_location('Leaving:'||l_proc, 30);
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    when others then
       hr_utility.set_location('Leaving:'||l_proc, 35);
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
  -- Validate legislation_code.
  --
  if p_legislation_code is not null and
     p_legislation_code <> 'ZZ' then
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
-- |---------------------------< chk_formula_name >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_formula_name
  (p_formula_name      in     varchar2
  ,p_template_type     in     varchar2
  ,p_legislation_code  in     varchar2
  ,p_business_group_id in     number
  ) is
  --
  -- Cursor to check that the formula name is unique within a legislation
  -- for all templates of template_type 'T'.
  --
  cursor csr_T_formula_name_exists
    (p_formula_name      in varchar2
    ,p_legislation_code  in varchar2
    ,p_business_group_id in number
    ) is
    select null
    from   pay_shadow_formulas sf
    where  sf.template_type = 'T'
    and    upper(sf.formula_name) = upper(p_formula_name)
    and
    (
     (sf.legislation_code is null and sf.business_group_id is null) or
     (p_legislation_code is null and p_business_group_id is null) or
     (sf.legislation_code = p_legislation_code) or
     (sf.business_group_id = p_business_group_id) or
     (p_legislation_code = (select legislation_code from per_business_groups_perf
                            where business_group_id = sf.business_group_id))
    );
  --
  -- Cursor to check that the formula name is unique within its business
  -- group if the template type is 'U'.
  --
  cursor csr_U_formula_name_exists is
  select null
  from   pay_shadow_formulas sf
  where  sf.template_type = 'U'
  and    upper(sf.formula_name) = upper(p_formula_name)
  and    sf.business_group_id = p_business_group_id;
--
  l_proc  varchar2(72) := g_package||'chk_formula_name';
  l_legislation_code varchar2(2000);
  l_exists           varchar2(1);
  l_value            varchar2(2000);
  l_output           varchar2(2000);
  l_rgeflg           varchar2(2000);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check that the name is not null.
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'p_formula_name'
  ,p_argument_value => p_formula_name
  );
  --
  -- Check that the formula name format is correct (database item name).
  --
  l_value := p_formula_name;
  if p_template_type = 'T' then
    --
    -- If the template type is 'T' then the name can start with a '_'
    -- which is not strictly the correct format.
    --
    l_value := replace(l_value, '_', 'A');
  end if;
  hr_chkfmt.checkformat
  (value   => l_value
  ,format  => 'DB_ITEM_NAME'
  ,output  => l_output
  ,minimum => null
  ,maximum => null
  ,nullok  => 'N'
  ,rgeflg  => l_rgeflg
  ,curcode => null
  );
  --
  -- Uniqueness checks.
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
    open csr_T_formula_name_exists
    (p_formula_name      => p_formula_name
    ,p_legislation_code  => l_legislation_code
    ,p_business_group_id => p_business_group_id
    );
    fetch csr_T_formula_name_exists into l_exists;
    if csr_T_formula_name_exists%found then
      close csr_T_formula_name_exists;
      hr_utility.set_location(' Leaving:'||l_proc, 10);
      fnd_message.set_name('PAY', 'PAY_50102_SF_FORMULA_EXISTS');
      fnd_message.set_token('FORMULA_NAME', p_formula_name);
      fnd_message.raise_error;
    end if;
    close csr_T_formula_name_exists;
  elsif p_template_type = 'U' then
    open csr_U_formula_name_exists;
    fetch csr_U_formula_name_exists into l_exists;
    if csr_U_formula_name_exists%found then
      hr_utility.set_location(' Leaving:'||l_proc, 15);
      close csr_U_formula_name_exists;
      fnd_message.set_name('PAY', 'PAY_50102_SF_FORMULA_EXISTS');
      fnd_message.set_token('FORMULA_NAME', p_formula_name);
      fnd_message.raise_error;
    end if;
    close csr_U_formula_name_exists;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End chk_formula_name;
--
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
-- |------------------------------< chk_delete >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (p_formula_id in     number
  ) is
  --
  -- Cursors to check for rows referencing the template.
  --
  cursor csr_element_types is
  select null
  from   pay_shadow_element_types pset
  where  pset.payroll_formula_id = p_formula_id;
  --
  --
  cursor csr_input_values is
  select null
  from   pay_shadow_input_values psiv
  where  psiv.formula_id = p_formula_id;
  --
  cursor csr_core_objects is
  select null
  from   pay_template_core_objects tco
  where  tco.core_object_type = pay_tco_shd.g_sf_lookup_type
  and    tco.shadow_object_id = p_formula_id;
  --
  cursor csr_ff_usages is
  select null
  from   pay_template_ff_usages tfu
  where  tfu.formula_id = p_formula_id;
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
  open csr_input_values;
  fetch csr_input_values into l_exists;
  if csr_input_values%found then
    hr_utility.set_location(' Leaving:'||l_proc, 12);
    close csr_input_values;
    raise l_error;
  end if;
  close csr_input_values;
  --
  open csr_core_objects;
  fetch csr_core_objects into l_exists;
  if csr_core_objects%found then
    hr_utility.set_location(' Leaving:'||l_proc, 15);
    close csr_core_objects;
    raise l_error;
  end if;
  close csr_core_objects;
  --
  open csr_ff_usages;
  fetch csr_ff_usages into l_exists;
  if csr_ff_usages%found then
    hr_utility.set_location(' Leaving:'||l_proc, 18);
    close csr_ff_usages;
    raise l_error;
  end if;
  close csr_ff_usages;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
exception
  when l_error then
    fnd_message.set_name('PAY', 'PAY_50103_SF_INVALID_DELETE');
    fnd_message.raise_error;
  when others then
    hr_utility.set_location(' Leaving:'||l_proc, 60);
    raise;
End chk_delete;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
(p_effective_date in date
,p_rec in pay_sf_shd.g_rec_type
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
  (p_effective_date    => p_effective_date
  ,p_legislation_code  => p_rec.legislation_code
  ,p_business_group_id => p_rec.business_group_id
  ,p_template_type     => p_rec.template_type
  );
  --
  chk_formula_name
  (p_formula_name      => p_rec.formula_name
  ,p_template_type     => p_rec.template_type
  ,p_legislation_code  => p_rec.legislation_code
  ,p_business_group_id => p_rec.business_group_id
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
(p_effective_date in date
,p_rec in pay_sf_shd.g_rec_type
) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_non_updateable_args(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pay_sf_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_delete(p_rec.formula_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_sf_bus;

/
