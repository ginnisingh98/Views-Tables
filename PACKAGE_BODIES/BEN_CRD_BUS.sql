--------------------------------------------------------
--  DDL for Package Body BEN_CRD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CRD_BUS" as
/* $Header: becrdrhi.pkb 115.4 2002/12/16 11:03:52 rpgupta ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_crd_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_crt_ordr_cvrd_per_id >------|
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
--   crt_ordr_cvrd_per_id PK of record being inserted or updated.
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
Procedure chk_crt_ordr_cvrd_per_id(p_crt_ordr_cvrd_per_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_crt_ordr_cvrd_per_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_crd_shd.api_updating
    (p_crt_ordr_cvrd_per_id                => p_crt_ordr_cvrd_per_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_crt_ordr_cvrd_per_id,hr_api.g_number)
     <>  ben_crd_shd.g_old_rec.crt_ordr_cvrd_per_id) then
    --
    -- raise error as PK has changed
    --
    ben_crd_shd.constraint_error('BEN_CRT_ORDR_CVRD_PER_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_crt_ordr_cvrd_per_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_crd_shd.constraint_error('BEN_CRT_ORDR_CVRD_PER_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_crt_ordr_cvrd_per_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_person_id >------|
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
--   p_crt_ordr_cvrd_per_id PK
--   p_person_id ID of FK column
--   p_effective_date Session Date of record
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
Procedure chk_person_id (p_crt_ordr_cvrd_per_id          in number,
                            p_person_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_person_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_all_people_f a
    where  a.person_id = p_person_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_crd_shd.api_updating
     (p_crt_ordr_cvrd_per_id            => p_crt_ordr_cvrd_per_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_person_id,hr_api.g_number)
     <> nvl(ben_crd_shd.g_old_rec.person_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if person_id value exists in per_all_people_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_all_people_f
        -- table.
        --
        ben_crd_shd.constraint_error('BEN_CRT_ORDR_CVRD_PER_DT1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_person_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_crt_ordr_id >------|
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
--   p_crt_ordr_cvrd_per_id PK
--   p_crt_ordr_id ID of FK column
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
Procedure chk_crt_ordr_id (p_crt_ordr_cvrd_per_id          in number,
                            p_crt_ordr_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_crt_ordr_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_crt_ordr a
    where  a.crt_ordr_id = p_crt_ordr_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
   l_api_updating := ben_crd_shd.api_updating
    (p_crt_ordr_cvrd_per_id                => p_crt_ordr_cvrd_per_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_crt_ordr_id,hr_api.g_number)
     <> nvl(ben_crd_shd.g_old_rec.crt_ordr_id,hr_api.g_number)
     or not l_api_updating) and
     p_crt_ordr_id is not null then
    --
    -- check if crt_ordr_id value exists in ben_crt_ordr table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_crt_ordr
        -- table.
        --
        ben_crd_shd.constraint_error('BEN_CRT_ORDR_CVRD_PER_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_crt_ordr_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_crd_shd.g_rec_type) is
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
  chk_crt_ordr_cvrd_per_id
  (p_crt_ordr_cvrd_per_id          => p_rec.crt_ordr_cvrd_per_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_crt_ordr_id
  (p_crt_ordr_cvrd_per_id          => p_rec.crt_ordr_cvrd_per_id,
   p_crt_ordr_id          => p_rec.crt_ordr_id,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_crd_shd.g_rec_type) is
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
  chk_crt_ordr_cvrd_per_id
  (p_crt_ordr_cvrd_per_id          => p_rec.crt_ordr_cvrd_per_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_crt_ordr_id
  (p_crt_ordr_cvrd_per_id          => p_rec.crt_ordr_cvrd_per_id,
   p_crt_ordr_id          => p_rec.crt_ordr_id,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_crd_shd.g_rec_type) is
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
  (p_crt_ordr_cvrd_per_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_crt_ordr_cvrd_per b
    where b.crt_ordr_cvrd_per_id      = p_crt_ordr_cvrd_per_id
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
                             p_argument       => 'crt_ordr_cvrd_per_id',
                             p_argument_value => p_crt_ordr_cvrd_per_id);
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
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
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
end ben_crd_bus;

/
