--------------------------------------------------------
--  DDL for Package Body BEN_LOP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LOP_BUS" as
/* $Header: beloprhi.pkb 115.12 2002/12/13 06:19:42 hmani ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_lop_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_ler_chg_oipl_enrt_id >------|
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
--   ler_chg_oipl_enrt_id PK of record being inserted or updated.
--   effective_date Effective Date of session
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
Procedure chk_ler_chg_oipl_enrt_id(p_ler_chg_oipl_enrt_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ler_chg_oipl_enrt_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lop_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_ler_chg_oipl_enrt_id                => p_ler_chg_oipl_enrt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ler_chg_oipl_enrt_id,hr_api.g_number)
     <>  ben_lop_shd.g_old_rec.ler_chg_oipl_enrt_id) then
    --
    -- raise error as PK has changed
    --
    ben_lop_shd.constraint_error('BEN_LER_CHG_OIPL_ENRT_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_ler_chg_oipl_enrt_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_lop_shd.constraint_error('BEN_LER_CHG_OIPL_ENRT_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ler_chg_oipl_enrt_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_auto_enrt_flag >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_oipl_enrt_id PK of record being inserted or updated.
--   auto_enrt_flag Value of lookup code.
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
Procedure chk_auto_enrt_flag(p_ler_chg_oipl_enrt_id       in number,
                             p_auto_enrt_flag             in varchar2,
                             p_effective_date             in date,
                             p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_auto_enrt_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lop_shd.api_updating
    (p_ler_chg_oipl_enrt_id        => p_ler_chg_oipl_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_auto_enrt_flag
      <> nvl(ben_lop_shd.g_old_rec.auto_enrt_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_auto_enrt_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_auto_enrt_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_auto_enrt_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_auto_enrt_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_stl_elig_cant_chg_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_oipl_enrt_id PK of record being inserted or updated.
--   stl_elig_cant_chg_flag Value of lookup code.
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
Procedure chk_stl_elig_cant_chg_flag(p_ler_chg_oipl_enrt_id                in number,
                            p_stl_elig_cant_chg_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_stl_elig_cant_chg_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lop_shd.api_updating
    (p_ler_chg_oipl_enrt_id                => p_ler_chg_oipl_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_stl_elig_cant_chg_flag
      <> nvl(ben_lop_shd.g_old_rec.stl_elig_cant_chg_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_stl_elig_cant_chg_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_stl_elig_cant_chg_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('PAY','HR_LOOKUP_DOES_NOT_EXIST');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_stl_elig_cant_chg_flag;
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
--   ler_chg_oipl_enrt_id PK of record being inserted or updated.
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
Procedure chk_dflt_flag(p_ler_chg_oipl_enrt_id                in number,
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
  l_api_updating := ben_lop_shd.api_updating
    (p_ler_chg_oipl_enrt_id                => p_ler_chg_oipl_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dflt_flag
      <> nvl(ben_lop_shd.g_old_rec.dflt_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_dflt_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_dflt_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('PAY','HR_LOOKUP_DOES_NOT_EXIST');
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
-- |------< chk_dflt_enrt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_oipl_enrt_id PK of record being inserted or updated.
--   dflt_enrt_cd Value of lookup code.
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
Procedure chk_dflt_enrt_cd(p_ler_chg_oipl_enrt_id                in number,
                            p_dflt_enrt_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dflt_enrt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lop_shd.api_updating
    (p_ler_chg_oipl_enrt_id                => p_ler_chg_oipl_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dflt_enrt_cd
      <> nvl(ben_lop_shd.g_old_rec.dflt_enrt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_dflt_enrt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_DFLT_ENRT',
           p_lookup_code    => p_dflt_enrt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('PAY','HR_LOOKUP_DOES_NOT_EXIST');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dflt_enrt_cd;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_dflt_enrt_rl >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_oipl_enrt_id   PK of record being inserted or updated.
--   dflt_enrt_rl           Value of lookup code.
--   effective_date         effective date
--   object_version_number  Object version number of record being
--                          inserted or updated.
--   business_group_id
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
Procedure chk_dflt_enrt_rl(p_ler_chg_oipl_enrt_id        in number,
                           p_dflt_enrt_rl                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number,
                           p_business_group_id           in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dflt_enrt_rl';
  l_api_updating boolean;
  l_dummy varchar2(30);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff,
           per_business_groups pbg
    where  ff.formula_id = p_dflt_enrt_rl
    and    ff.formula_type_id = - 32
    and    pbg.business_group_id = p_business_group_id
    and    nvl(ff.business_group_id, p_business_group_id) =
           p_business_group_id
    and    nvl(ff.legislation_code, pbg.legislation_code) =
           pbg.legislation_code
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lop_shd.api_updating
    (p_ler_chg_oipl_enrt_id        => p_ler_chg_oipl_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dflt_enrt_rl
      <> nvl(ben_lop_shd.g_old_rec.dflt_enrt_rl,hr_api.g_number)
      or not l_api_updating)
      and p_dflt_enrt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1;
      --
      -- fetch value from cursor if it returns a record then the
      -- formula is valid otherwise its invalid
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error
        --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_dflt_enrt_rl);
      fnd_message.set_token('TYPE_ID',-32);
      fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dflt_enrt_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_enrt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_oipl_enrt_id PK of record being inserted or updated.
--   enrt_cd Value of lookup code.
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
Procedure chk_enrt_cd(p_ler_chg_oipl_enrt_id                in number,
                            p_enrt_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lop_shd.api_updating
    (p_ler_chg_oipl_enrt_id                => p_ler_chg_oipl_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_cd
      <> nvl(ben_lop_shd.g_old_rec.enrt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_enrt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ENRT',
           p_lookup_code    => p_enrt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('PAY','HR_LOOKUP_DOES_NOT_EXIST');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enrt_cd;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_enrt_rl >-----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_oipl_enrt_id   PK of record being inserted or updated.
--   enrt_rl                Value of lookup code.
--   effective_date         effective date
--   object_version_number  Object version number of record being
--                          inserted or updated.
--   business_group_id
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
Procedure chk_enrt_rl(p_ler_chg_oipl_enrt_id              in number,
                            p_enrt_rl                     in number,
                            p_effective_date              in date,
                            p_object_version_number       in number,
                            p_business_group_id           in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_rl';
  l_api_updating boolean;
  l_dummy varchar2(30);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff,
           per_business_groups pbg
    where  ff.formula_id = p_enrt_rl
    and    ff.formula_type_id = - 393
    and    pbg.business_group_id = p_business_group_id
    and    nvl(ff.business_group_id, p_business_group_id) =
           p_business_group_id
    and    nvl(ff.legislation_code, pbg.legislation_code) =
           pbg.legislation_code
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lop_shd.api_updating
    (p_ler_chg_oipl_enrt_id        => p_ler_chg_oipl_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_rl
      <> nvl(ben_lop_shd.g_old_rec.enrt_rl,hr_api.g_number)
      or not l_api_updating)
      and p_enrt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1;
      --
      -- fetch value from cursor if it returns a record then the
      -- formula is valid otherwise its invalid
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error
        --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_enrt_rl);
      fnd_message.set_token('TYPE_ID',-393);
      fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enrt_rl;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_auto_enrt_mthd_rl >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_oipl_enrt_id   PK of record being inserted or updated.
--   auto_enrt_mthd_rl      Value of lookup code.
--   effective_date         effective date
--   object_version_number  Object version number of record being
--                          inserted or updated.
--   business_group_id
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
Procedure chk_auto_enrt_mthd_rl(p_ler_chg_oipl_enrt_id    in number,
                            p_auto_enrt_mthd_rl           in number,
                            p_effective_date              in date,
                            p_object_version_number       in number,
                            p_business_group_id           in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_auto_enrt_mthd_rl';
  l_api_updating boolean;
  l_dummy varchar2(30);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff,
           per_business_groups pbg
    where  ff.formula_id = p_auto_enrt_mthd_rl
    and    ff.formula_type_id = - 146
    and    pbg.business_group_id = p_business_group_id
    and    nvl(ff.business_group_id, p_business_group_id) =
           p_business_group_id
    and    nvl(ff.legislation_code, pbg.legislation_code) =
           pbg.legislation_code
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lop_shd.api_updating
    (p_ler_chg_oipl_enrt_id        => p_ler_chg_oipl_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_auto_enrt_mthd_rl
      <> nvl(ben_lop_shd.g_old_rec.auto_enrt_mthd_rl,hr_api.g_number)
      or not l_api_updating)
      and p_auto_enrt_mthd_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1;
      --
      -- fetch value from cursor if it returns a record then the
      -- formula is valid otherwise its invalid
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error
        --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_auto_enrt_mthd_rl);
      fnd_message.set_token('TYPE_ID',-146);
      fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_auto_enrt_mthd_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_use_schedd_enrt_dfns_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_oipl_enrt_id PK of record being inserted or updated.
--   use_schedd_enrt_dfns_flag Value of lookup code.
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
/*
--
Procedure chk_use_schedd_enrt_dfns_flag(p_ler_chg_oipl_enrt_id                in number,
                            p_use_schedd_enrt_dfns_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_use_schedd_enrt_dfns_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lop_shd.api_updating
    (p_ler_chg_oipl_enrt_id                => p_ler_chg_oipl_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_use_schedd_enrt_dfns_flag
      <> nvl(ben_lop_shd.g_old_rec.use_schedd_enrt_dfns_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_use_schedd_enrt_dfns_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_use_schedd_enrt_dfns_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('PAY','HR_LOOKUP_DOES_NOT_EXIST');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_use_schedd_enrt_dfns_flag;
--
*/
--
-- ----------------------------------------------------------------------------
-- |------< chk_use_schedd_enrt_dflts_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_oipl_enrt_id PK of record being inserted or updated.
--   use_schedd_enrt_dflts_flag Value of lookup code.
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
/*
--
Procedure chk_use_schedd_enrt_dflts_flag(p_ler_chg_oipl_enrt_id                in number,
                            p_use_schedd_enrt_dflts_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_use_schedd_enrt_dflts_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lop_shd.api_updating
    (p_ler_chg_oipl_enrt_id                => p_ler_chg_oipl_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_use_schedd_enrt_dflts_flag
      <> nvl(ben_lop_shd.g_old_rec.use_schedd_enrt_dflts_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_use_schedd_enrt_dflts_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_use_schedd_enrt_dflts_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('PAY','HR_LOOKUP_DOES_NOT_EXIST');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_use_schedd_enrt_dflts_flag;
--
*/
--
-- ----------------------------------------------------------------------------
-- |------< chk_new_crnt_enrl_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_oipl_enrt_id PK of record being inserted or updated.
--   new_crnt_enrl_cd Value of lookup code.
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
/*
Procedure chk_new_crnt_enrl_cd(p_ler_chg_oipl_enrt_id                in number,
                            p_new_crnt_enrl_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_new_crnt_enrl_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lop_shd.api_updating
    (p_ler_chg_oipl_enrt_id                => p_ler_chg_oipl_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_new_crnt_enrl_cd
      <> nvl(ben_lop_shd.g_old_rec.new_crnt_enrl_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_NEW_CRNT_ENRT',
           p_lookup_code    => p_new_crnt_enrl_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('PAY','HR_LOOKUP_DOES_NOT_EXIST');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_new_crnt_enrl_cd;
*/
--
-- ----------------------------------------------------------------------------
-- |------< chk_crnt_enrt_prclds_chg_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_oipl_enrt_id PK of record being inserted or updated.
--   crnt_enrt_prclds_chg_flag Value of lookup code.
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
Procedure chk_crnt_enrt_prclds_chg_flag(p_ler_chg_oipl_enrt_id                in number,
                            p_crnt_enrt_prclds_chg_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_crnt_enrt_prclds_chg_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lop_shd.api_updating
    (p_ler_chg_oipl_enrt_id                => p_ler_chg_oipl_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_crnt_enrt_prclds_chg_flag
      <> nvl(ben_lop_shd.g_old_rec.crnt_enrt_prclds_chg_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_crnt_enrt_prclds_chg_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_crnt_enrt_prclds_chg_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('PAY','HR_LOOKUP_DOES_NOT_EXIST');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_crnt_enrt_prclds_chg_flag;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_update_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   parent entities when a datetrack update operation is taking place
--   and where there is no cascading of update defined for this entity.
--
-- Prerequisites:
--   This procedure is called from the update_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_validate
            (p_ler_id                        in number default hr_api.g_number,
             p_oipl_id                       in number default hr_api.g_number,
	     p_datetrack_mode		     in varchar2,
             p_validation_start_date	     in date,
	     p_validation_end_date	     in date) Is
--
  l_proc	    varchar2(72) := g_package||'dt_update_validate';
  l_integrity_error Exception;
  l_table_name	    all_tables.table_name%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'datetrack_mode',
     p_argument_value => p_datetrack_mode);
  --
  -- Only perform the validation if the datetrack update mode is valid
  --
  If (dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode)) then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_start_date',
       p_argument_value => p_validation_start_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_end_date',
       p_argument_value => p_validation_end_date);
    --
    If ((nvl(p_ler_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_ler_f',
             p_base_key_column => 'ler_id',
             p_base_key_value  => p_ler_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_ler_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_oipl_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_oipl_f',
             p_base_key_column => 'oipl_id',
             p_base_key_value  => p_oipl_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_oipl_f';
      Raise l_integrity_error;
    End If;
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When l_integrity_error Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    ben_utility.parent_integrity_error(p_table_name => l_table_name);
    --
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
End dt_update_validate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_delete_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   child entities when either a datetrack DELETE or ZAP is in operation
--   and where there is no cascading of delete defined for this entity.
--   For the datetrack mode of DELETE or ZAP we must ensure that no
--   datetracked child rows exist between the validation start and end
--   dates.
--
-- Prerequisites:
--   This procedure is called from the delete_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a row exists by determining the returning Boolean value from the
--   generic dt_api.rows_exist function then we must supply an error via
--   the use of the local exception handler l_rows_exist.
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_validate
            (p_ler_chg_oipl_enrt_id		in number,
             p_datetrack_mode		in varchar2,
	     p_validation_start_date	in date,
	     p_validation_end_date	in date) Is
--
  l_proc	varchar2(72) 	:= g_package||'dt_delete_validate';
  l_rows_exist	Exception;
  l_table_name	all_tables.table_name%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'datetrack_mode',
     p_argument_value => p_datetrack_mode);
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = 'DELETE' or
      p_datetrack_mode = 'ZAP') then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_start_date',
       p_argument_value => p_validation_start_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_end_date',
       p_argument_value => p_validation_end_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'ler_chg_oipl_enrt_id',
       p_argument_value => p_ler_chg_oipl_enrt_id);
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_ler_chg_oipl_enrt_rl_f',
           p_base_key_column => 'ler_chg_oipl_enrt_id',
           p_base_key_value  => p_ler_chg_oipl_enrt_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_ler_chg_oipl_enrt_rl_f';
      Raise l_rows_exist;
    End If;
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When l_rows_exist Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    ben_utility.child_exists_error(p_table_name => l_table_name);
    --
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
	(p_rec 			 in ben_lop_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_ler_chg_oipl_enrt_id
  (p_ler_chg_oipl_enrt_id          => p_rec.ler_chg_oipl_enrt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_auto_enrt_flag
  (p_ler_chg_oipl_enrt_id  => p_rec.ler_chg_oipl_enrt_id,
   p_auto_enrt_flag        => p_rec.auto_enrt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_stl_elig_cant_chg_flag
  (p_ler_chg_oipl_enrt_id          => p_rec.ler_chg_oipl_enrt_id,
   p_stl_elig_cant_chg_flag         => p_rec.stl_elig_cant_chg_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_flag
  (p_ler_chg_oipl_enrt_id          => p_rec.ler_chg_oipl_enrt_id,
   p_dflt_flag         => p_rec.dflt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --

  chk_dflt_enrt_cd
  (p_ler_chg_oipl_enrt_id          => p_rec.ler_chg_oipl_enrt_id,
   p_dflt_enrt_cd         => p_rec.dflt_enrt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_enrt_rl
  (p_ler_chg_oipl_enrt_id          => p_rec.ler_chg_oipl_enrt_id,
   p_dflt_enrt_rl                  => p_rec.dflt_enrt_rl,
   p_effective_date                => p_effective_date,
   p_object_version_number         => p_rec.object_version_number,
   p_business_group_id             => p_rec.business_group_id);
  --
  chk_enrt_cd
  (p_ler_chg_oipl_enrt_id          => p_rec.ler_chg_oipl_enrt_id,
   p_enrt_cd         => p_rec.enrt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_rl
  (p_ler_chg_oipl_enrt_id          => p_rec.ler_chg_oipl_enrt_id,
   p_enrt_rl                       => p_rec.enrt_rl,
   p_effective_date                => p_effective_date,
   p_object_version_number         => p_rec.object_version_number,
   p_business_group_id             => p_rec.business_group_id);
  --
  chk_auto_enrt_mthd_rl
  (p_ler_chg_oipl_enrt_id          => p_rec.ler_chg_oipl_enrt_id,
   p_auto_enrt_mthd_rl             => p_rec.auto_enrt_mthd_rl,
   p_effective_date                => p_effective_date,
   p_object_version_number         => p_rec.object_version_number,
   p_business_group_id             => p_rec.business_group_id);
/*
  --
  chk_use_schedd_enrt_dfns_flag
  (p_ler_chg_oipl_enrt_id          => p_rec.ler_chg_oipl_enrt_id,
   p_use_schedd_enrt_dfns_flag         => p_rec.use_schedd_enrt_dfns_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_use_schedd_enrt_dflts_flag
  (p_ler_chg_oipl_enrt_id          => p_rec.ler_chg_oipl_enrt_id,
   p_use_schedd_enrt_dflts_flag         => p_rec.use_schedd_enrt_dflts_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_new_crnt_enrl_cd
  (p_ler_chg_oipl_enrt_id          => p_rec.ler_chg_oipl_enrt_id,
   p_new_crnt_enrl_cd         => p_rec.new_crnt_enrl_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
*/
  --
  chk_crnt_enrt_prclds_chg_flag
  (p_ler_chg_oipl_enrt_id          => p_rec.ler_chg_oipl_enrt_id,
   p_crnt_enrt_prclds_chg_flag         => p_rec.crnt_enrt_prclds_chg_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_lop_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_ler_chg_oipl_enrt_id
  (p_ler_chg_oipl_enrt_id          => p_rec.ler_chg_oipl_enrt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_auto_enrt_flag
  (p_ler_chg_oipl_enrt_id          => p_rec.ler_chg_oipl_enrt_id,
   p_auto_enrt_flag        => p_rec.auto_enrt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_stl_elig_cant_chg_flag
  (p_ler_chg_oipl_enrt_id          => p_rec.ler_chg_oipl_enrt_id,
   p_stl_elig_cant_chg_flag         => p_rec.stl_elig_cant_chg_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_flag
  (p_ler_chg_oipl_enrt_id          => p_rec.ler_chg_oipl_enrt_id,
   p_dflt_flag         => p_rec.dflt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_enrt_cd
  (p_ler_chg_oipl_enrt_id          => p_rec.ler_chg_oipl_enrt_id,
   p_dflt_enrt_cd         => p_rec.dflt_enrt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_enrt_rl
  (p_ler_chg_oipl_enrt_id          => p_rec.ler_chg_oipl_enrt_id,
   p_dflt_enrt_rl                  => p_rec.dflt_enrt_rl,
   p_effective_date                => p_effective_date,
   p_object_version_number         => p_rec.object_version_number,
   p_business_group_id             => p_rec.business_group_id);
  --
  chk_enrt_cd
  (p_ler_chg_oipl_enrt_id          => p_rec.ler_chg_oipl_enrt_id,
   p_enrt_cd         => p_rec.enrt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_rl
  (p_ler_chg_oipl_enrt_id          => p_rec.ler_chg_oipl_enrt_id,
   p_enrt_rl                       => p_rec.enrt_rl,
   p_effective_date                => p_effective_date,
   p_object_version_number         => p_rec.object_version_number,
   p_business_group_id             => p_rec.business_group_id);
  --
  chk_auto_enrt_mthd_rl
  (p_ler_chg_oipl_enrt_id          => p_rec.ler_chg_oipl_enrt_id,
   p_auto_enrt_mthd_rl             => p_rec.auto_enrt_mthd_rl,
   p_effective_date                => p_effective_date,
   p_object_version_number         => p_rec.object_version_number,
   p_business_group_id             => p_rec.business_group_id);
/*
  --
  chk_use_schedd_enrt_dfns_flag
  (p_ler_chg_oipl_enrt_id          => p_rec.ler_chg_oipl_enrt_id,
   p_use_schedd_enrt_dfns_flag         => p_rec.use_schedd_enrt_dfns_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_use_schedd_enrt_dflts_flag
  (p_ler_chg_oipl_enrt_id          => p_rec.ler_chg_oipl_enrt_id,
   p_use_schedd_enrt_dflts_flag         => p_rec.use_schedd_enrt_dflts_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_new_crnt_enrl_cd
  (p_ler_chg_oipl_enrt_id          => p_rec.ler_chg_oipl_enrt_id,
   p_new_crnt_enrl_cd         => p_rec.new_crnt_enrl_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
*/
  --
  chk_crnt_enrt_prclds_chg_flag
  (p_ler_chg_oipl_enrt_id          => p_rec.ler_chg_oipl_enrt_id,
   p_crnt_enrt_prclds_chg_flag         => p_rec.crnt_enrt_prclds_chg_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_ler_id                        => p_rec.ler_id,
             p_oipl_id                       => p_rec.oipl_id,
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date	     => p_validation_start_date,
     p_validation_end_date	     => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
	(p_rec 			 in ben_lop_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode		=> p_datetrack_mode,
     p_validation_start_date	=> p_validation_start_date,
     p_validation_end_date	=> p_validation_end_date,
     p_ler_chg_oipl_enrt_id		=> p_rec.ler_chg_oipl_enrt_id);
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
  (p_ler_chg_oipl_enrt_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_ler_chg_oipl_enrt_f b
    where b.ler_chg_oipl_enrt_id      = p_ler_chg_oipl_enrt_id
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
                             p_argument       => 'ler_chg_oipl_enrt_id',
                             p_argument_value => p_ler_chg_oipl_enrt_id);
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
end ben_lop_bus;

/
