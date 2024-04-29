--------------------------------------------------------
--  DDL for Package Body PAY_SBF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SBF_BUS" as
/* $Header: pysbfrhi.pkb 115.9 2003/02/05 17:28:10 arashid ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_sbf_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_template_info >---------------------------|
-- ----------------------------------------------------------------------------
Procedure get_template_info
  (p_input_value_id              in     number
  ,p_template_id                 in out nocopy number
  ) is
  --
  -- Cursor to get the template information.
  --
  cursor csr_get_template_info is
  select pet.template_id
  from   pay_shadow_input_values siv
  ,      pay_shadow_element_types pset
  ,      pay_element_templates pet
  where  siv.input_value_id = p_input_value_id
  and    pset.element_type_id = siv.element_type_id
  and    pet.template_id = pset.template_id;
--
  l_proc  varchar2(72) := g_package||'get_template_info';
  l_api_updating boolean;
  l_valid        varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  open csr_get_template_info;
  fetch csr_get_template_info
  into  p_template_id;
  close csr_get_template_info;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
End get_template_info;
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_rec     in     pay_sbf_shd.g_rec_type
  ) is
  --
  -- Cursor to disallow update if a core balance classification has been
  -- generated from this shadow balance classification.
  --
  cursor csr_disallow_update is
  select null
  from   pay_template_core_objects tco
  where  tco.core_object_type = pay_tco_shd.g_sbf_lookup_type
  and    tco.shadow_object_id = p_rec.balance_feed_id;
--
  l_proc  varchar2(72) := g_package||'chk_non_updateable_args';
  l_updating boolean;
  l_error    exception;
  l_argument varchar2(30);
  l_api_updating boolean;
  l_disallow     varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sbf_shd.api_updating
    (p_balance_feed_id       => p_rec.balance_feed_id
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
  -- Check that the update is actually allowed.
  --
  open csr_disallow_update;
  fetch csr_disallow_update into l_disallow;
  if csr_disallow_update%found then
    hr_utility.set_location(l_proc, 20);
    close csr_disallow_update;
    fnd_message.set_name('PAY', 'PAY_50104_SBF_CORE_ROW_EXISTS');
    fnd_message.raise_error;
  end if;
  close csr_disallow_update;
  --
  -- p_input_value_id
  --
  if nvl(p_rec.input_value_id, hr_api.g_number) <>
     nvl(pay_sbf_shd.g_old_rec.input_value_id, hr_api.g_number)
  then
    hr_utility.set_location(l_proc, 25);
    l_argument := 'p_input_value_id';
    raise l_error;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 40);
exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    when others then
       hr_utility.set_location('Leaving:'||l_proc, 45);
       raise;
End chk_non_updateable_args;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_input_value_id >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_input_value_id
  (p_input_value_id     in     number
  ) is
  --
  -- Cursor to check that the element type exists.
  --
  cursor csr_input_value_exists is
  select null
  from   pay_shadow_input_values siv
  where  siv.input_value_id = p_input_value_id;
--
  l_proc  varchar2(72) := g_package||'chk_input_value_id';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check that the input value is not null.
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'p_input_value_id'
  ,p_argument_value => p_input_value_id
  );
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
  hr_utility.set_location(' Leaving:'||l_proc, 15);
End chk_input_value_id;
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_balance_type_id >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_balance_type_id
  (p_balance_type_id       in     number
  ,p_input_value_id        in     number
  ,p_template_id           in     number
  ,p_balance_name          in     varchar2
  ,p_balance_feed_id       in     number
  ,p_object_version_number in     number
  ) is
  --
  -- Cursor to check that this combination of the input value and
  -- balance type is unique.
  --
  cursor csr_exists is
  select null
  from   pay_shadow_balance_feeds sbf
  where  sbf.input_value_id = p_input_value_id
  and    nvl(sbf.balance_type_id, hr_api.g_number) = p_balance_type_id;
  --
  -- Cursor to check that the balance type exists and is compatible with
  -- the input value (same uom and from the same template).
  --
  cursor csr_compatible is
  select null
  from   pay_shadow_input_values  siv
  ,      pay_shadow_balance_types sbt
  where  siv.input_value_id = p_input_value_id
  and    sbt.balance_type_id = p_balance_type_id
  and    upper(siv.uom) = upper(sbt.balance_uom)
  and    sbt.template_id = p_template_id;
--
  l_proc  varchar2(72) := g_package||'chk_balance_type_id';
  l_okay   varchar2(1);
  l_exists varchar2(1);
  l_api_updating boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sbf_shd.api_updating
  (p_balance_feed_id       => p_balance_feed_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_balance_type_id, hr_api.g_number) <>
      nvl(pay_sbf_shd.g_old_rec.balance_type_id, hr_api.g_number)) or
     not l_api_updating
  then
    --
    -- If the balance name is null then balance_type_id is mandatory.
    --
    if p_balance_name is null then
      hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'p_balance_type_id'
      ,p_argument_value => p_balance_type_id
      );
    --
    -- Only one of the balance name and balance_type_id may be not null.
    --
    elsif p_balance_type_id is not null then
      hr_utility.set_location(' Leaving:'||l_proc, 15);
      fnd_message.set_name('PAY', 'PAY_50105_SBF_ID_TYPE_NOT_NULL');
      fnd_message.raise_error;
    end if;
    --
    if p_balance_type_id is not null then
      --
      -- Check that the balance exists and is compatible with the
      -- input value.
      --
      open csr_compatible;
      fetch csr_compatible into l_okay;
      if csr_compatible%notfound then
        hr_utility.set_location(' Leaving:'||l_proc, 20);
        close csr_compatible;
        fnd_message.set_name('PAY', 'PAY_50106_SBF_UOM_MISMATCH');
        fnd_message.raise_error;
      end if;
      close csr_compatible;
      --
      -- Check that this input value/balance type combination does not
      -- exist.
      --
      open csr_exists;
      fetch csr_exists into l_exists;
      if csr_exists%found then
        hr_utility.set_location(' Leaving:'||l_proc, 25);
        close csr_exists;
        fnd_message.set_name('PAY', 'PAY_50107_SBF_FEED_EXISTS');
        fnd_message.raise_error;
      end if;
      close csr_exists;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 30);
End chk_balance_type_id;
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_balance_name >--------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_balance_name
  (p_balance_name          in     varchar2
  ,p_input_value_id        in     number
  ,p_balance_type_id       in     number
  ,p_balance_feed_id       in     number
  ,p_object_version_number in   number
  ) is
  --
  -- Cursor to check that this combination of balance name and input value
  -- is unique.
  --
  cursor csr_exists is
  select null
  from   pay_shadow_balance_feeds sbf
  where  sbf.input_value_id = p_input_value_id
  and    nvl(upper(sbf.balance_name), hr_api.g_varchar2) =
         upper(p_balance_name);
--
  l_proc  varchar2(72) := g_package||'chk_balance_name';
  l_exists varchar2(1);
  l_api_updating boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sbf_shd.api_updating
  (p_balance_feed_id       => p_balance_feed_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_balance_name, hr_api.g_varchar2) <>
      nvl(pay_sbf_shd.g_old_rec.balance_name, hr_api.g_varchar2)) or
     not l_api_updating
  then
    --
    -- The balance name is mandatory if balance_type_id is null.
    --
    if p_balance_type_id is null then
      hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'p_balance_name'
      ,p_argument_value => p_balance_name
      );
    end if;
    --
    if p_balance_name is not null then
      --
      -- Check that this input value/balance type combination does not
      -- exist.
      --
      open csr_exists;
      fetch csr_exists into l_exists;
      if csr_exists%found then
        hr_utility.set_location(' Leaving:'||l_proc, 20);
        close csr_exists;
        fnd_message.set_name('PAY', 'PAY_50107_SBF_FEED_EXISTS');
        fnd_message.raise_error;
      end if;
      close csr_exists;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 25);
End chk_balance_name;
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_scale >--------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_scale
  (p_scale                 in number
  ,p_balance_feed_id       in number
  ,p_object_version_number in number
  ) is
  l_proc  varchar2(72) := g_package||'chk_scale';
  l_api_updating boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sbf_shd.api_updating
  (p_balance_feed_id       => p_balance_feed_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_scale, hr_api.g_number) <>
      nvl(pay_sbc_shd.g_old_rec.scale, hr_api.g_number)) or
      not l_api_updating
  then
    --
    -- Check that scale is not null.
    --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_scale'
    ,p_argument_value => p_scale
    );
    --
    -- Check that scale is valid.
    --
    if p_scale <> 1 and p_scale <> -1 then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
      fnd_message.set_name('PAY', 'PAY_50089_ETM_INVALID_SCALE');
      fnd_message.set_token('POSITIVE', 1);
      fnd_message.set_token('NEGATIVE', -1);
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
End chk_scale;
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_exclusion_rule_id >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_exclusion_rule_id
  (p_exclusion_rule_id     in     number
  ,p_template_id           in     number
  ,p_balance_feed_id       in     number
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
  l_api_updating := pay_sbf_shd.api_updating
  (p_balance_feed_id       => p_balance_feed_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_exclusion_rule_id, hr_api.g_number) <>
      nvl(pay_sbf_shd.g_old_rec.exclusion_rule_id, hr_api.g_number)) or
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
  (p_balance_feed_id     in     number
  ) is
  --
  -- Cursors to check for rows referencing the balance classification.
  --
  cursor csr_core_objects is
  select null
  from   pay_template_core_objects tco
  where  tco.core_object_type = pay_tco_shd.g_sbf_lookup_type
  and    tco.shadow_object_id = p_balance_feed_id;
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
  hr_utility.set_location(' Leaving:'||l_proc, 15);
exception
  when l_error then
    fnd_message.set_name('PAY', 'PAY_50108_SBF_INVALID_DELETE');
    fnd_message.raise_error;
  when others then
    hr_utility.set_location(' Leaving:'||l_proc, 20);
    raise;
End chk_delete;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pay_sbf_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_template_id       number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_input_value_id(p_rec.input_value_id);
  --
  get_template_info
  (p_input_value_id    => p_rec.input_value_id
  ,p_template_id       => l_template_id
  );
  --
  chk_balance_type_id
  (p_balance_type_id       => p_rec.balance_type_id
  ,p_input_value_id        => p_rec.input_value_id
  ,p_template_id           => l_template_id
  ,p_balance_name          => p_rec.balance_name
  ,p_balance_feed_id       => p_rec.balance_feed_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_balance_name
  (p_balance_name          => p_rec.balance_name
  ,p_balance_type_id       => p_rec.balance_type_id
  ,p_input_value_id        => p_rec.input_value_id
  ,p_balance_feed_id       => p_rec.balance_feed_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_scale
  (p_scale                 => p_rec.scale
  ,p_balance_feed_id       => p_rec.balance_feed_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_exclusion_rule_id
  (p_exclusion_rule_id     => p_rec.exclusion_rule_id
  ,p_template_id           => l_template_id
  ,p_balance_feed_id       => p_rec.balance_feed_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pay_sbf_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
  l_template_id       number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_non_updateable_args(p_rec);
  --
  get_template_info
  (p_input_value_id    => p_rec.input_value_id
  ,p_template_id       => l_template_id
  );
  --
  chk_balance_type_id
  (p_balance_type_id       => p_rec.balance_type_id
  ,p_input_value_id        => p_rec.input_value_id
  ,p_template_id           => l_template_id
  ,p_balance_name          => p_rec.balance_name
  ,p_balance_feed_id       => p_rec.balance_feed_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_balance_name
  (p_balance_name          => p_rec.balance_name
  ,p_balance_type_id       => p_rec.balance_type_id
  ,p_input_value_id        => p_rec.input_value_id
  ,p_balance_feed_id       => p_rec.balance_feed_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_scale
  (p_scale                 => p_rec.scale
  ,p_balance_feed_id       => p_rec.balance_feed_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_exclusion_rule_id
  (p_exclusion_rule_id     => p_rec.exclusion_rule_id
  ,p_template_id           => l_template_id
  ,p_balance_feed_id       => p_rec.balance_feed_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pay_sbf_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_delete(p_rec.balance_feed_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_sbf_bus;

/
