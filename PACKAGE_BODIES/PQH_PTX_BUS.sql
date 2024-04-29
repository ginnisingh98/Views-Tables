--------------------------------------------------------
--  DDL for Package Body PQH_PTX_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PTX_BUS" as
/* $Header: pqptxrhi.pkb 120.0.12010000.2 2008/08/05 13:41:09 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_ptx_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_position_transaction_id >------|
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
--   position_transaction_id PK of record being inserted or updated.
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
Procedure chk_position_transaction_id(p_position_transaction_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_position_transaction_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_ptx_shd.api_updating
    (p_position_transaction_id                => p_position_transaction_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_position_transaction_id,hr_api.g_number)
     <>  pqh_ptx_shd.g_old_rec.position_transaction_id) then
    --
    -- raise error as PK has changed
    --
    pqh_ptx_shd.constraint_error('PQH_POSITION_TRANSACTIONS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_position_transaction_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_ptx_shd.constraint_error('PQH_POSITION_TRANSACTIONS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_position_transaction_id;
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
--   p_position_transaction_id PK
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
Procedure chk_organization_id (p_position_transaction_id          in number,
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
  l_api_updating := pqh_ptx_shd.api_updating
    (p_position_transaction_id                => p_position_transaction_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_organization_id,hr_api.g_number)
     <> nvl(pqh_ptx_shd.g_old_rec.organization_id,hr_api.g_number)
     or not l_api_updating) and
     p_organization_id is not null then
    --
    -- check if organization_id value exists in hr_all_organization_units table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in hr_all_organization_units
        -- table.
        --
        pqh_ptx_shd.constraint_error('PQH_POSITION_TRANSACTIONS_FK9');
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
-- ----------------------------------------------------------------------------
-- |------< chk_position_definition_id >------|
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
--   p_position_transaction_id PK
--   p_position_definition_id ID of FK column
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
Procedure chk_position_definition_id (p_position_transaction_id          in number,
                            p_position_definition_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_position_definition_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_position_definitions a
    where  a.position_definition_id = p_position_definition_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_ptx_shd.api_updating
    (p_position_transaction_id                => p_position_transaction_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_position_definition_id,hr_api.g_number)
     <> nvl(pqh_ptx_shd.g_old_rec.position_definition_id,hr_api.g_number)
     or not l_api_updating) and
     p_position_definition_id is not null then
    --
    -- check if position_definition_id value exists in per_position_definitions table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_position_definitions
        -- table.
        --
        pqh_ptx_shd.constraint_error('PQH_POSITION_TRANSACTIONS_FK6');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_position_definition_id;
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
--   p_position_transaction_id PK
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
Procedure chk_job_id (p_position_transaction_id          in number,
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
  l_api_updating := pqh_ptx_shd.api_updating
    (p_position_transaction_id                => p_position_transaction_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_job_id,hr_api.g_number)
     <> nvl(pqh_ptx_shd.g_old_rec.job_id,hr_api.g_number)
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
        pqh_ptx_shd.constraint_error('PQH_POSITION_TRANSACTIONS_FK5');
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
-- |------< chk_location_id >------|
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
--   p_position_transaction_id PK
--   p_location_id ID of FK column
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
Procedure chk_location_id (p_position_transaction_id          in number,
                            p_location_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_location_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   hr_locations_all a
    where  a.location_id = p_location_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_ptx_shd.api_updating
    (p_position_transaction_id                => p_position_transaction_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_location_id,hr_api.g_number)
     <> nvl(pqh_ptx_shd.g_old_rec.location_id,hr_api.g_number)
     or not l_api_updating) and
     p_location_id is not null then
    --
    -- check if location_id value exists in hr_locations_all table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in hr_locations_all
        -- table.
        --
        pqh_ptx_shd.constraint_error('PQH_POSITION_TRANSACTIONS_FK4');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_location_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_availability_status_id >------|
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
--   p_position_transaction_id PK
--   p_availability_status_id ID of FK column
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
Procedure chk_availability_status_id (p_position_transaction_id          in number,
                            p_availability_status_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_availability_status_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_shared_types a
    where  a.shared_type_id = p_availability_status_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_ptx_shd.api_updating
    (p_position_transaction_id                => p_position_transaction_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_availability_status_id,hr_api.g_number)
     <> nvl(pqh_ptx_shd.g_old_rec.availability_status_id,hr_api.g_number)
     or not l_api_updating) and
     p_availability_status_id is not null then
    --
    -- check if availability_status_id value exists in per_shared_types table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_shared_types
        -- table.
        --
        pqh_ptx_shd.constraint_error('PQH_POSITION_TRANSACTIONS_FK12');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_availability_status_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_entry_grade_id >------|
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
--   p_position_transaction_id PK
--   p_entry_grade_id ID of FK column
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
Procedure chk_entry_grade_id (p_position_transaction_id          in number,
                            p_entry_grade_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_entry_grade_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_grades a
    where  a.grade_id = p_entry_grade_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_ptx_shd.api_updating
    (p_position_transaction_id                => p_position_transaction_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_entry_grade_id,hr_api.g_number)
     <> nvl(pqh_ptx_shd.g_old_rec.entry_grade_id,hr_api.g_number)
     or not l_api_updating) and
     p_entry_grade_id is not null then
    --
    -- check if entry_grade_id value exists in per_grades table
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
        pqh_ptx_shd.constraint_error('PQH_POSITION_TRANSACTIONS_FK11');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_entry_grade_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_work_term_end_month_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_transaction_id PK of record being inserted or updated.
--   work_term_end_month_cd Value of lookup code.
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
Procedure chk_work_term_end_month_cd(p_position_transaction_id                in number,
                            p_work_term_end_month_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_work_term_end_month_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_ptx_shd.api_updating
    (p_position_transaction_id                => p_position_transaction_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_work_term_end_month_cd
      <> nvl(pqh_ptx_shd.g_old_rec.work_term_end_month_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_work_term_end_month_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'MONTH_CODE',
           p_lookup_code    => p_work_term_end_month_cd,
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
end chk_work_term_end_month_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_work_term_end_day_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_transaction_id PK of record being inserted or updated.
--   work_term_end_day_cd Value of lookup code.
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
Procedure chk_work_term_end_day_cd(p_position_transaction_id                in number,
                            p_work_term_end_day_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_work_term_end_day_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_ptx_shd.api_updating
    (p_position_transaction_id                => p_position_transaction_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_work_term_end_day_cd
      <> nvl(pqh_ptx_shd.g_old_rec.work_term_end_day_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_work_term_end_day_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'DAY_CODE',
           p_lookup_code    => p_work_term_end_day_cd,
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
end chk_work_term_end_day_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_work_period_type_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_transaction_id PK of record being inserted or updated.
--   work_period_type_cd Value of lookup code.
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
Procedure chk_work_period_type_cd(p_position_transaction_id                in number,
                            p_work_period_type_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_work_period_type_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_ptx_shd.api_updating
    (p_position_transaction_id                => p_position_transaction_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_work_period_type_cd
      <> nvl(pqh_ptx_shd.g_old_rec.work_period_type_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_work_period_type_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_work_period_type_cd,
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
end chk_work_period_type_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_works_council_approval_flg >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_transaction_id PK of record being inserted or updated.
--   works_council_approval_flag Value of lookup code.
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
Procedure chk_works_council_approval_flg(p_position_transaction_id                in number,
                            p_works_council_approval_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_works_council_approval_flg';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_ptx_shd.api_updating
    (p_position_transaction_id                => p_position_transaction_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_works_council_approval_flag
      <> nvl(pqh_ptx_shd.g_old_rec.works_council_approval_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_works_council_approval_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_works_council_approval_flag,
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
end chk_works_council_approval_flg;
--
-- ----------------------------------------------------------------------------
-- |------< chk_term_start_month_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_transaction_id PK of record being inserted or updated.
--   term_start_month_cd Value of lookup code.
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
Procedure chk_term_start_month_cd(p_position_transaction_id                in number,
                            p_term_start_month_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_term_start_month_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_ptx_shd.api_updating
    (p_position_transaction_id                => p_position_transaction_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_term_start_month_cd
      <> nvl(pqh_ptx_shd.g_old_rec.term_start_month_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_term_start_month_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'MONTH_CODE',
           p_lookup_code    => p_term_start_month_cd,
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
end chk_term_start_month_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_term_start_day_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_transaction_id PK of record being inserted or updated.
--   term_start_day_cd Value of lookup code.
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
Procedure chk_term_start_day_cd(p_position_transaction_id                in number,
                            p_term_start_day_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_term_start_day_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_ptx_shd.api_updating
    (p_position_transaction_id                => p_position_transaction_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_term_start_day_cd
      <> nvl(pqh_ptx_shd.g_old_rec.term_start_day_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_term_start_day_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'DAY_CODE',
           p_lookup_code    => p_term_start_day_cd,
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
end chk_term_start_day_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_seasonal_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_transaction_id PK of record being inserted or updated.
--   seasonal_flag Value of lookup code.
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
Procedure chk_seasonal_flag(p_position_transaction_id                in number,
                            p_seasonal_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_seasonal_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_ptx_shd.api_updating
    (p_position_transaction_id                => p_position_transaction_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_seasonal_flag
      <> nvl(pqh_ptx_shd.g_old_rec.seasonal_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_seasonal_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_seasonal_flag,
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
end chk_seasonal_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_review_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_transaction_id PK of record being inserted or updated.
--   review_flag Value of lookup code.
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
Procedure chk_review_flag(p_position_transaction_id                in number,
                            p_review_flag               in varchar2,
			    p_position_id		in number,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_review_flag';
  l_api_updating boolean;
  l_dummy	 varchar2(10);
  --
  cursor c_position_transactions(p_position_id number) is
  select 'x'
  from pqh_position_transactions
  where position_id = p_position_id
  and position_transaction_id <> p_position_transaction_id
  and transaction_status not in ('TERMINATE', 'APPLIED', 'REJECT');
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_ptx_shd.api_updating
    (p_position_transaction_id                	=> p_position_transaction_id,
     p_object_version_number       		=> p_object_version_number);
  --
  if (l_api_updating
      and p_review_flag
      <> nvl(pqh_ptx_shd.g_old_rec.review_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_review_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_review_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
    if p_position_id is not null then
      open c_position_transactions(p_position_id);
      fetch c_position_transactions into l_dummy;
      --
      if c_position_transactions%found then
        hr_utility.set_message(8302,'PQH_PTX_EXISTS_CANT_REVIEW');
        hr_utility.raise_error;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_review_flag;
--
-- -------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |------< chk_replacement_required_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_transaction_id PK of record being inserted or updated.
--   replacement_required_flag Value of lookup code.
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
Procedure chk_replacement_required_flag(p_position_transaction_id                in number,
                            p_replacement_required_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_replacement_required_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_ptx_shd.api_updating
    (p_position_transaction_id                => p_position_transaction_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_replacement_required_flag
      <> nvl(pqh_ptx_shd.g_old_rec.replacement_required_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_replacement_required_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_replacement_required_flag,
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
end chk_replacement_required_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_probation_period_unit_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_transaction_id PK of record being inserted or updated.
--   probation_period_unit_cd Value of lookup code.
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
Procedure chk_probation_period_unit_cd(p_position_transaction_id                in number,
                            p_probation_period_unit_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_probation_period_unit_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_ptx_shd.api_updating
    (p_position_transaction_id                => p_position_transaction_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_probation_period_unit_cd
      <> nvl(pqh_ptx_shd.g_old_rec.probation_period_unit_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_probation_period_unit_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'FREQUENCY',
           p_lookup_code    => p_probation_period_unit_cd,
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
end chk_probation_period_unit_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_permit_recruitment_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_transaction_id PK of record being inserted or updated.
--   permit_recruitment_flag Value of lookup code.
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
Procedure chk_permit_recruitment_flag(p_position_transaction_id                in number,
                            p_permit_recruitment_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_permit_recruitment_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_ptx_shd.api_updating
    (p_position_transaction_id                => p_position_transaction_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_permit_recruitment_flag
      <> nvl(pqh_ptx_shd.g_old_rec.permit_recruitment_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_permit_recruitment_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_permit_recruitment_flag,
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
end chk_permit_recruitment_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_permanent_temporary_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_transaction_id PK of record being inserted or updated.
--   permanent_temporary_flag Value of lookup code.
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
Procedure chk_permanent_temporary_flag(p_position_transaction_id                in number,
                            p_permanent_temporary_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_permanent_temporary_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_ptx_shd.api_updating
    (p_position_transaction_id                => p_position_transaction_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_permanent_temporary_flag
      <> nvl(pqh_ptx_shd.g_old_rec.permanent_temporary_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_permanent_temporary_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_permanent_temporary_flag,
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
end chk_permanent_temporary_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pay_term_end_month_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_transaction_id PK of record being inserted or updated.
--   pay_term_end_month_cd Value of lookup code.
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
Procedure chk_pay_term_end_month_cd(p_position_transaction_id                in number,
                            p_pay_term_end_month_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pay_term_end_month_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_ptx_shd.api_updating
    (p_position_transaction_id                => p_position_transaction_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_pay_term_end_month_cd
      <> nvl(pqh_ptx_shd.g_old_rec.pay_term_end_month_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pay_term_end_month_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'MONTH_CODE',
           p_lookup_code    => p_pay_term_end_month_cd,
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
end chk_pay_term_end_month_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pay_term_end_day_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_transaction_id PK of record being inserted or updated.
--   pay_term_end_day_cd Value of lookup code.
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
Procedure chk_pay_term_end_day_cd(p_position_transaction_id                in number,
                            p_pay_term_end_day_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pay_term_end_day_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_ptx_shd.api_updating
    (p_position_transaction_id                => p_position_transaction_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_pay_term_end_day_cd
      <> nvl(pqh_ptx_shd.g_old_rec.pay_term_end_day_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pay_term_end_day_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'DAY_CODE',
           p_lookup_code    => p_pay_term_end_day_cd,
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
end chk_pay_term_end_day_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_overlap_unit_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_transaction_id PK of record being inserted or updated.
--   overlap_unit_cd Value of lookup code.
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
Procedure chk_overlap_unit_cd(p_position_transaction_id                in number,
                            p_overlap_unit_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_overlap_unit_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_ptx_shd.api_updating
    (p_position_transaction_id                => p_position_transaction_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_overlap_unit_cd
      <> nvl(pqh_ptx_shd.g_old_rec.overlap_unit_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_overlap_unit_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'FREQUENCY',
           p_lookup_code    => p_overlap_unit_cd,
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
end chk_overlap_unit_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_bargaining_unit_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_transaction_id PK of record being inserted or updated.
--   bargaining_unit_cd Value of lookup code.
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
Procedure chk_bargaining_unit_cd(p_position_transaction_id                in number,
                            p_bargaining_unit_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_bargaining_unit_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_ptx_shd.api_updating
    (p_position_transaction_id                => p_position_transaction_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_bargaining_unit_cd
      <> nvl(pqh_ptx_shd.g_old_rec.bargaining_unit_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bargaining_unit_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BARGAINING_UNIT_CODE',
           p_lookup_code    => p_bargaining_unit_cd,
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
end chk_bargaining_unit_cd;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_extended_pay >--------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_extended_pay
  (p_position_transaction_id               in number
  ,p_work_period_type_cd       in varchar2
  ,p_term_start_day_cd         in varchar2
  ,p_term_start_month_cd       in varchar2
  ,p_pay_term_end_day_cd       in varchar2
  ,p_pay_term_end_month_cd     in varchar2
  ,p_work_term_end_day_cd      in varchar2
  ,p_work_term_end_month_cd    in varchar2 ) is
  --
  l_proc varchar2(30):='chk_extended_flag';
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_work_period_type_cd = 'Y' then
/*
    if p_pay_term_end_day_cd is null    or
       p_pay_term_end_month_cd is null  or
       p_work_term_end_day_cd is null   or
       p_work_term_end_month_cd is null     then
      --
       hr_utility.set_message(800,'HR_PAY_WORK_TERM_MUST_BE_ENTR');
       hr_utility.raise_error;
*/
    if (( (p_pay_term_end_day_cd is null and
          p_pay_term_end_month_cd is not null)  or
         (p_pay_term_end_day_cd is not null and
          p_pay_term_end_month_cd is null)) or
       ( (p_term_start_day_cd is null and
          p_term_start_month_cd is not null)  or
         (p_term_start_day_cd is not null and
          p_term_start_month_cd is null))) then
      --
       hr_utility.set_message(800,'HR_INVALID_PAY_TERM');
       hr_utility.raise_error;
    end if;
    if ( (p_work_term_end_day_cd is null and
          p_work_term_end_month_cd is not null)  or
         (p_work_term_end_day_cd is not null and
          p_work_term_end_month_cd is null)) then
      --
       hr_utility.set_message(800,'HR_INVALID_WORK_TERM');
       hr_utility.raise_error;
    end if;
  else
    if p_pay_term_end_day_cd is not null    or
       p_pay_term_end_month_cd is not null  or
       p_term_start_day_cd is not null    or
       p_term_start_month_cd is not null  or
       p_work_term_end_day_cd is not null   or
       p_work_term_end_month_cd is not null     then
      --
       hr_utility.set_message(800,'HR_PAY_WORK_TERM_MUST_BE_NULL');
       hr_utility.raise_error;
    end if;
  end if;
  --
