--------------------------------------------------------
--  DDL for Package Body BEN_LDC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LDC_BUS" as
/* $Header: beldcrhi.pkb 120.0.12010000.2 2008/08/05 14:28:29 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ldc_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_ler_chg_dpnt_cvg_id >------|
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
--   ler_chg_dpnt_cvg_id PK of record being inserted or updated.
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
Procedure chk_ler_chg_dpnt_cvg_id(p_ler_chg_dpnt_cvg_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ler_chg_dpnt_cvg_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ldc_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_ler_chg_dpnt_cvg_id                => p_ler_chg_dpnt_cvg_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ler_chg_dpnt_cvg_id,hr_api.g_number)
     <>  ben_ldc_shd.g_old_rec.ler_chg_dpnt_cvg_id) then
    --
    -- raise error as PK has changed
    --
    ben_ldc_shd.constraint_error('BEN_LER_CHG_DPNT_CVG_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_ler_chg_dpnt_cvg_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_ldc_shd.constraint_error('BEN_LER_CHG_DPNT_CVG_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ler_chg_dpnt_cvg_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_ler_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to ensure that the value is unique within parent
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
Procedure chk_ler_id(p_ler_chg_dpnt_cvg_id    in number,
                            p_ler_id            in number,
                            p_pgm_id            in number,
                            p_ptip_id              in number,
                            p_pl_id                in number,
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
  -- unique in bg, parent, and eff dates
  --
  cursor chk_unique is
     select null
        from ben_ler_chg_dpnt_cvg_f
        where ler_id = p_ler_id
          and ler_chg_dpnt_cvg_id  <> nvl(p_ler_chg_dpnt_cvg_id, hr_api.g_number)
          and (ptip_id = p_ptip_id or pgm_id = p_pgm_id or pl_id = p_pl_id)
          and business_group_id + 0 = p_business_group_id
          and p_validation_start_date <= effective_end_date
          and p_validation_end_date >= effective_start_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ldc_shd.api_updating
    (p_ler_chg_dpnt_cvg_id   => p_ler_chg_dpnt_cvg_id  ,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_ler_id
      <> nvl(ben_ldc_shd.g_old_rec.ler_id,hr_api.g_number)
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
      fnd_message.set_name('PAY','VALUE IS NOT UNIQUE');
      fnd_message.raise_error;
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
-- |------< chk_cvg_eff_end_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_dpnt_cvg_id PK of record being inserted or updated.
--   cvg_eff_end_rl Value of formula rule id.
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
Procedure chk_cvg_eff_end_rl(p_ler_chg_dpnt_cvg_id                in number,
                             p_cvg_eff_end_rl              in number,
                             p_effective_date              in date,
                             p_business_group_id           in number,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cvg_eff_end_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_cvg_eff_end_rl
    and    ff.formula_type_id = -28 --Dependent Coverage End
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
  l_api_updating := ben_ldc_shd.api_updating
    (p_ler_chg_dpnt_cvg_id                => p_ler_chg_dpnt_cvg_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_cvg_eff_end_rl,hr_api.g_number)
      <> ben_ldc_shd.g_old_rec.cvg_eff_end_rl
      or not l_api_updating)
      and p_cvg_eff_end_rl is not null then
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
        fnd_message.set_name('PAY','FORMULA_DOES_NOT_EXIST');
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
end chk_cvg_eff_end_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_cvg_eff_strt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_dpnt_cvg_id PK of record being inserted or updated.
--   cvg_eff_strt_rl Value of formula rule id.
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
Procedure chk_cvg_eff_strt_rl(p_ler_chg_dpnt_cvg_id                in number,
                             p_cvg_eff_strt_rl              in number,
                             p_effective_date              in date,
                             p_business_group_id           in number,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cvg_eff_strt_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_cvg_eff_strt_rl
    and    ff.formula_type_id = -27 --Dependent Coverage Start
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
  l_api_updating := ben_ldc_shd.api_updating
    (p_ler_chg_dpnt_cvg_id                => p_ler_chg_dpnt_cvg_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_cvg_eff_strt_rl,hr_api.g_number)
      <> ben_ldc_shd.g_old_rec.cvg_eff_strt_rl
      or not l_api_updating)
      and p_cvg_eff_strt_rl is not null then
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
        fnd_message.set_name('PAY','FORMULA_DOES_NOT_EXIST');
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
end chk_cvg_eff_strt_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_ler_chg_dpnt_cvg_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_dpnt_cvg_id PK of record being inserted or updated.
--   ler_chg_dpnt_cvg_rl Value of formula rule id.
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
Procedure chk_ler_chg_dpnt_cvg_rl(p_ler_chg_dpnt_cvg_id                in number,
                             p_ler_chg_dpnt_cvg_rl              in number,
                             p_effective_date              in date,
                             p_business_group_id           in number,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ler_chg_dpnt_cvg_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_ler_chg_dpnt_cvg_rl
    and    ff.formula_type_id = -36  --Change Dependent Coverage
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
  l_api_updating := ben_ldc_shd.api_updating
    (p_ler_chg_dpnt_cvg_id                => p_ler_chg_dpnt_cvg_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_ler_chg_dpnt_cvg_rl,hr_api.g_number)
      <> ben_ldc_shd.g_old_rec.ler_chg_dpnt_cvg_rl
      or not l_api_updating)
      and p_ler_chg_dpnt_cvg_rl is not null then
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
        fnd_message.set_name('PAY','FORMULA_DOES_NOT_EXIST');
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
end chk_ler_chg_dpnt_cvg_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_cvg_eff_strt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_dpnt_cvg_id PK of record being inserted or updated.
--   cvg_eff_strt_cd Value of lookup code.
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
Procedure chk_cvg_eff_strt_cd(p_ler_chg_dpnt_cvg_id                in number,
                            p_cvg_eff_strt_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cvg_eff_strt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ldc_shd.api_updating
    (p_ler_chg_dpnt_cvg_id                => p_ler_chg_dpnt_cvg_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_cvg_eff_strt_cd
      <> nvl(ben_ldc_shd.g_old_rec.cvg_eff_strt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_cvg_eff_strt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_DPNT_CVG_STRT',
           p_lookup_code    => p_cvg_eff_strt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_cvg_eff_strt_cd');
      fnd_message.set_token('TYPE','BEN_DPNT_CVG_STRT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_cvg_eff_strt_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_cvg_eff_end_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_dpnt_cvg_id PK of record being inserted or updated.
--   cvg_eff_end_cd Value of lookup code.
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
Procedure chk_cvg_eff_end_cd(p_ler_chg_dpnt_cvg_id                in number,
                            p_cvg_eff_end_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cvg_eff_end_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ldc_shd.api_updating
    (p_ler_chg_dpnt_cvg_id                => p_ler_chg_dpnt_cvg_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_cvg_eff_end_cd
      <> nvl(ben_ldc_shd.g_old_rec.cvg_eff_end_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_cvg_eff_end_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_DPNT_CVG_END',
           p_lookup_code    => p_cvg_eff_end_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_cvg_eff_end_cd');
      fnd_message.set_token('TYPE','BEN_DPNT_CVG_END');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_cvg_eff_end_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_add_rmv_cvg_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_dpnt_cvg_id PK of record being inserted or updated.
--   add_rmv_cvg_cd Value of lookup code.
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
Procedure chk_add_rmv_cvg_cd(p_ler_chg_dpnt_cvg_id                in number,
                            p_add_rmv_cvg_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_add_rmv_cvg_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ldc_shd.api_updating
    (p_ler_chg_dpnt_cvg_id                => p_ler_chg_dpnt_cvg_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_add_rmv_cvg_cd
      <> nvl(ben_ldc_shd.g_old_rec.add_rmv_cvg_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ADD_RMV',
           p_lookup_code    => p_add_rmv_cvg_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_add_rmv_cvg_cd');
      fnd_message.set_token('TYPE','BEN_ADD_RMV');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_add_rmv_cvg_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_dsgn_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the dpnt_dsgn_cd on ben_pgm_f has a
--   value of 'O' 'R'.  If not, signal error, and disallow the insert/update.
--
-- Pre Conditions
--   None.
--
-- In Parameters
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
Procedure chk_dpnt_dsgn_cd(p_ler_chg_dpnt_cvg_id          in number,
                            p_pgm_id                        in varchar2,
                            p_ptip_id                       in number,
                            p_pl_id                         in number,
                            p_effective_date                in date,
				    p_validation_start_date         in date,
                            p_validation_end_date           in date,
                            p_business_group_id             in number,
                            p_object_version_number         in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_dsgn_cd';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  -- ben_pgm_f.dpnt_dsgn_cd must = 'R' or 'O' in order to insert/update.
  --
  cursor chk_dpnt_dsgn is
     select null
        from ben_pgm_f
        where pgm_id = p_pgm_id
          and dpnt_dsgn_cd in ('R','O')
          and business_group_id + 0 = p_business_group_id
          and p_effective_date
              between effective_start_date and
                      effective_end_date;
--          and p_validation_start_date <= effective_end_date
--          and p_validation_end_date >= effective_start_date;
   --
   -- Note:  currently documents say to only check pgm, but pl and ptip also
   -- have a dpnt_dsgn_cd, so we may need to add 2 more cursors here in the
   -- future.
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_pgm_id is not null then
    --
    open chk_dpnt_dsgn;
    fetch chk_dpnt_dsgn into l_exists;
    if chk_dpnt_dsgn%notfound then
      close chk_dpnt_dsgn;
      --
      -- raise error
      --
      fnd_message.set_name('PAY','PGM_DPNT_DSGN_NOT_O_R');
      fnd_message.raise_error;
      --
    end if;
    --
    close chk_dpnt_dsgn;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_dsgn_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_ler_chg_dpnt_cvg_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--   If ler_chg_dpnt_cvg_cd is not null then cvg_eff_strt_cd and cvg_eff_end_cd
--   should also be not null.
--   If ler_chg_dpnt_cvg_cd is null then cvg_eff_strt_cd and cvg_eff_end_cd
--   should also be null.
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_dpnt_cvg_id PK of record being inserted or updated.
--   ler_chg_dpnt_cvg_cd Value of lookup code.
--   cvg_eff_strt_cd     Value of cvg_eff_strt_cd
--   cvg_eff_end_cd      Value of cvg_eff_end_cd
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
Procedure chk_ler_chg_dpnt_cvg_cd(p_ler_chg_dpnt_cvg_id   in number,
                            p_ler_chg_dpnt_cvg_cd         in varchar2,
                            p_cvg_eff_strt_cd             in varchar2,
                            p_cvg_eff_end_cd              in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ler_chg_dpnt_cvg_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ldc_shd.api_updating
    (p_ler_chg_dpnt_cvg_id                => p_ler_chg_dpnt_cvg_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_ler_chg_dpnt_cvg_cd
      <> nvl(ben_ldc_shd.g_old_rec.ler_chg_dpnt_cvg_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_ler_chg_dpnt_cvg_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_LER_CHG_DPNT_CVG',
           p_lookup_code    => p_ler_chg_dpnt_cvg_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_ler_chg_dpnt_cvg_cd');
      fnd_message.set_token('TYPE','BEN_LER_CHG_DPNT_CVG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  -- Commented per Bug 1403687 on 29-Sep-2000 by Indrasen
  /*
  if (p_ler_chg_dpnt_cvg_cd is not null) and
     (p_cvg_eff_strt_cd is null or p_cvg_eff_end_cd is null) then

    fnd_message.set_name('BEN','BEN_92513_DPNDNT_CVRG_DT_NULL');
    fnd_message.raise_error;
  end if;
  */
  --
  if (p_ler_chg_dpnt_cvg_cd is null) and
     (p_cvg_eff_strt_cd is not null or p_cvg_eff_end_cd is not null) then
     --null;
    fnd_message.set_name('BEN','BEN_92514_CHNG_DPNDNT_CVG_RQD');
    fnd_message.raise_error;
  end if;

  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_ler_chg_dpnt_cvg_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_cvg_eff_strt_dependency >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check the code/rule dependency as following:
--             If code = 'Rule' then rule must be selected.
--             If code <> 'Rule' then code must not be selected.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_dpnt_cvg_id PK of record being inserted or updated.
--   cvg_eff_strt_cd Value of lookup code.
--   cvg_eff_strt_rl
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
Procedure chk_cvg_eff_strt_dependency(p_ler_chg_dpnt_cvg_id       in number,
                            p_cvg_eff_strt_cd             in varchar2,
                            p_cvg_eff_strt_rl             in number,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cvg_eff_strt_dependency ';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ldc_shd.api_updating
    (p_ler_chg_dpnt_cvg_id         => p_ler_chg_dpnt_cvg_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and
         (nvl(p_cvg_eff_strt_cd,hr_api.g_varchar2)
               <> nvl(ben_ldc_shd.g_old_rec.cvg_eff_strt_cd,hr_api.g_varchar2) or
          nvl(p_cvg_eff_strt_rl,hr_api.g_number)
               <> nvl(ben_ldc_shd.g_old_rec.cvg_eff_strt_rl,hr_api.g_number))
      or not l_api_updating) then
    --
    if (p_cvg_eff_strt_cd = 'RL' and p_cvg_eff_strt_rl is null) then
             --
             fnd_message.set_name('BEN','BEN_91623_CD_RL_1');
             fnd_message.raise_error;
         -- please word this message like 'If you choose a Coverage Start Code of "Rule",
         -- you must choose a Coverage Start Rule.'
    end if;
    --
    if nvl(p_cvg_eff_strt_cd,hr_api.g_varchar2) <> 'RL' and p_cvg_eff_strt_rl is not null then
             --
             fnd_message.set_name('BEN','BEN_91624_CD_RL_2');
             fnd_message.raise_error;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_cvg_eff_strt_dependency;
--
-- ----------------------------------------------------------------------------
-- |------< chk_cvg_eff_end_dependency >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check the code/rule dependency as following:
--             If code = 'Rule' then rule must be selected.
--             If code <> 'Rule' then code must not be selected.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_dpnt_cvg_id PK of record being inserted or updated.
--   cvg_eff_end_cd Value of lookup code.
--   cvg_eff_end_rl
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
Procedure chk_cvg_eff_end_dependency(p_ler_chg_dpnt_cvg_id       in number,
                            p_cvg_eff_end_cd             in varchar2,
                            p_cvg_eff_end_rl             in number,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cvg_eff_end_dependency ';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ldc_shd.api_updating
    (p_ler_chg_dpnt_cvg_id         => p_ler_chg_dpnt_cvg_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and
         (nvl(p_cvg_eff_end_cd,hr_api.g_varchar2)
               <> nvl(ben_ldc_shd.g_old_rec.cvg_eff_end_cd,hr_api.g_varchar2) or
          nvl(p_cvg_eff_end_rl,hr_api.g_number)
               <> nvl(ben_ldc_shd.g_old_rec.cvg_eff_end_rl,hr_api.g_number))
      or not l_api_updating) then
    --
    if (p_cvg_eff_end_cd = 'RL' and p_cvg_eff_end_rl is null) then
             --
             fnd_message.set_name('BEN','BEN_91623_CD_RL_1');
             fnd_message.raise_error;
         -- please word this message like 'If you choose a Coverage Start Code of "Rule",
         -- you must choose a Coverage Start Rule.'
    end if;
    --
    if nvl(p_cvg_eff_end_cd,hr_api.g_varchar2) <> 'RL' and p_cvg_eff_end_rl is not null then
             --
             fnd_message.set_name('BEN','BEN_91624_CD_RL_2');
             fnd_message.raise_error;
         -- please word this message like 'If you choose a Coverage Start Rule,
         -- you must choose a Coverage Start Code of "Rule".'
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_cvg_eff_end_dependency;
--
-- ----------------------------------------------------------------------------
-- |------< chk_chg_dpnt_cvg_dependency >------|
-- ---------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check the code/rule dependency as following:
--             If code = 'Rule' then rule must be selected.
--             If code <> 'Rule' then code must not be selected.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_dpnt_cvg_id PK of record being inserted or updated.
--   ler_chg_dpnt_cvg_cd Value of lookup code.
--   ler_chg_dpnt_cvg_rl
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
Procedure chk_chg_dpnt_cvg_dependency(p_ler_chg_dpnt_cvg_id       in number,
                            p_ler_chg_dpnt_cvg_cd             in varchar2,
                            p_ler_chg_dpnt_cvg_rl             in number,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_chg_dpnt_cvg_dependency';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ldc_shd.api_updating
    (p_ler_chg_dpnt_cvg_id         => p_ler_chg_dpnt_cvg_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and
         (nvl(p_ler_chg_dpnt_cvg_cd,hr_api.g_varchar2)
               <> nvl(ben_ldc_shd.g_old_rec.ler_chg_dpnt_cvg_cd,hr_api.g_varchar2) or
          nvl(p_ler_chg_dpnt_cvg_rl,hr_api.g_number)
               <> nvl(ben_ldc_shd.g_old_rec.ler_chg_dpnt_cvg_rl,hr_api.g_number))
      or not l_api_updating) then
    --
    if (p_ler_chg_dpnt_cvg_cd = 'RL' and p_ler_chg_dpnt_cvg_rl is null) then
             --
             fnd_message.set_name('BEN','BEN_91623_CD_RL_1');
             fnd_message.raise_error;
         -- please word this message like 'If you choose a Coverage Start Code of "Rule",
         -- you must choose a Coverage Start Rule.'
    end if;
    --
    if nvl(p_ler_chg_dpnt_cvg_cd,hr_api.g_varchar2) <> 'RL' and p_ler_chg_dpnt_cvg_rl  is not null then
             --
             fnd_message.set_name('BEN','BEN_91624_CD_RL_2');
             fnd_message.raise_error;
         -- please word this message like 'If you choose a Coverage Start Rule,
         -- you must choose a Coverage Start Code of "Rule".'
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_chg_dpnt_cvg_dependency;
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
            (p_ler_chg_dpnt_cvg_rl           in number default hr_api.g_number,
             p_cvg_eff_strt_rl           in number default hr_api.g_number,
             p_cvg_eff_end_rl           in number default hr_api.g_number,
             p_ptip_id                       in number default hr_api.g_number,
             p_ler_id                        in number default hr_api.g_number,
             p_pl_id                         in number default hr_api.g_number,
             p_pgm_id                        in number default hr_api.g_number,
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
    If ((nvl(p_ler_chg_dpnt_cvg_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_ler_chg_dpnt_cvg_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_cvg_eff_strt_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_cvg_eff_strt_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_cvg_eff_end_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_cvg_eff_end_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_ptip_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_ptip_f',
             p_base_key_column => 'ptip_id',
             p_base_key_value  => p_ptip_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_ptip_f';
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
    If ((nvl(p_pl_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_pl_f',
             p_base_key_column => 'pl_id',
             p_base_key_value  => p_pl_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_pl_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_pgm_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_pgm_f',
             p_base_key_column => 'pgm_id',
             p_base_key_value  => p_pgm_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_pgm_f';
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
            (p_ler_chg_dpnt_cvg_id		in number,
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
       p_argument       => 'ler_chg_dpnt_cvg_id',
       p_argument_value => p_ler_chg_dpnt_cvg_id);
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_ler_chg_dpnt_cvg_ctfn_f',
           p_base_key_column => 'ler_chg_dpnt_cvg_id',
           p_base_key_value  => p_ler_chg_dpnt_cvg_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_ler_chg_dpnt_cvg_ctfn_f';
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
	(p_rec 			 in ben_ldc_shd.g_rec_type,
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
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_ler_chg_dpnt_cvg_id
  (p_ler_chg_dpnt_cvg_id          => p_rec.ler_chg_dpnt_cvg_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ler_id
  (p_ler_chg_dpnt_cvg_id          => p_rec.ler_chg_dpnt_cvg_id,
   p_ler_id              => p_rec.ler_id,
   p_pgm_id              => p_rec.pgm_id,
   p_ptip_id              => p_rec.ptip_id,
   p_pl_id              => p_rec.pl_id,
   p_effective_date        => p_effective_date,
   p_validation_start_date  =>    p_validation_start_date,
   p_validation_end_date      =>  p_validation_end_date,
   p_business_group_id        =>  p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
   --
  chk_cvg_eff_end_rl
  (p_ler_chg_dpnt_cvg_id          => p_rec.ler_chg_dpnt_cvg_id,
   p_cvg_eff_end_rl        => p_rec.cvg_eff_end_rl,
   p_effective_date        => p_effective_date,
   p_business_group_id        =>  p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cvg_eff_strt_rl
  (p_ler_chg_dpnt_cvg_id          => p_rec.ler_chg_dpnt_cvg_id,
   p_cvg_eff_strt_rl        => p_rec.cvg_eff_strt_rl,
   p_effective_date        => p_effective_date,
   p_business_group_id        =>  p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ler_chg_dpnt_cvg_rl
  (p_ler_chg_dpnt_cvg_id          => p_rec.ler_chg_dpnt_cvg_id,
   p_ler_chg_dpnt_cvg_rl        => p_rec.ler_chg_dpnt_cvg_rl,
   p_effective_date        => p_effective_date,
   p_business_group_id        =>  p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
 chk_ler_chg_dpnt_cvg_cd
  (p_ler_chg_dpnt_cvg_id   => p_rec.ler_chg_dpnt_cvg_id,
   p_ler_chg_dpnt_cvg_cd   => p_rec.ler_chg_dpnt_cvg_cd,
   p_cvg_eff_strt_cd       => p_rec.cvg_eff_strt_cd,
   p_cvg_eff_end_cd        => p_rec.cvg_eff_end_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cvg_eff_strt_cd
  (p_ler_chg_dpnt_cvg_id          => p_rec.ler_chg_dpnt_cvg_id,
   p_cvg_eff_strt_cd         => p_rec.cvg_eff_strt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cvg_eff_end_cd
  (p_ler_chg_dpnt_cvg_id          => p_rec.ler_chg_dpnt_cvg_id,
   p_cvg_eff_end_cd         => p_rec.cvg_eff_end_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_add_rmv_cvg_cd
  (p_ler_chg_dpnt_cvg_id          => p_rec.ler_chg_dpnt_cvg_id,
   p_add_rmv_cvg_cd         => p_rec.add_rmv_cvg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_dsgn_cd
  (p_ler_chg_dpnt_cvg_id          => p_rec.ler_chg_dpnt_cvg_id,
   p_pgm_id              => p_rec.pgm_id,
   p_ptip_id              => p_rec.ptip_id,
   p_pl_id              => p_rec.pl_id,
   p_effective_date        => p_effective_date,
   p_validation_start_date  =>    p_validation_start_date,
   p_validation_end_date      =>  p_validation_end_date,
   p_business_group_id        =>  p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cvg_eff_strt_dependency
  (p_ler_chg_dpnt_cvg_id          => p_rec.ler_chg_dpnt_cvg_id,
   p_cvg_eff_strt_cd         => p_rec.cvg_eff_strt_cd,
   p_cvg_eff_strt_rl         => p_rec.cvg_eff_strt_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cvg_eff_end_dependency
  (p_ler_chg_dpnt_cvg_id          => p_rec.ler_chg_dpnt_cvg_id,
   p_cvg_eff_end_cd         => p_rec.cvg_eff_end_cd,
   p_cvg_eff_end_rl         => p_rec.cvg_eff_end_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_chg_dpnt_cvg_dependency
  (p_ler_chg_dpnt_cvg_id          => p_rec.ler_chg_dpnt_cvg_id,
   p_ler_chg_dpnt_cvg_cd         => p_rec.ler_chg_dpnt_cvg_cd,
   p_ler_chg_dpnt_cvg_rl         => p_rec.ler_chg_dpnt_cvg_rl,
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
	(p_rec 			 in ben_ldc_shd.g_rec_type,
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
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  -- Call all supporting business operations
  --
  chk_ler_chg_dpnt_cvg_id
  (p_ler_chg_dpnt_cvg_id          => p_rec.ler_chg_dpnt_cvg_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ler_id
  (p_ler_chg_dpnt_cvg_id          => p_rec.ler_chg_dpnt_cvg_id,
   p_ler_id              => p_rec.ler_id,
   p_pgm_id              => p_rec.pgm_id,
   p_ptip_id              => p_rec.ptip_id,
   p_pl_id              => p_rec.pl_id,
   p_effective_date        => p_effective_date,
   p_validation_start_date  =>    p_validation_start_date,
   p_validation_end_date      =>  p_validation_end_date,
   p_business_group_id        =>  p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
   --
  chk_cvg_eff_end_rl
  (p_ler_chg_dpnt_cvg_id          => p_rec.ler_chg_dpnt_cvg_id,
   p_cvg_eff_end_rl        => p_rec.cvg_eff_end_rl,
   p_effective_date        => p_effective_date,
   p_business_group_id        =>  p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cvg_eff_strt_rl
  (p_ler_chg_dpnt_cvg_id          => p_rec.ler_chg_dpnt_cvg_id,
   p_cvg_eff_strt_rl        => p_rec.cvg_eff_strt_rl,
   p_effective_date        => p_effective_date,
   p_business_group_id        =>  p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ler_chg_dpnt_cvg_rl
  (p_ler_chg_dpnt_cvg_id          => p_rec.ler_chg_dpnt_cvg_id,
   p_ler_chg_dpnt_cvg_rl        => p_rec.ler_chg_dpnt_cvg_rl,
   p_effective_date        => p_effective_date,
   p_business_group_id        =>  p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ler_chg_dpnt_cvg_cd
  (p_ler_chg_dpnt_cvg_id   => p_rec.ler_chg_dpnt_cvg_id,
   p_ler_chg_dpnt_cvg_cd   => p_rec.ler_chg_dpnt_cvg_cd,
   p_cvg_eff_strt_cd       => p_rec.cvg_eff_strt_cd,
   p_cvg_eff_end_cd        => p_rec.cvg_eff_end_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cvg_eff_strt_cd
  (p_ler_chg_dpnt_cvg_id          => p_rec.ler_chg_dpnt_cvg_id,
   p_cvg_eff_strt_cd         => p_rec.cvg_eff_strt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cvg_eff_end_cd
  (p_ler_chg_dpnt_cvg_id          => p_rec.ler_chg_dpnt_cvg_id,
   p_cvg_eff_end_cd         => p_rec.cvg_eff_end_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_add_rmv_cvg_cd
  (p_ler_chg_dpnt_cvg_id          => p_rec.ler_chg_dpnt_cvg_id,
   p_add_rmv_cvg_cd         => p_rec.add_rmv_cvg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_dsgn_cd
  (p_ler_chg_dpnt_cvg_id          => p_rec.ler_chg_dpnt_cvg_id,
   p_pgm_id              => p_rec.pgm_id,
   p_ptip_id              => p_rec.ptip_id,
   p_pl_id              => p_rec.pl_id,
   p_effective_date        => p_effective_date,
   p_validation_start_date  =>    p_validation_start_date,
   p_validation_end_date      =>  p_validation_end_date,
   p_business_group_id        =>  p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cvg_eff_strt_dependency
  (p_ler_chg_dpnt_cvg_id          => p_rec.ler_chg_dpnt_cvg_id,
   p_cvg_eff_strt_cd         => p_rec.cvg_eff_strt_cd,
   p_cvg_eff_strt_rl         => p_rec.cvg_eff_strt_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cvg_eff_end_dependency
  (p_ler_chg_dpnt_cvg_id          => p_rec.ler_chg_dpnt_cvg_id,
   p_cvg_eff_end_cd         => p_rec.cvg_eff_end_cd,
   p_cvg_eff_end_rl         => p_rec.cvg_eff_end_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_chg_dpnt_cvg_dependency
  (p_ler_chg_dpnt_cvg_id          => p_rec.ler_chg_dpnt_cvg_id,
   p_ler_chg_dpnt_cvg_cd         => p_rec.ler_chg_dpnt_cvg_cd,
   p_ler_chg_dpnt_cvg_rl         => p_rec.ler_chg_dpnt_cvg_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_ler_chg_dpnt_cvg_rl           => p_rec.ler_chg_dpnt_cvg_rl,
             p_cvg_eff_strt_rl           => p_rec.cvg_eff_strt_rl,
             p_cvg_eff_end_rl           => p_rec.cvg_eff_end_rl,
             p_ptip_id                       => p_rec.ptip_id,
             p_ler_id                        => p_rec.ler_id,
             p_pl_id                         => p_rec.pl_id,
             p_pgm_id                        => p_rec.pgm_id,
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
	(p_rec 			 in ben_ldc_shd.g_rec_type,
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
     p_ler_chg_dpnt_cvg_id		=> p_rec.ler_chg_dpnt_cvg_id);
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
  (p_ler_chg_dpnt_cvg_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_ler_chg_dpnt_cvg_f b
    where b.ler_chg_dpnt_cvg_id      = p_ler_chg_dpnt_cvg_id
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
                             p_argument       => 'ler_chg_dpnt_cvg_id',
                             p_argument_value => p_ler_chg_dpnt_cvg_id);
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
end ben_ldc_bus;

/
