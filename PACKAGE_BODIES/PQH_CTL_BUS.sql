--------------------------------------------------------
--  DDL for Package Body PQH_CTL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CTL_BUS" as
/* $Header: pqctlrhi.pkb 120.1 2005/08/06 13:16:22 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_ctl_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_transaction_category_id >------|
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
--   transaction_category_id PK of record being inserted or updated.
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
Procedure chk_transaction_category_id
               (p_transaction_category_id                in number,
                           p_language       in varchar2) is
  --
  l_proc         varchar2(72) := g_package||'chk_transaction_category_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_ctl_shd.api_updating
    (p_transaction_category_id                => p_transaction_category_id,
     p_language       => p_language);
  --
  if (l_api_updating
     and nvl(p_transaction_category_id,hr_api.g_number)
     <>  pqh_ctl_shd.g_old_rec.transaction_category_id) then
    --
    -- raise error as PK has changed
    --
    pqh_ctl_shd.constraint_error('PQH_TXN_CATEGORIES_TL_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_transaction_category_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_ctl_shd.constraint_error('PQH_TXN_CATEGORIES_TL_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_transaction_category_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_ctl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_transaction_category_id
  (p_transaction_category_id          => p_rec.transaction_category_id,
   p_language => p_rec.language);
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pqh_ctl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_transaction_category_id
  (p_transaction_category_id          => p_rec.transaction_category_id,
   p_language => p_rec.language);
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqh_ctl_shd.g_rec_type) is
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
end pqh_ctl_bus;

/
