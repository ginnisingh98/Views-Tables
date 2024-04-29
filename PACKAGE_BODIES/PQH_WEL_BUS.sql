--------------------------------------------------------
--  DDL for Package Body PQH_WEL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_WEL_BUS" as
/* $Header: pqwelrhi.pkb 115.4 2002/12/13 00:36:31 rpasapul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_wel_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_worksheet_bdgt_elmnt_id >------|
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
--   worksheet_bdgt_elmnt_id PK of record being inserted or updated.
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
Procedure chk_worksheet_bdgt_elmnt_id(p_worksheet_bdgt_elmnt_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_worksheet_bdgt_elmnt_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_wel_shd.api_updating
    (p_worksheet_bdgt_elmnt_id                => p_worksheet_bdgt_elmnt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_worksheet_bdgt_elmnt_id,hr_api.g_number)
     <>  pqh_wel_shd.g_old_rec.worksheet_bdgt_elmnt_id) then
    --
    -- raise error as PK has changed
    --
    pqh_wel_shd.constraint_error('PQH_WORKSHEET_BDGT_ELMNTS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_worksheet_bdgt_elmnt_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_wel_shd.constraint_error('PQH_WORKSHEET_BDGT_ELMNTS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_worksheet_bdgt_elmnt_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_worksheet_budget_set_id >------|
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
--   p_worksheet_bdgt_elmnt_id PK
--   p_worksheet_budget_set_id ID of FK column
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
Procedure chk_worksheet_budget_set_id (p_worksheet_bdgt_elmnt_id          in number,
                            p_worksheet_budget_set_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_worksheet_budget_set_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_worksheet_budget_sets a
    where  a.worksheet_budget_set_id = p_worksheet_budget_set_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_wel_shd.api_updating
     (p_worksheet_bdgt_elmnt_id            => p_worksheet_bdgt_elmnt_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_worksheet_budget_set_id,hr_api.g_number)
     <> nvl(pqh_wel_shd.g_old_rec.worksheet_budget_set_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if worksheet_budget_set_id value exists in pqh_worksheet_budget_sets table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_worksheet_budget_sets
        -- table.
        --
        pqh_wel_shd.constraint_error('PQH_WORKSHEET_BDGT_ELMNTS_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_worksheet_budget_set_id;
--
--
----------------------------------------------------------------------------
-- Additional checks
----------------------------------------------------------------------------
--
--
Procedure chk_element_type_id (p_worksheet_bdgt_elmnt_id          in number,
                            p_element_type_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_element_type_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pay_element_types_f a
    where  a.element_type_id = p_element_type_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_wel_shd.api_updating
     (p_worksheet_bdgt_elmnt_id            => p_worksheet_bdgt_elmnt_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_element_type_id,hr_api.g_number)
     <> nvl(pqh_wel_shd.g_old_rec.element_type_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if worksheet_budget_set_id value exists in pqh_worksheet_budget_sets table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pay_element_types_f
        -- table.
        --
        hr_utility.set_message(8302,'PQH_INVALID_WKS_ELEMENT_TYPE');
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
End chk_element_type_id;
--
--
--
Procedure chk_distribution_percentage(p_worksheet_bdgt_elmnt_id      in number,
                            p_distribution_percentage          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_distribution_percentage';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_wel_shd.api_updating
     (p_worksheet_bdgt_elmnt_id            => p_worksheet_bdgt_elmnt_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_distribution_percentage,hr_api.g_number)
     <> nvl(pqh_wel_shd.g_old_rec.distribution_percentage,hr_api.g_number)
     or not l_api_updating)
     and p_distribution_percentage is not null then
    --
    -- check if worksheet_budget_set_id value exists in pqh_worksheet_budget_sets table
    --
      If p_distribution_percentage < 0 then
         hr_utility.set_message(8302,'PQH_INVALID_DISTRIB_PERCENT');
         hr_utility.raise_error;
      End if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_distribution_percentage;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_wel_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_worksheet_bdgt_elmnt_id
  (p_worksheet_bdgt_elmnt_id          => p_rec.worksheet_bdgt_elmnt_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_worksheet_budget_set_id
  (p_worksheet_bdgt_elmnt_id          => p_rec.worksheet_bdgt_elmnt_id,
   p_worksheet_budget_set_id          => p_rec.worksheet_budget_set_id,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  chk_distribution_percentage
  (p_worksheet_bdgt_elmnt_id          => p_rec.worksheet_bdgt_elmnt_id,
   p_distribution_percentage          => p_rec.distribution_percentage,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_element_type_id
  (p_worksheet_bdgt_elmnt_id          => p_rec.worksheet_bdgt_elmnt_id,
   p_element_type_id                  => p_rec.element_type_id,
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
Procedure update_validate(p_rec in pqh_wel_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_worksheet_bdgt_elmnt_id
  (p_worksheet_bdgt_elmnt_id          => p_rec.worksheet_bdgt_elmnt_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_worksheet_budget_set_id
  (p_worksheet_bdgt_elmnt_id          => p_rec.worksheet_bdgt_elmnt_id,
   p_worksheet_budget_set_id          => p_rec.worksheet_budget_set_id,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  chk_distribution_percentage
  (p_worksheet_bdgt_elmnt_id          => p_rec.worksheet_bdgt_elmnt_id,
   p_distribution_percentage          => p_rec.distribution_percentage,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_element_type_id
  (p_worksheet_bdgt_elmnt_id          => p_rec.worksheet_bdgt_elmnt_id,
   p_element_type_id                  => p_rec.element_type_id,
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
Procedure delete_validate(p_rec in pqh_wel_shd.g_rec_type) is
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
end pqh_wel_bus;

/
