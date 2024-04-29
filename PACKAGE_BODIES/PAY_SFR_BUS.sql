--------------------------------------------------------
--  DDL for Package Body PAY_SFR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SFR_BUS" as
/* $Header: pysfrrhi.pkb 120.0 2005/05/29 08:40:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_sfr_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_rec     in     pay_sfr_shd.g_rec_type
  ) is
  --
  -- Cursor to disallow update if a core formula result rule has been
  -- generated from this shadow formula result rule.
  --
  cursor csr_disallow_update is
  select null
  from   pay_template_core_objects tco
  where  tco.core_object_type = pay_tco_shd.g_sfr_lookup_type
  and    tco.shadow_object_id = p_rec.formula_result_rule_id;
--
  l_proc  varchar2(72) := g_package||'chk_non_updateable_args';
  l_updating boolean;
  l_error    exception;
  l_argument varchar2(30);
  l_api_updating boolean;
  l_disallow varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sfr_shd.api_updating
    (p_formula_result_rule_id => p_rec.formula_result_rule_id
    ,p_object_version_number  => p_rec.object_version_number
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
  -- Check that the update is actually allowed.
  --
  open csr_disallow_update;
  fetch csr_disallow_update into l_disallow;
  if csr_disallow_update%found then
    hr_utility.set_location(l_proc, 20);
    close csr_disallow_update;
    fnd_message.set_name('PAY', 'PAY_50094_SFR_CORE_ROW_EXISTS');
    fnd_message.raise_error;
  end if;
  close csr_disallow_update;
  --
  -- p_shadow_element_type_id
  --
  if nvl(p_rec.shadow_element_type_id, hr_api.g_number) <>
     nvl(pay_sfr_shd.g_old_rec.shadow_element_type_id, hr_api.g_number)
  then
    hr_utility.set_location(l_proc, 25);
    l_argument := 'p_shadow_element_type_id';
    raise l_error;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 25);
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
-- |----------------------< chk_shadow_element_type_id >----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_shadow_element_type_id
  (p_shadow_element_type_id     in     number
  ) is
  --
  -- Cursor to check that the element type exists.
  --
  cursor csr_shadow_element_type_exists is
  select null
  from   pay_shadow_element_types pset
  where  pset.element_type_id = p_shadow_element_type_id;
--
  l_proc  varchar2(72) := g_package||'chk_shadow_element_type_id';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check that the shadow element type is not null.
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'p_shadow_element_type_id'
  ,p_argument_value => p_shadow_element_type_id
  );
  --
  -- Check that the shadow element type exists.
  --
  open csr_shadow_element_type_exists;
  fetch csr_shadow_element_type_exists into l_exists;
  if csr_shadow_element_type_exists%notfound then
    hr_utility.set_location(' Leaving:'||l_proc, 10);
    close csr_shadow_element_type_exists;
    fnd_message.set_name('PAY', 'PAY_50095_ETM_INVALID_ELE_TYPE');
    fnd_message.raise_error;
  end if;
  close csr_shadow_element_type_exists;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End chk_shadow_element_type_id;
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_result_rule_type >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_result_rule_type
(p_effective_date         in date
,p_result_rule_type         in varchar2
,p_formula_result_rule_id in number
,p_object_version_number  in number
) is
--
  l_proc  varchar2(72) := g_package||'chk_result_rule_type';
  l_api_updating boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sfr_shd.api_updating
  (p_formula_result_rule_id => p_formula_result_rule_id
  ,p_object_version_number  => p_object_version_number
  );
  if (l_api_updating and
      nvl(p_result_rule_type, hr_api.g_varchar2) <>
      nvl(pay_sfr_shd.g_old_rec.result_rule_type, hr_api.g_varchar2))
     or not l_api_updating
  then
    --
    -- Result rule type is mandatory.
    --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_result_rule_type'
    ,p_argument_value => p_result_rule_type
    );
    --
    -- Validate against hr_lookups.
    --
    if hr_api.not_exists_in_hr_lookups
       (p_effective_date => p_effective_date
       ,p_lookup_type    => 'RESULT_RULE_TYPE'
       ,p_lookup_code    => p_result_rule_type
       )
    then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
      fnd_message.set_name('PAY', 'HR_52966_INVALID_LOOKUP');
      fnd_message.set_token('LOOKUP_TYPE', 'RESULT_RULE_TYPE');
      fnd_message.set_token('COLUMN', 'RESULT_RULE_TYPE');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End chk_result_rule_type;
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_element_type_id >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_element_type_id
  (p_element_type_id        in     number
  ,p_element_name           in     varchar2
  ,p_shadow_element_type_id in     number
  ,p_result_rule_type       in     varchar2
  ,p_formula_result_rule_id in     number
  ,p_object_version_number  in     number
  ) is
  --
  -- Cursor to check that the element type exists (and is in the same
  -- template as the shadow element type).
  --
  cursor csr_element_type_exists is
  select null
  from   pay_shadow_element_types pset
  ,      pay_shadow_element_types pset1
  where  pset.element_type_id  = p_shadow_element_type_id
  and    pset1.element_type_id = p_element_type_id
  and    pset1.template_id     = pset.template_id;
--
  l_proc  varchar2(72) := g_package||'chk_element_type_id';
  l_exists varchar2(1);
  l_api_updating boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sfr_shd.api_updating
    (p_formula_result_rule_id => p_formula_result_rule_id
    ,p_object_version_number  => p_object_version_number
    );
  if (l_api_updating and nvl(p_element_type_id, hr_api.g_number) <>
      nvl(pay_sfr_shd.g_old_rec.element_type_id, hr_api.g_number)) or
     not l_api_updating
  then
    if p_element_type_id is not null then
      --
      -- Check that the element type exists.
      --
      open csr_element_type_exists;
      fetch csr_element_type_exists into l_exists;
      if csr_element_type_exists%notfound then
        hr_utility.set_location(' Leaving:'||l_proc, 10);
        close csr_element_type_exists;
        fnd_message.set_name('PAY', 'PAY_50096_SFR_ELE_ETM_MISMATCH');
        fnd_message.raise_error;
      end if;
      close csr_element_type_exists;
    end if;
  end if;
  --
  -- Confirm that at least one of p_element_type_id and p_element_name is
  -- null.
  --
  if p_element_type_id is not null and p_element_name is not null then
    hr_utility.set_location(' Leaving:'||l_proc, 15);
    fnd_message.set_name('PAY', 'PAY_50214_SFR_ELE_NOT_NULL');
    fnd_message.raise_error;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End chk_element_type_id;
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_input_value_id >--------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_input_value_id
  (p_input_value_id         in     number
  ,p_shadow_element_type_id in     number
  ,p_result_rule_type       in     varchar2
  ,p_formula_result_rule_id in     number
  ,p_object_version_number  in     number
  ) is
  --
  -- Cursor to check that the input value exists (and is in the same
  -- template as the shadow element type).
  --
  cursor csr_input_value_exists is
  select null
  from   pay_shadow_element_types pset
  ,      pay_shadow_element_types pset1
  ,      pay_shadow_input_values  psiv
  where  pset.element_type_id = p_shadow_element_type_id
  and    pset1.template_id    = pset.template_id
  and    psiv.input_value_id  = p_input_value_id
  and    psiv.element_type_id = pset1.element_type_id;
--
  l_proc  varchar2(72) := g_package||'chk_input_value_id';
  l_exists varchar2(1);
  l_api_updating boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sfr_shd.api_updating
    (p_formula_result_rule_id => p_formula_result_rule_id
    ,p_object_version_number  => p_object_version_number
    );
  if (l_api_updating and nvl(p_input_value_id, hr_api.g_number) <>
      nvl(pay_sfr_shd.g_old_rec.input_value_id, hr_api.g_number)) or
     not l_api_updating
  then
    if p_input_value_id is not null then
      --
      -- Check that the input value exists.
      --
      open csr_input_value_exists;
      fetch csr_input_value_exists into l_exists;
      if csr_input_value_exists%notfound then
        hr_utility.set_location(' Leaving:'||l_proc, 10);
        close csr_input_value_exists;
        fnd_message.set_name('PAY', 'PAY_50098_ETM_INVALID_INP_VAL');
        fnd_message.raise_error;
      end if;
      close csr_input_value_exists;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End chk_input_value_id;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_result_name >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_result_name
  (p_result_name            in     varchar2
  ,p_formula_result_rule_id in    number
  ,p_object_version_number  in     number
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_result_name';
  l_legislation_code varchar2(2000);
  l_exists           varchar2(1);
  l_value            varchar2(2000);
  l_output           varchar2(2000);
  l_rgeflg           varchar2(2000);
  l_api_updating     boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sfr_shd.api_updating
  (p_formula_result_rule_id => p_formula_result_rule_id
  ,p_object_version_number  => p_object_version_number
  );
  if (l_api_updating and nvl(p_result_name, hr_api.g_varchar2) <>
      nvl(pay_sfr_shd.g_old_rec.result_name, hr_api.g_varchar2)) or
      not l_api_updating
  then
    --
    -- Check that the name format is correct (not null database item name).
    --
    l_value := p_result_name;
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
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End chk_result_name;
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_severity_level >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_severity_level
(p_effective_date         in date
,p_severity_level         in varchar2
,p_result_rule_type       in varchar2
,p_formula_result_rule_id in number
,p_object_version_number  in number
) is
--
  l_proc  varchar2(72) := g_package||'chk_severity_level';
  l_api_updating boolean;
  l_result_rule_changed boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sfr_shd.api_updating
  (p_formula_result_rule_id => p_formula_result_rule_id
  ,p_object_version_number  => p_object_version_number
  );
  l_result_rule_changed :=
  l_api_updating and nvl(p_result_rule_type, hr_api.g_varchar2) <>
  nvl(pay_sfr_shd.g_old_rec.result_rule_type, hr_api.g_varchar2);
  --
  if (l_api_updating and
      nvl(p_severity_level, hr_api.g_varchar2) <>
      nvl(pay_sfr_shd.g_old_rec.severity_level, hr_api.g_varchar2))
     or not l_api_updating or l_result_rule_changed
  then
    --
    -- Severity level is mandatory if result rule type is 'M'.
    --
    if p_result_rule_type = 'M' then
      hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'p_severity_level'
      ,p_argument_value => p_severity_level
      );
      --
      -- Validate against hr_lookups.
      --
      if hr_api.not_exists_in_hr_lookups
         (p_effective_date => p_effective_date
         ,p_lookup_type    => 'MESSAGE_LEVEL'
         ,p_lookup_code    => p_severity_level
         )
      then
        hr_utility.set_location(' Leaving:'||l_proc, 10);
        fnd_message.set_name('PAY', 'HR_52966_INVALID_LOOKUP');
        fnd_message.set_token('LOOKUP_TYPE', 'MESSAGE_LEVEL');
        fnd_message.set_token('COLUMN', 'SEVERITY_LEVEL');
        fnd_message.raise_error;
      end if;
    --
    -- Severity level must be null otherwise.
    --
    elsif p_severity_level is not null then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
      fnd_message.set_name('PAY', 'PAY_50097_SFR_SEV_LVL_NOT_NULL');
      fnd_message.set_token('RESULT_RULE_TYPE', p_result_rule_type);
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End chk_severity_level;
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_exclusion_rule_id >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_exclusion_rule_id
  (p_exclusion_rule_id      in     number
  ,p_shadow_element_type_id in     number
  ,p_formula_result_rule_id in     number
  ,p_object_version_number  in     number
  ) is
  --
  -- Cursor to check that the exclusion_rule_id is valid.
  --
  cursor csr_exclusion_rule_id_valid is
  select null
  from  pay_shadow_element_types     pset
  ,     pay_template_exclusion_rules ter
  where pset.element_type_id  = p_shadow_element_type_id
  and   ter.template_id       = pset.template_id
  and   ter.exclusion_rule_id = p_exclusion_rule_id;
--
  l_proc  varchar2(72) := g_package||'chk_exclusion_rule_id';
  l_api_updating boolean;
  l_valid        varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sfr_shd.api_updating
  (p_formula_result_rule_id        => p_formula_result_rule_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_exclusion_rule_id, hr_api.g_number) <>
      nvl(pay_sfr_shd.g_old_rec.exclusion_rule_id, hr_api.g_number)) or
     not l_api_updating
  then
    if p_exclusion_rule_id is not null then
      open csr_exclusion_rule_id_valid;
      fetch csr_exclusion_rule_id_valid into l_valid;
      if csr_exclusion_rule_id_valid%notfound then
        hr_utility.set_location('Leaving:'||l_proc, 10);
        close csr_exclusion_rule_id_valid;
        fnd_message.set_name('PAY', 'PAY_50100_ETM_INVALID_EXC_RULE');
        fnd_message.raise_error;
      end if;
      close csr_exclusion_rule_id_valid;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
End chk_exclusion_rule_id;
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_delete >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (p_formula_result_rule_id     in     number
  ) is
  --
  -- Cursors to check for rows referencing the balance classification.
  --
  cursor csr_core_objects is
  select null
  from   pay_template_core_objects tco
  where  tco.core_object_type = pay_tco_shd.g_sfr_lookup_type
  and    tco.shadow_object_id = p_formula_result_rule_id;
--
  l_proc  varchar2(72) := g_package||'chk_delete';
  l_error  exception;
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open csr_core_objects;
  fetch csr_core_objects into l_exists;
  if csr_core_objects%found then
    hr_utility.set_location(' Leaving:'||l_proc, 10);
    close csr_core_objects;
    raise l_error;
  end if;
  close csr_core_objects;
  hr_utility.set_location(' Leaving:'||l_proc, 25);
exception
  when l_error then
    fnd_message.set_name('PAY', 'PAY_50099_SFR_INVALID_DELETE');
    fnd_message.raise_error;
  when others then
    hr_utility.set_location(' Leaving:'||l_proc, 30);
    raise;
End chk_delete;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
(p_effective_date in date
,p_rec in pay_sfr_shd.g_rec_type
) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_shadow_element_type_id(p_rec.shadow_element_type_id);
  --
  chk_result_rule_type
  (p_effective_date         => p_effective_date
  ,p_result_rule_type       => p_rec.result_rule_type
  ,p_formula_result_rule_id => p_rec.formula_result_rule_id
  ,p_object_version_number  => p_rec.object_version_number
  );
  --
  chk_element_type_id
  (p_element_type_id        => p_rec.element_type_id
  ,p_element_name           => p_rec.element_name
  ,p_shadow_element_type_id => p_rec.shadow_element_type_id
  ,p_result_rule_type       => p_rec.result_rule_type
  ,p_formula_result_rule_id => p_rec.formula_result_rule_id
  ,p_object_version_number  => p_rec.object_version_number
  );
  --
  chk_input_value_id
  (p_input_value_id         => p_rec.input_value_id
  ,p_shadow_element_type_id => p_rec.shadow_element_type_id
  ,p_result_rule_type       => p_rec.result_rule_type
  ,p_formula_result_rule_id => p_rec.formula_result_rule_id
  ,p_object_version_number  => p_rec.object_version_number
  );
  --
  chk_result_name
  (p_result_name            => p_rec.result_name
  ,p_formula_result_rule_id => p_rec.formula_result_rule_id
  ,p_object_version_number  => p_rec.object_version_number
  );
  --
  chk_severity_level
  (p_effective_date         => p_effective_date
  ,p_severity_level         => p_rec.severity_level
  ,p_result_rule_type       => p_rec.result_rule_type
  ,p_formula_result_rule_id => p_rec.formula_result_rule_id
  ,p_object_version_number  => p_rec.object_version_number
  );
  --
  chk_exclusion_rule_id
  (p_exclusion_rule_id      => p_rec.exclusion_rule_id
  ,p_shadow_element_type_id => p_rec.shadow_element_type_id
  ,p_formula_result_rule_id => p_rec.formula_result_rule_id
  ,p_object_version_number  => p_rec.object_version_number
  );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
(p_effective_date in date
,p_rec in pay_sfr_shd.g_rec_type
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
  chk_result_rule_type
  (p_effective_date         => p_effective_date
  ,p_result_rule_type       => p_rec.result_rule_type
  ,p_formula_result_rule_id => p_rec.formula_result_rule_id
  ,p_object_version_number  => p_rec.object_version_number
  );
  --
  chk_element_type_id
  (p_element_type_id        => p_rec.element_type_id
  ,p_element_name           => p_rec.element_name
  ,p_shadow_element_type_id => p_rec.shadow_element_type_id
  ,p_result_rule_type       => p_rec.result_rule_type
  ,p_formula_result_rule_id => p_rec.formula_result_rule_id
  ,p_object_version_number  => p_rec.object_version_number
  );
  --
  chk_input_value_id
  (p_input_value_id         => p_rec.input_value_id
  ,p_shadow_element_type_id => p_rec.shadow_element_type_id
  ,p_result_rule_type       => p_rec.result_rule_type
  ,p_formula_result_rule_id => p_rec.formula_result_rule_id
  ,p_object_version_number  => p_rec.object_version_number
  );
  --
  chk_result_name
  (p_result_name            => p_rec.result_name
  ,p_formula_result_rule_id => p_rec.formula_result_rule_id
  ,p_object_version_number  => p_rec.object_version_number
  );
  --
  chk_severity_level
  (p_effective_date         => p_effective_date
  ,p_severity_level         => p_rec.severity_level
  ,p_result_rule_type       => p_rec.result_rule_type
  ,p_formula_result_rule_id => p_rec.formula_result_rule_id
  ,p_object_version_number  => p_rec.object_version_number
  );
  --
  chk_exclusion_rule_id
  (p_exclusion_rule_id      => p_rec.exclusion_rule_id
  ,p_shadow_element_type_id => p_rec.shadow_element_type_id
  ,p_formula_result_rule_id => p_rec.formula_result_rule_id
  ,p_object_version_number  => p_rec.object_version_number
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pay_sfr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_delete(p_rec.formula_result_rule_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_sfr_bus;

/
