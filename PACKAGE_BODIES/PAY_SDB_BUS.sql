--------------------------------------------------------
--  DDL for Package Body PAY_SDB_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SDB_BUS" as
/* $Header: pysdbrhi.pkb 120.0 2005/05/29 08:35:06 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_sdb_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_rec     in     pay_sdb_shd.g_rec_type
  ) is
  --
  -- Cursor to disallow update if a core defined balance has been
  -- generated from this shadow defined balance.
  --
  cursor csr_disallow_update is
  select null
  from   pay_template_core_objects tco
  where  tco.core_object_type = pay_tco_shd.g_sdb_lookup_type
  and    tco.shadow_object_id = p_rec.defined_balance_id;
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
  l_api_updating := pay_sdb_shd.api_updating
    (p_defined_balance_id    => p_rec.defined_balance_id
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
    fnd_message.set_name('PAY', 'PAY_50090_SDB_CORE_ROW_EXISTS');
    fnd_message.raise_error;
  end if;
  close csr_disallow_update;
  --
  -- p_balance_type_id
  --
  if nvl(p_rec.balance_type_id, hr_api.g_number) <>
     nvl(pay_sdb_shd.g_old_rec.balance_type_id, hr_api.g_number)
  then
    hr_utility.set_location(l_proc, 25);
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
  (p_exclusion_rule_id     in     number
  ,p_balance_type_id       in     number
  ,p_defined_balance_id    in     number
  ,p_object_version_number in     number
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
  l_api_updating := pay_sdb_shd.api_updating
  (p_defined_balance_id    => p_defined_balance_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_exclusion_rule_id, hr_api.g_number) <>
      nvl(pay_sdb_shd.g_old_rec.exclusion_rule_id, hr_api.g_number)) or
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
-- |--------------------------< chk_dimension_name >--------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_dimension_name
  (p_dimension_name        in     varchar2
  ,p_balance_type_id       in     number
  ,p_defined_balance_id    in     number
  ,p_object_version_number in     number
  ) is
  --
  -- Cursor to check the combination of dimension and balance type is
  -- unique.
  --
  cursor csr_defined_balance_exists is
  select null
  from   pay_shadow_defined_balances sdb
  where  sdb.balance_type_id = p_balance_type_id
  and    upper(sdb.dimension_name) = upper(p_dimension_name);
--
  l_proc  varchar2(72) := g_package||'chk_dimension_name';
  l_api_updating boolean;
  l_exists       varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sdb_shd.api_updating
  (p_defined_balance_id    => p_defined_balance_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_dimension_name, hr_api.g_varchar2)
     <> nvl(pay_sdb_shd.g_old_rec.dimension_name, hr_api.g_varchar2))
     or not l_api_updating
  then
    --
    -- Check that the balance dimension is not null.
    --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_dimension_name'
    ,p_argument_value => p_dimension_name
    );
    --
    -- Check that the defined balance is unique.
    --
    open csr_defined_balance_exists;
    fetch csr_defined_balance_exists into l_exists;
    if csr_defined_balance_exists%found then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
      close csr_defined_balance_exists;
      fnd_message.set_name('PAY', 'PAY_50091_SDB_DEF_BAL_EXISTS');
      fnd_message.raise_error;
    end if;
    close csr_defined_balance_exists;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 25);
End chk_dimension_name;
-- ----------------------------------------------------------------------------
-- |---------------------< chk_force_latest_bal_flag >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_force_latest_bal_flag
(p_effective_date            in date
,p_force_latest_balance_flag in varchar2
,p_defined_balance_id        in number
,p_object_version_number     in number
) is
--
  l_proc  varchar2(72) := g_package||'chk_force_latest_bal_flag';
  l_api_updating boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sdb_shd.api_updating
  (p_defined_balance_id    => p_defined_balance_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and
      nvl(p_force_latest_balance_flag, hr_api.g_varchar2) <>
      nvl(pay_sdb_shd.g_old_rec.force_latest_balance_flag, hr_api.g_varchar2))
     or not l_api_updating
  then
    if p_force_latest_balance_flag is not null then
      --
      -- Validate against hr_lookups.
      --
      if hr_api.not_exists_in_hr_lookups
         (p_effective_date => p_effective_date
         ,p_lookup_type    => 'YES_NO'
         ,p_lookup_code    => p_force_latest_balance_flag
         )
      then
        hr_utility.set_location(' Leaving:'||l_proc, 10);
        fnd_message.set_name('PAY', 'HR_52966_INVALID_LOOKUP');
        fnd_message.set_token('LOOKUP_TYPE', 'YES_NO');
        fnd_message.set_token('COLUMN', 'FORCE_LATEST_BALANCE_FLAG');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End chk_force_latest_bal_flag;
-- ----------------------------------------------------------------------------
-- |---------------------< chk_grossup_allowed_flag >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_grossup_allowed_flag
(p_effective_date            in date
,p_grossup_allowed_flag      in varchar2
,p_defined_balance_id        in number
,p_object_version_number     in number
) is
--
  l_proc  varchar2(72) := g_package||'chk_grossup_allowed_flag';
  l_api_updating boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sdb_shd.api_updating
  (p_defined_balance_id    => p_defined_balance_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and
      nvl(p_grossup_allowed_flag, hr_api.g_varchar2) <>
      nvl(pay_sdb_shd.g_old_rec.grossup_allowed_flag, hr_api.g_varchar2))
     or not l_api_updating
  then
    if p_grossup_allowed_flag is not null then
      --
      -- Validate against hr_lookups.
      --
      if hr_api.not_exists_in_hr_lookups
         (p_effective_date => p_effective_date
         ,p_lookup_type    => 'YES_NO'
         ,p_lookup_code    => p_grossup_allowed_flag
         )
      then
        hr_utility.set_location(' Leaving:'||l_proc, 10);
        fnd_message.set_name('PAY', 'HR_52966_INVALID_LOOKUP');
        fnd_message.set_token('LOOKUP_TYPE', 'YES_NO');
        fnd_message.set_token('COLUMN', 'GROSSUP_ALLOWED_FLAG');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End chk_grossup_allowed_flag;
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_delete >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (p_defined_balance_id     in     number
  ) is
  --
  -- Cursors to check for rows referencing the balance classification.
  --
  cursor csr_core_objects is
  select null
  from   pay_template_core_objects tco
  where  tco.core_object_type = pay_tco_shd.g_sdb_lookup_type
  and    tco.shadow_object_id = p_defined_balance_id;
  --
  cursor csr_bal_attributes is
  select null
  from   pay_shadow_bal_attributes ba
  where  ba.defined_balance_id = p_defined_balance_id
  ;
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
  --
  open csr_bal_attributes;
  fetch csr_bal_attributes into l_exists;
  if csr_bal_attributes%found then
    hr_utility.set_location(' Leaving:'||l_proc, 12);
    close csr_bal_attributes;
    raise l_error;
  end if;
  close csr_bal_attributes;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
exception
  when l_error then
    fnd_message.set_name('PAY', 'PAY_50092_SDB_INVALID_DELETE');
    fnd_message.raise_error;
  when others then
    hr_utility.set_location(' Leaving:'||l_proc, 20);
    raise;
End chk_delete;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
(p_effective_date in date
,p_rec in pay_sdb_shd.g_rec_type
) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_balance_type_id(p_rec.balance_type_id);
  --
  chk_dimension_name
  (p_dimension_name        => p_rec.dimension_name
  ,p_balance_type_id       => p_rec.balance_type_id
  ,p_defined_balance_id    => p_rec.defined_balance_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_force_latest_bal_flag
  (p_effective_date            => p_effective_date
  ,p_force_latest_balance_flag => p_rec.force_latest_balance_flag
  ,p_defined_balance_id        => p_rec.defined_balance_id
  ,p_object_version_number     => p_rec.object_version_number
  );
  --
  chk_grossup_allowed_flag
  (p_effective_date            => p_effective_date
  ,p_grossup_allowed_flag      => p_rec.grossup_allowed_flag
  ,p_defined_balance_id        => p_rec.defined_balance_id
  ,p_object_version_number     => p_rec.object_version_number
  );
  --
  chk_exclusion_rule_id
  (p_exclusion_rule_id     => p_rec.exclusion_rule_id
  ,p_balance_type_id       => p_rec.balance_type_id
  ,p_defined_balance_id    => p_rec.defined_balance_id
  ,p_object_version_number => p_rec.object_version_number
  );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
(p_effective_date in date
,p_rec in pay_sdb_shd.g_rec_type
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
  chk_dimension_name
  (p_dimension_name        => p_rec.dimension_name
  ,p_balance_type_id       => p_rec.balance_type_id
  ,p_defined_balance_id    => p_rec.defined_balance_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_force_latest_bal_flag
  (p_effective_date            => p_effective_date
  ,p_force_latest_balance_flag => p_rec.force_latest_balance_flag
  ,p_defined_balance_id        => p_rec.defined_balance_id
  ,p_object_version_number     => p_rec.object_version_number
  );
  --
  chk_grossup_allowed_flag
  (p_effective_date            => p_effective_date
  ,p_grossup_allowed_flag      => p_rec.grossup_allowed_flag
  ,p_defined_balance_id        => p_rec.defined_balance_id
  ,p_object_version_number     => p_rec.object_version_number
  );
  --
  chk_exclusion_rule_id
  (p_exclusion_rule_id     => p_rec.exclusion_rule_id
  ,p_balance_type_id       => p_rec.balance_type_id
  ,p_defined_balance_id    => p_rec.defined_balance_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pay_sdb_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_delete(p_rec.defined_balance_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_sdb_bus;

/
