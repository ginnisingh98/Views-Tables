--------------------------------------------------------
--  DDL for Package Body PQH_BPR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BPR_BUS" as
/* $Header: pqbprrhi.pkb 115.8 2002/12/05 19:29:59 rpasapul ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_bpr_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_budget_period_id >------|
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
--   budget_period_id PK of record being inserted or updated.
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
Procedure chk_budget_period_id(p_budget_period_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_budget_period_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_bpr_shd.api_updating
    (p_budget_period_id                => p_budget_period_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_budget_period_id,hr_api.g_number)
     <>  pqh_bpr_shd.g_old_rec.budget_period_id) then
    --
    -- raise error as PK has changed
    --
    pqh_bpr_shd.constraint_error('PQH_BUDGET_PERIODS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_budget_period_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_bpr_shd.constraint_error('PQH_BUDGET_PERIODS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_budget_period_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_end_time_period_id >------|
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
--   p_budget_period_id PK
--   p_end_time_period_id ID of FK column
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
Procedure chk_end_time_period_id (p_budget_period_id          in number,
                            p_end_time_period_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_end_time_period_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_time_periods a
    where  a.time_period_id = p_end_time_period_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_bpr_shd.api_updating
     (p_budget_period_id            => p_budget_period_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_end_time_period_id,hr_api.g_number)
     <> nvl(pqh_bpr_shd.g_old_rec.end_time_period_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if end_time_period_id value exists in per_time_periods table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_time_periods
        -- table.
        --
        pqh_bpr_shd.constraint_error('PQH_BUDGET_PERIODS_FK3');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_end_time_period_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_start_time_period_id >------|
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
--   p_budget_period_id PK
--   p_start_time_period_id ID of FK column
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
Procedure chk_start_time_period_id (p_budget_period_id          in number,
                            p_start_time_period_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_start_time_period_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_time_periods a
    where  a.time_period_id = p_start_time_period_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_bpr_shd.api_updating
     (p_budget_period_id            => p_budget_period_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_start_time_period_id,hr_api.g_number)
     <> nvl(pqh_bpr_shd.g_old_rec.start_time_period_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if start_time_period_id value exists in per_time_periods table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_time_periods
        -- table.
        --
        pqh_bpr_shd.constraint_error('PQH_BUDGET_PERIODS_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_start_time_period_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_budget_detail_id >------|
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
--   p_budget_period_id PK
--   p_budget_detail_id ID of FK column
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
Procedure chk_budget_detail_id (p_budget_period_id          in number,
                            p_budget_detail_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_budget_detail_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_budget_details a
    where  a.budget_detail_id = p_budget_detail_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_bpr_shd.api_updating
     (p_budget_period_id            => p_budget_period_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_budget_detail_id,hr_api.g_number)
     <> nvl(pqh_bpr_shd.g_old_rec.budget_detail_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if budget_detail_id value exists in pqh_budget_details table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_budget_details
        -- table.
        --
        pqh_bpr_shd.constraint_error('PQH_BUDGET_PERIODS_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_budget_detail_id;
--
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
--   p_budget_period_id PK of record being inserted or updated.
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
Procedure chk_budget_unit3_value_type_cd(p_budget_period_id                in number,
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
  l_api_updating := pqh_bpr_shd.api_updating
    (p_budget_period_id                => p_budget_period_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_budget_unit3_value_type_cd
      <> nvl(pqh_bpr_shd.g_old_rec.budget_unit3_value_type_cd,hr_api.g_varchar2)
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
--   p_budget_period_id PK of record being inserted or updated.
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
Procedure chk_budget_unit2_value_type_cd(p_budget_period_id                in number,
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
  l_api_updating := pqh_bpr_shd.api_updating
    (p_budget_period_id                => p_budget_period_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_budget_unit2_value_type_cd
      <> nvl(pqh_bpr_shd.g_old_rec.budget_unit2_value_type_cd,hr_api.g_varchar2)
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
--   p_budget_period_id PK of record being inserted or updated.
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
Procedure chk_budget_unit1_value_type_cd(p_budget_period_id                in number,
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
  l_api_updating := pqh_bpr_shd.api_updating
    (p_budget_period_id                => p_budget_period_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_budget_unit1_value_type_cd
      <> nvl(pqh_bpr_shd.g_old_rec.budget_unit1_value_type_cd,hr_api.g_varchar2)
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
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_bpr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_budget_period_id
  (p_budget_period_id          => p_rec.budget_period_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_end_time_period_id
  (p_budget_period_id          => p_rec.budget_period_id,
   p_end_time_period_id          => p_rec.end_time_period_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_start_time_period_id
  (p_budget_period_id          => p_rec.budget_period_id,
   p_start_time_period_id          => p_rec.start_time_period_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_detail_id
  (p_budget_period_id          => p_rec.budget_period_id,
   p_budget_detail_id          => p_rec.budget_detail_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_unit1_value_type_cd
  (p_budget_period_id           => p_rec.budget_period_id,
   p_budget_unit1_value_type_cd => p_rec.budget_unit1_value_type_cd,
   p_effective_date             => sysdate,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_budget_unit2_value_type_cd
  (p_budget_period_id           => p_rec.budget_period_id,
   p_budget_unit2_value_type_cd => p_rec.budget_unit2_value_type_cd,
   p_effective_date             => sysdate,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_budget_unit3_value_type_cd
  (p_budget_period_id           => p_rec.budget_period_id,
   p_budget_unit3_value_type_cd => p_rec.budget_unit3_value_type_cd,
   p_effective_date             => sysdate,
   p_object_version_number      => p_rec.object_version_number);
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pqh_bpr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_budget_period_id
  (p_budget_period_id          => p_rec.budget_period_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_end_time_period_id
  (p_budget_period_id          => p_rec.budget_period_id,
   p_end_time_period_id          => p_rec.end_time_period_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_start_time_period_id
  (p_budget_period_id          => p_rec.budget_period_id,
   p_start_time_period_id          => p_rec.start_time_period_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_detail_id
  (p_budget_period_id          => p_rec.budget_period_id,
   p_budget_detail_id          => p_rec.budget_detail_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_unit1_value_type_cd
  (p_budget_period_id           => p_rec.budget_period_id,
   p_budget_unit1_value_type_cd => p_rec.budget_unit1_value_type_cd,
   p_effective_date             => sysdate,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_budget_unit2_value_type_cd
  (p_budget_period_id           => p_rec.budget_period_id,
   p_budget_unit2_value_type_cd => p_rec.budget_unit2_value_type_cd,
   p_effective_date             => sysdate,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_budget_unit3_value_type_cd
  (p_budget_period_id           => p_rec.budget_period_id,
   p_budget_unit3_value_type_cd => p_rec.budget_unit3_value_type_cd,
   p_effective_date             => sysdate,
   p_object_version_number      => p_rec.object_version_number);
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqh_bpr_shd.g_rec_type) is
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
end pqh_bpr_bus;

/
