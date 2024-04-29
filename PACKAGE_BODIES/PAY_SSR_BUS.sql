--------------------------------------------------------
--  DDL for Package Body PAY_SSR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SSR_BUS" as
/* $Header: pyssrrhi.pkb 120.0 2005/05/29 08:55:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_ssr_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_exclusion_rule_id >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_exclusion_rule_id
  (p_exclusion_rule_id          in     number
  ,p_element_type_id            in     number
  ,p_sub_classification_rule_id in     number
  ,p_object_version_number      in     number
  ) is
  --
  -- Cursor to check that the exclusion_rule_id is valid.
  --
  cursor csr_exclusion_rule_id_valid is
  select null
  from  pay_template_exclusion_rules ter
  ,     pay_shadow_element_types bt
  where bt.element_type_id = p_element_type_id
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
  l_api_updating := pay_ssr_shd.api_updating
  (p_sub_classification_rule_id => p_sub_classification_rule_id
  ,p_object_version_number      => p_object_version_number
  );
  if (l_api_updating and nvl(p_exclusion_rule_id, hr_api.g_number) <>
      nvl(pay_ssr_shd.g_old_rec.exclusion_rule_id, hr_api.g_number)) or
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
  hr_utility.set_location('Leaving:'||l_proc, 15);
end chk_exclusion_rule_id;
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_delete >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (p_sub_classification_rule_id     in     number
  ) is
  --
  -- Cursors to check for rows referencing the balance classification.
  --
  cursor csr_core_objects is
  select null
  from   pay_template_core_objects tco
  where  tco.core_object_type = pay_tco_shd.g_ssr_lookup_type
  and    tco.shadow_object_id = p_sub_classification_rule_id;
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
    fnd_message.set_name('PAY', 'PAY_50111_SSR_INVALID_DELETE');
    fnd_message.raise_error;
  when others then
    hr_utility.set_location(' Leaving:'||l_proc, 20);
    raise;
End chk_delete;
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_rec     in     pay_ssr_shd.g_rec_type
  ) is
  --
  -- Cursor to disallow update if a core balance classification has been
  -- generated from this shadow balance classification.
  --
  cursor csr_disallow_update is
  select null
  from   pay_template_core_objects tco
  where  tco.core_object_type = pay_tco_shd.g_ssr_lookup_type
  and    tco.shadow_object_id = p_rec.sub_classification_rule_id;
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
  l_api_updating := pay_ssr_shd.api_updating
    (p_sub_classification_rule_id => p_rec.sub_classification_rule_id
    ,p_object_version_number      => p_rec.object_version_number
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
    fnd_message.set_name('PAY', 'PAY_50109_SSR_CORE_ROW_EXISTS');
    fnd_message.raise_error;
  end if;
  close csr_disallow_update;
  --
  -- p_element_type_id
  --
  if nvl(p_rec.element_type_id, hr_api.g_number) <>
     nvl(pay_ssr_shd.g_old_rec.element_type_id, hr_api.g_number)
  then
    hr_utility.set_location(l_proc, 20);
    l_argument := 'p_element_type_id';
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
-- |--------------------------< chk_element_type_id >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_element_type_id
  (p_element_type_id     in     number
  ) is
  --
  -- Cursor to check that the element type exists.
  --
  cursor csr_element_type_exists is
  select null
  from   pay_shadow_element_types sbt
  where  sbt.element_type_id = p_element_type_id;
--
  l_proc  varchar2(72) := g_package||'chk_element_type_id';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check that the element type is not null.
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'p_element_type_id'
  ,p_argument_value => p_element_type_id
  );
  --
  -- Check that the element type exists.
  --
  open csr_element_type_exists;
  fetch csr_element_type_exists into l_exists;
  if csr_element_type_exists%notfound then
    hr_utility.set_location(' Leaving:'||l_proc, 10);
    close csr_element_type_exists;
    fnd_message.set_name('PAY', 'PAY_50095_ETM_INVALID_ELE_TYPE');
    fnd_message.raise_error;
  end if;
  close csr_element_type_exists;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
End chk_element_type_id;
-- ----------------------------------------------------------------------------
-- |------------------------< chk_ele_classification >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_ele_classification
  (p_element_classification      in     varchar2
  ,p_element_type_id             in     number
  ,p_sub_classification_rule_id  in     number
  ,p_object_version_number       in     number
  ) is
  --
  -- Cursor to check the combination of element classification and
  -- balance type is unique.
  --
  cursor csr_sub_classi_rule_exists is
  select null
  from   pay_shadow_sub_classi_rules ssr
  where  ssr.element_type_id = p_element_type_id
  and    upper(ssr.element_classification) = upper(p_element_classification);
--
  l_proc  varchar2(72) := g_package||'chk_ele_classification';
  l_api_updating boolean;
  l_exists       varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_ssr_shd.api_updating
  (p_sub_classification_rule_id => p_sub_classification_rule_id
  ,p_object_version_number      => p_object_version_number
  );
  if (l_api_updating and nvl(p_element_classification, hr_api.g_varchar2)
     <> nvl(pay_ssr_shd.g_old_rec.element_classification, hr_api.g_varchar2))
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
    -- Check that the sub-classification rule is unique.
    --
    open csr_sub_classi_rule_exists;
    fetch csr_sub_classi_rule_exists into l_exists;
    if csr_sub_classi_rule_exists%found then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
      close csr_sub_classi_rule_exists;
      fnd_message.set_name('PAY', 'PAY_50110_SSR_RULE_EXISTS');
      fnd_message.raise_error;
    end if;
    close csr_sub_classi_rule_exists;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 25);
End chk_ele_classification;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pay_ssr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_element_type_id(p_rec.element_type_id);
  --
  chk_ele_classification
  (p_element_classification     => p_rec.element_classification
  ,p_element_type_id            => p_rec.element_type_id
  ,p_sub_classification_rule_id => p_rec.sub_classification_rule_id
  ,p_object_version_number      => p_rec.object_version_number
  );
  --
  chk_exclusion_rule_id
  (p_exclusion_rule_id          => p_rec.exclusion_rule_id
  ,p_element_type_id            => p_rec.element_type_id
  ,p_sub_classification_rule_id => p_rec.sub_classification_rule_id
  ,p_object_version_number      => p_rec.object_version_number
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pay_ssr_shd.g_rec_type) is
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
  (p_element_classification     => p_rec.element_classification
  ,p_element_type_id            => p_rec.element_type_id
  ,p_sub_classification_rule_id => p_rec.sub_classification_rule_id
  ,p_object_version_number      => p_rec.object_version_number
  );
  --
  chk_exclusion_rule_id
  (p_exclusion_rule_id          => p_rec.exclusion_rule_id
  ,p_element_type_id            => p_rec.element_type_id
  ,p_sub_classification_rule_id => p_rec.sub_classification_rule_id
  ,p_object_version_number      => p_rec.object_version_number
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pay_ssr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_delete(p_rec.sub_classification_rule_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_ssr_bus;

/
