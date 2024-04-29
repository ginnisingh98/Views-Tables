--------------------------------------------------------
--  DDL for Package Body PAY_SBA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SBA_BUS" as
/* $Header: pysbarhi.pkb 120.0 2005/05/29 08:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_sba_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
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
  (p_rec     in     pay_sba_shd.g_rec_type
  ) is
  --
  -- Cursor to disallow update if a core defined balance has been
  -- generated from this shadow defined balance.
  --
  cursor csr_disallow_update is
  select null
  from   pay_template_core_objects tco
  where  tco.core_object_type = pay_tco_shd.g_sba_lookup_type
  and    tco.shadow_object_id = p_rec.balance_attribute_id;
--
  l_proc  varchar2(72) := g_package||'chk_non_updateable_args';
  l_updating boolean;
  l_argument varchar2(30);
  l_api_updating boolean;
  l_disallow varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sba_shd.api_updating
    (p_balance_attribute_id    => p_rec.balance_attribute_id
    ,p_object_version_number   => p_rec.object_version_number
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
    fnd_message.set_name('PAY', 'PAY_50202_SBA_CORE_ROW_EXISTS');
    fnd_message.raise_error;
  end if;
  close csr_disallow_update;
  hr_utility.set_location(' Leaving:'||l_proc, 25);
exception
    when others then
       hr_utility.set_location('Leaving:'||l_proc, 35);
       raise;
End chk_non_updateable_args;
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_exclusion_rule_id >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_exclusion_rule_id
  (p_exclusion_rule_id     in     number
  ,p_defined_balance_id    in     number
  ,p_balance_attribute_id  in     number
  ,p_object_version_number in     number
  ) is
  --
  -- Cursor to check that the exclusion_rule_id is valid.
  --
  cursor csr_exclusion_rule_id_valid is
  select null
  from  pay_template_exclusion_rules ter
  ,     pay_shadow_balance_types bt
  ,     pay_shadow_defined_balances db
  where db.defined_balance_id = p_defined_balance_id
  and   bt.balance_type_id    = db.balance_type_id
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
  l_api_updating := pay_sba_shd.api_updating
  (p_balance_attribute_id  => p_balance_attribute_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_exclusion_rule_id, hr_api.g_number) <>
      nvl(pay_sba_shd.g_old_rec.exclusion_rule_id, hr_api.g_number)) or
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
-- |------------------------< chk_defined_balance_id >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_defined_balance_id
  (p_defined_balance_id     in     number
  ) is
  --
  -- Cursor to check that the balance type exists.
  --
  cursor csr_defined_balance_exists is
  select null
  from   pay_shadow_defined_balances sdb
  where  sdb.defined_balance_id = p_defined_balance_id;
--
  l_proc  varchar2(72) := g_package||'chk_defined_balance_id';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check that the balance type is not null.
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'p_defined_balance_id'
  ,p_argument_value => p_defined_balance_id
  );
  --
  -- Check that the balance type exists.
  --
  open csr_defined_balance_exists;
  fetch csr_defined_balance_exists into l_exists;
  if csr_defined_balance_exists%notfound then
    hr_utility.set_location(' Leaving:'||l_proc, 10);
    close csr_defined_balance_exists;
    fnd_message.set_name('PAY', 'PAY_50203_ETM_INVALID_DEF_BAL');
    fnd_message.raise_error;
  end if;
  close csr_defined_balance_exists;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
End chk_defined_balance_id;
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_attribute_name >--------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_attribute_name
  (p_attribute_name        in     varchar2
  ,p_defined_balance_id    in     number
  ,p_balance_attribute_id  in     number
  ,p_object_version_number in     number
  ) is
  --
  -- Cursor to check the combination of attribute name and defined balance
  -- is unique.
  --
  cursor csr_balance_attribute_exists is
  select null
  from   pay_shadow_bal_attributes sba
  where  sba.defined_balance_id = p_defined_balance_id
  and    upper(sba.attribute_name) = upper(p_attribute_name);
--
  l_proc  varchar2(72) := g_package||'chk_attribute_name';
  l_api_updating boolean;
  l_exists       varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sba_shd.api_updating
  (p_balance_attribute_id  => p_balance_attribute_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_attribute_name, hr_api.g_varchar2)
     <> nvl(pay_sba_shd.g_old_rec.attribute_name, hr_api.g_varchar2))
     or not l_api_updating
  then
    --
    -- Check that the attribute name is not null.
    --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_attribute_name'
    ,p_argument_value => p_attribute_name
    );
    --
    -- Check that the defined balance is unique.
    --
    open csr_balance_attribute_exists;
    fetch csr_balance_attribute_exists into l_exists;
    if csr_balance_attribute_exists%found then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
      close csr_balance_attribute_exists;
      fnd_message.set_name('PAY', 'PAY_50205_SBA_BAL_ATTR_EXISTS');
      fnd_message.raise_error;
    end if;
    close csr_balance_attribute_exists;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 25);
End chk_attribute_name;
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_delete >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (p_balance_attribute_id     in     number
  ) is
  --
  -- Cursors to check for rows referencing the balance classification.
  --
  cursor csr_core_objects is
  select null
  from   pay_template_core_objects tco
  where  tco.core_object_type = pay_tco_shd.g_sba_lookup_type
  and    tco.shadow_object_id = p_balance_attribute_id;
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
    fnd_message.set_name('PAY', 'PAY_50204_SBA_INVALID_DELETE');
    fnd_message.raise_error;
  when others then
    hr_utility.set_location(' Leaving:'||l_proc, 20);
    raise;
End chk_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in pay_sba_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS.
  --
  -- Validate Dependent Attributes
  --
  --
  chk_attribute_name
  (p_attribute_name        => p_rec.attribute_name
  ,p_defined_balance_id    => p_rec.defined_balance_id
  ,p_balance_attribute_id  => p_rec.balance_attribute_id
  ,p_object_version_number => p_rec.object_version_number
  );
  chk_defined_balance_id
  (p_defined_balance_id => p_rec.defined_balance_id
  );
  chk_exclusion_rule_id
  (p_exclusion_rule_id     => p_rec.exclusion_rule_id
  ,p_defined_balance_id    => p_rec.defined_balance_id
  ,p_balance_attribute_id  => p_rec.balance_attribute_id
  ,p_object_version_number => p_rec.object_version_number
  );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in pay_sba_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS.
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args(p_rec => p_rec);
  --
  --
  chk_attribute_name
  (p_attribute_name        => p_rec.attribute_name
  ,p_defined_balance_id    => p_rec.defined_balance_id
  ,p_balance_attribute_id  => p_rec.balance_attribute_id
  ,p_object_version_number => p_rec.object_version_number
  );
  chk_defined_balance_id
  (p_defined_balance_id => p_rec.defined_balance_id
  );
  chk_exclusion_rule_id
  (p_exclusion_rule_id     => p_rec.exclusion_rule_id
  ,p_defined_balance_id    => p_rec.defined_balance_id
  ,p_balance_attribute_id  => p_rec.balance_attribute_id
  ,p_object_version_number => p_rec.object_version_number
  );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pay_sba_shd.g_rec_type
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
  (p_balance_attribute_id => p_rec.balance_attribute_id
  );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_sba_bus;

/