end chk_extended_pay;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< permit_extended_pay >-------------------------|
-- ----------------------------------------------------------------------------
function permit_extended_pay(p_position_transaction_id varchar2) return boolean is
l_proc varchar2(100) :='PERMIT_EXTENDED_PAY';
l_position_family   varchar2(100);
l_chk               boolean := false;
cursor c1 is
select information3
from pqh_ptx_extra_info
where position_transaction_id = p_position_transaction_id
and information_type = 'PER_FAMILY'
and information3 in ('ACADEMIC','FACULTY');
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  if p_position_transaction_id is not null then
    open c1;
    fetch c1 into l_position_family;
    if c1%found then
      hr_utility.set_location('Academic/Faculty Position Extra info Found:'||l_proc,10);
      close c1;
      return true;
    else
      close c1;
      hr_utility.set_location('Academic/Faculty Position Extra info not Found:'||l_proc,10);
      return false;
    end if;
  else
    return(false);
  end if;
    hr_utility.set_location('Leaving:'||l_proc,20);
end;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_extended_pay_permit >---------------------|
-- ----------------------------------------------------------------------------
procedure chk_extended_pay_permit
(p_position_transaction_id	in number
  ,p_work_period_type_cd       in varchar2
  ,p_object_version_number     in number
) is
l_proc			varchar2(100):='chk_extended_pay_permit';
l_api_updating		boolean;
l_permit_extended_pay	boolean;
begin
    hr_utility.set_location('Entering:'||l_proc,10);
  l_api_updating := pqh_ptx_shd.api_updating
    (p_position_transaction_id            => p_position_transaction_id
    ,p_object_version_number  => p_object_version_number);

  if (((l_api_updating and p_work_period_type_cd
      <> nvl(pqh_ptx_shd.g_old_rec.work_period_type_cd,hr_api.g_varchar2)) or not l_api_updating)
      and nvl(p_WORK_PERIOD_TYPE_CD,'N') = 'Y') then
    hr_utility.set_location('Check permit_extended_pay:'||l_proc,10);
    l_permit_extended_pay := permit_extended_pay(p_position_transaction_id => p_position_transaction_id);
        hr_utility.set_location('Checking permit_extended_pay complete:'||l_proc,10);
    if (l_permit_extended_pay = false)  then
      --Position family is neither Academic nor Faculty, so Extended pay cannot be permitted.
      fnd_message.set_name(800,'HR_INV_EXTD_PAY_PERMIT');
      fnd_message.raise_error;
    end if;
  end if;
    hr_utility.set_location('Leaving:'||l_proc,20);
