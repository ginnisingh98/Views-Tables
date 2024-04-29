--------------------------------------------------------
--  DDL for Package Body PQH_CEC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CEC_BUS" as
/* $Header: pqcecrhi.pkb 120.2 2005/10/12 20:18:10 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_cec_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_context >------|
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
--   context PK of record being inserted or updated.
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
Procedure chk_context(p_context                in varchar2,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_context';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_cec_shd.api_updating
    (p_context                => p_context,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_context,hr_api.g_varchar2)
     <>  pqh_cec_shd.g_old_rec.context) then
    --
    -- raise error as PK has changed
    --
    pqh_cec_shd.constraint_error('PQH_COPY_ENTITY_CONTEXTS_PK');
    --
  -- elsif not l_api_updating then
    --
    -- check if PK is null
    -- this is not true here as context is not generated
    --
    -- if p_context is not null then
      --
      -- raise error as PK is not null
      --
      -- pqh_cec_shd.constraint_error('PQH_COPY_ENTITY_CONTEXTS_PK');
      --
    -- end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_context;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_cec_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_context
  (p_context          => p_rec.context,
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
Procedure update_validate(p_rec in pqh_cec_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_context
  (p_context          => p_rec.context,
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
Procedure delete_validate(p_rec in pqh_cec_shd.g_rec_type) is
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
end pqh_cec_bus;

/
