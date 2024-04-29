--------------------------------------------------------
--  DDL for Package Body PQH_BDT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BDT_BUS" as
/* $Header: pqbdtrhi.pkb 120.0 2005/05/29 01:28:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_bdt_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_budget_detail_id >------|
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
--   budget_detail_id PK of record being inserted or updated.
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
Procedure chk_budget_detail_id(p_budget_detail_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_budget_detail_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_bdt_shd.api_updating
    (p_budget_detail_id                => p_budget_detail_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_budget_detail_id,hr_api.g_number)
     <>  pqh_bdt_shd.g_old_rec.budget_detail_id) then
    --
    -- raise error as PK has changed
    --
    pqh_bdt_shd.constraint_error('PQH_BUDGET_DETAILS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_budget_detail_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_bdt_shd.constraint_error('PQH_BUDGET_DETAILS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_budget_detail_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_grade_id >------|
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
--   p_budget_detail_id PK
--   p_grade_id ID of FK column
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
Procedure chk_grade_id (p_budget_detail_id          in number,
                            p_grade_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_grade_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_grades a
    where  a.grade_id = p_grade_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_bdt_shd.api_updating
    (p_budget_detail_id                => p_budget_detail_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_grade_id,hr_api.g_number)
     <> nvl(pqh_bdt_shd.g_old_rec.grade_id,hr_api.g_number)
     or not l_api_updating) and
     p_grade_id is not null then
    --
    -- check if grade_id value exists in per_grades table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_grades
        -- table.
        --
        pqh_bdt_shd.constraint_error('PQH_BUDGET_DETAILS_FK5');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_grade_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_job_id >------|
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
--   p_budget_detail_id PK
--   p_job_id ID of FK column
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
Procedure chk_job_id (p_budget_detail_id          in number,
                            p_job_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_job_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_jobs a
    where  a.job_id = p_job_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_bdt_shd.api_updating
    (p_budget_detail_id                => p_budget_detail_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_job_id,hr_api.g_number)
     <> nvl(pqh_bdt_shd.g_old_rec.job_id,hr_api.g_number)
     or not l_api_updating) and
     p_job_id is not null then
    --
    -- check if job_id value exists in per_jobs table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_jobs
        -- table.
        --
        pqh_bdt_shd.constraint_error('PQH_BUDGET_DETAILS_FK4');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_job_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_budget_version_id >------|
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
--   p_budget_detail_id PK
--   p_budget_version_id ID of FK column
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
Procedure chk_budget_version_id (p_budget_detail_id          in number,
                            p_budget_version_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_budget_version_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_budget_versions a
    where  a.budget_version_id = p_budget_version_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_bdt_shd.api_updating
    (p_budget_detail_id                => p_budget_detail_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_budget_version_id,hr_api.g_number)
     <> nvl(pqh_bdt_shd.g_old_rec.budget_version_id,hr_api.g_number)
     or not l_api_updating) and
     p_budget_version_id is not null then
    --
    -- check if budget_version_id value exists in pqh_budget_versions table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_budget_versions
        -- table.
        --
        pqh_bdt_shd.constraint_error('PQH_BUDGET_DETAILS_FK3');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_budget_version_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_organization_id >------|
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
--   p_budget_detail_id PK
--   p_organization_id ID of FK column
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
Procedure chk_organization_id (p_budget_detail_id          in number,
                            p_organization_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_organization_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   hr_all_organization_units a
    where  a.organization_id = p_organization_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_bdt_shd.api_updating
    (p_budget_detail_id                => p_budget_detail_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_organization_id,hr_api.g_number)
     <> nvl(pqh_bdt_shd.g_old_rec.organization_id,hr_api.g_number)
     or not l_api_updating) and
     p_organization_id is not null then
    --
    -- check if organization_id value exists in hr_organization_units table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in hr_organization_units
        -- table.
        --
        pqh_bdt_shd.constraint_error('PQH_BUDGET_DETAILS_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_organization_id;
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
--   budget_set_id PK of record being inserted or updated.
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
Procedure chk_budget_unit3_value_type_cd(p_budget_detail_id                in number,
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
  l_api_updating := pqh_bdt_shd.api_updating
    (p_budget_detail_id                => p_budget_detail_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_budget_unit3_value_type_cd
      <> nvl(pqh_bdt_shd.g_old_rec.budget_unit3_value_type_cd,hr_api.g_varchar2)
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
--   budget_set_id PK of record being inserted or updated.
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
Procedure chk_budget_unit2_value_type_cd(p_budget_detail_id                in number,
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
  l_api_updating := pqh_bdt_shd.api_updating
    (p_budget_detail_id                => p_budget_detail_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_budget_unit2_value_type_cd
      <> nvl(pqh_bdt_shd.g_old_rec.budget_unit2_value_type_cd,hr_api.g_varchar2)
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
--   budget_set_id PK of record being inserted or updated.
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
Procedure chk_budget_unit1_value_type_cd(p_budget_detail_id                in number,
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
  l_api_updating := pqh_bdt_shd.api_updating
    (p_budget_detail_id                => p_budget_detail_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_budget_unit1_value_type_cd
      <> nvl(pqh_bdt_shd.g_old_rec.budget_unit1_value_type_cd,hr_api.g_varchar2)
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
Procedure insert_validate(p_rec in pqh_bdt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_budget_detail_id
  (p_budget_detail_id          => p_rec.budget_detail_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_grade_id
  (p_budget_detail_id          => p_rec.budget_detail_id,
   p_grade_id          => p_rec.grade_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_job_id
  (p_budget_detail_id          => p_rec.budget_detail_id,
   p_job_id          => p_rec.job_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_version_id
  (p_budget_detail_id          => p_rec.budget_detail_id,
   p_budget_version_id          => p_rec.budget_version_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_organization_id
  (p_budget_detail_id          => p_rec.budget_detail_id,
   p_organization_id          => p_rec.organization_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_unit1_value_type_cd
  (p_budget_detail_id           => p_rec.budget_detail_id,
   p_budget_unit1_value_type_cd =>  p_rec.budget_unit1_value_type_cd,
   p_effective_date             => sysdate,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_budget_unit2_value_type_cd
  (p_budget_detail_id           => p_rec.budget_detail_id,
   p_budget_unit2_value_type_cd =>  p_rec.budget_unit2_value_type_cd,
   p_effective_date             => sysdate,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_budget_unit3_value_type_cd
  (p_budget_detail_id           => p_rec.budget_detail_id,
   p_budget_unit3_value_type_cd =>  p_rec.budget_unit3_value_type_cd,
   p_effective_date             => sysdate,
   p_object_version_number      => p_rec.object_version_number);
  --
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pqh_bdt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_budget_detail_id
  (p_budget_detail_id          => p_rec.budget_detail_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_grade_id
  (p_budget_detail_id          => p_rec.budget_detail_id,
   p_grade_id          => p_rec.grade_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_job_id
  (p_budget_detail_id          => p_rec.budget_detail_id,
   p_job_id          => p_rec.job_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_version_id
  (p_budget_detail_id          => p_rec.budget_detail_id,
   p_budget_version_id          => p_rec.budget_version_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_organization_id
  (p_budget_detail_id          => p_rec.budget_detail_id,
   p_organization_id          => p_rec.organization_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_unit1_value_type_cd
  (p_budget_detail_id           => p_rec.budget_detail_id,
   p_budget_unit1_value_type_cd =>  p_rec.budget_unit1_value_type_cd,
   p_effective_date             => sysdate,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_budget_unit2_value_type_cd
  (p_budget_detail_id           => p_rec.budget_detail_id,
   p_budget_unit2_value_type_cd =>  p_rec.budget_unit2_value_type_cd,
   p_effective_date             => sysdate,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_budget_unit3_value_type_cd
  (p_budget_detail_id           => p_rec.budget_detail_id,
   p_budget_unit3_value_type_cd =>  p_rec.budget_unit3_value_type_cd,
   p_effective_date             => sysdate,
   p_object_version_number      => p_rec.object_version_number);
  --
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqh_bdt_shd.g_rec_type) is
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
end pqh_bdt_bus;

/