end;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_end_dates >---------------------|
-- ----------------------------------------------------------------------------
--
procedure chk_end_dates
(
p_position_transaction_id       in number
,position_id                    in number
,availability_status_id         in number
,p_effective_date               in date
,current_org_prop_end_date      in date
,current_job_prop_end_date      in date
,avail_status_prop_end_date     in date
,earliest_hire_date             in date
,fill_by_date                   in date
,proposed_date_for_layoff       in date
,date_effective                 in date
,p_object_version_number        in number)
is
   l_avail_status_start_date  date;
   l_proc                       varchar2(100) := 'pqh_ptx_bus.chk_end_dates';
   l_api_updating           boolean;
begin

--
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_ptx_shd.api_updating
    (p_position_transaction_id  => p_position_transaction_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(date_effective,hr_api.g_date)
     <> nvl(pqh_ptx_shd.g_old_rec.date_effective,hr_api.g_date)
     or not l_api_updating) and
     date_effective is not null then
    --
   if current_org_prop_end_date < date_effective then
      hr_utility.set_message('800','PER_INVALID_ORG_PROP_END_DATE');
      hr_utility.raise_error;
   end if;
   --
   if current_job_prop_end_date < date_effective then
      hr_utility.set_message('800','PER_INVALID_JOB_PROP_END_DATE');
      hr_utility.raise_error;
   end if;

   l_avail_status_start_date := hr_general.DECODE_AVAIL_STATUS_START_DATE (
                                            position_id
                                            ,availability_status_id
                                            ,p_effective_date ) ;
   if avail_status_prop_end_date < nvl(l_avail_status_start_date,date_effective) then
      hr_utility.set_message('800','PER_INVALID_STATUS_PROP_END_DT');
      hr_utility.raise_error;
   end if;

   if earliest_hire_date < date_effective then
      hr_utility.set_message('800','PER_INVALID_EARLIEST_HIRE_DATE');
      hr_utility.raise_error;
   end if;
   if fill_by_date < nvl(earliest_hire_date, date_effective) then
      hr_utility.set_message('800','PER_INVALID_FILL_BY_DATE');
      hr_utility.set_message_token('VALID_DATE',nvl(earliest_hire_date, date_effective));
      hr_utility.raise_error;
   end if;
   if proposed_date_for_layoff <= date_effective then
      hr_utility.set_message('800','PER_INVALID_PROP_DT_FOR_LAYOFF');
      hr_utility.raise_error;
   end if;
   end if;
  --
  if (l_api_updating
     and nvl(current_org_prop_end_date,hr_api.g_date)
     <> nvl(pqh_ptx_shd.g_old_rec.current_org_prop_end_date,hr_api.g_date)
     or not l_api_updating) and
     current_org_prop_end_date is not null then
    --
   if current_org_prop_end_date < date_effective then
      hr_utility.set_message('800','PER_INVALID_ORG_PROP_END_DATE');
      hr_utility.raise_error;
   end if;
  end if;
   --
  if (l_api_updating
     and nvl(current_job_prop_end_date,hr_api.g_date)
     <> nvl(pqh_ptx_shd.g_old_rec.current_job_prop_end_date,hr_api.g_date)
     or not l_api_updating) and
     current_job_prop_end_date is not null then
    --
   if current_job_prop_end_date < date_effective then
      hr_utility.set_message('800','PER_INVALID_JOB_PROP_END_DATE');
      hr_utility.raise_error;
   end if;
  end if;
   --
  if (l_api_updating
     and nvl(avail_status_prop_end_date,hr_api.g_date)
     <> nvl(pqh_ptx_shd.g_old_rec.avail_status_prop_end_date,hr_api.g_date)
     or not l_api_updating) and
     avail_status_prop_end_date is not null then
    --
   l_avail_status_start_date := hr_general.DECODE_AVAIL_STATUS_START_DATE (
                                            position_id
                                            ,availability_status_id
                                            ,p_effective_date ) ;
   if avail_status_prop_end_date < nvl(l_avail_status_start_date,date_effective) then
      hr_utility.set_message('800','PER_INVALID_STATUS_PROP_END_DT');
      hr_utility.raise_error;
   end if;
  end if;
   --
  if (l_api_updating
     and nvl(earliest_hire_date,hr_api.g_date)
     <> nvl(pqh_ptx_shd.g_old_rec.earliest_hire_date,hr_api.g_date)
     or not l_api_updating) and
     earliest_hire_date is not null then
    --
   if earliest_hire_date < date_effective then
      hr_utility.set_message('800','PER_INVALID_EARLIEST_HIRE_DATE');
      hr_utility.raise_error;
   end if;
   --
   if fill_by_date < nvl(earliest_hire_date, date_effective) then
      hr_utility.set_message('800','PER_INVALID_FILL_BY_DATE');
      hr_utility.set_message_token('VALID_DATE',nvl(earliest_hire_date, date_effective));
      hr_utility.raise_error;
   end if;
  end if;
   --
  if (l_api_updating
     and nvl(fill_by_date,hr_api.g_date)
     <> nvl(pqh_ptx_shd.g_old_rec.fill_by_date,hr_api.g_date)
     or not l_api_updating) and
     fill_by_date is not null then
    --
   if fill_by_date < nvl(earliest_hire_date, date_effective) then
      hr_utility.set_message('800','PER_INVALID_FILL_BY_DATE');
      hr_utility.set_message_token('VALID_DATE',nvl(earliest_hire_date, date_effective));
      hr_utility.raise_error;
   end if;
  end if;
   --
  if (l_api_updating
     and nvl(fill_by_date,hr_api.g_date)
     <> nvl(pqh_ptx_shd.g_old_rec.fill_by_date,hr_api.g_date)
     or not l_api_updating) and
     fill_by_date is not null then
    --
   if proposed_date_for_layoff <= date_effective then
      hr_utility.set_message('800','PER_INVALID_PROP_DT_FOR_LAYOFF');
      hr_utility.raise_error;
   end if;
  end if;
