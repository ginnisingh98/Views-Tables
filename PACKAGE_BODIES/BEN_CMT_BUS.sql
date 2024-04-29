--------------------------------------------------------
--  DDL for Package Body BEN_CMT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CMT_BUS" as
/* $Header: becmtrhi.pkb 115.14 2002/12/31 23:57:48 mmudigon ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_cmt_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_cm_dlvry_mthd_typ_id >------|
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
--   cm_dlvry_mthd_typ_id PK of record being inserted or updated.
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
Procedure chk_cm_dlvry_mthd_typ_id
          (p_cm_dlvry_mthd_typ_id        in number,
           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cm_dlvry_mthd_typ_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cmt_shd.api_updating
    (p_cm_dlvry_mthd_typ_id        => p_cm_dlvry_mthd_typ_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_cm_dlvry_mthd_typ_id,hr_api.g_number)
     <>  ben_cmt_shd.g_old_rec.cm_dlvry_mthd_typ_id) then
    --
    -- raise error as PK has changed
    --
    ben_cmt_shd.constraint_error('BEN_CM_DLVRY_MTHD_TYP_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_cm_dlvry_mthd_typ_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_cmt_shd.constraint_error('BEN_CM_DLVRY_MTHD_TYP_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_cm_dlvry_mthd_typ_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_cm_typ_id >------|
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
--   p_cm_dlvry_mthd_typ_id PK
--   p_cm_typ_id ID of FK column
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
Procedure chk_cm_typ_id (p_cm_dlvry_mthd_typ_id  in number,
                         p_cm_typ_id             in number,
                         p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cm_typ_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_cm_typ_f a
    where  a.cm_typ_id = p_cm_typ_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_cmt_shd.api_updating
    (p_cm_dlvry_mthd_typ_id        => p_cm_dlvry_mthd_typ_id,
     p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_cm_typ_id,hr_api.g_number)
     <> nvl(ben_cmt_shd.g_old_rec.cm_typ_id,hr_api.g_number)
     or not l_api_updating) and
     p_cm_typ_id is not null then
    --
    -- check if cm_typ_id value exists in ben_cm_typ_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_cm_typ_f
        -- table.
        --
        ben_cmt_shd.constraint_error('BEN_CM_DLVRY_MTHD_TYP_FK3');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_cm_typ_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dflt_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cm_dlvry_mthd_typ_id PK of record being inserted or updated.
--   dflt_flag Value of lookup code.
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
Procedure chk_dflt_flag(p_cm_dlvry_mthd_typ_id                in number,
                            p_dflt_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dflt_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cmt_shd.api_updating
    (p_cm_dlvry_mthd_typ_id        => p_cm_dlvry_mthd_typ_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dflt_flag
      <> nvl(ben_cmt_shd.g_old_rec.dflt_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_dflt_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91210_INVLD_DFLT_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dflt_flag;
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
--   cm_dlvry_mthd_typ_id PK of record being inserted or updated.
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
Procedure chk_rqd_flag(p_cm_dlvry_mthd_typ_id                in number,
                       p_rqd_flag               in varchar2,
                       p_effective_date         in date,
                       p_object_version_number  in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rqd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cmt_shd.api_updating
    (p_cm_dlvry_mthd_typ_id        => p_cm_dlvry_mthd_typ_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rqd_flag
      <> nvl(ben_cmt_shd.g_old_rec.rqd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_rqd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91211_INVLD_RQD_FLAG');
      fnd_message.raise_error;
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
-- |------< chk_cm_dlvry_mthd_typ_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cm_dlvry_mthd_typ_id PK of record being inserted or updated.
--   cm_dlvry_mthd_typ_cd Value of lookup code.
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
Procedure chk_cm_dlvry_mthd_typ_cd
         (p_cm_dlvry_mthd_typ_id        in number,
          p_cm_dlvry_mthd_typ_cd        in varchar2,
          p_effective_date              in date,
          p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cm_dlvry_mthd_typ_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cmt_shd.api_updating
    (p_cm_dlvry_mthd_typ_id                => p_cm_dlvry_mthd_typ_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_cm_dlvry_mthd_typ_cd
      <> nvl(ben_cmt_shd.g_old_rec.cm_dlvry_mthd_typ_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_DLVRY_MTHD',
           p_lookup_code    => p_cm_dlvry_mthd_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91208_INVLD_DLVRY_MTHD_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_cm_dlvry_mthd_typ_cd;
--
-- --------------------------------------------------------------------------
--
-- |------< chk_dup_cm_dlvry_mthd >------|
-- --------------------------------------------------------------------------
--
--
-- Description
--   This procedure checks the Communication delivery method is Unique
--   in the Communication Type, in other words duplicates are not allowed.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_cm_typ_id ID of FK column
--   p_cm_dlvry_mthd_typ_id PK
--   p_effective_date session date
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
----------------------------------------------------------------------------
Procedure chk_dupl_cm_dlvry_mthd
                   (p_cm_dlvry_mthd_typ_id     in number,
                    p_cm_dlvry_mthd_typ_cd     in varchar2,
                    p_cm_typ_id                in number,
                    p_effective_date              in date,
                    p_business_group_id           in number,
                    p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dupl_cm_dlvry_mthd';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  --
  cursor crs_cm_dlvry_mthd is
    select null
    from   ben_cm_dlvry_mthd_typ
    where  cm_typ_id = nvl(p_cm_typ_id, hr_api.g_number)
    /* Bug Fix for Bug 1862 Benefits Bugs */
    and    cm_dlvry_mthd_typ_cd = p_cm_dlvry_mthd_typ_cd
    and    business_group_id + 0 = p_business_group_id ;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cmt_shd.api_updating
    ( p_cm_dlvry_mthd_typ_id        => p_cm_dlvry_mthd_typ_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_cm_dlvry_mthd_typ_cd <> ben_cmt_shd.g_old_rec.cm_dlvry_mthd_typ_cd)
