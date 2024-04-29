--------------------------------------------------------
--  DDL for Package Body PER_STT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_STT_BUS" as
/* $Header: pesttrhi.pkb 115.4 2002/12/09 14:19:55 eumenyio ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_stt_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_shared_type_id >------|
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
--   shared_type_id PK of record being inserted or updated.
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
Procedure chk_shared_type_id(p_shared_type_id                in number,
                             p_language       in varchar2) is
  --
  l_proc         varchar2(72) := g_package||'chk_shared_type_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := per_stt_shd.api_updating
    (p_shared_type_id                => p_shared_type_id,
     p_language                    => p_language             );
  --
  if (l_api_updating
     and nvl(p_shared_type_id,hr_api.g_number)
     <>  per_stt_shd.g_old_rec.shared_type_id) then
    --
    -- raise error as PK has changed
    --
    per_stt_shd.constraint_error('PER_SHARED_TYPES_TL_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_shared_type_id is not null then
      --
      -- raise error as PK is not null
      --
      per_stt_shd.constraint_error('PER_SHARED_TYPES_TL_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_shared_type_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in per_stt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_shared_type_id
  (p_shared_type_id          => p_rec.shared_type_id,
   p_language                => p_rec.language);
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in per_stt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_shared_type_id
  (p_shared_type_id          => p_rec.shared_type_id,
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
Procedure delete_validate(p_rec in per_stt_shd.g_rec_type) is
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
end per_stt_bus;

/