end chk_end_dates;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------<  chk_seasonal_poi  >--------------------------|
-- ----------------------------------------------------------------------------
procedure chk_seasonal_poi
(p_position_transaction_id 		       in number
  ,p_seasonal_flag 	       in varchar2
  ,p_object_version_number     in number) is
l_dummy             varchar2(1);
l_api_updating	    boolean;

cursor c_seasonal is
select 'X'
from pqh_ptx_extra_info
where position_transaction_id = nvl(p_position_transaction_id,-1)
and information_type = 'PER_SEASONAL';
begin
  l_api_updating := pqh_ptx_shd.api_updating
    (p_position_transaction_id          => p_position_transaction_id
    ,p_object_version_number            => p_object_version_number);

  if (l_api_updating
      and p_seasonal_flag
      <> nvl(pqh_ptx_shd.g_old_rec.seasonal_flag,hr_api.g_varchar2)
      and (p_seasonal_flag='N' or p_seasonal_flag is null)) then
    open c_seasonal;
    fetch c_seasonal into l_dummy;
    if c_seasonal%found then
          close c_seasonal;
          hr_utility.set_message(800,'HR_INV_SEASONAL_FLAG');
          hr_utility.raise_error;
    end if;
    close c_seasonal;
  end if;
end;
-- ----------------------------------------------------------------------------
-- |--------------------------<   chk_overlap_poi  >--------------------------|
-- ----------------------------------------------------------------------------
procedure chk_overlap_poi
(p_position_transaction_id 		       in number
  ,p_overlap_period 	       in number
  ,p_object_version_number     in number) is
