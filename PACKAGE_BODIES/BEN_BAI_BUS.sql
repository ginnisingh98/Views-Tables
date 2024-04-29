--------------------------------------------------------
--  DDL for Package Body BEN_BAI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BAI_BUS" as
/* $Header: bebairhi.pkb 115.7 2002/12/13 06:21:35 hmani ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_bai_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_batch_actn_item_id >------|
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
--   batch_actn_item_id PK of record being inserted or updated.
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
Procedure chk_batch_actn_item_id(p_batch_actn_item_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_batch_actn_item_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bai_shd.api_updating
    (p_batch_actn_item_id                => p_batch_actn_item_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_batch_actn_item_id,hr_api.g_number)
     <>  ben_bai_shd.g_old_rec.batch_actn_item_id) then
    --
    -- raise error as PK has changed
    --
    ben_bai_shd.constraint_error('BEN_BATCH_ACTN_ITEM_INFO_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_batch_actn_item_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_bai_shd.constraint_error('BEN_BATCH_ACTN_ITEM_INFO_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_batch_actn_item_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_actn_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   batch_actn_item_id PK of record being inserted or updated.
--   actn_cd Value of lookup code.
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
Procedure chk_actn_cd(p_batch_actn_item_id                in number,
                            p_actn_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_actn_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bai_shd.api_updating
    (p_batch_actn_item_id                => p_batch_actn_item_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_actn_cd
      <> nvl(ben_bai_shd.g_old_rec.actn_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_actn_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'ENTER-LKP-TYPE',
           p_lookup_code    => p_actn_cd,
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
end chk_actn_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rqd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   batch_actn_item_id PK of record being inserted or updated.
--   rqd_flag Value of lookup code.
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
Procedure chk_rqd_flag(p_batch_actn_item_id                in number,
                            p_rqd_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rqd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bai_shd.api_updating
    (p_batch_actn_item_id                => p_batch_actn_item_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rqd_flag
      <> nvl(ben_bai_shd.g_old_rec.rqd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rqd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'ENTER-LKP-TYPE',
           p_lookup_code    => p_rqd_flag,
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
end chk_rqd_flag;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_bai_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_batch_actn_item_id
  (p_batch_actn_item_id          => p_rec.batch_actn_item_id,
   p_object_version_number => p_rec.object_version_number);
  --
/*
  chk_actn_cd
  (p_batch_actn_item_id          => p_rec.batch_actn_item_id,
   p_actn_cd         => p_rec.actn_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rqd_flag
  (p_batch_actn_item_id          => p_rec.batch_actn_item_id,
   p_rqd_flag         => p_rec.rqd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
*/
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_bai_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_batch_actn_item_id
  (p_batch_actn_item_id          => p_rec.batch_actn_item_id,
   p_object_version_number => p_rec.object_version_number);
  --
/*
  chk_actn_cd
  (p_batch_actn_item_id          => p_rec.batch_actn_item_id,
   p_actn_cd         => p_rec.actn_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rqd_flag
  (p_batch_actn_item_id          => p_rec.batch_actn_item_id,
   p_rqd_flag         => p_rec.rqd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
*/
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_bai_shd.g_rec_type
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
  (p_batch_actn_item_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_batch_actn_item_info b
    where b.batch_actn_item_id      = p_batch_actn_item_id
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
                             p_argument       => 'batch_actn_item_id',
                             p_argument_value => p_batch_actn_item_id);
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
end ben_bai_bus;

/
