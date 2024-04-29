--------------------------------------------------------
--  DDL for Package Body PQH_CET_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CET_BUS" as
/* $Header: pqcetrhi.pkb 120.2 2005/10/01 10:56:44 scnair noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_cet_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_copy_entity_txn_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the primary key for the table
--   is created properly. It should be null on insert and
--   should not be able to be updated.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   copy_entity_txn_id PK of record being inserted or updated.
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_copy_entity_txn_id(p_copy_entity_txn_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_copy_entity_txn_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_cet_shd.api_updating
    (p_copy_entity_txn_id                => p_copy_entity_txn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_copy_entity_txn_id,hr_api.g_number)
     <>  pqh_cet_shd.g_old_rec.copy_entity_txn_id) then
    --
    -- raise error as PK has changed
    --
    pqh_cet_shd.constraint_error('PQH_COPY_ENTITY_TXNS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_copy_entity_txn_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_cet_shd.constraint_error('PQH_COPY_ENTITY_TXNS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_copy_entity_txn_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_any_completed_target---|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_copy_entity_txn_id PK
--   p_txn_category_attribute_idf FK column
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_completed_target_err (p_copy_entity_txn_id  in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_completed_target_err';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  if pqh_cet_bus.chk_completed_target(p_copy_entity_txn_id) then
	   --
        -- raise error as atleast one target record has been successfully completed
        --
        pqh_cet_shd.constraint_error('PQH_COMPLETED_TARGET');
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_completed_target_err;
--
function chk_completed_target(p_copy_entity_txn_id in number) return boolean is
  --
  l_proc         varchar2(72) := g_package||'chk_completed_target';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_copy_entity_results a
    where  a.copy_entity_txn_id = p_copy_entity_txn_id
    and    a.result_type_cd     = 'TARGET'
    and    a.status             = 'COMPLETED' ;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  if p_copy_entity_txn_id is not null then
    --
    open c1;
    --
   fetch c1 into l_dummy;
      if c1%found then
        --
        close c1;
        --
        -- return true as atleast one target record has been found successfully completed
        --
	   return (TRUE);
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  return (FALSE);
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_completed_target;
--
-- ----------------------------------------------------------------------------
-- |------< chk_txn_category_attribute_id---|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_copy_entity_txn_id PK
--   p_txn_category_attribute_idf FK column
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_txn_category_attribute_id (p_copy_entity_txn_id          in number,
                            p_txn_category_attribute_id     in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_txn_category_attribute_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_txn_category_attributes a
    where  a.txn_category_attribute_id = p_txn_category_attribute_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_cet_shd.api_updating
     (p_copy_entity_txn_id            => p_copy_entity_txn_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_txn_category_attribute_id,hr_api.g_number)
     <> nvl(pqh_cet_shd.g_old_rec.txn_category_attribute_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if txn_category_attribute_id value exists in pqh_special_attributes table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_special_attributes
        -- table.
        --
        pqh_cet_shd.constraint_error('PQH_COPY_ENTITY_TXNS_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_txn_category_attribute_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_context_business_group_id---|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_copy_entity_txn_id PK
--   p_context_business_group_idf FK column
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_context_business_group_id (p_copy_entity_txn_id          in number,
                            p_context_business_group_id     in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_context_business_group_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_business_groups a
    where  a.business_group_id = p_context_business_group_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_cet_shd.api_updating
     (p_copy_entity_txn_id            => p_copy_entity_txn_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_context_business_group_id,hr_api.g_number)
     <> nvl(pqh_cet_shd.g_old_rec.context_business_group_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if context_business_group_id value exists in per_business_groups table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_business_groups
        -- table.
        --
        pqh_cet_shd.constraint_error('PQH_COPY_ENTITY_TXNS_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_context_business_group_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_transaction_category_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_copy_entity_txn_id PK
--   p_transaction_category_id ID of FK column
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_transaction_category_id (p_copy_entity_txn_id          in number,
                            p_transaction_category_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_transaction_category_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_transaction_categories a
    where  a.transaction_category_id = p_transaction_category_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_cet_shd.api_updating
     (p_copy_entity_txn_id            => p_copy_entity_txn_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_transaction_category_id,hr_api.g_number)
     <> nvl(pqh_cet_shd.g_old_rec.transaction_category_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if transaction_category_id value exists in pqh_transaction_categories table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_transaction_categories
        -- table.
        --
        pqh_cet_shd.constraint_error('PQH_COPY_ENTITY_TXNS_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_transaction_category_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_replacement_type_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   copy_entity_txn_id PK of record being inserted or updated.
--   replacement_type_cd Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_replacement_type_cd(p_copy_entity_txn_id                in number,
                            p_replacement_type_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_replacement_type_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_cet_shd.api_updating
    (p_copy_entity_txn_id                => p_copy_entity_txn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_replacement_type_cd
      <> nvl(pqh_cet_shd.g_old_rec.replacement_type_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_replacement_type_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_GEN_REPL_TYPE',
           p_lookup_code    => p_replacement_type_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_replacement_type_cd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_cet_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_copy_entity_txn_id
  (p_copy_entity_txn_id          => p_rec.copy_entity_txn_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_transaction_category_id
  (p_copy_entity_txn_id          => p_rec.copy_entity_txn_id,
   p_transaction_category_id          => p_rec.transaction_category_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_replacement_type_cd
  (p_copy_entity_txn_id          => p_rec.copy_entity_txn_id,
   p_replacement_type_cd         => p_rec.replacement_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pqh_cet_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_copy_entity_txn_id
  (p_copy_entity_txn_id          => p_rec.copy_entity_txn_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_transaction_category_id
  (p_copy_entity_txn_id          => p_rec.copy_entity_txn_id,
   p_transaction_category_id          => p_rec.transaction_category_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_replacement_type_cd
  (p_copy_entity_txn_id          => p_rec.copy_entity_txn_id,
   p_replacement_type_cd         => p_rec.replacement_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqh_cet_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pqh_cet_bus;

/