l_proc varchar2(100) :='chk_overlap_poi';
l_dummy             varchar2(1);
l_api_updating	    boolean;
--
cursor c_overlap is
select 'X'
from pqh_ptx_extra_info
where position_transaction_id = p_position_transaction_id
and information_type = 'PER_OVERLAP';
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  l_api_updating := pqh_ptx_shd.api_updating
    (p_position_transaction_id          => p_position_transaction_id
    ,p_object_version_number            => p_object_version_number);

  if (l_api_updating
      and nvl(p_overlap_period,-1)
      <> nvl(pqh_ptx_shd.g_old_rec.overlap_period,hr_api.g_number)
      and p_overlap_period is null) then
    hr_utility.set_location('Checking for Overlap Dates in Position Extra Info:'||l_proc,20);
    open c_overlap;
    fetch c_overlap into l_dummy;
    hr_utility.set_location('Checked for Overlap Dates in Position Extra Info:'||l_proc,30);
    if c_overlap%found then
    hr_utility.set_location('Overlap Dates Found in Position Extra Info:'||l_proc,40);
          close c_overlap;
          hr_utility.set_message(800,'HR_INV_OVERLAP_PERIOD');
          hr_utility.raise_error;
    end if;
    hr_utility.set_location('Overlap Dates not Found in Position Extra Info:'||l_proc,40);
    close c_overlap;
  end if;
  hr_utility.set_location('Leaving:'||l_proc,20);
