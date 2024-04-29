--------------------------------------------------------
--  DDL for Package Body PQH_BVR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BVR_BUS" as
/* $Header: pqbvrrhi.pkb 115.10 2002/12/05 19:30:27 rpasapul ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_bvr_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_budget_version_id >------|
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
--   budget_version_id PK of record being inserted or updated.
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
Procedure chk_budget_version_id(p_budget_version_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_budget_version_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_bvr_shd.api_updating
    (p_budget_version_id                => p_budget_version_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_budget_version_id,hr_api.g_number)
     <>  pqh_bvr_shd.g_old_rec.budget_version_id) then
    --
    -- raise error as PK has changed
    --
    pqh_bvr_shd.constraint_error('PQH_BUDGET_VERSIONS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_budget_version_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_bvr_shd.constraint_error('PQH_BUDGET_VERSIONS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
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
--   p_budget_version_id PK
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
Procedure chk_budget_id (p_budget_version_id          in number,
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
  l_api_updating := pqh_bvr_shd.api_updating
    (p_budget_version_id                => p_budget_version_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_budget_id,hr_api.g_number)
     <> nvl(pqh_bvr_shd.g_old_rec.budget_id,hr_api.g_number)
     or not l_api_updating) and
     p_budget_id is not null then
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
        pqh_bvr_shd.constraint_error('PQH_BUDGET_VERSIONS_FK1');
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
-- |------< chk_xfer_to_other_apps_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   budget_version_id PK of record being inserted or updated.
--   xfer_to_other_apps_cd Value of lookup code.
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
Procedure chk_xfer_to_other_apps_cd(p_budget_version_id                in number,
                            p_xfer_to_other_apps_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_xfer_to_other_apps_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_bvr_shd.api_updating
    (p_budget_version_id                => p_budget_version_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_xfer_to_other_apps_cd
      <> nvl(pqh_bvr_shd.g_old_rec.xfer_to_other_apps_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_xfer_to_other_apps_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_xfer_to_other_apps_cd,
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
end chk_xfer_to_other_apps_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_transfered_to_gl_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   budget_version_id PK of record being inserted or updated.
--   transfered_to_gl_flag Value of lookup code.
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
Procedure chk_transfered_to_gl_flag(p_budget_version_id                in number,
                            p_transfered_to_gl_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_transfered_to_gl_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_bvr_shd.api_updating
    (p_budget_version_id                => p_budget_version_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_transfered_to_gl_flag
      <> nvl(pqh_bvr_shd.g_old_rec.transfered_to_gl_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_transfered_to_gl_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_transfered_to_gl_flag,
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
end chk_transfered_to_gl_flag;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_bvr_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_budget_version_id
  (p_budget_version_id          => p_rec.budget_version_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_id
  (p_budget_version_id          => p_rec.budget_version_id,
   p_budget_id          => p_rec.budget_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_xfer_to_other_apps_cd
  (p_budget_version_id          => p_rec.budget_version_id,
   p_xfer_to_other_apps_cd         => p_rec.xfer_to_other_apps_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_transfered_to_gl_flag
  (p_budget_version_id          => p_rec.budget_version_id,
   p_transfered_to_gl_flag         => p_rec.transfered_to_gl_flag,
   p_effective_date        => p_effective_date,
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
Procedure update_validate(p_rec in pqh_bvr_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_budget_version_id
  (p_budget_version_id          => p_rec.budget_version_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_id
  (p_budget_version_id          => p_rec.budget_version_id,
   p_budget_id          => p_rec.budget_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_xfer_to_other_apps_cd
  (p_budget_version_id          => p_rec.budget_version_id,
   p_xfer_to_other_apps_cd         => p_rec.xfer_to_other_apps_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_transfered_to_gl_flag
  (p_budget_version_id          => p_rec.budget_version_id,
   p_transfered_to_gl_flag         => p_rec.transfered_to_gl_flag,
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
Procedure delete_validate(p_rec in pqh_bvr_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
CURSOR csr_bvr IS
SELECT transfered_to_gl_flag,
       gl_status
FROM pqh_budget_versions
WHERE budget_version_id = p_rec.budget_version_id;

l_gl_flag      pqh_budget_versions.transfered_to_gl_flag%TYPE := '';
l_gl_status    pqh_budget_versions.gl_status%TYPE := '';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  --
  OPEN csr_bvr;
    FETCH csr_bvr INTO l_gl_flag,l_gl_status;
  CLOSE csr_bvr;

  --
  hr_utility.set_location('transfered_to_gl_flag: '||l_gl_flag, 10);
  hr_utility.set_location('gl_status: '||l_gl_status, 10);
  --

  IF (l_gl_flag IS NOT NULL) AND (l_gl_status IS NOT NULL) THEN
   -- this is a posted version, delete not allowed
      hr_utility.set_message(8302,'PQH_GL_REC_EXISTS');
      hr_utility.raise_error;
   --
  END IF;

  --

  hr_utility.set_location(' Leaving:'||l_proc, 100);

End delete_validate;

--
end pqh_bvr_bus;

/
