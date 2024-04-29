--------------------------------------------------------
--  DDL for Package Body BEN_EGD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EGD_BUS" as
/* $Header: beegdrhi.pkb 120.0.12010000.2 2008/08/05 14:24:02 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_egd_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_elig_dpnt_id >------|
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
--   elig_dpnt_id PK of record being inserted or updated.
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
Procedure chk_elig_dpnt_id(p_elig_dpnt_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_elig_dpnt_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_egd_shd.api_updating
    (p_elig_dpnt_id                => p_elig_dpnt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_elig_dpnt_id,hr_api.g_number)
     <>  ben_egd_shd.g_old_rec.elig_dpnt_id) then
    --
    -- raise error as PK has changed
    --
    ben_egd_shd.constraint_error('BEN_ELIG_DPNT_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_elig_dpnt_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_egd_shd.constraint_error('BEN_ELIG_DPNT_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_elig_dpnt_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_elig_per_opt_id >------|
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
--   p_elig_dpnt_id PK
--   p_elig_per_opt_id ID of FK column
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
Procedure chk_elig_per_opt_id (p_elig_dpnt_id          in number,
                            p_elig_per_opt_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_elig_per_opt_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_elig_per_opt_f a
    where  a.elig_per_opt_id = p_elig_per_opt_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_egd_shd.api_updating
     (p_elig_dpnt_id            => p_elig_dpnt_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_elig_per_opt_id,hr_api.g_number)
     <> nvl(ben_egd_shd.g_old_rec.elig_per_opt_id,hr_api.g_number)
     or not l_api_updating)
     and p_elig_per_opt_id is not null then
    --
    -- check if elig_per_opt_id value exists in ben_elig_per_opt_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_elig_per_opt_f
        -- table.
        --
        ben_egd_shd.constraint_error('BEN_ELIG_DPNT_DT1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_elig_per_opt_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_elig_per_id >------|
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
--   p_elig_dpnt_id PK
--   p_elig_per_id ID of FK column
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
Procedure chk_elig_per_id (p_elig_dpnt_id          in number,
                            p_elig_per_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_elig_per_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_elig_per_f a
    where  a.elig_per_id = p_elig_per_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_egd_shd.api_updating
     (p_elig_dpnt_id            => p_elig_dpnt_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_elig_per_id,hr_api.g_number)
     <> nvl(ben_egd_shd.g_old_rec.elig_per_id,hr_api.g_number)
     or not l_api_updating)
     and p_elig_per_id is not null then
    --
    -- check if elig_per_id value exists in ben_elig_per_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_elig_per_f
        -- table.
        --
        ben_egd_shd.constraint_error('BEN_ELIG_DPNT_DT2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_elig_per_id;
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
--   p_elig_dpnt_id PK
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
Procedure chk_person_id (p_elig_dpnt_id          in number,
                            p_dpnt_person_id          in number,
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
    where  a.person_id = p_dpnt_person_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_egd_shd.api_updating
     (p_elig_dpnt_id            => p_elig_dpnt_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_dpnt_person_id,hr_api.g_number)
     <> nvl(ben_egd_shd.g_old_rec.dpnt_person_id,hr_api.g_number)
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
        ben_egd_shd.constraint_error('BEN_ELIG_DPNT_DT4');
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
-- |------< chk_per_in_ler_id >------|
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
--   p_elig_dpnt_id PK
--   p_per_in_ler_id ID of FK column
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
Procedure chk_per_in_ler_id (p_elig_dpnt_id          in number,
                            p_per_in_ler_id          in number,
                            p_object_version_number in number,
                            p_effective_date        in date ) is
  --
  l_proc         varchar2(72) := g_package||'chk_per_in_ler_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_per_in_ler a ,
           ben_ler_f b
    where  a.per_in_ler_id = p_per_in_ler_id
      and  a.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT')
      and  a.ler_id = b.ler_id
      and  b.typ_cd <> 'COMP'
      and    p_effective_date
           between b.effective_start_date
           and     b.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_egd_shd.api_updating
     (p_elig_dpnt_id            => p_elig_dpnt_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_per_in_ler_id,hr_api.g_number)
     <> nvl(ben_egd_shd.g_old_rec.per_in_ler_id,hr_api.g_number)
     or not l_api_updating) and
     p_per_in_ler_id is not null then
    --
    -- check if per_in_ler_id value exists in ben_per_in_ler table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_per_in_ler
        -- table.
        --
        ben_egd_shd.constraint_error('BEN_ELIG_DPNT_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_per_in_ler_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_inelig_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_dpnt_id PK of record being inserted or updated.
--   dpnt_inelig_flag Value of lookup code.
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
Procedure chk_dpnt_inelig_flag(p_elig_dpnt_id                in number,
                            p_dpnt_inelig_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_inelig_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_egd_shd.api_updating
    (p_elig_dpnt_id                => p_elig_dpnt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dpnt_inelig_flag
      <> nvl(ben_egd_shd.g_old_rec.dpnt_inelig_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_dpnt_inelig_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_dpnt_inelig_flag);
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_inelig_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_inelg_rsn_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_dpnt_id PK of record being inserted or updated.
--   inelg_rsn_cd Value of lookup code.
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
Procedure chk_inelg_rsn_cd(p_elig_dpnt_id                in number,
                            p_inelg_rsn_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_inelg_rsn_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_egd_shd.api_updating
    (p_elig_dpnt_id                => p_elig_dpnt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_inelg_rsn_cd
      <> nvl(ben_egd_shd.g_old_rec.inelg_rsn_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_inelg_rsn_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_INELG_RSN',
           p_lookup_code    => p_inelg_rsn_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_inelg_rsn_cd);
      fnd_message.set_token('TYPE','BEN_INELG_RSN');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_inelg_rsn_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_ovrdn_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_dpnt_id PK of record being inserted or updated.
--   ovrdn_flag Value of lookup code.
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
Procedure chk_ovrdn_flag(p_elig_dpnt_id                in number,
                            p_ovrdn_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ovrdn_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_egd_shd.api_updating
    (p_elig_dpnt_id                => p_elig_dpnt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_ovrdn_flag
      <> nvl(ben_egd_shd.g_old_rec.ovrdn_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_ovrdn_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_ovrdn_flag);
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_ovrdn_flag;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_egd_shd.g_rec_type
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
  chk_elig_dpnt_id
  (p_elig_dpnt_id          => p_rec.elig_dpnt_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_per_in_ler_id
  (p_elig_dpnt_id          => p_rec.elig_dpnt_id,
   p_per_in_ler_id          => p_rec.per_in_ler_id,
   p_object_version_number => p_rec.object_version_number,
   p_effective_date        => p_effective_date );
  --
  chk_elig_per_opt_id
  (p_elig_dpnt_id          => p_rec.elig_dpnt_id,
   p_elig_per_opt_id       => p_rec.elig_per_opt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_elig_per_id
  (p_elig_dpnt_id          => p_rec.elig_dpnt_id,
   p_elig_per_id           => p_rec.elig_per_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_person_id
  (p_elig_dpnt_id          => p_rec.elig_dpnt_id,
   p_dpnt_person_id        => p_rec.dpnt_person_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_inelig_flag
  (p_elig_dpnt_id          => p_rec.elig_dpnt_id,
   p_dpnt_inelig_flag      => p_rec.dpnt_inelig_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_inelg_rsn_cd
  (p_elig_dpnt_id          => p_rec.elig_dpnt_id,
   p_inelg_rsn_cd         => p_rec.inelg_rsn_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ovrdn_flag
  (p_elig_dpnt_id          => p_rec.elig_dpnt_id,
   p_ovrdn_flag         => p_rec.ovrdn_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_egd_shd.g_rec_type
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
  chk_elig_dpnt_id
  (p_elig_dpnt_id          => p_rec.elig_dpnt_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_per_in_ler_id
  (p_elig_dpnt_id          => p_rec.elig_dpnt_id,
   p_per_in_ler_id         => p_rec.per_in_ler_id,
   p_object_version_number => p_rec.object_version_number,
   p_effective_date        => p_effective_date);
  --
  chk_elig_per_opt_id
  (p_elig_dpnt_id          => p_rec.elig_dpnt_id,
   p_elig_per_opt_id       => p_rec.elig_per_opt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_elig_per_id
  (p_elig_dpnt_id          => p_rec.elig_dpnt_id,
   p_elig_per_id           => p_rec.elig_per_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_person_id
  (p_elig_dpnt_id          => p_rec.elig_dpnt_id,
   p_dpnt_person_id        => p_rec.dpnt_person_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_inelig_flag
  (p_elig_dpnt_id          => p_rec.elig_dpnt_id,
   p_dpnt_inelig_flag         => p_rec.dpnt_inelig_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_inelg_rsn_cd
  (p_elig_dpnt_id          => p_rec.elig_dpnt_id,
   p_inelg_rsn_cd         => p_rec.inelg_rsn_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ovrdn_flag
  (p_elig_dpnt_id          => p_rec.elig_dpnt_id,
   p_ovrdn_flag         => p_rec.ovrdn_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_egd_shd.g_rec_type
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
  (p_elig_dpnt_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_elig_dpnt b
    where b.elig_dpnt_id      = p_elig_dpnt_id
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
                             p_argument       => 'elig_dpnt_id',
                             p_argument_value => p_elig_dpnt_id);
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
end ben_egd_bus;

/