or
      not l_api_updating then
      --
      hr_utility.set_location('Entering:'||l_proc, 10);
      --
      -- check if this code is already exist
      --
      open crs_cm_dlvry_mthd;
      fetch crs_cm_dlvry_mthd into l_exists;
      if crs_cm_dlvry_mthd%found then
        close crs_cm_dlvry_mthd;
        --
        -- raise error as UK1 is violated
        --
        -- ben_cmt_shd.constraint_error('BEN_REGN_UK1');
        fnd_message.set_name('BEN','BEN_91407_DUP_CM_MTHD_CD');
        fnd_message.raise_error;
        --
    end if;
    --
    close crs_cm_dlvry_mthd;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
End chk_dupl_cm_dlvry_mthd;

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_cmt_shd.g_rec_type
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
  chk_cm_dlvry_mthd_typ_id
  (p_cm_dlvry_mthd_typ_id          => p_rec.cm_dlvry_mthd_typ_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cm_typ_id
  (p_cm_dlvry_mthd_typ_id          => p_rec.cm_dlvry_mthd_typ_id,
   p_cm_typ_id          => p_rec.cm_typ_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_flag
  (p_cm_dlvry_mthd_typ_id          => p_rec.cm_dlvry_mthd_typ_id,
   p_dflt_flag         => p_rec.dflt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rqd_flag
  (p_cm_dlvry_mthd_typ_id          => p_rec.cm_dlvry_mthd_typ_id,
   p_rqd_flag         => p_rec.rqd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cm_dlvry_mthd_typ_cd
  (p_cm_dlvry_mthd_typ_id          => p_rec.cm_dlvry_mthd_typ_id,
   p_cm_dlvry_mthd_typ_cd         => p_rec.cm_dlvry_mthd_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dupl_cm_dlvry_mthd
  (p_cm_dlvry_mthd_typ_id   => p_rec.cm_dlvry_mthd_typ_id,
   p_cm_dlvry_mthd_typ_cd   => p_rec.cm_dlvry_mthd_typ_cd,
   p_cm_typ_id              => p_rec.cm_typ_id ,
   p_effective_date         => p_effective_date,
   p_business_group_id      => p_rec.business_group_id,
   p_object_version_number  => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_cmt_shd.g_rec_type
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
  chk_cm_dlvry_mthd_typ_id
  (p_cm_dlvry_mthd_typ_id          => p_rec.cm_dlvry_mthd_typ_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cm_typ_id
  (p_cm_dlvry_mthd_typ_id          => p_rec.cm_dlvry_mthd_typ_id,
   p_cm_typ_id          => p_rec.cm_typ_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_flag
  (p_cm_dlvry_mthd_typ_id          => p_rec.cm_dlvry_mthd_typ_id,
   p_dflt_flag         => p_rec.dflt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rqd_flag
  (p_cm_dlvry_mthd_typ_id          => p_rec.cm_dlvry_mthd_typ_id,
   p_rqd_flag         => p_rec.rqd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cm_dlvry_mthd_typ_cd
  (p_cm_dlvry_mthd_typ_id          => p_rec.cm_dlvry_mthd_typ_id,
   p_cm_dlvry_mthd_typ_cd         => p_rec.cm_dlvry_mthd_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dupl_cm_dlvry_mthd
  (p_cm_dlvry_mthd_typ_id   => p_rec.cm_dlvry_mthd_typ_id,
   p_cm_dlvry_mthd_typ_cd   => p_rec.cm_dlvry_mthd_typ_cd,
   p_cm_typ_id              => p_rec.cm_typ_id ,
   p_effective_date         => p_effective_date,
   p_business_group_id      => p_rec.business_group_id,
   p_object_version_number  => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_cmt_shd.g_rec_type
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
  (p_cm_dlvry_mthd_typ_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_cm_dlvry_mthd_typ b
    where b.cm_dlvry_mthd_typ_id      = p_cm_dlvry_mthd_typ_id
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
                             p_argument       => 'cm_dlvry_mthd_typ_id',
                             p_argument_value => p_cm_dlvry_mthd_typ_id);
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
end ben_cmt_bus;

/
