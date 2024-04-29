--------------------------------------------------------
--  DDL for Package Body PQH_TCA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_TCA_BUS" as
/* $Header: pqtcarhi.pkb 120.2 2005/10/12 20:19:48 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_tca_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_txn_category_attribute_id >------|
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
--   txn_category_attribute_id PK of record being inserted or updated.
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
Procedure chk_txn_category_attribute_id(p_txn_category_attribute_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_txn_category_attribute_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tca_shd.api_updating
    (p_txn_category_attribute_id                => p_txn_category_attribute_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_txn_category_attribute_id,hr_api.g_number)
     <>  pqh_tca_shd.g_old_rec.txn_category_attribute_id) then
    --
    -- raise error as PK has changed
    --
    pqh_tca_shd.constraint_error('PQH_TXN_CATEGORY_ATTRIBUTES_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_txn_category_attribute_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_tca_shd.constraint_error('PQH_TXN_CATEGORY_ATTRIBUTES_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_txn_category_attribute_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_transaction_table_route_id >------|
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
--   p_txn_category_attribute_id PK
--   p_transaction_table_route_id ID of FK column
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
Procedure chk_transaction_table_route_id (p_txn_category_attribute_id          in number,
                            p_transaction_table_route_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_transaction_table_route_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_table_route a
    where  a.table_route_id = p_transaction_table_route_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_tca_shd.api_updating
     (p_txn_category_attribute_id            => p_txn_category_attribute_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_transaction_table_route_id,hr_api.g_number)
     <> nvl(pqh_tca_shd.g_old_rec.transaction_table_route_id,hr_api.g_number)
     or not l_api_updating) and
     p_transaction_table_route_id is not null then
    --
    -- check if transaction_table_route_id value exists in pqh_table_route table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_table_route
        -- table.
        --
        pqh_tca_shd.constraint_error('PQH_TXN_CAT_ATTRIBUTES_FK4');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_transaction_table_route_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_value_set_id >------|
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
--   p_txn_category_attribute_id PK
--   p_value_set_id ID of FK column
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
Procedure chk_value_set_id (p_txn_category_attribute_id          in number,
                            p_value_set_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_value_set_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   fnd_flex_value_sets a
    where  a.flex_value_Set_id = p_value_set_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_tca_shd.api_updating
     (p_txn_category_attribute_id            => p_txn_category_attribute_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_value_set_id,hr_api.g_number)
     <> nvl(pqh_tca_shd.g_old_rec.value_set_id,hr_api.g_number)
     or not l_api_updating) and
     p_value_set_id is not null then
    --
    -- check if value_Set_id value exists in fnd_flex_value_Sets table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_table_route
        -- table.
        --
        pqh_tca_shd.constraint_error('PQH_TXN_CAT_ATTRIBUTES_FK5');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_value_set_id;
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
--   p_txn_category_attribute_id PK
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
Procedure chk_transaction_category_id (p_txn_category_attribute_id          in number,
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
  l_api_updating := pqh_tca_shd.api_updating
     (p_txn_category_attribute_id            => p_txn_category_attribute_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_transaction_category_id,hr_api.g_number)
     <> nvl(pqh_tca_shd.g_old_rec.transaction_category_id,hr_api.g_number)
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
        pqh_tca_shd.constraint_error('PQH_TXN_CATEGORY_ATTRIBUTE_FK2');
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
-- |------< chk_attribute_id >------|
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
--   p_txn_category_attribute_id PK
--   p_attribute_id ID of FK column
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
Procedure chk_attribute_id (p_txn_category_attribute_id          in number,
                            p_attribute_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_attribute_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_attributes a
    where  a.attribute_id = p_attribute_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_tca_shd.api_updating
     (p_txn_category_attribute_id            => p_txn_category_attribute_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_attribute_id,hr_api.g_number)
     <> nvl(pqh_tca_shd.g_old_rec.attribute_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if attribute_id value exists in pqh_attributes table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_attributes
        -- table.
        --
        pqh_tca_shd.constraint_error('PQH_TXN_CATEGORY_ATTRIBUTE_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_attribute_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_value_style_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   txn_category_attribute_id PK of record being inserted or updated.
--   value_style_cd Value of lookup code.
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
Procedure chk_value_style_cd(p_txn_category_attribute_id                in number,
                            p_value_style_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_value_style_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tca_shd.api_updating
    (p_txn_category_attribute_id                => p_txn_category_attribute_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_value_style_cd
      <> nvl(pqh_tca_shd.g_old_rec.value_style_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_value_style_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_VALUE_STYLE',
           p_lookup_code    => p_value_style_cd,
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
end chk_value_style_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_refresh_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   txn_category_attribute_id PK of record being inserted or updated.
--   refresh_flag Value of lookup code.
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
Procedure chk_refresh_flag(p_txn_category_attribute_id                in number,
                            p_refresh_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_refresh_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tca_shd.api_updating
    (p_txn_category_attribute_id                => p_txn_category_attribute_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_refresh_flag
      <> nvl(pqh_tca_shd.g_old_rec.refresh_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_refresh_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_refresh_flag,
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
end chk_refresh_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_select_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   txn_category_attribute_id PK of record being inserted or updated.
--   select_flag Value of lookup code.
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
Procedure chk_select_flag(p_txn_category_attribute_id                in number,
                          p_select_flag                 in varchar2,
                          p_effective_date              in date,
                          p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_select_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tca_shd.api_updating
    (p_txn_category_attribute_id                => p_txn_category_attribute_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_select_flag
      <> nvl(pqh_tca_shd.g_old_rec.select_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_select_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_select_flag,
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
end chk_select_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_member_identifying_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   txn_category_attribute_id PK of record being inserted or updated.
--   member_identifying_flag Value of lookup code.
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
Procedure chk_member_identifying_flag(
                            p_txn_category_attribute_id   in number,
                            p_attribute_id                in number,
                            p_identifier_flag             in varchar2,
                            p_delete_attr_ranges_flag     in varchar2,
                            p_member_identifying_flag     in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_member_identifying_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tca_shd.api_updating
    (p_txn_category_attribute_id                => p_txn_category_attribute_id,
     p_object_version_number       => p_object_version_number);
  --
  --
  -- Error if child rows exists in pqh_attribute_ranges
  --
  if (l_api_updating
      and nvl(p_member_identifying_flag,hr_api.g_varchar2)
       <> nvl(pqh_tca_shd.g_old_rec.member_identifying_flag,hr_api.g_varchar2))
     then
       --
       if p_member_identifying_flag = 'N' then
       --
       --
          pqh_ATTRIBUTE_RANGES_pkg.Delete_attribute_ranges
                       (p_attribute_id            => p_attribute_id,
                        p_delete_attr_ranges_flag => p_delete_attr_ranges_flag ,
                        p_primary_flag            => 'N');
       --
       --
       end if;
       --
  end if;
  --

  if (l_api_updating
      and p_member_identifying_flag
      <> nvl(pqh_tca_shd.g_old_rec.member_identifying_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_member_identifying_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_member_identifying_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
    --
    --  CHECK if identifier_flag is Y
    --  member_identifying_flag can be Y only if identifier_flag is Y
    --
       if nvl(p_identifier_flag,hr_api.g_varchar2) <> 'Y' and p_member_identifying_flag = 'Y' then
          --
          -- raise error
          --
          hr_utility.set_message(8302,'PQH_INVALID_MEMBER_IDENTIFIER');
          hr_utility.raise_error;
          --
       end if;
    --

  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_member_identifying_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_list_identifying_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   txn_category_attribute_id PK of record being inserted or updated.
--   list_identifying_flag Value of lookup code.
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
Procedure chk_list_identifying_flag(
                            p_txn_category_attribute_id   in number,
                            p_attribute_id                in number,
                            p_identifier_flag             in varchar2,
                            p_delete_attr_ranges_flag     in varchar2,
                            p_list_identifying_flag       in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_list_identifying_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tca_shd.api_updating
    (p_txn_category_attribute_id                => p_txn_category_attribute_id,
     p_object_version_number       => p_object_version_number);
  --
  --
  -- Error if records exist in pqh_attribute_ranges for this attribute_id
  --
  if (l_api_updating
      and nvl(p_list_identifying_flag,hr_api.g_varchar2)
      <>  nvl(pqh_tca_shd.g_old_rec.list_identifying_flag,hr_api.g_varchar2)) then
      --
       if p_list_identifying_flag = 'N' then
        --
          pqh_ATTRIBUTE_RANGES_pkg.Delete_attribute_ranges
                       (p_attribute_id            => p_attribute_id,
                        p_delete_attr_ranges_flag => p_delete_attr_ranges_flag ,
                        p_primary_flag            => 'Y');
       end if;
     --

  end if;
  --

  if (l_api_updating
      and p_list_identifying_flag
      <> nvl(pqh_tca_shd.g_old_rec.list_identifying_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_list_identifying_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_list_identifying_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
    --
    --  CHECK if identifier_flag is Y
    --  list_identifying_flag can be Y only if identifier_flag is Y
    --
    if nvl(p_identifier_flag,hr_api.g_varchar2) <> 'Y' and p_list_identifying_flag = 'Y' then
       --
       -- raise error
       --
       hr_utility.set_message(8302,'PQH_INVALID_LIST_IDENTIFIER');
       hr_utility.raise_error;
       --
   end if;
   --

  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_list_identifying_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_identifier_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   txn_category_attribute_id PK of record being inserted or updated.
--   identifier_flag Value of lookup code.
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
Procedure chk_identifier_flag(p_txn_category_attribute_id                in number,
                            p_identifier_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_identifier_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tca_shd.api_updating
    (p_txn_category_attribute_id                => p_txn_category_attribute_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_identifier_flag
      <> nvl(pqh_tca_shd.g_old_rec.identifier_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_identifier_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_identifier_flag,
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
end chk_identifier_flag;
--
------------------------------------------------------------------------------
--     Additional checks
------------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |------< chk_transaction_category_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that no attributes are added once its
--   associated transaction_category_id is frozen
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_attribute_id PK
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
Procedure chk_transaction_cat_status (p_attribute_id          in number,
                                       p_object_version_number in number) is
  --
  l_proc              varchar2(72) := g_package||'chk_transaction_cat_status';
  l_api_updating      boolean;
  l_freeze_status_cd  pqh_transaction_categories.freeze_status_cd%type;
  --
  cursor c1 is
    select nvl(b.freeze_status_cd,hr_api.g_varchar2)
    from   pqh_txn_category_attributes a, pqh_transaction_categories b
    where  a.attribute_id = p_attribute_id
      AND  a.transaction_category_id = b.transaction_category_id;
  --
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  --
  if l_freeze_status_cd = 'FREEZE_ATTRIBUTES'
  OR l_freeze_status_cd = 'FREEZE_CATEGORY' then
     hr_utility.set_message(8302,'PQH_CANNOT_MODIFY_TXN_CAT_ATTR');
     hr_utility.raise_error;
  End if;

  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_transaction_cat_status;
--

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_tca_shd.g_rec_type
                         ,p_effective_date in date) is
  p_delete_attr_ranges_flag varchar2(10) := 'N';
--
  l_proc  varchar2(72) := g_package||'insert_validate';

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_txn_category_attribute_id
  (p_txn_category_attribute_id          => p_rec.txn_category_attribute_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_transaction_table_route_id
  (p_txn_category_attribute_id          => p_rec.txn_category_attribute_id,
   p_transaction_table_route_id          => p_rec.transaction_table_route_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_value_set_id
  (p_txn_category_attribute_id     => p_rec.txn_category_attribute_id,
   p_value_set_id                  => p_rec.value_set_id,
   p_object_version_number         => p_rec.object_version_number);
  --
  chk_transaction_category_id
  (p_txn_category_attribute_id     => p_rec.txn_category_attribute_id,
   p_transaction_category_id       => p_rec.transaction_category_id,
   p_object_version_number         => p_rec.object_version_number);
  --
  chk_attribute_id
  (p_txn_category_attribute_id          => p_rec.txn_category_attribute_id,
   p_attribute_id          => p_rec.attribute_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_value_style_cd
  (p_txn_category_attribute_id          => p_rec.txn_category_attribute_id,
   p_value_style_cd         => p_rec.value_style_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_refresh_flag
  (p_txn_category_attribute_id          => p_rec.txn_category_attribute_id,
   p_refresh_flag         => p_rec.refresh_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_select_flag
  (p_txn_category_attribute_id          => p_rec.txn_category_attribute_id,
   p_select_flag         => p_rec.select_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_member_identifying_flag
  (p_txn_category_attribute_id          => p_rec.txn_category_attribute_id,
   p_attribute_id          => p_rec.attribute_id,
   p_identifier_flag         => p_rec.identifier_flag,
   p_delete_attr_ranges_flag  => p_delete_attr_ranges_flag,
   p_member_identifying_flag         => p_rec.member_identifying_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_list_identifying_flag
  (p_txn_category_attribute_id          => p_rec.txn_category_attribute_id,
   p_attribute_id          => p_rec.attribute_id,
   p_identifier_flag         => p_rec.identifier_flag,
   p_delete_attr_ranges_flag  => p_delete_attr_ranges_flag,
   p_list_identifying_flag         => p_rec.list_identifying_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_identifier_flag
  (p_txn_category_attribute_id          => p_rec.txn_category_attribute_id,
   p_identifier_flag         => p_rec.identifier_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_transaction_cat_status
  (p_attribute_id          => p_rec.attribute_id,
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
Procedure update_validate(p_rec in pqh_tca_shd.g_rec_type
                         ,p_effective_date in date
                         ,p_delete_attr_ranges_flag in varchar2) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_txn_category_attribute_id
  (p_txn_category_attribute_id          => p_rec.txn_category_attribute_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_transaction_table_route_id
  (p_txn_category_attribute_id          => p_rec.txn_category_attribute_id,
   p_transaction_table_route_id          => p_rec.transaction_table_route_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_value_set_id
  (p_txn_category_attribute_id     => p_rec.txn_category_attribute_id,
   p_value_set_id                  => p_rec.value_set_id,
   p_object_version_number         => p_rec.object_version_number);
  --
  chk_transaction_category_id
  (p_txn_category_attribute_id          => p_rec.txn_category_attribute_id,
   p_transaction_category_id          => p_rec.transaction_category_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_attribute_id
  (p_txn_category_attribute_id          => p_rec.txn_category_attribute_id,
   p_attribute_id          => p_rec.attribute_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_value_style_cd
  (p_txn_category_attribute_id          => p_rec.txn_category_attribute_id,
   p_value_style_cd         => p_rec.value_style_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_refresh_flag
  (p_txn_category_attribute_id          => p_rec.txn_category_attribute_id,
   p_refresh_flag         => p_rec.refresh_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_select_flag
  (p_txn_category_attribute_id          => p_rec.txn_category_attribute_id,
   p_select_flag         => p_rec.select_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_member_identifying_flag
  (p_txn_category_attribute_id          => p_rec.txn_category_attribute_id,
   p_attribute_id          => p_rec.attribute_id,
   p_identifier_flag         => p_rec.identifier_flag,
   p_delete_attr_ranges_flag  => p_delete_attr_ranges_flag,
   p_member_identifying_flag         => p_rec.member_identifying_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_list_identifying_flag
  (p_txn_category_attribute_id          => p_rec.txn_category_attribute_id,
   p_attribute_id          => p_rec.attribute_id,
   p_identifier_flag         => p_rec.identifier_flag,
   p_delete_attr_ranges_flag  => p_delete_attr_ranges_flag,
   p_list_identifying_flag         => p_rec.list_identifying_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_identifier_flag
  (p_txn_category_attribute_id          => p_rec.txn_category_attribute_id,
   p_identifier_flag         => p_rec.identifier_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_transaction_cat_status
  (p_attribute_id          => p_rec.attribute_id,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqh_tca_shd.g_rec_type
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
end pqh_tca_bus;

/
