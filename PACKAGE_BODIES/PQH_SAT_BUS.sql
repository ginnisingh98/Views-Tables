--------------------------------------------------------
--  DDL for Package Body PQH_SAT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_SAT_BUS" as
/* $Header: pqsatrhi.pkb 120.2 2005/10/12 20:19:29 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_sat_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_special_attribute_id >------|
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
--   special_attribute_id PK of record being inserted or updated.
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
Procedure chk_special_attribute_id(p_special_attribute_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_special_attribute_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_sat_shd.api_updating
    (p_special_attribute_id                => p_special_attribute_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_special_attribute_id,hr_api.g_number)
     <>  pqh_sat_shd.g_old_rec.special_attribute_id) then
    --
    -- raise error as PK has changed
    --
    pqh_sat_shd.constraint_error('PQH_SPECIAL_ATTRIBUTES_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_special_attribute_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_sat_shd.constraint_error('PQH_SPECIAL_ATTRIBUTES_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_special_attribute_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_context >------|
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
--   p_special_attribute_id PK
--   p_context ID of FK column
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
Procedure chk_context (p_special_attribute_id          in number,
                            p_context          in varchar2,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_context';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_copy_entity_contexts a
    where  a.context = p_context;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_sat_shd.api_updating
     (p_special_attribute_id            => p_special_attribute_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_context,hr_api.g_varchar2)
     <> nvl(pqh_sat_shd.g_old_rec.context,hr_api.g_varchar2)
     or not l_api_updating) then
    --
    -- check if context value exists in pqh_copy_entity_contexts table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_copy_entity_contexts
        -- table.
        --
        pqh_sat_shd.constraint_error('PQH_SPECIAL_ATTRIBUTES_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_context;
--
-- ----------------------------------------------------------------------------
-- |------< chk_txn_category_attribute_id >------|
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
--   p_special_attribute_id PK
--   p_txn_category_attribute_id ID of FK column
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
Procedure chk_txn_category_attribute_id (p_special_attribute_id          in number,
                            p_txn_category_attribute_id          in number,
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
  l_api_updating := pqh_sat_shd.api_updating
     (p_special_attribute_id            => p_special_attribute_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_txn_category_attribute_id,hr_api.g_number)
     <> nvl(pqh_sat_shd.g_old_rec.txn_category_attribute_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if txn_category_attribute_id value exists in pqh_txn_category_attributes table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_txn_category_attributes
        -- table.
        --
        pqh_sat_shd.constraint_error('PQH_SPECIAL_ATTRIBUTES_FK1');
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
-- |------< chk_key_attribute_type >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   special_attribute_id PK of record being inserted or updated.
--   key_attribute_type Value of lookup code.
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
Procedure chk_key_attribute_type(p_special_attribute_id                in number,
                            p_key_attribute_type               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_key_attribute_type';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_sat_shd.api_updating
    (p_special_attribute_id                => p_special_attribute_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_key_attribute_type
      <> nvl(pqh_sat_shd.g_old_rec.key_attribute_type,hr_api.g_varchar2)
      or not l_api_updating)
      and p_key_attribute_type is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_ATTRIBUTE_TYPE_CD',
           p_lookup_code    => p_key_attribute_type,
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
end chk_key_attribute_type;
-- ----------------------------------------------------------------------------
-- |------< chk_enable_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   special_attribute_id PK of record being inserted or updated.
--   enable_flag Value of lookup code.
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
Procedure chk_enable_flag(p_special_attribute_id                in number,
                            p_enable_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enable_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_sat_shd.api_updating
    (p_special_attribute_id                => p_special_attribute_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enable_flag
      <> nvl(pqh_sat_shd.g_old_rec.enable_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_enable_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_enable_flag,
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
end chk_enable_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_attribute_type_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   special_attribute_id PK of record being inserted or updated.
--   attribute_type_cd Value of lookup code.
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
Procedure chk_attribute_type_cd(p_special_attribute_id                in number,
                            p_attribute_type_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_attribute_type_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_sat_shd.api_updating
    (p_special_attribute_id                => p_special_attribute_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_attribute_type_cd
      <> nvl(pqh_sat_shd.g_old_rec.attribute_type_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_attribute_type_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_ATTRIBUTE_TYPE_CD',
           p_lookup_code    => p_attribute_type_cd,
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
end chk_attribute_type_cd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_sat_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_special_attribute_id
  (p_special_attribute_id          => p_rec.special_attribute_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_context
  (p_special_attribute_id          => p_rec.special_attribute_id,
   p_context          => p_rec.context,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_txn_category_attribute_id
  (p_special_attribute_id          => p_rec.special_attribute_id,
   p_txn_category_attribute_id          => p_rec.txn_category_attribute_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_attribute_type_cd
  (p_special_attribute_id          => p_rec.special_attribute_id,
   p_attribute_type_cd         => p_rec.attribute_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_key_attribute_type
  (p_special_attribute_id  => p_rec.special_attribute_id,
   p_key_attribute_type    => p_rec.key_attribute_type,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enable_flag
  (p_special_attribute_id  => p_rec.special_attribute_id,
   p_enable_flag           => p_rec.enable_flag,
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
Procedure update_validate(p_rec in pqh_sat_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_special_attribute_id
  (p_special_attribute_id          => p_rec.special_attribute_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_context
  (p_special_attribute_id          => p_rec.special_attribute_id,
   p_context          => p_rec.context,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_txn_category_attribute_id
  (p_special_attribute_id          => p_rec.special_attribute_id,
   p_txn_category_attribute_id          => p_rec.txn_category_attribute_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_attribute_type_cd
  (p_special_attribute_id          => p_rec.special_attribute_id,
   p_attribute_type_cd         => p_rec.attribute_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_key_attribute_type
  (p_special_attribute_id  => p_rec.special_attribute_id,
   p_key_attribute_type    => p_rec.key_attribute_type,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enable_flag
  (p_special_attribute_id  => p_rec.special_attribute_id,
   p_enable_flag           => p_rec.enable_flag,
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
Procedure delete_validate(p_rec in pqh_sat_shd.g_rec_type
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
end pqh_sat_bus;

/