end;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_ptx_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_position_transaction_id
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_organization_id
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_organization_id          => p_rec.organization_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_position_definition_id
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_position_definition_id          => p_rec.position_definition_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_job_id
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_job_id          => p_rec.job_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_location_id
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_location_id          => p_rec.location_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_availability_status_id
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_availability_status_id          => p_rec.availability_status_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_end_dates
(
p_position_transaction_id          => p_rec.position_transaction_id
,position_id                     =>p_rec.position_id
,availability_status_id         =>p_rec.availability_status_id
,p_effective_date               =>p_rec.action_date
,current_org_prop_end_date      =>p_rec.current_org_prop_end_date
,current_job_prop_end_date      =>p_rec.current_job_prop_end_date
,avail_status_prop_end_date     =>p_rec.avail_status_prop_end_date
,earliest_hire_date             =>p_rec.earliest_hire_date
,fill_by_date                   =>p_rec.fill_by_date
,proposed_date_for_layoff       =>p_rec.proposed_date_for_layoff
,date_effective                 =>p_rec.date_effective
,p_object_version_number        => p_rec.object_version_number);
  --
  chk_entry_grade_id
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_entry_grade_id          => p_rec.entry_grade_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_work_term_end_month_cd
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_work_term_end_month_cd         => p_rec.work_term_end_month_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_work_term_end_day_cd
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_work_term_end_day_cd         => p_rec.work_term_end_day_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_work_period_type_cd
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_work_period_type_cd         => p_rec.work_period_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_works_council_approval_flg
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_works_council_approval_flag         => p_rec.works_council_approval_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_term_start_month_cd
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_term_start_month_cd         => p_rec.term_start_month_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_term_start_day_cd
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_term_start_day_cd         => p_rec.term_start_day_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_seasonal_flag
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_seasonal_flag         => p_rec.seasonal_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_review_flag
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_review_flag         => p_rec.review_flag,
   p_position_id	   => p_rec.position_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_replacement_required_flag
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_replacement_required_flag         => p_rec.replacement_required_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_probation_period_unit_cd
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_probation_period_unit_cd         => p_rec.probation_period_unit_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_permit_recruitment_flag
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_permit_recruitment_flag         => p_rec.permit_recruitment_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_permanent_temporary_flag
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_permanent_temporary_flag         => p_rec.permanent_temporary_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pay_term_end_month_cd
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_pay_term_end_month_cd         => p_rec.pay_term_end_month_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pay_term_end_day_cd
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_pay_term_end_day_cd         => p_rec.pay_term_end_day_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_overlap_unit_cd
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_overlap_unit_cd         => p_rec.overlap_unit_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_bargaining_unit_cd
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_bargaining_unit_cd         => p_rec.bargaining_unit_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  chk_extended_pay
  (p_position_transaction_id   => p_rec.position_transaction_id
  ,p_work_period_type_cd       => p_rec.work_period_type_cd
  ,p_term_start_day_cd         => p_rec.term_start_day_cd
  ,p_term_start_month_cd       => p_rec.term_start_month_cd
  ,p_pay_term_end_day_cd       => p_rec.pay_term_end_day_cd
  ,p_pay_term_end_month_cd     => p_rec.pay_term_end_month_cd
  ,p_work_term_end_day_cd      => p_rec.work_term_end_day_cd
  ,p_work_term_end_month_cd    => p_rec.work_term_end_month_cd
  );
  --
