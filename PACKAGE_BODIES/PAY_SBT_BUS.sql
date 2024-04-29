--------------------------------------------------------
--  DDL for Package Body PAY_SBT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SBT_BUS" as
/* $Header: pysbtrhi.pkb 120.0 2005/05/29 08:34:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_sbt_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_template_info >--------------------------|
-- ----------------------------------------------------------------------------
Procedure get_template_info
  (p_template_id                 in            number
  ,p_business_group_id           in out nocopy number
  ,p_template_type               in out nocopy varchar2
  ) is
  --
  -- Cursor to get the template information.
  --
  cursor csr_get_template_info is
  select pet.business_group_id
  ,      pet.template_type
  from   pay_element_templates pet
  where  pet.template_id = p_template_id;
--
  l_proc  varchar2(72) := g_package||'get_template_info';
  l_api_updating boolean;
  l_valid        varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  open csr_get_template_info;
  fetch csr_get_template_info
  into  p_business_group_id
  ,     p_template_type;
  close csr_get_template_info;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
End get_template_info;
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
(p_rec in pay_sbt_shd.g_rec_type
) is
  --
  -- Cursor to disallow update if a balance has been generated from
  -- this shadow balance.
  --
  cursor csr_disallow_update is
  select null
  from   pay_template_core_objects tco
  where  tco.core_object_type = pay_tco_shd.g_sbt_lookup_type
  and    tco.shadow_object_id = p_rec.balance_type_id;
  --
  -- Cursor to disallow update of balance UOM if balance feeds to this
  -- balance exists.
  --
  cursor csr_disallow_uom is
  select null
  from   pay_shadow_balance_feeds sbf
  where  sbf.balance_type_id = p_rec.balance_type_id;
--
  l_proc  varchar2(72) := g_package||'chk_non_updateable_args';
  l_error exception;
  l_api_updating boolean;
  l_argument     varchar2(30);
  l_disallow     varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sbt_shd.api_updating
    (p_balance_type_id       => p_rec.balance_type_id
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
    fnd_message.set_name('PAY', 'PAY_50113_SBT_CORE_ROW_EXISTS');
    fnd_message.raise_error;
  end if;
  close csr_disallow_update;
  --
  -- Check the otherwise non-updateable arguments.
  --
  -- p_template_id
  --
  if nvl(p_rec.template_id, hr_api.g_number) <>
     nvl(pay_sbt_shd.g_old_rec.template_id, hr_api.g_number)
  then
    l_argument := 'p_template_id';
    raise l_error;
  end if;
  --
  -- p_balance_uom
  --
  if nvl(p_rec.balance_uom, hr_api.g_varchar2) <>
     nvl(pay_sbt_shd.g_old_rec.balance_uom, hr_api.g_varchar2)
  then
    --
    -- Check to see if the update is allowed.
    --
    open csr_disallow_uom;
    fetch csr_disallow_uom into l_disallow;
    if csr_disallow_uom%found then
      close csr_disallow_uom;
      l_argument := 'p_balance_uom';
      raise l_error;
    end if;
    close csr_disallow_uom;
  end if;
  --
  -- p_input_value_id
  --
  if nvl(p_rec.input_value_id, hr_api.g_number) <>
     nvl(pay_sbt_shd.g_old_rec.input_value_id, hr_api.g_number)
  then
    l_argument := 'input_value_id';
    raise l_error;
  end if;
  --
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
-- |---------------------------< chk_template_id >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_template_id
  (p_template_id     in     number
  ) is
  --
  -- Cursor to check that template_id is valid.
  --
  cursor csr_template_id_valid is
  select null
  from   pay_element_templates pet
  where  pet.template_id = p_template_id;
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
    fnd_message.set_name('PAY', 'PAY_50114_ETM_INVALID_TEMPLATE');
    fnd_message.raise_error;
  end if;
  close csr_template_id_valid;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
End chk_template_id;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_balance_name >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_balance_name
  (p_balance_name          in     varchar2
  ,p_template_id           in     number
  ,p_template_type         in     varchar2
  ,p_business_group_id     in     number
  ,p_balance_type_id       in     number
  ,p_object_version_number in     number
  ) is
  --
  -- Cursor to check that the balance name is unique within a template
  -- (template_type = 'T').
  --
  cursor csr_T_balance_name_exists is
    select null
    from   pay_shadow_balance_types sbt
    where  sbt.template_id = p_template_id
    and    upper(nvl(sbt.balance_name, hr_api.g_varchar2)) =
           upper(nvl(p_balance_name, hr_api.g_varchar2));
  --
  -- Cursor to check that the balance name is unique for a business group
  -- (template type = 'U').
  --
  cursor csr_U_balance_name_exists is
    select null
    from   pay_shadow_balance_types sbt
    ,      pay_element_templates    pet
    where  upper(sbt.balance_name) = upper(p_balance_name)
    and    pet.template_id  = sbt.template_id
    and    pet.template_type = 'U'
    and    pet.business_group_id = p_business_group_id;
--
  l_proc  varchar2(72) := g_package||'chk_balance_name';
  l_exists           varchar2(1);
  l_value            varchar2(2000);
  l_output           varchar2(2000);
  l_rgeflg           varchar2(2000);
  l_nullok           varchar2(2000);
  l_api_updating     boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sbt_shd.api_updating
  (p_balance_type_id       => p_balance_type_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_balance_name, hr_api.g_varchar2) <>
      nvl(pay_sbt_shd.g_old_rec.balance_name, hr_api.g_varchar2)) or
      not l_api_updating
  then
    --
    -- The name cannot be null if the template type is 'U'.
    --
    if p_template_type = 'U' then
      l_nullok := 'N';
    else
      l_nullok := 'Y';
    end if;
    --
    -- Check that the name format is correct (payroll name).
    --
    l_value := p_balance_name;
    if p_template_type = 'T' then
      --
      -- If template type is 'T' then the balance name can begin
      -- with a space which is not the correct format.
      --
      l_value := replace(l_value, ' ', 'A');
    end if;
    hr_chkfmt.checkformat
    (value   => l_value
    ,format  => 'PAY_NAME'
    ,output  => l_output
    ,minimum => null
    ,maximum => null
    ,nullok  => l_nullok
    ,rgeflg  => l_rgeflg
    ,curcode => null
    );
    --
    -- Uniqueness checks.
    --
    if p_template_type = 'T' then
      --
      -- Check for uniqueness using the cursor.
      --
      open csr_T_balance_name_exists;
      fetch csr_T_balance_name_exists into l_exists;
      if csr_T_balance_name_exists%found then
        close csr_T_balance_name_exists;
        hr_utility.set_location(' Leaving:'||l_proc, 10);
        fnd_message.set_name('PAY', 'PAY_50115_SBT_BALANCE_EXISTS');
        fnd_message.set_token('BALANCE_NAME', p_balance_name);
        fnd_message.raise_error;
      end if;
      close csr_T_balance_name_exists;
    elsif p_template_type = 'U' then
      --
      -- Check for uniqueness using the cursor.
      --
      open csr_U_balance_name_exists;
      fetch csr_U_balance_name_exists into l_exists;
      if csr_U_balance_name_exists%found then
        close csr_U_balance_name_exists;
        hr_utility.set_location(' Leaving:'||l_proc, 15);
        fnd_message.set_name('PAY', 'PAY_50115_SBT_BALANCE_EXISTS');
        fnd_message.set_token('BALANCE_NAME', p_balance_name);
        fnd_message.raise_error;
      end if;
      close csr_U_balance_name_exists;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End chk_balance_name;
-- ----------------------------------------------------------------------------
-- |----------------------< chk_asg_remuneration_flag >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_asg_remuneration_flag
(p_effective_date               in date
,p_assignment_remuneration_flag in varchar2
,p_balance_type_id              in number
,p_object_version_number        in number
) is
--
  l_proc  varchar2(72) := g_package||'chk_asg_remuneration_flag';
  l_api_updating boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sbt_shd.api_updating
  (p_balance_type_id       => p_balance_type_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and
      nvl(p_assignment_remuneration_flag, hr_api.g_varchar2) <>
      nvl(pay_sbt_shd.g_old_rec.assignment_remuneration_flag,
          hr_api.g_varchar2)) or
     not l_api_updating
  then
    --
    -- Check that the core object type is not null.
    --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_assignment_remuneration_flag'
    ,p_argument_value => p_assignment_remuneration_flag
    );
    --
    -- Validate against hr_lookups.
    --
    if hr_api.not_exists_in_hr_lookups
       (p_effective_date => p_effective_date
       ,p_lookup_type    => 'YES_NO'
       ,p_lookup_code    => p_assignment_remuneration_flag
       )
    then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
      fnd_message.set_name('PAY', 'HR_52966_INVALID_LOOKUP');
      fnd_message.set_token('LOOKUP_TYPE', 'YES_NO');
      fnd_message.set_token('COLUMN', 'ASSIGNMENT_REMUNERATION_FLAG');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End chk_asg_remuneration_flag;
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_balance_uom >-----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_balance_uom
(p_effective_date        in date
,p_balance_uom           in varchar2
,p_balance_type_id       in number
,p_input_value_id        in number
,p_object_version_number in number
) is
--
  l_proc  varchar2(72) := g_package||'chk_balance_uom';
  l_api_updating boolean;
  l_exists varchar2(1);
  --
  -- Cursor to check the uom of input value matches that of the balance.
  --
  Cursor csr_chk_uom is
    select null
      from pay_shadow_input_values siv
     where siv.input_value_id = p_input_value_id
       and upper(siv.uom) = upper(p_balance_uom);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sbt_shd.api_updating
  (p_balance_type_id       => p_balance_type_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_balance_uom, hr_api.g_varchar2) <>
      nvl(pay_sbt_shd.g_old_rec.balance_uom, hr_api.g_varchar2)) or
     not l_api_updating
  then
    --
    -- Check that the core object type is not null.
    --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_balance_uom'
    ,p_argument_value => p_balance_uom
    );
    --
    -- Validate against hr_lookups.
    --
    if hr_api.not_exists_in_hr_lookups
       (p_effective_date => p_effective_date
       ,p_lookup_type    => 'UNITS'
       ,p_lookup_code    => p_balance_uom
       )
    then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
      fnd_message.set_name('PAY', 'HR_52966_INVALID_LOOKUP');
      fnd_message.set_token('LOOKUP_TYPE', 'UNITS');
      fnd_message.set_token('COLUMN', 'BALANCE_UOM');
      fnd_message.raise_error;
    end if;
  end if;
  --
  if (l_api_updating and nvl(p_balance_uom, hr_api.g_varchar2) <>
      nvl(pay_sbt_shd.g_old_rec.balance_uom, hr_api.g_varchar2)) and
     (p_input_value_id is not null) then
    --
    -- Check that the UOMs are compatible
    --
    open csr_chk_uom;
    fetch csr_chk_uom into l_exists;
    if csr_chk_uom%notfound then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
      close csr_chk_uom;
      fnd_message.set_name('PAY', 'PAY_51522_SBT_UOM_MISMATCH');
      fnd_message.raise_error;
    end if;
    close csr_chk_uom;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End chk_balance_uom;
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_currency_code >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_currency_code
  (p_currency_code         in     varchar2
  ,p_balance_type_id       in     number
  ,p_object_version_number in     number
  ) is
  --
  -- Check that the currency code is valid.
  --
  cursor csr_valid_currency_code is
  select null
  from   fnd_currencies fc
  where  upper(fc.currency_code) = upper(p_currency_code)
  and    fc.enabled_flag = 'Y'
  and    fc.currency_flag = 'Y';
--
  l_proc  varchar2(72) := g_package||'chk_currency_code';
  l_api_updating boolean;
  l_valid        varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sbt_shd.api_updating
  (p_balance_type_id       => p_balance_type_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_currency_code, hr_api.g_varchar2) <>
      nvl(pay_sbt_shd.g_old_rec.currency_code, hr_api.g_varchar2)) or
     not l_api_updating
  then
    if p_currency_code is not null then
      open csr_valid_currency_code;
      fetch csr_valid_currency_code into l_valid;
      if csr_valid_currency_code%notfound then
        hr_utility.set_location(' Leaving:'||l_proc, 10);
        close csr_valid_currency_code;
        fnd_message.set_name('PAY', 'HR_51855_QUA_CCY_INV');
        fnd_message.raise_error;
      end if;
      close csr_valid_currency_code;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc, 15);
  end if;
End chk_currency_code;
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_exclusion_rule_id >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_exclusion_rule_id
  (p_exclusion_rule_id     in     number
  ,p_template_id           in     number
  ,p_balance_type_id       in     number
  ,p_object_version_number in     number
  ) is
  --
  -- Cursor to check that the exclusion_rule_id is valid.
  --
  cursor csr_exclusion_rule_id_valid is
  select null
  from pay_template_exclusion_rules ter
  where ter.exclusion_rule_id = p_exclusion_rule_id
  and   ter.template_id = p_template_id;
--
  l_proc  varchar2(72) := g_package||'chk_exclusion_rule_id';
  l_api_updating boolean;
  l_valid        varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sbt_shd.api_updating
  (p_balance_type_id       => p_balance_type_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_exclusion_rule_id, hr_api.g_number) <>
      nvl(pay_sbt_shd.g_old_rec.exclusion_rule_id, hr_api.g_number)) or
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
-- |-----------------------< chk_base_balance_type_id >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_base_balance_type_id
  (p_base_balance_type_id  in number
  ,p_base_balance_name     in varchar2
  ,p_template_id           in number
  ,p_balance_type_id       in number
  ,p_object_version_number in number
  ) is
  --
  l_proc         varchar2(72) := g_package||'chk_base_balance_type_id';
  l_exists       varchar2(1);
  l_api_updating boolean;
  --
  Cursor csr_chk_template is
    select null
      from pay_shadow_balance_types sbt
     where sbt.balance_type_id = p_base_balance_type_id
       and sbt.template_id = p_template_id;
  --
  Cursor csr_base_balances is
    select base_balance_type_id
    from   pay_shadow_balance_types
    start with balance_type_id = p_base_balance_type_id
    connect by prior base_balance_type_id = balance_type_id
    ;
Begin
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  l_api_updating := pay_sbt_shd.api_updating
  (p_balance_type_id       => p_balance_type_id
  ,p_object_version_number => p_object_version_number
  );

  if (l_api_updating and nvl(p_base_balance_type_id, hr_api.g_number) <>
      nvl(pay_sbt_shd.g_old_rec.base_balance_type_id, hr_api.g_number)) or
     not l_api_updating
  then
    --
    -- Only one of the base_balance_name and base_balance_type_id may be
    -- not null.
    --
    if (p_base_balance_type_id is not null and p_base_balance_name is not null) then
      fnd_message.set_name('PAY', 'PAY_51523_SBT_ID_TYPE_NOT_NULL');
      fnd_message.raise_error;
    end if;
    --
    if p_base_balance_type_id is not null then
      --
      -- Check that the template of the base balance is same as the
      -- current balance type
      --
      open csr_chk_template;
      fetch csr_chk_template into l_exists;
      if csr_chk_template%notfound then
        hr_utility.set_location(' Leaving:'||l_proc, 20);
        close csr_chk_template;
        fnd_message.set_name('PAY', 'PAY_51524_SBT_INVALID_BASENAME');
        fnd_message.raise_error;
      end if;
      close csr_chk_template;
      --
      -- Look for circular references in base balance. This is only
      -- necessary when p_base_balance_type_id is being updated with a
      -- NOT NULL value.
      --
      -- A new balance cannot cause a circular reference. A circular
      -- reference can be caused if balance B1 is made the base balance for
      -- balance B2, but balance B2 is the base balance for balance B1 or
      -- another balance further up from B1.
      --
      if l_api_updating then
        for crec in csr_base_balances loop
          if crec.base_balance_type_id = p_balance_type_id then
            fnd_message.set_name('PAY', 'PAY_50212_SBT_CIRCULAR_BAL_REF');
            fnd_message.raise_error;
          end if;
        end loop;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 30);
End chk_base_balance_type_id;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_input_value_id >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_input_value_id
  (p_input_value_id     in     number
  ,p_balance_uom        in     varchar2
  ,p_template_id        in     number
  ) is
  --
  -- Cursor to check that the input value exists.
  --
  Cursor csr_input_value_exists is
    select null
      from pay_shadow_input_values siv
          ,pay_shadow_element_types sel
     where siv.input_value_id = p_input_value_id
       and siv.element_type_id = sel.element_type_id
       and sel.template_id = p_template_id;
  --
  -- Cursor to check the uom of input value matches that of the balance.
  --
  Cursor csr_chk_uom is
    select null
      from pay_shadow_input_values siv
     where siv.input_value_id = p_input_value_id
       and upper(siv.uom) = upper(p_balance_uom);
--
  l_proc  varchar2(72) := g_package||'chk_input_value_id';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check that the input value exists.
  --
  if p_input_value_id is not null then
    open csr_input_value_exists;
    fetch csr_input_value_exists into l_exists;
    if csr_input_value_exists%notfound then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
      close csr_input_value_exists;
      fnd_message.set_name('PAY', 'PAY_50098_ETM_INVALID_INP_VAL');
      fnd_message.raise_error;
    end if;
    close csr_input_value_exists;
    --
    -- Check that the UOMs are compatible
    --
    open csr_chk_uom;
    fetch csr_chk_uom into l_exists;
    if csr_chk_uom%notfound then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
      close csr_chk_uom;
      fnd_message.set_name('PAY', 'PAY_51522_SBT_UOM_MISMATCH');
      fnd_message.raise_error;
    end if;
    close csr_chk_uom;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
End chk_input_value_id;
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_delete >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (p_balance_type_id     in     number
  ) is
  --
  -- Cursors to check for rows referencing the balance.
  --
  cursor csr_defined_balances is
  select null
  from   pay_shadow_defined_balances sdb
  where  sdb.balance_type_id = p_balance_type_id;
  --
  cursor csr_core_objects is
  select null
  from   pay_template_core_objects tco
  where  tco.core_object_type = pay_tco_shd.g_sbt_lookup_type
  and    tco.shadow_object_id = p_balance_type_id;
  --
  cursor csr_balance_types is
  select null
  from   pay_shadow_balance_types sbt
  where  sbt.base_balance_type_id = p_balance_type_id;
  --
  cursor csr_balance_feeds is
  select null
  from   pay_shadow_balance_feeds sdb
  where  sdb.balance_type_id = p_balance_type_id;
  --
  cursor csr_balance_classis is
  select null
  from   pay_shadow_balance_classi sbc
  where  sbc.balance_type_id = p_balance_type_id;
  --
  cursor csr_gu_bal_exclusions is
  select null
  from   pay_shadow_gu_bal_exclusions
  where  balance_type_id = p_balance_type_id;
--
  l_proc  varchar2(72) := g_package||'chk_delete';
  l_error  exception;
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open csr_defined_balances;
  fetch csr_defined_balances into l_exists;
  if csr_defined_balances%found then
    hr_utility.set_location(' Leaving:'||l_proc, 10);
    close csr_defined_balances;
    raise l_error;
  end if;
  close csr_defined_balances;
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
  open csr_balance_feeds;
  fetch csr_balance_feeds into l_exists;
  if csr_balance_feeds%found then
    hr_utility.set_location(' Leaving:'||l_proc, 20);
    close csr_balance_feeds;
    raise l_error;
  end if;
  close csr_balance_feeds;
  --
  open csr_balance_classis;
  fetch csr_balance_classis into l_exists;
  if csr_balance_classis%found then
    hr_utility.set_location(' Leaving:'||l_proc, 25);
    close csr_balance_classis;
    raise l_error;
  end if;
  close csr_balance_classis;
  --
  open csr_gu_bal_exclusions;
  fetch csr_gu_bal_exclusions into l_exists;
  if csr_gu_bal_exclusions%found then
    hr_utility.set_location(' Leaving:'||l_proc, 30);
    close csr_gu_bal_exclusions;
    raise l_error;
  end if;
  close csr_gu_bal_exclusions;
  --
  open csr_balance_types;
  fetch csr_balance_types into l_exists;
  if csr_balance_types%found then
    hr_utility.set_location(' Leaving:'||l_proc, 35);
    close csr_balance_types;
    raise l_error;
  end if;
  close csr_balance_types;
  hr_utility.set_location(' Leaving:'||l_proc, 100);
exception
  when l_error then
    fnd_message.set_name('PAY', 'PAY_50117_SBT_INVALID_DELETE');
    fnd_message.raise_error;
  when others then
    hr_utility.set_location(' Leaving:'||l_proc, 110);
    raise;
End chk_delete;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
(p_effective_date in date
,p_rec in pay_sbt_shd.g_rec_type
) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_business_group_id number;
  l_template_type     varchar2(2000);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_template_id(p_rec.template_id);
  --
  get_template_info
  (p_template_id       => p_rec.template_id
  ,p_business_group_id => l_business_group_id
  ,p_template_type     => l_template_type
  );
  --
  chk_balance_name
  (p_balance_name          => p_rec.balance_name
  ,p_template_id           => p_rec.template_id
  ,p_template_type         => l_template_type
  ,p_business_group_id     => l_business_group_id
  ,p_balance_type_id       => p_rec.balance_type_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_asg_remuneration_flag
  (p_effective_date               => p_effective_date
  ,p_assignment_remuneration_flag => p_rec.assignment_remuneration_flag
  ,p_balance_type_id              => p_rec.balance_type_id
  ,p_object_version_number        => p_rec.object_version_number
  );
  --
  chk_balance_uom
  (p_effective_date        => p_effective_date
  ,p_balance_uom           => p_rec.balance_uom
  ,p_balance_type_id       => p_rec.balance_type_id
  ,p_input_value_id        => p_rec.input_value_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_currency_code
  (p_currency_code         => p_rec.currency_code
  ,p_balance_type_id       => p_rec.balance_type_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_exclusion_rule_id
  (p_exclusion_rule_id     => p_rec.exclusion_rule_id
  ,p_template_id           => p_rec.template_id
  ,p_balance_type_id       => p_rec.balance_type_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_base_balance_type_id
  (p_base_balance_type_id  => p_rec.base_balance_type_id
  ,p_base_balance_name     => p_rec.base_balance_name
  ,p_template_id           => p_rec.template_id
  ,p_balance_type_id       => p_rec.balance_type_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_input_value_id
  (p_input_value_id => p_rec.input_value_id
  ,p_balance_uom    => p_rec.balance_uom
  ,p_template_id    => p_rec.template_id
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
,p_rec in pay_sbt_shd.g_rec_type
) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
  l_business_group_id number;
  l_template_type     varchar2(2000);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_non_updateable_args(p_rec);
  --
  get_template_info
  (p_template_id       => p_rec.template_id
  ,p_business_group_id => l_business_group_id
  ,p_template_type     => l_template_type
  );
  --
  chk_balance_name
  (p_balance_name          => p_rec.balance_name
  ,p_template_id           => p_rec.template_id
  ,p_template_type         => l_template_type
  ,p_business_group_id     => l_business_group_id
  ,p_balance_type_id       => p_rec.balance_type_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_asg_remuneration_flag
  (p_effective_date               => p_effective_date
  ,p_assignment_remuneration_flag => p_rec.assignment_remuneration_flag
  ,p_balance_type_id              => p_rec.balance_type_id
  ,p_object_version_number        => p_rec.object_version_number
  );
  --
  chk_balance_uom
  (p_effective_date        => p_effective_date
  ,p_balance_uom           => p_rec.balance_uom
  ,p_balance_type_id       => p_rec.balance_type_id
  ,p_input_value_id        => p_rec.input_value_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_currency_code
  (p_currency_code         => p_rec.currency_code
  ,p_balance_type_id       => p_rec.balance_type_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_exclusion_rule_id
  (p_exclusion_rule_id     => p_rec.exclusion_rule_id
  ,p_template_id           => p_rec.template_id
  ,p_balance_type_id       => p_rec.balance_type_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_base_balance_type_id
  (p_base_balance_type_id  => p_rec.base_balance_type_id
  ,p_base_balance_name     => p_rec.base_balance_name
  ,p_template_id           => p_rec.template_id
  ,p_balance_type_id       => p_rec.balance_type_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pay_sbt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_delete(p_rec.balance_type_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_sbt_bus;

/
