--------------------------------------------------------
--  DDL for Package Body PQH_CEA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CEA_BUS" as
/* $Header: pqcearhi.pkb 115.5 2003/09/28 21:33:49 scnair ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_cea_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_copy_entity_attrib_id >------|
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
--   copy_entity_attrib_id PK of record being inserted or updated.
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
Procedure chk_copy_entity_attrib_id(p_copy_entity_attrib_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_copy_entity_attrib_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_cea_shd.api_updating
    (p_copy_entity_attrib_id                => p_copy_entity_attrib_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_copy_entity_attrib_id,hr_api.g_number)
     <>  pqh_cea_shd.g_old_rec.copy_entity_attrib_id) then
    --
    -- raise error as PK has changed
    --
    pqh_cea_shd.constraint_error('PQH_COPY_ENTITY_ATTRIBS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_copy_entity_attrib_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_cea_shd.constraint_error('PQH_COPY_ENTITY_ATTRIBS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_copy_entity_attrib_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_copy_entity_txn_id >------|
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
--   p_copy_entity_attrib_id PK
--   p_copy_entity_txn_id ID of FK column
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
Procedure chk_copy_entity_txn_id (p_copy_entity_attrib_id          in number,
                            p_copy_entity_txn_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_copy_entity_txn_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_copy_entity_txns a
    where  a.copy_entity_txn_id = p_copy_entity_txn_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_cea_shd.api_updating
     (p_copy_entity_attrib_id            => p_copy_entity_attrib_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_copy_entity_txn_id,hr_api.g_number)
     <> nvl(pqh_cea_shd.g_old_rec.copy_entity_txn_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if copy_entity_txn_id value exists in pqh_copy_entity_txns table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_copy_entity_txns
        -- table.
        --
        pqh_cea_shd.constraint_error('PQH_COPY_ENTITY_ATTRIBS_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_copy_entity_txn_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_row_type_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   copy_entity_attrib_id PK of record being inserted or updated.
--   row_type_cd Value of lookup code.
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
Procedure chk_row_type_cd(p_copy_entity_attrib_id                in number,
                            p_row_type_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_row_type_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_cea_shd.api_updating
    (p_copy_entity_attrib_id                => p_copy_entity_attrib_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_row_type_cd
      <> nvl(pqh_cea_shd.g_old_rec.row_type_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_row_type_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'ENTER-LKP-TYPE',
           p_lookup_code    => p_row_type_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
--      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_row_type_cd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_cea_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_copy_entity_attrib_id
  (p_copy_entity_attrib_id          => p_rec.copy_entity_attrib_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_copy_entity_txn_id
  (p_copy_entity_attrib_id          => p_rec.copy_entity_attrib_id,
   p_copy_entity_txn_id          => p_rec.copy_entity_txn_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_row_type_cd
  (p_copy_entity_attrib_id          => p_rec.copy_entity_attrib_id,
   p_row_type_cd         => p_rec.row_type_cd,
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
Procedure update_validate(p_rec in pqh_cea_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_copy_entity_attrib_id
  (p_copy_entity_attrib_id          => p_rec.copy_entity_attrib_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_copy_entity_txn_id
  (p_copy_entity_attrib_id          => p_rec.copy_entity_attrib_id,
   p_copy_entity_txn_id          => p_rec.copy_entity_txn_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_row_type_cd
  (p_copy_entity_attrib_id          => p_rec.copy_entity_attrib_id,
   p_row_type_cd         => p_rec.row_type_cd,
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
Procedure delete_validate(p_rec in pqh_cea_shd.g_rec_type
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
end pqh_cea_bus;

/
