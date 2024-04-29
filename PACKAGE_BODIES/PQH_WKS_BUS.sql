--------------------------------------------------------
--  DDL for Package Body PQH_WKS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_WKS_BUS" as
/* $Header: pqwksrhi.pkb 120.0 2005/05/29 03:01:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_wks_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_worksheet_id >------|
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
--   worksheet_id PK of record being inserted or updated.
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
Procedure chk_worksheet_id(p_worksheet_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_worksheet_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_wks_shd.api_updating
    (p_worksheet_id                => p_worksheet_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_worksheet_id,hr_api.g_number)
     <>  pqh_wks_shd.g_old_rec.worksheet_id) then
    --
    -- raise error as PK has changed
    --
    pqh_wks_shd.constraint_error('PQH_WORKSHEETS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_worksheet_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_wks_shd.constraint_error('PQH_WORKSHEETS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_worksheet_id;
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
--   p_worksheet_id PK
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
Procedure chk_budget_version_id (p_worksheet_id          in number,
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
  l_api_updating := pqh_wks_shd.api_updating
     (p_worksheet_id            => p_worksheet_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_budget_version_id,hr_api.g_number)
     <> nvl(pqh_wks_shd.g_old_rec.budget_version_id,hr_api.g_number)
     or not l_api_updating) then
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
        pqh_wks_shd.constraint_error('PQH_WORKSHEETS_FK2');
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
-- |------< chk_budget_id >------|
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
--   p_worksheet_id PK
--   p_budget_id ID of FK column
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
Procedure chk_budget_id (p_worksheet_id          in number,
                            p_budget_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_budget_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_budgets a
    where  a.budget_id = p_budget_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_wks_shd.api_updating
     (p_worksheet_id            => p_worksheet_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_budget_id,hr_api.g_number)
     <> nvl(pqh_wks_shd.g_old_rec.budget_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if budget_id value exists in pqh_budgets table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_budgets
        -- table.
        --
        pqh_wks_shd.constraint_error('PQH_WORKSHEETS_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_budget_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_worksheet_mode_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   worksheet_id PK of record being inserted or updated.
--   worksheet_mode_cd Value of lookup code.
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
Procedure chk_worksheet_mode_cd(p_worksheet_id                in number,
                            p_worksheet_mode_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_worksheet_mode_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_wks_shd.api_updating
    (p_worksheet_id                => p_worksheet_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_worksheet_mode_cd
      <> nvl(pqh_wks_shd.g_old_rec.worksheet_mode_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_worksheet_mode_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_WORKSHEET_MODE',
           p_lookup_code    => p_worksheet_mode_cd,
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
end chk_worksheet_mode_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_transaction_status >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   worksheet_id PK of record being inserted or updated.
--   transaction_status Value of lookup code.
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
Procedure chk_transaction_status(p_worksheet_id                in number,
                     p_transaction_status                      in varchar2,
                     p_effective_date              in date,
                     p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_transaction_status';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_wks_shd.api_updating
    (p_worksheet_id                => p_worksheet_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_transaction_status
      <> nvl(pqh_wks_shd.g_old_rec.transaction_status,hr_api.g_varchar2)
      or not l_api_updating)
      and p_transaction_status is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_TRANSACTION_STATUS',
           p_lookup_code    => p_transaction_status,
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
end chk_transaction_status;
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
--   worksheet_id PK of record being inserted or updated.
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
Procedure chk_propagation_method(p_worksheet_id                in number,
                     p_propagation_method                      in varchar2,
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
  l_api_updating := pqh_wks_shd.api_updating
    (p_worksheet_id                => p_worksheet_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_propagation_method
      <> nvl(pqh_wks_shd.g_old_rec.propagation_method,hr_api.g_varchar2)
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
-- ----------------------------------------------------------------------------
-- |------< chk_version_number >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the version numberis valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   worksheet_id PK of record being inserted or updated.
--   budget_id FK of record being inserted or updated.
--   version_number of budget_id being inserted or updated.
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
Procedure chk_version_number(p_worksheet_id                in number,
                     p_budget_id                   in number,
                     p_version_number              in number,
                     p_effective_date              in date,
                     p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_version_number';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  Cursor c1 is
    Select null
      from pqh_budget_versions a
     where a.budget_id      = p_budget_id
       AND a.version_number = p_version_number;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_wks_shd.api_updating
    (p_worksheet_id                => p_worksheet_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_version_number
      <> nvl(pqh_wks_shd.g_old_rec.version_number,hr_api.g_number)
      or not l_api_updating)
      and p_version_number is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
      If p_budget_id IS NULL then
         --
         -- There can be no version number without budget id
         --
         hr_utility.set_message(8302,'PQH_NO_BDGT_ID_FOR_VERSION_NO');
         hr_utility.raise_error;
      Else
         --
         -- Check if the version exists for the budget id.
         --
         Open c1;
         --
         Fetch c1 into l_dummy;
         --
         If c1%notfound then
         --
            Close c1;
            hr_utility.set_message(8302,'PQH_INVALID_VERSION_FOR_BDGT');
            hr_utility.raise_error;
         --
         End if;
         --
         Close c1;
         --
      End if;
      --
    end if;
    --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_version_number;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dates >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the version numberis valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   worksheet_id PK of record being inserted or updated.
--   dates of budget_id being inserted or updated.
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
Procedure chk_dates(p_worksheet_id                 in number,
                     p_date_from                   in date,
                     p_date_to                     in date,
                     p_effective_date              in date,
                     p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dates';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If nvl(p_date_to,to_date('31/12/4712','dd/mm/RRRR')) <
     nvl(p_date_from,to_date('31/12/4712','dd/mm/RRRR')) then
         --
         hr_utility.set_message(8302,'PQH_TO_DT_LESS_THAN_FROM_DT');
         hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dates;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_wks_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_worksheet_id
  (p_worksheet_id          => p_rec.worksheet_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_version_id
  (p_worksheet_id          => p_rec.worksheet_id,
   p_budget_version_id          => p_rec.budget_version_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_id
  (p_worksheet_id          => p_rec.worksheet_id,
   p_budget_id          => p_rec.budget_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_worksheet_mode_cd
  (p_worksheet_id          => p_rec.worksheet_id,
   p_worksheet_mode_cd         => p_rec.worksheet_mode_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_propagation_method
  (p_worksheet_id          => p_rec.worksheet_id,
   p_propagation_method    => p_rec.propagation_method,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_transaction_status
  (p_worksheet_id          => p_rec.worksheet_id,
   p_transaction_status                => p_rec.transaction_status,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_version_number
  (p_worksheet_id          => p_rec.worksheet_id,
   p_budget_id             => p_rec.budget_id,
   p_version_number        => p_rec.version_number,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dates
  (p_worksheet_id          => p_rec.worksheet_id,
   p_date_from             => p_rec.date_from,
   p_date_to               => p_rec.date_to,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pqh_wks_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_worksheet_id
  (p_worksheet_id          => p_rec.worksheet_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_version_id
  (p_worksheet_id          => p_rec.worksheet_id,
   p_budget_version_id          => p_rec.budget_version_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_id
  (p_worksheet_id          => p_rec.worksheet_id,
   p_budget_id          => p_rec.budget_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_worksheet_mode_cd
  (p_worksheet_id          => p_rec.worksheet_id,
   p_worksheet_mode_cd         => p_rec.worksheet_mode_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_propagation_method
  (p_worksheet_id          => p_rec.worksheet_id,
   p_propagation_method    => p_rec.propagation_method,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  chk_transaction_status
  (p_worksheet_id          => p_rec.worksheet_id,
   p_transaction_status                => p_rec.transaction_status,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_version_number
  (p_worksheet_id          => p_rec.worksheet_id,
   p_budget_id             => p_rec.budget_id,
   p_version_number        => p_rec.version_number,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dates
  (p_worksheet_id          => p_rec.worksheet_id,
   p_date_from             => p_rec.date_from,
   p_date_to               => p_rec.date_to,
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
Procedure delete_validate(p_rec in pqh_wks_shd.g_rec_type
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
end pqh_wks_bus;

/
