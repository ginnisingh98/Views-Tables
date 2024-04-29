--------------------------------------------------------
--  DDL for Package Body PQH_BGM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BGM_BUS" as
/* $Header: pqbgmrhi.pkb 115.3 2002/12/05 16:33:25 rpasapul ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_bgm_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_budget_gl_flex_map_id >------|
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
--   budget_gl_flex_map_id PK of record being inserted or updated.
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
Procedure chk_budget_gl_flex_map_id(p_budget_gl_flex_map_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_budget_gl_flex_map_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_bgm_shd.api_updating
    (p_budget_gl_flex_map_id                => p_budget_gl_flex_map_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_budget_gl_flex_map_id,hr_api.g_number)
     <>  pqh_bgm_shd.g_old_rec.budget_gl_flex_map_id) then
    --
    -- raise error as PK has changed
    --
    pqh_bgm_shd.constraint_error('PQH_BUDGET_GL_FLEX_MAPS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_budget_gl_flex_map_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_bgm_shd.constraint_error('PQH_BUDGET_GL_FLEX_MAPS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_budget_gl_flex_map_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_mapped_segments >----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_mapped_segments(p_budget_gl_flex_map_id in number,
                              p_budget_id            in number,
                              p_gl_account_segment   in varchar2) is
--
/*
  This procedure checks that gl_acc_segments don't repeat more then 1 time for
  a given budget id
  This procedure will check that the combination of gl_acc seg and
  payroll_cost_seg is unique for a given budget id
*/
  l_proc         varchar2(72) := g_package||'chk_mapped_segments';
  l_count        number  := 0;
  l_api_updating boolean;

CURSOR csr_map_count IS
SELECT COUNT(*)
FROM pqh_budget_gl_flex_maps
WHERE budget_id = p_budget_id
  AND gl_account_segment   = p_gl_account_segment
  AND budget_gl_flex_map_id <> p_budget_gl_flex_map_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

        OPEN csr_map_count;
          FETCH csr_map_count INTO l_count;
        CLOSE csr_map_count;

        IF NVL(l_count,0) <> 0 THEN
          -- raise error as combination already exists
           hr_utility.set_message(8302,'PQH_INVALID_BUDGET_GL_MAP');
           hr_utility.raise_error;
        END IF;


  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_mapped_segments;
  --
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_cost_segments >----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_cost_segments(p_budget_id            in number,
                              p_gl_account_segment   in varchar2,
                              p_payroll_cost_segment in varchar2) is
--
/*
  This procedure will check that the payroll_cost_segment is NOT NULL in UPDATE
  This will ONLY be called in update_validate
*/
  l_proc         varchar2(72) := g_package||'chk_cost_segments';

  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    IF p_gl_account_segment   IS NULL OR
       p_payroll_cost_segment IS NULL THEN

      -- raise error as combination already exists
       hr_utility.set_message(8302,'PQH_COST_GL_MAP_NULL');
       hr_utility.raise_error;
    END IF;

  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_cost_segments;
  --
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_bgm_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_budget_gl_flex_map_id
  (p_budget_gl_flex_map_id          => p_rec.budget_gl_flex_map_id,
   p_object_version_number => p_rec.object_version_number);
  --
chk_mapped_segments
  (p_budget_gl_flex_map_id    => p_rec.budget_gl_flex_map_id,
   p_budget_id            => p_rec.budget_id,
   p_gl_account_segment   => p_rec.gl_account_segment
  );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pqh_bgm_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_budget_gl_flex_map_id
  (p_budget_gl_flex_map_id          => p_rec.budget_gl_flex_map_id,
   p_object_version_number => p_rec.object_version_number);
  --
chk_mapped_segments
  (p_budget_gl_flex_map_id    => p_rec.budget_gl_flex_map_id,
   p_budget_id            => p_rec.budget_id,
   p_gl_account_segment   => p_rec.gl_account_segment
  );
  --
chk_cost_segments
  (p_budget_id            => p_rec.budget_id,
   p_gl_account_segment   => p_rec.gl_account_segment,
   p_payroll_cost_segment => p_rec.payroll_cost_segment
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqh_bgm_shd.g_rec_type) is
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
end pqh_bgm_bus;

/
