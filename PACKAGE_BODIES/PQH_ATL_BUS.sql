--------------------------------------------------------
--  DDL for Package Body PQH_ATL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_ATL_BUS" as
/* $Header: pqatlrhi.pkb 120.2 2006/05/23 15:58:59 srajakum ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_atl_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_attribute_id >------|
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
--   attribute_id PK of record being inserted or updated.
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
Procedure chk_attribute_id(p_attribute_id                in number,
                           p_language                    in varchar2) is
  --
  l_proc         varchar2(72) := g_package||'chk_attribute_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_atl_shd.api_updating
    (p_attribute_id                => p_attribute_id,
     p_language                    => p_language);
  --
  if (l_api_updating
     and nvl(p_attribute_id,hr_api.g_number)
     <>  pqh_atl_shd.g_old_rec.attribute_id) then
    --
    -- raise error as PK has changed
    --
    pqh_atl_shd.constraint_error('PQH_ATTRIBUTES_TL_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_attribute_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_atl_shd.constraint_error('PQH_ATTRIBUTES_TL_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_attribute_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_atl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_attribute_id
  (p_attribute_id          => p_rec.attribute_id,
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
Procedure update_validate(p_rec in pqh_atl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_attribute_id
  (p_attribute_id          => p_rec.attribute_id,
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
Procedure delete_validate(p_rec in pqh_atl_shd.g_rec_type) is
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
end pqh_atl_bus;

/