/*
chk_extended_pay_permit
(p_position_transaction_id	=> p_rec.position_transaction_id
  ,p_work_period_type_cd        => p_rec.work_period_type_cd
  ,p_object_version_number      => p_rec.object_version_number
);
*/
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pqh_ptx_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_position_transaction_id
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_organization_id
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_organization_id          => p_rec.organization_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_position_definition_id
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_position_definition_id          => p_rec.position_definition_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_job_id
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_job_id          => p_rec.job_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_location_id
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_location_id          => p_rec.location_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_availability_status_id
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_availability_status_id          => p_rec.availability_status_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_end_dates
(
p_position_transaction_id          => p_rec.position_transaction_id
,position_id                     =>p_rec.position_id
,availability_status_id         =>p_rec.availability_status_id
,p_effective_date               =>p_rec.action_date
,current_org_prop_end_date      =>p_rec.current_org_prop_end_date
,current_job_prop_end_date      =>p_rec.current_job_prop_end_date
,avail_status_prop_end_date     =>p_rec.avail_status_prop_end_date
,earliest_hire_date             =>p_rec.earliest_hire_date
,fill_by_date                   =>p_rec.fill_by_date
,proposed_date_for_layoff       =>p_rec.proposed_date_for_layoff
,date_effective                 =>p_rec.date_effective
,p_object_version_number        => p_rec.object_version_number);
  --
  chk_entry_grade_id
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_entry_grade_id          => p_rec.entry_grade_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_work_term_end_month_cd
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_work_term_end_month_cd         => p_rec.work_term_end_month_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_work_term_end_day_cd
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_work_term_end_day_cd         => p_rec.work_term_end_day_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_work_period_type_cd
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_work_period_type_cd         => p_rec.work_period_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_works_council_approval_flg
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_works_council_approval_flag         => p_rec.works_council_approval_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_term_start_month_cd
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_term_start_month_cd         => p_rec.term_start_month_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_term_start_day_cd
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_term_start_day_cd         => p_rec.term_start_day_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_seasonal_flag
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_seasonal_flag         => p_rec.seasonal_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_review_flag
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_review_flag         => p_rec.review_flag,
   p_position_id           => p_rec.position_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_replacement_required_flag
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_replacement_required_flag         => p_rec.replacement_required_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_probation_period_unit_cd
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_probation_period_unit_cd         => p_rec.probation_period_unit_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_permit_recruitment_flag
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_permit_recruitment_flag         => p_rec.permit_recruitment_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_permanent_temporary_flag
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_permanent_temporary_flag         => p_rec.permanent_temporary_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pay_term_end_month_cd
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_pay_term_end_month_cd         => p_rec.pay_term_end_month_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pay_term_end_day_cd
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_pay_term_end_day_cd         => p_rec.pay_term_end_day_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_overlap_unit_cd
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_overlap_unit_cd         => p_rec.overlap_unit_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_bargaining_unit_cd
  (p_position_transaction_id          => p_rec.position_transaction_id,
   p_bargaining_unit_cd         => p_rec.bargaining_unit_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_extended_pay
  (p_position_transaction_id   => p_rec.position_transaction_id
  ,p_work_period_type_cd       => p_rec.work_period_type_cd
  ,p_term_start_day_cd         => p_rec.term_start_day_cd
  ,p_term_start_month_cd       => p_rec.term_start_month_cd
  ,p_pay_term_end_day_cd       => p_rec.pay_term_end_day_cd
  ,p_pay_term_end_month_cd     => p_rec.pay_term_end_month_cd
  ,p_work_term_end_day_cd      => p_rec.work_term_end_day_cd
  ,p_work_term_end_month_cd    => p_rec.work_term_end_month_cd
  );
  --
/*
  chk_seasonal_poi
  (p_position_transaction_id	=> p_rec.position_transaction_id
  ,p_seasonal_flag		=> p_rec.seasonal_flag
  ,p_object_version_number      => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 480);
  --
  chk_overlap_poi
  (p_position_transaction_id	=> p_rec.position_transaction_id
  ,p_overlap_period		=> p_rec.overlap_period
  ,p_object_version_number      => p_rec.object_version_number);
  --
*/
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqh_ptx_shd.g_rec_type
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
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_position_transaction_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           pqh_position_transactions b
    where b.position_transaction_id      = p_position_transaction_id
    and   a.business_group_id = b.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'position_transaction_id',
                             p_argument_value => p_position_transaction_id);
  --
  open csr_leg_code;
    --
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      close csr_leg_code;
      --
      -- The primary key is invalid therefore we must error
      --
      hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
      --
    end if;
    --
  close csr_leg_code;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
  return l_legislation_code;
  --
end return_legislation_code;
--
end pqh_ptx_bus;

/
