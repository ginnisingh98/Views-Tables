--------------------------------------------------------
--  DDL for Package Body PAY_SGB_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SGB_BUS" as
/* $Header: pysgbrhi.pkb 115.3 2003/02/05 17:11:07 arashid noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_sgb_bus.';  -- Global package name
--
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
  (p_rec in pay_sgb_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_sgb_shd.api_updating
      (p_grossup_balances_id                  => p_rec.grossup_balances_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- p_source_id
  --
  if nvl(p_rec.source_id, hr_api.g_number) <>
     nvl(pay_sgb_shd.g_old_rec.source_id, hr_api.g_number)
  then
        l_argument := 'p_source_id';
     raise l_error;
  end if;
  --
  --
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_source_id >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_source_id
  (p_source_id in number
  ) is
  --
  -- Cursor to check that the source_id references an existing element type
  --
  cursor c_element_type_exists is
  select null
  from   pay_shadow_element_types pset
  where  pset.element_type_id = p_source_id;
--
  l_proc   varchar2(72) := g_package||'chk_source_id';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check that the source_id is not null.
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'SOURCE_ID'
  ,p_argument_value => p_source_id
  );
  --
  -- Check that the source_id references an existing element type
  --
  open c_element_type_exists;
  fetch c_element_type_exists into l_exists;
  if c_element_type_exists%notfound then
    close c_element_type_exists;
    fnd_message.set_name('PAY', 'PAY_50095_ETM_INVALID_ELE_TYPE');
    fnd_message.raise_error;
  end if;
  close c_element_type_exists;
  hr_utility.set_location('Leaving:'||l_proc, 10);
End chk_source_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_source_type >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_source_type
  (p_source_type in varchar2
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_source_type';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  if UPPER(p_source_type) <> 'ET' then
    fnd_message.set_name('PAY', 'PAY_50120_SGB_BAD_SOURCE_TYPE');
    fnd_message.set_token('SOURCE_TYPE', p_source_type);
    fnd_message.raise_error;
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 10);
End chk_source_type;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_balance_type_name >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_balance_type_name
  (p_balance_type_name in varchar2
  ,p_balance_type_id   in number
  ) is
--
  l_proc         varchar2(72) := g_package||'chk_balance_type_name';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  if p_balance_type_id is null then
    --
    -- Balance type name is mandatory
    --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'BALANCE_TYPE_NAME'
    ,p_argument_value => p_balance_type_name
    );
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 10);
End chk_balance_type_name;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_balance_type_id >--------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_balance_type_id
  (p_balance_type_id       in number
  ,p_balance_type_name     in varchar2
  ,p_source_id             in number
  ,p_grossup_balances_id   in number
  ,p_object_version_number in number
  ) is
--
-- Cursor to check that the balance_type_id is valid.
--
cursor c_bal_type_id_valid is
select null
from   pay_shadow_balance_types sbt
,      pay_shadow_element_types pset
where  sbt.balance_type_id = p_balance_type_id
and    sbt.template_id     = pset.template_id
and    pset.element_type_id = p_source_id;
--
  l_proc         varchar2(72) := g_package||'chk_balance_type_id';
  l_api_updating boolean;
  l_valid        varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sgb_shd.api_updating
  (p_grossup_balances_id   => p_grossup_balances_id
  ,p_object_version_number => p_object_version_number
  );
  if p_balance_type_name is null then
    --
    -- Balance type ID is mandatory
    --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'BALANCE_TYPE_ID'
    ,p_argument_value => p_balance_type_id
    );
  end if;
--
  if (l_api_updating and nvl(p_balance_type_id, hr_api.g_number) <>
     nvl(pay_sgb_shd.g_old_rec.balance_type_id, hr_api.g_number)) or
     not l_api_updating
  then
    if p_balance_type_id is not null then
      open c_bal_type_id_valid;
      fetch c_bal_type_id_valid into l_valid;
      if c_bal_type_id_valid%notfound then
        close c_bal_type_id_valid;
        fnd_message.set_name('PAY', 'PAY_50086_ETM_INVALID_BAL_TYPE');
        fnd_message.raise_error;
      end if;
      close c_bal_type_id_valid;
    end if;
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 10);
End chk_balance_type_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_exclusion_rule_id >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_exclusion_rule_id
  (p_exclusion_rule_id      in number
  ,p_source_id              in number
  ,p_grossup_balances_id    in number
  ,p_object_version_number  in number
  ) is
--
-- Cursor to check that the exclusion_rule_id is valid.
--
cursor c_exclusion_rule_id_valid is
select null
from   pay_shadow_element_types     pset
,      pay_template_exclusion_rules ter
where  ter.exclusion_rule_id = p_exclusion_rule_id
and    ter.template_id       = pset.template_id
and    pset.element_type_id   = p_source_id;
--
  l_proc         varchar2(72) := g_package||'chk_exclusion_rule_id';
  l_api_updating boolean;
  l_valid        varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sgb_shd.api_updating
  (p_grossup_balances_id   => p_grossup_balances_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_exclusion_rule_id, hr_api.g_number) <>
     nvl(pay_sgb_shd.g_old_rec.exclusion_rule_id, hr_api.g_number)) or
     not l_api_updating
  then
    if p_exclusion_rule_id is not null then
    open c_exclusion_rule_id_valid;
    fetch c_exclusion_rule_id_valid into l_valid;
      if c_exclusion_rule_id_valid%notfound then
        close c_exclusion_rule_id_valid;
        fnd_message.set_name('PAY', 'PAY_50100_ETM_INVALID_EXC_RULE');
        fnd_message.raise_error;
      end if;
      close c_exclusion_rule_id_valid;
    end if;
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 10);
End chk_exclusion_rule_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_delete >-------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (p_grossup_balances_id in number
  ) is
--
-- Cursor to check for rows referencing the balance exclusion
--
cursor c_core_objects is
select null
from   pay_template_core_objects tco
where  tco.core_object_type = pay_tco_shd.g_sgb_lookup_type
and    tco.shadow_object_id = p_grossup_balances_id;
--
  l_proc   varchar2(72) := g_package||'chk_delete';
  l_error  exception;
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_core_objects;
  fetch c_core_objects into l_exists;
  if c_core_objects%found then
    close c_core_objects;
    raise l_error;
  end if;
  close c_core_objects;
  hr_utility.set_location('Leaving:'||l_proc, 10);
exception
  when l_error then
    fnd_message.set_name('PAY', 'PAY_50119_SGB_INVALID_DELETE');
    fnd_message.raise_error;
  when others then
    hr_utility.set_location('Leaving:'||l_proc, 15);
    raise;
End chk_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pay_sgb_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_source_id(p_rec.source_id);
  --
  chk_source_type(p_rec.source_type);
  --
  chk_balance_type_name
  (p_balance_type_name => p_rec.balance_type_name
  ,p_balance_type_id   => p_rec.balance_type_id
  );
  --
  chk_balance_type_id
  (p_balance_type_id       => p_rec.balance_type_id
  ,p_balance_type_name     => p_rec.balance_type_name
  ,p_source_id             => p_rec.source_id
  ,p_grossup_balances_id   => p_rec.grossup_balances_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_exclusion_rule_id
  (p_exclusion_rule_id     => p_rec.exclusion_rule_id
  ,p_source_id             => p_rec.source_id
  ,p_grossup_balances_id   => p_rec.grossup_balances_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in pay_sgb_shd.g_rec_type
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
  chk_source_type(p_rec.source_type);
  --
  chk_balance_type_name
  (p_balance_type_name => p_rec.balance_type_name
  ,p_balance_type_id   => p_rec.balance_type_id
  );
  --
  chk_balance_type_id
  (p_balance_type_id       => p_rec.balance_type_id
  ,p_balance_type_name     => p_rec.balance_type_name
  ,p_source_id             => p_rec.source_id
  ,p_grossup_balances_id   => p_rec.grossup_balances_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_exclusion_rule_id
  (p_exclusion_rule_id     => p_rec.exclusion_rule_id
  ,p_source_id             => p_rec.source_id
  ,p_grossup_balances_id   => p_rec.grossup_balances_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pay_sgb_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_delete(p_rec.grossup_balances_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_sgb_bus;

/
