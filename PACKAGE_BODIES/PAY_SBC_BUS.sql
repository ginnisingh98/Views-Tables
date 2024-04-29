--------------------------------------------------------
--  DDL for Package Body PAY_SBC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SBC_BUS" as
/* $Header: pysbcrhi.pkb 120.0 2005/05/29 08:33:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_sbc_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_rec     in     pay_sbc_shd.g_rec_type
  ) is
  --
  -- Cursor to disallow update if a core balance classification has been
  -- generated from this shadow balance classification.
  --
  cursor csr_disallow_update is
  select null
  from   pay_template_core_objects tco
  where  tco.core_object_type = pay_tco_shd.g_sbc_lookup_type
  and    tco.shadow_object_id = p_rec.balance_classification_id;
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
  l_api_updating := pay_sbc_shd.api_updating
    (p_balance_classification_id => p_rec.balance_classification_id
    ,p_object_version_number     => p_rec.object_version_number
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
    fnd_message.set_name('PAY', 'PAY_50085_SBC_CORE_ROW_EXISTS');
    fnd_message.raise_error;
  end if;
  close csr_disallow_update;
  --
  -- p_balance_type_id
  --
  if nvl(p_rec.balance_type_id, hr_api.g_number) <>
     nvl(pay_sbc_shd.g_old_rec.balance_type_id, hr_api.g_number)
  then
    hr_utility.set_location(l_proc, 20);
    l_argument := 'p_balance_type_id';
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
-- |-------------------------< chk_exclusion_rule_id >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_exclusion_rule_id
  (p_exclusion_rule_id         in     number
  ,p_balance_type_id           in     number
  ,p_balance_classification_id in     number
  ,p_object_version_number     in     number
  ) is
  --
  -- Cursor to check that the exclusion_rule_id is valid.
  --
  cursor csr_exclusion_rule_id_valid is
  select null
  from  pay_template_exclusion_rules ter
  ,     pay_shadow_balance_types bt
  where bt.balance_type_id = p_balance_type_id
  and   ter.exclusion_rule_id = p_exclusion_rule_id
  and   ter.template_id = bt.template_id
  ;
--
  l_proc  varchar2(72) := g_package||'chk_exclusion_rule_id';
  l_api_updating boolean;
  l_valid        varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sbc_shd.api_updating
  (p_balance_classification_id => p_balance_classification_id
  ,p_object_version_number     => p_object_version_number
  );
  if (l_api_updating and nvl(p_exclusion_rule_id, hr_api.g_number) <>
      nvl(pay_sbc_shd.g_old_rec.exclusion_rule_id, hr_api.g_number)) or
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
  hr_utility.set_location('Leaving:'||l_proc, 5);
end chk_exclusion_rule_id;
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_balance_type_id >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_balance_type_id
  (p_balance_type_id     in     number
  ) is
  --
  -- Cursor to check that the balance type exists.
  --
  cursor csr_balance_type_exists is
  select null
  from   pay_shadow_balance_types sbt
  where  sbt.balance_type_id = p_balance_type_id;
--
  l_proc  varchar2(72) := g_package||'chk_balance_type_id';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check that the balance type is not null.
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'p_balance_type_id'
  ,p_argument_value => p_balance_type_id
  );
  --
  -- Check that the balance type exists.
  --
  open csr_balance_type_exists;
  fetch csr_balance_type_exists into l_exists;
  if csr_balance_type_exists%notfound then
    hr_utility.set_location(' Leaving:'||l_proc, 10);
    close csr_balance_type_exists;
    fnd_message.set_name('PAY', 'PAY_50086_ETM_INVALID_BAL_TYPE');
    fnd_message.raise_error;
  end if;
  close csr_balance_type_exists;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
End chk_balance_type_id;
-- ----------------------------------------------------------------------------
-- |------------------------< chk_ele_classification >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_ele_classification
  (p_element_classification      in     varchar2
  ,p_balance_type_id             in     number
  ,p_balance_classification_id   in     number
  ,p_object_version_number       in     number
  ) is
  --
  -- Cursor to check the combination of element classification and
  -- balance type is unique.
  --
  cursor csr_bal_class_exists is
  select null
  from   pay_shadow_balance_classi sbc
  where  sbc.balance_type_id = p_balance_type_id
  and    upper(sbc.element_classification) = upper(p_element_classification);
--
  l_proc  varchar2(72) := g_package||'chk_ele_classification';
  l_api_updating boolean;
  l_exists       varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sbc_shd.api_updating
  (p_balance_classification_id => p_balance_classification_id
  ,p_object_version_number     => p_object_version_number
  );
  if (l_api_updating and nvl(p_element_classification, hr_api.g_varchar2)
     <> nvl(pay_sbc_shd.g_old_rec.element_classification, hr_api.g_varchar2))
     or not l_api_updating
  then
    --
    -- Check that the element classification is not null.
    --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_element_classification'
    ,p_argument_value => p_element_classification
    );
    --
    -- Check that the balance classification is unique.
    --
    open csr_bal_class_exists;
    fetch csr_bal_class_exists into l_exists;
    if csr_bal_class_exists%found then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
      close csr_bal_class_exists;
      fnd_message.set_name('PAY', 'PAY_50087_SBC_BAL_CLASS_EXISTS');
      fnd_message.raise_error;
    end if;
    close csr_bal_class_exists;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 25);
End chk_ele_classification;
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_delete >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (p_balance_classification_id     in     number
  ) is
  --
  -- Cursors to check for rows referencing the balance classification.
  --
  cursor csr_core_objects is
  select null
  from   pay_template_core_objects tco
  where  tco.core_object_type = pay_tco_shd.g_sbc_lookup_type
  and    tco.shadow_object_id = p_balance_classification_id;
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
    fnd_message.set_name('PAY', 'PAY_50088_SBC_INVALID_DELETE');
    fnd_message.raise_error;
  when others then
    hr_utility.set_location(' Leaving:'||l_proc, 20);
    raise;
End chk_delete;
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_scale >--------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_scale
  (p_scale                     in number
  ,p_balance_classification_id in number
  ,p_object_version_number     in number
  ) is
  l_proc  varchar2(72) := g_package||'chk_scale';
  l_api_updating boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sbc_shd.api_updating
  (p_balance_classification_id => p_balance_classification_id
  ,p_object_version_number     => p_object_version_number
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
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pay_sbc_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_template_id number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_balance_type_id(p_balance_type_id => p_rec.balance_type_id);
  --
  chk_ele_classification
  (p_element_classification    => p_rec.element_classification
  ,p_balance_type_id           => p_rec.balance_type_id
  ,p_balance_classification_id => p_rec.balance_classification_id
  ,p_object_version_number     => p_rec.object_version_number
  );
  --
  chk_scale
  (p_scale                     => p_rec.scale
  ,p_balance_classification_id => p_rec.balance_classification_id
  ,p_object_version_number     => p_rec.object_version_number
  );
  --
  chk_exclusion_rule_id
  (p_exclusion_rule_id         => p_rec.exclusion_rule_id
  ,p_balance_type_id           => p_rec.balance_type_id
  ,p_balance_classification_id => p_rec.balance_classification_id
  ,p_object_version_number     => p_rec.object_version_number
  );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pay_sbc_shd.g_rec_type) is
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
  chk_ele_classification
  (p_element_classification    => p_rec.element_classification
  ,p_balance_type_id           => p_rec.balance_type_id
  ,p_balance_classification_id => p_rec.balance_classification_id
  ,p_object_version_number     => p_rec.object_version_number
  );
  --
  chk_scale
  (p_scale                     => p_rec.scale
  ,p_balance_classification_id => p_rec.balance_classification_id
  ,p_object_version_number     => p_rec.object_version_number
  );
  --
  chk_exclusion_rule_id
  (p_exclusion_rule_id         => p_rec.exclusion_rule_id
  ,p_balance_type_id           => p_rec.balance_type_id
  ,p_balance_classification_id => p_rec.balance_classification_id
  ,p_object_version_number     => p_rec.object_version_number
  );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pay_sbc_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_delete(p_rec.balance_classification_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_sbc_bus;

/
