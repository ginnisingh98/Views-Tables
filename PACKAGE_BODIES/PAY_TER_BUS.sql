--------------------------------------------------------
--  DDL for Package Body PAY_TER_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_TER_BUS" as
/* $Header: pyterrhi.pkb 120.0 2005/05/29 09:04:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_ter_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_rec     in     pay_ter_shd.g_rec_type
  ) is
  l_proc  varchar2(72) := g_package||'chk_non_updateable_args';
  l_updating boolean;
  l_error    exception;
  l_argument varchar2(30);
  l_api_updating boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_ter_shd.api_updating
    (p_exclusion_rule_id     => p_rec.exclusion_rule_id
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
  -- p_template_id
  --
  if nvl(p_rec.template_id, hr_api.g_number) <>
     nvl(pay_ter_shd.g_old_rec.template_id, hr_api.g_number)
  then
    l_argument := 'p_template_id';
    raise l_error;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
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
-- |---------------------------< chk_template_id >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_template_id
  (p_template_id     in     number
  ) is
  --
  -- Cursor to check that template_id is valid and refers to a template
  -- of type 'T'.
  --
  cursor csr_template_id_valid is
  select null
  from   pay_element_templates pet
  where  pet.template_id = p_template_id
  and    pet.template_type = 'T';
  --
  l_proc  varchar2(72) := g_package||'chk_template_id';
  l_valid varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check that template_id is not null.
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'p_template_id'
  ,p_argument_value => p_template_id
  );
  --
  -- Check that template_id is valid.
  --
  open csr_template_id_valid;
  fetch csr_template_id_valid into l_valid;
  if csr_template_id_valid%notfound then
    hr_utility.set_location(' Leaving:'||l_proc, 10);
    close csr_template_id_valid;
    fnd_message.set_name('PAY', 'PAY_50057_BAD_SOURCE_TEMPLATE');
    fnd_message.raise_error;
  end if;
  close csr_template_id_valid;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
End chk_template_id;
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_flexfield_column >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_flexfield_column
  (p_flexfield_column      in     varchar2
  ,p_template_id           in     number
  ,p_exclusion_rule_id     in     number
  ,p_object_version_number in     number
  ) is
  --
  -- Cursor to ensure that the flexfield column is not being used as
  -- a default value column in PAY_SHADOW_INPUT_VALUES.
  --
  cursor csr_default_value_clash is
  select null
  from   pay_shadow_element_types pset
  ,      pay_shadow_input_values psiv
  where  pset.template_id = p_template_id
  and    psiv.element_type_id = pset.element_type_id
  and    nvl(upper(psiv.default_value_column), hr_api.g_varchar2) =
         upper(p_flexfield_column);
--
  l_proc  varchar2(72) := g_package||'chk_flexfield_column';
  l_len   number;
  l_prefix varchar2(2000);
  l_suffix number;
  l_error  exception;
  l_api_updating boolean;
  l_clash  varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_ter_shd.api_updating
  (p_exclusion_rule_id     => p_exclusion_rule_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_flexfield_column, hr_api.g_varchar2) <>
      nvl(pay_ter_shd.g_old_rec.flexfield_column, hr_api.g_varchar2)) or
     not l_api_updating
  then
    --
    -- Check that the flexfield column is not null.
    --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_flexfield_column'
    ,p_argument_value => p_flexfield_column
    );
    --
    -- Check that the flexfield column name is valid i.e. in the set
    -- CONFIGURATION_INFORMATION1 .. CONFIGURATION_INFORMATION30
    --
    begin
      l_len := length('CONFIGURATION_INFORMATION');
      l_prefix := upper(substr(p_flexfield_column, 1, l_len));
      l_suffix :=
      fnd_number.canonical_to_number(substr(p_flexfield_column, l_len + 1));
      l_suffix := nvl(l_suffix, -1);
      if l_prefix <> 'CONFIGURATION_INFORMATION' or
         (l_suffix < 1 or l_suffix > 30) or
         (l_suffix <> trunc(l_suffix))
      then
        raise l_error;
      end if;
    exception
      --
      -- All exceptions are due to the name being in the incorrect
      -- format.
      --
      when others then
        hr_utility.set_location(' Leaving:'||l_proc, 10);
        fnd_message.set_name('PAY', 'PAY_50130_ETM_BAD_FLEX_COLUMN');
        fnd_message.set_token('FLEXFIELD_COLUMN', p_flexfield_column);
        fnd_message.raise_error;
    end;
    --
    -- Check that there are no clashes with default_value columns in
    -- PAY_SHADOW_INPUT_VALUES.
    --
    open csr_default_value_clash;
    fetch csr_default_value_clash into l_clash;
    if csr_default_value_clash%found then
      hr_utility.set_location(' Leaving:'||l_proc, 15);
      close csr_default_value_clash;
      fnd_message.set_name('PAY', 'PAY_50131_TER_SIV_CLASH');
      fnd_message.raise_error;
    end if;
    close csr_default_value_clash;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End chk_flexfield_column;
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_exclusion_value >--------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_exclusion_value
  (p_exclusion_value       in     varchar2
  ,p_exclusion_rule_id     in     number
  ,p_object_version_number in   number
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_exclusion_value';
  l_api_updating boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_ter_shd.api_updating
  (p_exclusion_rule_id     => p_exclusion_rule_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_exclusion_value, hr_api.g_varchar2) <>
      nvl(pay_ter_shd.g_old_rec.exclusion_value, hr_api.g_varchar2)) or
     not l_api_updating
  then
    --
    -- Check that the exclusion value is not null.
    --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_exclusion_value'
    ,p_argument_value => p_exclusion_value
    );
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
End chk_exclusion_value;
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_delete >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (p_exclusion_rule_id     in     number
  ) is
  --
  -- Cursors to check for rows referencing the exclusion rule.
  --
  cursor csr_element_types is
  select null
  from   pay_shadow_element_types pset
  where  pset.exclusion_rule_id = p_exclusion_rule_id;
  --
  cursor csr_balance_types is
  select null
  from   pay_shadow_balance_types sbt
  where  sbt.exclusion_rule_id = p_exclusion_rule_id;
  --
  cursor csr_input_values is
  select null
  from   pay_shadow_input_values siv
  where  siv.exclusion_rule_id = p_exclusion_rule_id;
  --
  cursor csr_balance_feeds is
  select null
  from   pay_shadow_balance_feeds sbf
  where  sbf.exclusion_rule_id = p_exclusion_rule_id;
  --
  cursor csr_formula_rules is
  select null
  from   pay_shadow_formula_rules sfr
  where  sfr.exclusion_rule_id = p_exclusion_rule_id;
  --
  cursor csr_iterative_rules is
  select null
  from   pay_shadow_iterative_rules sir
  where  sir.exclusion_rule_id = p_exclusion_rule_id;
  --
  cursor csr_ele_type_usages is
  select null
  from   pay_shadow_ele_type_usages etu
  where  etu.exclusion_rule_id = p_exclusion_rule_id;
  --
  cursor csr_gu_bal_exclusions is
  select null
  from   pay_shadow_gu_bal_exclusions sgb
  where  sgb.exclusion_rule_id = p_exclusion_rule_id;
  --
  cursor csr_balance_classi is
  select null
  from   pay_shadow_balance_classi sbc
  where  sbc.exclusion_rule_id = p_exclusion_rule_id;
  --
  cursor csr_defined_balances is
  select null
  from   pay_shadow_defined_balances sdb
  where  sdb.exclusion_rule_id = p_exclusion_rule_id;
  --
  cursor csr_sub_classi_rules is
  select null
  from   pay_shadow_sub_classi_rules ssr
  where  ssr.exclusion_rule_id = p_exclusion_rule_id;
  --
  cursor csr_bal_attributes is
  select null
  from   pay_shadow_bal_attributes sba
  where  sba.exclusion_rule_id = p_exclusion_rule_id;
  --
  cursor csr_template_ff_usages is
  select null
  from   pay_template_ff_usages tfu
  where  tfu.exclusion_rule_id = p_exclusion_rule_id;
--
  l_proc  varchar2(72) := g_package||'chk_delete';
  l_exists varchar(1);
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
  open csr_input_values;
  fetch csr_input_values into l_exists;
  if csr_input_values%found then
    hr_utility.set_location(' Leaving:'||l_proc, 20);
    close csr_input_values;
    raise l_error;
  end if;
  close csr_input_values;
  --
  open csr_balance_feeds;
  fetch csr_balance_feeds into l_exists;
  if csr_balance_feeds%found then
    hr_utility.set_location(' Leaving:'||l_proc, 25);
    close csr_balance_feeds;
    raise l_error;
  end if;
  close csr_balance_feeds;
  --
  open csr_formula_rules;
  fetch csr_formula_rules into l_exists;
  if csr_formula_rules%found then
    hr_utility.set_location(' Leaving:'||l_proc, 30);
    close csr_formula_rules;
    raise l_error;
  end if;
  close csr_formula_rules;
  --
  open csr_iterative_rules;
  fetch csr_iterative_rules into l_exists;
  if csr_iterative_rules%found then
    hr_utility.set_location(' Leaving:'||l_proc, 35);
    close csr_iterative_rules;
    raise l_error;
  end if;
  close csr_iterative_rules;
  --
  open csr_ele_type_usages;
  fetch csr_ele_type_usages into l_exists;
  if csr_ele_type_usages%found then
    hr_utility.set_location(' Leaving:'||l_proc, 40);
    close csr_ele_type_usages;
    raise l_error;
  end if;
  close csr_ele_type_usages;
  --
  open csr_gu_bal_exclusions;
  fetch csr_gu_bal_exclusions into l_exists;
  if csr_gu_bal_exclusions%found then
    hr_utility.set_location(' Leaving:'||l_proc, 45);
    close csr_gu_bal_exclusions;
    raise l_error;
  end if;
  close csr_gu_bal_exclusions;
  --
  open csr_balance_classi;
  fetch csr_balance_classi into l_exists;
  if csr_balance_classi%found then
    hr_utility.set_location(' Leaving:'||l_proc, 50);
    close csr_balance_classi;
    raise l_error;
  end if;
  close csr_balance_classi;
  --
  open csr_defined_balances;
  fetch csr_defined_balances into l_exists;
  if csr_defined_balances%found then
    hr_utility.set_location(' Leaving:'||l_proc, 55);
    close csr_defined_balances;
    raise l_error;
  end if;
  close csr_defined_balances;
  --
  open csr_sub_classi_rules;
  fetch csr_sub_classi_rules into l_exists;
  if csr_sub_classi_rules%found then
    hr_utility.set_location(' Leaving:'||l_proc, 60);
    close csr_sub_classi_rules;
    raise l_error;
  end if;
  close csr_sub_classi_rules;
  --
  open csr_template_ff_usages;
  fetch csr_template_ff_usages into l_exists;
  if csr_template_ff_usages%found then
    hr_utility.set_location(' Leaving:'||l_proc, 65);
    close csr_template_ff_usages;
    raise l_error;
  end if;
  close csr_template_ff_usages;
  --
  open csr_bal_attributes;
  fetch csr_bal_attributes into l_exists;
  if csr_bal_attributes%found then
    hr_utility.set_location(' Leaving:'||l_proc, 70);
    close csr_bal_attributes;
    raise l_error;
  end if;
  close csr_bal_attributes;
  hr_utility.set_location(' Leaving:'||l_proc, 75);
exception
  when l_error then
    fnd_message.set_name('PAY', 'PAY_50129_TER_INVALID_DELETE');
    fnd_message.raise_error;
  when others then
    hr_utility.set_location(' Leaving:'||l_proc, 200);
    raise;
End chk_delete;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pay_ter_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_template_id(p_rec.template_id);
  --
  chk_flexfield_column
  (p_flexfield_column      => p_rec.flexfield_column
  ,p_template_id           => p_rec.template_id
  ,p_exclusion_rule_id     => p_rec.exclusion_rule_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_exclusion_value
  (p_exclusion_value       => p_rec.exclusion_value
  ,p_exclusion_rule_id     => p_rec.exclusion_rule_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pay_ter_shd.g_rec_type) is
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
  chk_flexfield_column
  (p_flexfield_column      => p_rec.flexfield_column
  ,p_template_id           => p_rec.template_id
  ,p_exclusion_rule_id     => p_rec.exclusion_rule_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_exclusion_value
  (p_exclusion_value       => p_rec.exclusion_value
  ,p_exclusion_rule_id     => p_rec.exclusion_rule_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pay_ter_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_delete(p_rec.exclusion_rule_id);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_ter_bus;

/
