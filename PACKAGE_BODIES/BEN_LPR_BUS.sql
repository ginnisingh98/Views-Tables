--------------------------------------------------------
--  DDL for Package Body BEN_LPR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LPR_BUS" as
/* $Header: belprrhi.pkb 115.11 2004/01/18 23:15:35 abparekh ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_lpr_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_ler_chg_plip_enrt_id >------|
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
--   ler_chg_plip_enrt_id PK of record being inserted or updated.
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
Procedure chk_ler_chg_plip_enrt_id(p_ler_chg_plip_enrt_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ler_chg_plip_enrt_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lpr_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_ler_chg_plip_enrt_id                => p_ler_chg_plip_enrt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ler_chg_plip_enrt_id,hr_api.g_number)
     <>  ben_lpr_shd.g_old_rec.ler_chg_plip_enrt_id) then
    --
    -- raise error as PK has changed
    --
    ben_lpr_shd.constraint_error('BEN_LER_CHG_PLIP_EN_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_ler_chg_plip_enrt_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_lpr_shd.constraint_error('BEN_LER_CHG_PLIP_EN_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ler_chg_plip_enrt_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_ler_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to ensure that the value is unique within plip
--   and within bus grp. The FK check is done elsewhere in the dt logic.
--
-- Pre Conditions
--   None.
--
-- In Parameters
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
Procedure chk_ler_id(p_ler_chg_plip_enrt_id    in number,
                            p_ler_id            in number,
                            p_plip_id              in number,
                            p_effective_date              in date,
				    p_validation_start_date         in date,
                            p_validation_end_date           in date,
                            p_business_group_id           in number,
                            p_object_version_number       in number) is


 --
  l_proc         varchar2(72) := g_package||'chk_ler_id';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  -- unique in bg, plip, and eff dates
  --
  cursor chk_unique is
     select null
        from ben_ler_chg_plip_enrt_f
        where ler_id = p_ler_id
          and ler_chg_plip_enrt_id  <> nvl(p_ler_chg_plip_enrt_id, hr_api.g_number)
          and plip_id = p_plip_id
          and business_group_id + 0 = p_business_group_id
          and p_validation_start_date <= effective_end_date
          and p_validation_end_date >= effective_start_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lpr_shd.api_updating
    (p_ler_chg_plip_enrt_id   => p_ler_chg_plip_enrt_id  ,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_ler_id
      <> nvl(ben_lpr_shd.g_old_rec.ler_id,hr_api.g_number)
      or not l_api_updating) then
    --
    -- this value must be unique
    --
    open chk_unique;
    fetch chk_unique into l_exists;
    if chk_unique%found then
      close chk_unique;
      --
      -- raise error as UK1 is violated
      --
      --Bug 2960193 Created message and updated message name in call to set_name
      fnd_message.set_name('BEN','BEN_93794_FUTURE_LE_PLAN_EXIST');
      fnd_message.raise_error;
      --Bug 2960193
      --
    end if;
    --
    close chk_unique;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_ler_id;
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
--   ler_chg_plip_enrt_id PK of record being inserted or updated.
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
Procedure chk_enrt_cd(p_ler_chg_plip_enrt_id                in number,
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
  l_api_updating := ben_lpr_shd.api_updating
    (p_ler_chg_plip_enrt_id                => p_ler_chg_plip_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_cd
      <> nvl(ben_lpr_shd.g_old_rec.enrt_cd,hr_api.g_varchar2)
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
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_enrt_cd');
      fnd_message.set_token('TYPE', 'BEN_ENRT');
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
--   ler_chg_plip_enrt_id PK of record being inserted or updated.
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
Procedure chk_stl_elig_cant_chg_flag(p_ler_chg_plip_enrt_id                in number,
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
  l_api_updating := ben_lpr_shd.api_updating
    (p_ler_chg_plip_enrt_id        => p_ler_chg_plip_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_stl_elig_cant_chg_flag
      <> nvl(ben_lpr_shd.g_old_rec.stl_elig_cant_chg_flag,hr_api.g_varchar2)
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
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_stl_elig_cant_chg_flag');
      fnd_message.set_token('TYPE', 'YES_NO');
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
-- |------< chk_enrt_mthd_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_plip_enrt_id PK of record being inserted or updated.
--   enrt_mthd_cd Value of lookup code.
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
Procedure chk_enrt_mthd_cd(p_ler_chg_plip_enrt_id                in number,
                            p_enrt_mthd_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_mthd_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lpr_shd.api_updating
    (p_ler_chg_plip_enrt_id                => p_ler_chg_plip_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_mthd_cd
      <> nvl(ben_lpr_shd.g_old_rec.enrt_mthd_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_enrt_mthd_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ENRT_MTHD',
           p_lookup_code    => p_enrt_mthd_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_enrt_mthd_cd');
      fnd_message.set_token('TYPE', 'BEN_ENRT_MTHD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enrt_mthd_cd;
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
--   ler_chg_plip_enrt_id PK of record being inserted or updated.
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
Procedure chk_dflt_enrt_cd(p_ler_chg_plip_enrt_id                in number,
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
  l_api_updating := ben_lpr_shd.api_updating
    (p_ler_chg_plip_enrt_id                => p_ler_chg_plip_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dflt_enrt_cd
      <> nvl(ben_lpr_shd.g_old_rec.dflt_enrt_cd,hr_api.g_varchar2)
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
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_dflt_enrt_cd');
      fnd_message.set_token('TYPE', 'BEN_DFLT_ENRT');
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
-- |------< chk_enrt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_plip_enrt_id PK of record being inserted or updated.
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
Procedure chk_enrt_rl(p_ler_chg_plip_enrt_id              in number,
                            p_enrt_rl                     in number,
                            p_effective_date              in date,
                            p_business_group_id           in number,
                            p_object_version_number       in number) is
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
  l_api_updating := ben_lpr_shd.api_updating
    (p_ler_chg_plip_enrt_id        => p_ler_chg_plip_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_rl
      <> nvl(ben_lpr_shd.g_old_rec.enrt_rl,hr_api.g_number)
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
-- |------< chk_dflt_enrt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_plip_enrt_id PK of record being inserted or updated.
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
Procedure chk_dflt_enrt_rl(p_ler_chg_plip_enrt_id         in number,
                            p_dflt_enrt_rl                in number,
                            p_effective_date              in date,
                            p_business_group_id           in number,
                            p_object_version_number       in number) is
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
  l_api_updating := ben_lpr_shd.api_updating
    (p_ler_chg_plip_enrt_id        => p_ler_chg_plip_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dflt_enrt_rl
      <> nvl(ben_lpr_shd.g_old_rec.dflt_enrt_rl,hr_api.g_number)
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
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dflt_enrt_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dflt_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid and only
--   one record can have a 'Y' value.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_plip_enrt_id PK of record being inserted or updated.
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
Procedure chk_dflt_flag(p_ler_chg_plip_enrt_id                in number,
                            p_dflt_flag               in varchar2,
                            p_effective_date              in date,
                            p_plip_id               in number,
				    p_validation_start_date         in date,
                            p_validation_end_date           in date,
                            p_business_group_id           in number,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dflt_flag';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  -- only one 'YES' value is allowed within parent, bg, and eff dates
  --
  cursor chk_unique is
     select null
        from ben_ler_chg_plip_enrt_f
        where dflt_flag = p_dflt_flag
          and dflt_flag = 'Y'
          and ler_chg_plip_enrt_id  <> nvl(p_ler_chg_plip_enrt_id, hr_api.g_number)
          and plip_id = p_plip_id
          and business_group_id + 0 = p_business_group_id
          and p_validation_start_date <= effective_end_date
          and p_validation_end_date >= effective_start_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lpr_shd.api_updating
    (p_ler_chg_plip_enrt_id        => p_ler_chg_plip_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dflt_flag
      <> nvl(ben_lpr_shd.g_old_rec.dflt_flag,hr_api.g_varchar2)
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
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_dflt_flag');
      fnd_message.set_token('TYPE', 'YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
-- COMMENTING OUT PER BUG# 849
--  -- Only one 'Y' value is allowed within parent
--  --
--  open chk_unique;
--  fetch chk_unique into l_exists;
--  if chk_unique%found then
--    close chk_unique;
--    --
--    -- raise error as UK1 is violated
--    --
--    fnd_message.set_name('PAY','ONLY_ONE_DEFAULT');
--    fnd_message.raise_error;
--    --
--  end if;
--  --
--  close chk_unique;
----

  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dflt_flag;
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
--   ler_chg_plip_enrt_id PK of record being inserted or updated.
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
Procedure chk_crnt_enrt_prclds_chg_flag(p_ler_chg_plip_enrt_id                in number,
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
  l_api_updating := ben_lpr_shd.api_updating
    (p_ler_chg_plip_enrt_id        => p_ler_chg_plip_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_crnt_enrt_prclds_chg_flag
      <> nvl(ben_lpr_shd.g_old_rec.crnt_enrt_prclds_chg_flag,hr_api.g_varchar2)
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
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_crnt_enrt_prclds_chg_flag');
      fnd_message.set_token('TYPE', 'YES_NO');
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
-- |------< chk_tco_chg_enrt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_plip_enrt_id PK of record being inserted or updated.
--   tco_chg_enrt_cd Value of lookup code.
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
Procedure chk_tco_chg_enrt_cd(p_ler_chg_plip_enrt_id                in number,
                            p_tco_chg_enrt_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_tco_chg_enrt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lpr_shd.api_updating
    (p_ler_chg_plip_enrt_id        => p_ler_chg_plip_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_tco_chg_enrt_cd
      <> nvl(ben_lpr_shd.g_old_rec.tco_chg_enrt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_tco_chg_enrt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_TCO_CHG_ENRT',
           p_lookup_code    => p_tco_chg_enrt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_tco_chg_enrt_cd');
      fnd_message.set_token('TYPE', 'BEN_TCO_CHG_ENRT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_tco_chg_enrt_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_auto_enrt_mthd_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_plip_enrt_id PK of record being inserted or updated.
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
Procedure chk_auto_enrt_mthd_rl(p_ler_chg_plip_enrt_id                in number,
                            p_auto_enrt_mthd_rl           in number,
                            p_effective_date              in date,
                            p_business_group_id           in number,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_auto_enrt_mthd_rl';
  l_api_updating boolean;
  l_dummy varchar2(30);
  --
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
  l_api_updating := ben_lpr_shd.api_updating
    (p_ler_chg_plip_enrt_id        => p_ler_chg_plip_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_auto_enrt_mthd_rl,hr_api.g_number)
      <> nvl(ben_lpr_shd.g_old_rec.auto_enrt_mthd_rl,hr_api.g_number)
      or not l_api_updating) and p_auto_enrt_mthd_rl is not null then
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
            (p_plip_id                       in number default hr_api.g_number,
             p_ler_id                        in number default hr_api.g_number,
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
    If ((nvl(p_plip_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_plip_f',
             p_base_key_column => 'plip_id',
             p_base_key_value  => p_plip_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_plip_f';
      Raise l_integrity_error;
    End If;
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
            (p_ler_chg_plip_enrt_id		in number,
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
       p_argument       => 'ler_chg_plip_enrt_id',
       p_argument_value => p_ler_chg_plip_enrt_id);
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_ler_chg_plip_enrt_rl_f',
           p_base_key_column => 'ler_chg_plip_enrt_id',
           p_base_key_value  => p_ler_chg_plip_enrt_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_ler_chg_plip_enrt_rl_f';
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
	(p_rec 			 in ben_lpr_shd.g_rec_type,
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
  chk_ler_chg_plip_enrt_id
  (p_ler_chg_plip_enrt_id          => p_rec.ler_chg_plip_enrt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
 --
  chk_ler_id
  (p_ler_chg_plip_enrt_id          => p_rec.ler_chg_plip_enrt_id,
   p_ler_id              => p_rec.ler_id,
   p_plip_id              => p_rec.plip_id,
   p_effective_date        => p_effective_date,
   p_validation_start_date  =>    p_validation_start_date,
   p_validation_end_date      =>  p_validation_end_date,
   p_business_group_id        =>  p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
   --
  chk_enrt_cd
  (p_ler_chg_plip_enrt_id          => p_rec.ler_chg_plip_enrt_id,
   p_enrt_cd         => p_rec.enrt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_stl_elig_cant_chg_flag
  (p_ler_chg_plip_enrt_id          => p_rec.ler_chg_plip_enrt_id,
   p_stl_elig_cant_chg_flag         => p_rec.stl_elig_cant_chg_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_mthd_cd
  (p_ler_chg_plip_enrt_id          => p_rec.ler_chg_plip_enrt_id,
   p_enrt_mthd_cd         => p_rec.enrt_mthd_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_enrt_cd
  (p_ler_chg_plip_enrt_id          => p_rec.ler_chg_plip_enrt_id,
   p_dflt_enrt_cd         => p_rec.dflt_enrt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_rl
  (p_ler_chg_plip_enrt_id          => p_rec.ler_chg_plip_enrt_id,
   p_enrt_rl               => p_rec.enrt_rl,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_enrt_rl
  (p_ler_chg_plip_enrt_id          => p_rec.ler_chg_plip_enrt_id,
   p_dflt_enrt_rl         => p_rec.dflt_enrt_rl,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_flag
  (p_ler_chg_plip_enrt_id          => p_rec.ler_chg_plip_enrt_id,
   p_dflt_flag         => p_rec.dflt_flag,
   p_plip_id              => p_rec.plip_id,
   p_effective_date        => p_effective_date,
   p_validation_start_date  =>    p_validation_start_date,
   p_validation_end_date      =>  p_validation_end_date,
   p_business_group_id        =>  p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_crnt_enrt_prclds_chg_flag
  (p_ler_chg_plip_enrt_id          => p_rec.ler_chg_plip_enrt_id,
   p_crnt_enrt_prclds_chg_flag         => p_rec.crnt_enrt_prclds_chg_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_tco_chg_enrt_cd
  (p_ler_chg_plip_enrt_id          => p_rec.ler_chg_plip_enrt_id,
   p_tco_chg_enrt_cd         => p_rec.tco_chg_enrt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_auto_enrt_mthd_rl
  (p_ler_chg_plip_enrt_id          => p_rec.ler_chg_plip_enrt_id,
   p_auto_enrt_mthd_rl         => p_rec.auto_enrt_mthd_rl,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_lpr_shd.g_rec_type,
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
  chk_ler_chg_plip_enrt_id
  (p_ler_chg_plip_enrt_id          => p_rec.ler_chg_plip_enrt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
 --
  chk_ler_id
  (p_ler_chg_plip_enrt_id          => p_rec.ler_chg_plip_enrt_id,
   p_ler_id              => p_rec.ler_id,
   p_plip_id              => p_rec.plip_id,
   p_effective_date        => p_effective_date,
   p_validation_start_date  =>    p_validation_start_date,
   p_validation_end_date      =>  p_validation_end_date,
   p_business_group_id        =>  p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cd
  (p_ler_chg_plip_enrt_id          => p_rec.ler_chg_plip_enrt_id,
   p_enrt_cd         => p_rec.enrt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_stl_elig_cant_chg_flag
  (p_ler_chg_plip_enrt_id          => p_rec.ler_chg_plip_enrt_id,
   p_stl_elig_cant_chg_flag         => p_rec.stl_elig_cant_chg_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_mthd_cd
  (p_ler_chg_plip_enrt_id          => p_rec.ler_chg_plip_enrt_id,
   p_enrt_mthd_cd         => p_rec.enrt_mthd_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_enrt_cd
  (p_ler_chg_plip_enrt_id          => p_rec.ler_chg_plip_enrt_id,
   p_dflt_enrt_cd         => p_rec.dflt_enrt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_rl
  (p_ler_chg_plip_enrt_id          => p_rec.ler_chg_plip_enrt_id,
   p_enrt_rl               => p_rec.enrt_rl,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_enrt_rl
  (p_ler_chg_plip_enrt_id          => p_rec.ler_chg_plip_enrt_id,
   p_dflt_enrt_rl          => p_rec.dflt_enrt_rl,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_flag
  (p_ler_chg_plip_enrt_id          => p_rec.ler_chg_plip_enrt_id,
   p_dflt_flag         => p_rec.dflt_flag,
   p_plip_id              => p_rec.plip_id,
   p_effective_date        => p_effective_date,
   p_validation_start_date  =>    p_validation_start_date,
   p_validation_end_date      =>  p_validation_end_date,
   p_business_group_id        =>  p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_crnt_enrt_prclds_chg_flag
  (p_ler_chg_plip_enrt_id          => p_rec.ler_chg_plip_enrt_id,
   p_crnt_enrt_prclds_chg_flag         => p_rec.crnt_enrt_prclds_chg_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_tco_chg_enrt_cd
  (p_ler_chg_plip_enrt_id          => p_rec.ler_chg_plip_enrt_id,
   p_tco_chg_enrt_cd         => p_rec.tco_chg_enrt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_auto_enrt_mthd_rl
  (p_ler_chg_plip_enrt_id          => p_rec.ler_chg_plip_enrt_id,
   p_auto_enrt_mthd_rl         => p_rec.auto_enrt_mthd_rl,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_plip_id                       => p_rec.plip_id,
             p_ler_id                        => p_rec.ler_id,
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
	(p_rec 			 in ben_lpr_shd.g_rec_type,
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
     p_ler_chg_plip_enrt_id		=> p_rec.ler_chg_plip_enrt_id);
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
  (p_ler_chg_plip_enrt_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_ler_chg_plip_enrt_f b
    where b.ler_chg_plip_enrt_id      = p_ler_chg_plip_enrt_id
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
                             p_argument       => 'ler_chg_plip_enrt_id',
                             p_argument_value => p_ler_chg_plip_enrt_id);
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
end ben_lpr_bus;

/