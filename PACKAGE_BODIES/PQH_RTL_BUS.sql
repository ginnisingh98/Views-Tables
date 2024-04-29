--------------------------------------------------------
--  DDL for Package Body PQH_RTL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RTL_BUS" as
/* $Header: pqrtlrhi.pkb 115.7 2003/01/26 02:01:52 rpasapul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_rtl_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_rule_set_id >------|
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
--   rule_set_id PK of record being inserted or updated.
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
Procedure chk_rule_set_id(p_rule_set_id                in number,
                          p_language                   in varchar2) is
  --
  l_proc         varchar2(72) := g_package||'chk_rule_set_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_rtl_shd.api_updating
    (p_rule_set_id                => p_rule_set_id,
     p_language       => p_language);
  --
  if (l_api_updating
     and nvl(p_rule_set_id,hr_api.g_number)
     <>  pqh_rtl_shd.g_old_rec.rule_set_id) then
    --
    -- raise error as PK has changed
    --
    pqh_rtl_shd.constraint_error('PQH_RULE_SETS_TL_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_rule_set_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_rtl_shd.constraint_error('PQH_RULE_SETS_TL_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_rule_set_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_rtl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_rule_set_id
  (p_rule_set_id          => p_rec.rule_set_id,
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
Procedure update_validate(p_rec in pqh_rtl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_rule_set_id
  (p_rule_set_id          => p_rec.rule_set_id,
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
Procedure delete_validate(p_rec in pqh_rtl_shd.g_rec_type) is
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
end pqh_rtl_bus;

/
