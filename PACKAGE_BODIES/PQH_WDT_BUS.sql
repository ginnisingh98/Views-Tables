--------------------------------------------------------
--  DDL for Package Body PQH_WDT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_WDT_BUS" as
/* $Header: pqwdtrhi.pkb 120.0.12000000.1 2007/01/17 00:29:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_wdt_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_worksheet_detail_id >------|
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
--   worksheet_detail_id PK of record being inserted or updated.
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
Procedure chk_worksheet_detail_id(p_worksheet_detail_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_worksheet_detail_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_wdt_shd.api_updating
    (p_worksheet_detail_id                => p_worksheet_detail_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_worksheet_detail_id,hr_api.g_number)
     <>  pqh_wdt_shd.g_old_rec.worksheet_detail_id) then
    --
    -- raise error as PK has changed
    --
    pqh_wdt_shd.constraint_error('PQH_WORKSHEET_DETAILS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_worksheet_detail_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_wdt_shd.constraint_error('PQH_WORKSHEET_DETAILS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_worksheet_detail_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_parent_worksheet_detail_id >------|
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
--   p_worksheet_detail_id PK
--   p_parent_worksheet_detail_id ID of FK column
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
Procedure chk_parent_worksheet_detail_id (p_worksheet_detail_id          in number,
                            p_parent_worksheet_detail_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_parent_worksheet_detail_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_worksheet_details a
    where  a.worksheet_detail_id = p_parent_worksheet_detail_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_wdt_shd.api_updating
     (p_worksheet_detail_id            => p_worksheet_detail_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_parent_worksheet_detail_id,hr_api.g_number)
     <> nvl(pqh_wdt_shd.g_old_rec.parent_worksheet_detail_id,hr_api.g_number)
     or not l_api_updating) and
     p_parent_worksheet_detail_id is not null then
    --
    -- check if parent_worksheet_detail_id value exists in pqh_worksheet_details table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_worksheet_details
        -- table.
        --
        pqh_wdt_shd.constraint_error('PQH_WORKSHEET_DETAILS_FK8');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_parent_worksheet_detail_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_worksheet_id >------|
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
--   p_worksheet_detail_id PK
--   p_worksheet_id ID of FK column
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
Procedure chk_worksheet_id (p_worksheet_detail_id          in number,
                            p_worksheet_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_worksheet_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_worksheets a
    where  a.worksheet_id = p_worksheet_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_wdt_shd.api_updating
     (p_worksheet_detail_id            => p_worksheet_detail_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_worksheet_id,hr_api.g_number)
     <> nvl(pqh_wdt_shd.g_old_rec.worksheet_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if worksheet_id value exists in pqh_worksheets table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_worksheets
        -- table.
        --
        pqh_wdt_shd.constraint_error('PQH_WORKSHEET_DETAILS_FK7');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_worksheet_id;
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
--   p_worksheet_detail_id PK
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
Procedure chk_grade_id (p_worksheet_detail_id          in number,
                        p_worksheet_id                 in number,
                            p_grade_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_grade_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  l_budgeted_entity_cd pqh_budgets.budgeted_entity_cd%type;
  --
  --
  cursor c1 is
    select null
    from   per_grades a
    where  a.grade_id = p_grade_id;
  --
  Cursor c2 is
    select budgeted_entity_cd
      From pqh_budgets bdt,pqh_worksheets wks
     Where wks.worksheet_id = p_worksheet_id
       ANd bdt.budget_id    = wks.budget_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_wdt_shd.api_updating
     (p_worksheet_detail_id            => p_worksheet_detail_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_grade_id,hr_api.g_number)
     <> nvl(pqh_wdt_shd.g_old_rec.grade_id,hr_api.g_number)
     or not l_api_updating) and
     p_grade_id is not null then
    --
    /**
    --
    -- Raise error if budgeted entity cd = pos/job/org
    --
    Open c2;
    Fetch c2 into l_budgeted_entity_cd;
    If c2%notfound then
       --
       Close c2;
       hr_utility.set_message(8302,'PQH_NO_BUDGETED_ENTITY_CD');
       hr_utility.raise_error;
       --
    End if;
    Close c2;
    --
    If l_budgeted_entity_cd IS NOT NULL AND
       (l_budgeted_entity_cd = 'POSITION' OR
        l_budgeted_entity_cd = 'JOB' OR
        l_budgeted_entity_cd = 'ORGANIZATION') then
        --
        hr_utility.set_message(8302,'PQH_GRADE_MUST_BE_NULL');
        hr_utility.raise_error;
        --
    End if;
    **/
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
        pqh_wdt_shd.constraint_error('PQH_WORKSHEET_DETAILS_FK6');
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
--   p_worksheet_detail_id PK
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
Procedure chk_job_id (p_worksheet_detail_id          in number,
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
  l_api_updating := pqh_wdt_shd.api_updating
     (p_worksheet_detail_id            => p_worksheet_detail_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_job_id,hr_api.g_number)
     <> nvl(pqh_wdt_shd.g_old_rec.job_id,hr_api.g_number)
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
        pqh_wdt_shd.constraint_error('PQH_WORKSHEET_DETAILS_FK5');
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
-- |------< chk_position_transaction_id >------|
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
--   p_worksheet_detail_id PK
--   p_position_transaction_id ID of FK column
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
Procedure chk_position_transaction_id (p_worksheet_detail_id          in number,
                            p_position_transaction_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_position_transaction_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_position_transactions a
    where  a.position_transaction_id = p_position_transaction_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_wdt_shd.api_updating
     (p_worksheet_detail_id            => p_worksheet_detail_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_position_transaction_id,hr_api.g_number)
     <> nvl(pqh_wdt_shd.g_old_rec.position_transaction_id,hr_api.g_number)
     or not l_api_updating) and
     p_position_transaction_id is not null then
    --
    -- check if position_transaction_id value exists in pqh_position_transactions table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_position_transactions
        -- table.
        --
        pqh_wdt_shd.constraint_error('PQH_WORKSHEET_DETAILS_FK4');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_position_transaction_id;
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
--   p_worksheet_detail_id PK
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
Procedure chk_budget_detail_id (p_worksheet_detail_id          in number,
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
  l_api_updating := pqh_wdt_shd.api_updating
     (p_worksheet_detail_id            => p_worksheet_detail_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_budget_detail_id,hr_api.g_number)
     <> nvl(pqh_wdt_shd.g_old_rec.budget_detail_id,hr_api.g_number)
     or not l_api_updating) and
     p_budget_detail_id is not null then
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
        pqh_wdt_shd.constraint_error('PQH_WORKSHEET_DETAILS_FK3');
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
--   p_worksheet_detail_id PK
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
Procedure chk_organization_id (p_worksheet_detail_id          in number,
                               p_worksheet_id                 in number,
                            p_organization_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_organization_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  l_org_structure_version_id pqh_budgets.org_structure_version_id%type;
  l_start_organization_id    pqh_budgets.start_organization_id%type;
  --
  cursor c1 is
    select null
    from   hr_all_organization_units a
    where  a.organization_id = p_organization_id;
  --
  Cursor c2 is
   Select start_organization_id,org_structure_version_id
    From pqh_worksheets wfs , pqh_budgets bdt
   Where wfs.worksheet_id = p_worksheet_id
     AND wfs.budget_id = bdt.budget_id;
  --
  --
  Cursor c3 is
   Select null from dual
   Where p_organization_id in
         (Select ORGANIZATION_ID_CHILD
            from per_org_structure_elements
           where org_structure_version_id = l_org_structure_version_id);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_wdt_shd.api_updating
     (p_worksheet_detail_id            => p_worksheet_detail_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_organization_id,hr_api.g_number)
     <> nvl(pqh_wdt_shd.g_old_rec.organization_id,hr_api.g_number)
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
        pqh_wdt_shd.constraint_error('PQH_WORKSHEET_DETAILS_FK2');
        --
      end if;
      --
    close c1;
    --

    open c2;
    Fetch c2 into l_start_organization_id,l_org_structure_version_id ;
    If c2%notfound then
       Close c2;
       hr_utility.set_message(8302,'PQH_WDT_ORG_SRUCTURE_NOT_FOUND');
       hr_utility.raise_error;
    End if;
    Close c2;
    --
    If p_organization_id <> l_start_organization_id then
    --
    open c3;
    Fetch c3 into l_dummy;
    If c3%notfound then
       Close c3;
       hr_utility.set_message(8302,'PQH_ORG_NOT_IN_BDT_ORG_STRUCT');
       hr_utility.raise_error;
    End if;
    Close c3;
    --
    End if;
    --
  --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_organization_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_defer_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   worksheet_detail_id PK of record being inserted or updated.
--   defer_flag Value of lookup code.
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
Procedure chk_defer_flag(p_worksheet_detail_id                in number,
                            p_defer_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_defer_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_wdt_shd.api_updating
    (p_worksheet_detail_id                => p_worksheet_detail_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_defer_flag
      <> nvl(pqh_wdt_shd.g_old_rec.defer_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_defer_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_defer_flag,
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
end chk_defer_flag;
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
--   worksheet_detail_id PK of record being inserted or updated.
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
Procedure chk_budget_unit3_value_type_cd(p_worksheet_detail_id                in number,
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
  l_api_updating := pqh_wdt_shd.api_updating
    (p_worksheet_detail_id                => p_worksheet_detail_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_budget_unit3_value_type_cd
      <> nvl(pqh_wdt_shd.g_old_rec.budget_unit3_value_type_cd,hr_api.g_varchar2)
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
--   worksheet_detail_id PK of record being inserted or updated.
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
Procedure chk_budget_unit2_value_type_cd(p_worksheet_detail_id                in number,
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
  l_api_updating := pqh_wdt_shd.api_updating
    (p_worksheet_detail_id                => p_worksheet_detail_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_budget_unit2_value_type_cd
      <> nvl(pqh_wdt_shd.g_old_rec.budget_unit2_value_type_cd,hr_api.g_varchar2)
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
--   worksheet_detail_id PK of record being inserted or updated.
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
Procedure chk_budget_unit1_value_type_cd(p_worksheet_detail_id                in number,
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
  l_api_updating := pqh_wdt_shd.api_updating
    (p_worksheet_detail_id                => p_worksheet_detail_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_budget_unit1_value_type_cd
      <> nvl(pqh_wdt_shd.g_old_rec.budget_unit1_value_type_cd,hr_api.g_varchar2)
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
-- |------< chk_action_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   worksheet_detail_id PK of record being inserted or updated.
--   action_cd Value of lookup code.
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
Procedure chk_action_cd(p_worksheet_detail_id                in number,
                            p_action_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_action_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_wdt_shd.api_updating
    (p_worksheet_detail_id                => p_worksheet_detail_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_action_cd
      <> nvl(pqh_wdt_shd.g_old_rec.action_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_action_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_WORKSHEET_DETAIL_ACTION',
           p_lookup_code    => p_action_cd,
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
end chk_action_cd;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_status >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   worksheet_detail_id PK of record being inserted or updated.
--   status Value of lookup code.
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
Procedure chk_status(p_worksheet_detail_id                in number,
                            p_status               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_status';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_wdt_shd.api_updating
    (p_worksheet_detail_id                => p_worksheet_detail_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_status
      <> nvl(pqh_wdt_shd.g_old_rec.status,hr_api.g_varchar2)
      or not l_api_updating)
      and p_status is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_TRANSACTION_STATUS',
           p_lookup_code    => p_status,
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
end chk_status;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_propagation_method >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   worksheet_detail_id PK of record being inserted or updated.
--   propagation_method Value of lookup code.
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
Procedure chk_propagation_method(p_worksheet_detail_id                in number,
                            p_propagation_method               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_propagation_method';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_wdt_shd.api_updating
    (p_worksheet_detail_id                => p_worksheet_detail_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_propagation_method
      <> nvl(pqh_wdt_shd.g_old_rec.propagation_method,hr_api.g_varchar2)
      or not l_api_updating)
      and p_propagation_method is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_WORKSHEET_PROPAGATE_METHOD',
           p_lookup_code    => p_propagation_method,
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
end chk_propagation_method;
--
--
-- Additional checks
--
-- ----------------------------------------------------------------------------
-- |------< chk_position_id >------|
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
--   p_worksheet_detail_id PK
--   p_position_id ID of FK column
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
Procedure chk_position_id (p_worksheet_detail_id          in number,
                            p_position_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_position_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   hr_all_positions_f a
    where  a.position_id = p_position_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_wdt_shd.api_updating
     (p_worksheet_detail_id            => p_worksheet_detail_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_position_id,hr_api.g_number)
     <> nvl(pqh_wdt_shd.g_old_rec.position_id,hr_api.g_number)
     or not l_api_updating) and
     p_position_id is not null then
    --
    -- check if position_id value exists in hr_positions_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in hr_positions_f
        -- table.
        --
        hr_utility.set_message(8302,'PQH_INVALID_POSITION_ID');
        hr_utility.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_position_id;
--
Procedure chk_user_id (p_worksheet_detail_id          in number,
                            p_user_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_user_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   fnd_user a
    where  a.user_id = p_user_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_wdt_shd.api_updating
     (p_worksheet_detail_id            => p_worksheet_detail_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_user_id,hr_api.g_number)
     <> nvl(pqh_wdt_shd.g_old_rec.user_id,hr_api.g_number)
     or not l_api_updating) and
     p_user_id is not null then
    --
    -- check if user_id value exists in fnd_user table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in hr_positions_f
        -- table.
        --
        hr_utility.set_message(8302,'PQH_INVALID_USER_ID');
        hr_utility.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_user_id;
--
--
Procedure chk_numeric_values
                           (p_worksheet_detail_id          in number,
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
  -- Check if all non-numeric values are all +ve / 0
  --
  l_api_updating := pqh_wdt_shd.api_updating
     (p_worksheet_detail_id     => p_worksheet_detail_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_budget_unit1_percent,hr_api.g_number)
      <> nvl(pqh_wdt_shd.g_old_rec.budget_unit1_percent,hr_api.g_number)
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
      <> nvl(pqh_wdt_shd.g_old_rec.budget_unit1_value,hr_api.g_number)
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
      <> nvl(pqh_wdt_shd.g_old_rec.budget_unit1_available,hr_api.g_number)
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
      <> nvl(pqh_wdt_shd.g_old_rec.budget_unit2_percent,hr_api.g_number)
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
      <> nvl(pqh_wdt_shd.g_old_rec.budget_unit2_value,hr_api.g_number)
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
      <> nvl(pqh_wdt_shd.g_old_rec.budget_unit2_available,hr_api.g_number)
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
      <> nvl(pqh_wdt_shd.g_old_rec.budget_unit3_percent,hr_api.g_number)
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
      <> nvl(pqh_wdt_shd.g_old_rec.budget_unit3_value,hr_api.g_number)
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
      <> nvl(pqh_wdt_shd.g_old_rec.budget_unit3_available,hr_api.g_number)
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
Procedure insert_validate(p_rec in pqh_wdt_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_worksheet_detail_id
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_parent_worksheet_detail_id
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_parent_worksheet_detail_id          => p_rec.parent_worksheet_detail_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_worksheet_id
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_worksheet_id          => p_rec.worksheet_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_grade_id
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_worksheet_id          => p_rec.worksheet_id,
   p_grade_id          => p_rec.grade_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_job_id
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_job_id          => p_rec.job_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_position_transaction_id
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_position_transaction_id          => p_rec.position_transaction_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_detail_id
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_budget_detail_id          => p_rec.budget_detail_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_organization_id
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_worksheet_id          => p_rec.worksheet_id,
   p_organization_id          => p_rec.organization_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_defer_flag
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_defer_flag         => p_rec.defer_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_unit3_value_type_cd
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_budget_unit3_value_type_cd         => p_rec.budget_unit3_value_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_unit2_value_type_cd
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_budget_unit2_value_type_cd         => p_rec.budget_unit2_value_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_unit1_value_type_cd
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_budget_unit1_value_type_cd         => p_rec.budget_unit1_value_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_action_cd
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_action_cd         => p_rec.action_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_status
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_status         => p_rec.status,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_propagation_method
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_propagation_method         => p_rec.propagation_method,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  chk_position_id
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_position_id          => p_rec.position_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_user_id
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_user_id          => p_rec.user_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_numeric_values
  (p_worksheet_detail_id   => p_rec.worksheet_detail_id,
   p_budget_unit1_percent  => p_rec.budget_unit1_percent,
   p_budget_unit1_value    => p_rec.budget_unit1_value,
   p_budget_unit2_percent  => p_rec.budget_unit2_percent,
   p_budget_unit2_value    => p_rec.budget_unit2_value,
   p_budget_unit3_percent  => p_rec.budget_unit3_percent,
   p_budget_unit3_value    => p_rec.budget_unit3_value,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pqh_wdt_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_worksheet_detail_id
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_parent_worksheet_detail_id
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_parent_worksheet_detail_id          => p_rec.parent_worksheet_detail_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_worksheet_id
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_worksheet_id          => p_rec.worksheet_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_grade_id
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_worksheet_id          => p_rec.worksheet_id,
   p_grade_id          => p_rec.grade_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_job_id
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_job_id          => p_rec.job_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_position_transaction_id
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_position_transaction_id          => p_rec.position_transaction_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_detail_id
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_budget_detail_id          => p_rec.budget_detail_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_organization_id
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_worksheet_id          => p_rec.worksheet_id,
   p_organization_id          => p_rec.organization_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_defer_flag
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_defer_flag         => p_rec.defer_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_unit3_value_type_cd
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_budget_unit3_value_type_cd         => p_rec.budget_unit3_value_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_unit2_value_type_cd
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_budget_unit2_value_type_cd         => p_rec.budget_unit2_value_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_unit1_value_type_cd
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_budget_unit1_value_type_cd         => p_rec.budget_unit1_value_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_action_cd
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_action_cd         => p_rec.action_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_status
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_status         => p_rec.status,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_propagation_method
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_propagation_method         => p_rec.propagation_method,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  chk_position_id
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_position_id          => p_rec.position_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_user_id
  (p_worksheet_detail_id          => p_rec.worksheet_detail_id,
   p_user_id          => p_rec.user_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_numeric_values
  (p_worksheet_detail_id   => p_rec.worksheet_detail_id,
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
Procedure delete_validate(p_rec in pqh_wdt_shd.g_rec_type
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
end pqh_wdt_bus;

/
