--------------------------------------------------------
--  DDL for Package Body PQH_WST_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_WST_BUS" as
/* $Header: pqwstrhi.pkb 115.4 2002/12/13 00:07:23 rpasapul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_wst_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_worksheet_budget_set_id >------|
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
--   worksheet_budget_set_id PK of record being inserted or updated.
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
Procedure chk_worksheet_budget_set_id(p_worksheet_budget_set_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_worksheet_budget_set_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_wst_shd.api_updating
    (p_worksheet_budget_set_id                => p_worksheet_budget_set_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_worksheet_budget_set_id,hr_api.g_number)
     <>  pqh_wst_shd.g_old_rec.worksheet_budget_set_id) then
    --
    -- raise error as PK has changed
    --
    pqh_wst_shd.constraint_error('PQH_WORKSHEET_BUDGET_SETS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_worksheet_budget_set_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_wst_shd.constraint_error('PQH_WORKSHEET_BUDGET_SETS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_worksheet_budget_set_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dflt_budget_set_id >------|
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
--   p_worksheet_budget_set_id PK
--   p_dflt_budget_set_id ID of FK column
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
Procedure chk_dflt_budget_set_id (p_worksheet_budget_set_id          in number,
                            p_dflt_budget_set_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dflt_budget_set_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_dflt_budget_sets a
    where  a.dflt_budget_set_id = p_dflt_budget_set_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_wst_shd.api_updating
     (p_worksheet_budget_set_id            => p_worksheet_budget_set_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_dflt_budget_set_id,hr_api.g_number)
     <> nvl(pqh_wst_shd.g_old_rec.dflt_budget_set_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if dflt_budget_set_id value exists in pqh_dflt_budget_sets table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_dflt_budget_sets
        -- table.
        --
        pqh_wst_shd.constraint_error('PQH_WORKSHEET_BUDGET_SETS_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_dflt_budget_set_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_worksheet_period_id >------|
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
--   p_worksheet_budget_set_id PK
--   p_worksheet_period_id ID of FK column
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
Procedure chk_worksheet_period_id (p_worksheet_budget_set_id          in number,
                            p_worksheet_period_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_worksheet_period_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_worksheet_periods a
    where  a.worksheet_period_id = p_worksheet_period_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_wst_shd.api_updating
     (p_worksheet_budget_set_id            => p_worksheet_budget_set_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_worksheet_period_id,hr_api.g_number)
     <> nvl(pqh_wst_shd.g_old_rec.worksheet_period_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if worksheet_period_id value exists in pqh_worksheet_periods table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_worksheet_periods
        -- table.
        --
        pqh_wst_shd.constraint_error('PQH_WORKSHEET_BUDGET_SETS_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_worksheet_period_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_budget_unit3_value_type_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   worksheet_budget_set_id PK of record being inserted or updated.
--   budget_unit3_value_type_cd Value of lookup code.
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
Procedure chk_budget_unit3_value_type_cd(p_worksheet_budget_set_id                in number,
                            p_budget_unit3_value_type_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_budget_unit3_value_type_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_wst_shd.api_updating
    (p_worksheet_budget_set_id                => p_worksheet_budget_set_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_budget_unit3_value_type_cd
      <> nvl(pqh_wst_shd.g_old_rec.budget_unit3_value_type_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_budget_unit3_value_type_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_BUDGET_UNIT_VALUE_TYPE',
           p_lookup_code    => p_budget_unit3_value_type_cd,
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
end chk_budget_unit3_value_type_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_budget_unit2_value_type_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   worksheet_budget_set_id PK of record being inserted or updated.
--   budget_unit2_value_type_cd Value of lookup code.
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
Procedure chk_budget_unit2_value_type_cd(p_worksheet_budget_set_id                in number,
                            p_budget_unit2_value_type_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_budget_unit2_value_type_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_wst_shd.api_updating
    (p_worksheet_budget_set_id                => p_worksheet_budget_set_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_budget_unit2_value_type_cd
      <> nvl(pqh_wst_shd.g_old_rec.budget_unit2_value_type_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_budget_unit2_value_type_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_BUDGET_UNIT_VALUE_TYPE',
           p_lookup_code    => p_budget_unit2_value_type_cd,
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
end chk_budget_unit2_value_type_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_budget_unit1_value_type_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   worksheet_budget_set_id PK of record being inserted or updated.
--   budget_unit1_value_type_cd Value of lookup code.
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
Procedure chk_budget_unit1_value_type_cd(p_worksheet_budget_set_id                in number,
                            p_budget_unit1_value_type_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_budget_unit1_value_type_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_wst_shd.api_updating
    (p_worksheet_budget_set_id                => p_worksheet_budget_set_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_budget_unit1_value_type_cd
      <> nvl(pqh_wst_shd.g_old_rec.budget_unit1_value_type_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_budget_unit1_value_type_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_BUDGET_UNIT_VALUE_TYPE',
           p_lookup_code    => p_budget_unit1_value_type_cd,
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
end chk_budget_unit1_value_type_cd;
--
--
-- Additional values
--
Procedure chk_numeric_values
                           (p_worksheet_budget_set_id          in number,
                            p_budget_unit1_percent         in number,
                            p_budget_unit1_value           in number,
                            p_budget_unit2_percent         in number,
                            p_budget_unit2_value           in number,
                            p_budget_unit3_percent         in number,
                            p_budget_unit3_value           in number,
                            p_object_version_number        in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_numeric_values';
  l_api_updating boolean;
  --
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_wst_shd.api_updating
     (p_worksheet_budget_set_id     => p_worksheet_budget_set_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_budget_unit1_percent,hr_api.g_number)
      <> nvl(pqh_wst_shd.g_old_rec.budget_unit1_percent,hr_api.g_number)
     or not l_api_updating) and
     p_budget_unit1_percent is not null then
    --
    -- Raise error if the value is negative
    --
       If p_budget_unit1_percent < 0 then
        hr_utility.set_message(8302,'PQH_INVALID_BDGT_UNIT_PERCENT');
        hr_utility.raise_error;
       End if;
  end if;
  --
  --
  if (l_api_updating
     and nvl(p_budget_unit1_value,hr_api.g_number)
      <> nvl(pqh_wst_shd.g_old_rec.budget_unit1_value,hr_api.g_number)
     or not l_api_updating) and
     p_budget_unit1_value is not null then
    --
    -- Raise error if the value is negative
    --
       If p_budget_unit1_value < 0 then
        hr_utility.set_message(8302,'PQH_INVALID_BDGT_UNIT_VALUE');
        hr_utility.raise_error;
       End if;
  end if;
  --
  --
  /**
  if (l_api_updating
     and nvl(p_budget_unit1_available,hr_api.g_number)
      <> nvl(pqh_wst_shd.g_old_rec.budget_unit1_available,hr_api.g_number)
     or not l_api_updating) and
     p_budget_unit1_available is not null then
    --
    -- Raise error if the value is negative
    --
       If p_budget_unit1_available < 0 then
        hr_utility.set_message(8302,'PQH_INVALID_UNIT1_CONSUMED');
        hr_utility.raise_error;
       End if;
  end if;
  **/
  --
  --
  --
  if (l_api_updating
     and nvl(p_budget_unit2_percent,hr_api.g_number)
      <> nvl(pqh_wst_shd.g_old_rec.budget_unit2_percent,hr_api.g_number)
     or not l_api_updating) and
     p_budget_unit2_percent is not null then
    --
    -- Raise error if the value is negative
    --
       If p_budget_unit2_percent < 0 then
        hr_utility.set_message(8302,'PQH_INVALID_BDGT_UNIT_PERCENT');
        hr_utility.raise_error;
       End if;
  end if;
  --
  --
  if (l_api_updating
     and nvl(p_budget_unit2_value,hr_api.g_number)
      <> nvl(pqh_wst_shd.g_old_rec.budget_unit2_value,hr_api.g_number)
     or not l_api_updating) and
     p_budget_unit2_value is not null then
    --
    -- Raise error if the value is negative
    --
       If p_budget_unit2_value < 0 then
        hr_utility.set_message(8302,'PQH_INVALID_BDGT_UNIT_VALUE');
        hr_utility.raise_error;
       End if;
  end if;
  --
  --
  /**
  if (l_api_updating
     and nvl(p_budget_unit2_available,hr_api.g_number)
      <> nvl(pqh_wst_shd.g_old_rec.budget_unit2_available,hr_api.g_number)
     or not l_api_updating) and
     p_budget_unit2_available is not null then
    --
    -- Raise error if the value is negative
    --
       If p_budget_unit2_available < 0 then
        hr_utility.set_message(8302,'PQH_INVALID_UNIT2_CONSUMED');
        hr_utility.raise_error;
       End if;
  end if;
  **/
  --
  --
  if (l_api_updating
     and nvl(p_budget_unit3_percent,hr_api.g_number)
      <> nvl(pqh_wst_shd.g_old_rec.budget_unit3_percent,hr_api.g_number)
     or not l_api_updating) and
     p_budget_unit3_percent is not null then
    --
    -- Raise error if the value is negative
    --
       If p_budget_unit3_percent < 0 then
        hr_utility.set_message(8302,'PQH_INVALID_BDGT_UNIT_PERCENT');
        hr_utility.raise_error;
       End if;
  end if;
  --
  --
  if (l_api_updating
     and nvl(p_budget_unit3_value,hr_api.g_number)
      <> nvl(pqh_wst_shd.g_old_rec.budget_unit3_value,hr_api.g_number)
     or not l_api_updating) and
     p_budget_unit3_value is not null then
    --
    -- Raise error if the value is negative
    --
       If p_budget_unit3_value < 0 then
        hr_utility.set_message(8302,'PQH_INVALID_BDGT_UNIT_VALUE');
        hr_utility.raise_error;
       End if;
  end if;
  --
  --
  /**
  if (l_api_updating
     and nvl(p_budget_unit3_available,hr_api.g_number)
      <> nvl(pqh_wst_shd.g_old_rec.budget_unit3_available,hr_api.g_number)
     or not l_api_updating) and
     p_budget_unit3_available is not null then
    --
    -- Raise error if the value is negative
    --
       If p_budget_unit3_available < 0 then
        hr_utility.set_message(8302,'PQH_INVALID_UNIT3_CONSUMED');
        hr_utility.raise_error;
       End if;
  end if;
  **/
  --
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_numeric_values;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_wst_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_worksheet_budget_set_id
  (p_worksheet_budget_set_id          => p_rec.worksheet_budget_set_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_budget_set_id
  (p_worksheet_budget_set_id          => p_rec.worksheet_budget_set_id,
   p_dflt_budget_set_id          => p_rec.dflt_budget_set_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_worksheet_period_id
  (p_worksheet_budget_set_id          => p_rec.worksheet_budget_set_id,
   p_worksheet_period_id          => p_rec.worksheet_period_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_unit3_value_type_cd
  (p_worksheet_budget_set_id          => p_rec.worksheet_budget_set_id,
   p_budget_unit3_value_type_cd         => p_rec.budget_unit3_value_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_unit2_value_type_cd
  (p_worksheet_budget_set_id          => p_rec.worksheet_budget_set_id,
   p_budget_unit2_value_type_cd         => p_rec.budget_unit2_value_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_unit1_value_type_cd
  (p_worksheet_budget_set_id          => p_rec.worksheet_budget_set_id,
   p_budget_unit1_value_type_cd         => p_rec.budget_unit1_value_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  chk_numeric_values
  (p_worksheet_budget_set_id          => p_rec.worksheet_budget_set_id,
   p_budget_unit1_percent  => p_rec.budget_unit1_percent,
   p_budget_unit1_value    => p_rec.budget_unit1_value,
   p_budget_unit2_percent  => p_rec.budget_unit2_percent,
   p_budget_unit2_value    => p_rec.budget_unit2_value,
   p_budget_unit3_percent  => p_rec.budget_unit3_percent,
   p_budget_unit3_value    => p_rec.budget_unit3_value,
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
Procedure update_validate(p_rec in pqh_wst_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_worksheet_budget_set_id
  (p_worksheet_budget_set_id          => p_rec.worksheet_budget_set_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_budget_set_id
  (p_worksheet_budget_set_id          => p_rec.worksheet_budget_set_id,
   p_dflt_budget_set_id          => p_rec.dflt_budget_set_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_worksheet_period_id
  (p_worksheet_budget_set_id          => p_rec.worksheet_budget_set_id,
   p_worksheet_period_id          => p_rec.worksheet_period_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_unit3_value_type_cd
  (p_worksheet_budget_set_id          => p_rec.worksheet_budget_set_id,
   p_budget_unit3_value_type_cd         => p_rec.budget_unit3_value_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_unit2_value_type_cd
  (p_worksheet_budget_set_id          => p_rec.worksheet_budget_set_id,
   p_budget_unit2_value_type_cd         => p_rec.budget_unit2_value_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_unit1_value_type_cd
  (p_worksheet_budget_set_id          => p_rec.worksheet_budget_set_id,
   p_budget_unit1_value_type_cd         => p_rec.budget_unit1_value_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  chk_numeric_values
  (p_worksheet_budget_set_id          => p_rec.worksheet_budget_set_id,
   p_budget_unit1_percent  => p_rec.budget_unit1_percent,
   p_budget_unit1_value    => p_rec.budget_unit1_value,
   p_budget_unit2_percent  => p_rec.budget_unit2_percent,
   p_budget_unit2_value    => p_rec.budget_unit2_value,
   p_budget_unit3_percent  => p_rec.budget_unit3_percent,
   p_budget_unit3_value    => p_rec.budget_unit3_value,
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
Procedure delete_validate(p_rec in pqh_wst_shd.g_rec_type
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
end pqh_wst_bus;

/
