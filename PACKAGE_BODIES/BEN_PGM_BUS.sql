--------------------------------------------------------
--  DDL for Package Body BEN_PGM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PGM_BUS" as
/* $Header: bepgmrhi.pkb 120.1 2005/12/09 05:02:29 nhunur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pgm_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_pgm_id >-----------------------------|
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
--   pgm_id PK of record being inserted or updated.
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
Procedure chk_pgm_id(p_pgm_id                in number,
                     p_effective_date        in date,
                     p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pgm_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_effective_date        => p_effective_date,
     p_pgm_id                => p_pgm_id,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_pgm_id,hr_api.g_number)
     <>  ben_pgm_shd.g_old_rec.pgm_id) then
    --
    -- raise error as PK has changed
    --
    ben_pgm_shd.constraint_error('BEN_PGM_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_pgm_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_ade_shd.constraint_error('BEN_PGM_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_pgm_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_auto_enrt_mthd_rl >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
--   auto_enrt_mthd_rl Value of formula rule id.
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
Procedure chk_auto_enrt_mthd_rl(p_pgm_id                in number,
                              p_auto_enrt_mthd_rl       in number,
                              p_effective_date        in date,
                              p_object_version_number in number,
                              p_business_group_id     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_auto_enrt_mthd_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_auto_enrt_mthd_rl
    and    ff.formula_type_id = -146
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
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_auto_enrt_mthd_rl,hr_api.g_number)
      <> ben_pgm_shd.g_old_rec.auto_enrt_mthd_rl
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
        fnd_message.set_name('BEN','BEN_91953_NVLD_AUTO_ENR_MTH_RL');
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

-- --------------------------------chk_cd_rl_combination >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check the code is RULE then the rule must be
--   defined else it should not be.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_vrfy_fmly_mmbr_cd         in varchar2,
--   p_vrfy_fmly_mmbr_rl         in number
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
procedure chk_cd_rl_combination
(
    p_vrfy_fmly_mmbr_cd     in varchar2,
    p_vrfy_fmly_mmbr_rl     in number ) IS
   l_proc         varchar2(72) := g_package||'chk_cd_rl_combination';
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if    ( p_vrfy_fmly_mmbr_cd <> 'RL' and  p_vrfy_fmly_mmbr_rl is not null)
  then
                fnd_message.set_name('BEN','BEN_91730_NO_RULE');
                fnd_message.raise_error;
  end if;

  if ( p_vrfy_fmly_mmbr_cd = 'RL' and p_vrfy_fmly_mmbr_rl is null)
  then
                fnd_message.set_name('BEN','BEN_91731_RULE');
                fnd_message.raise_error;
  end if;
  --
--leaving Procedure.
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_cd_rl_combination;

---
-- ----------------------------------------------------------------------------
-- |------------------------< chk_enrt_rl >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
--   enrt_rl Value of formula rule id.
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
Procedure chk_enrt_rl
             (p_pgm_id                in number,
              p_enrt_rl               in number,
              p_effective_date        in date,
              p_object_version_number in number,
              p_business_group_id     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_enrt_rl
    and    ff.formula_type_id = -393
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
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_enrt_rl,hr_api.g_number)
      <> ben_pgm_shd.g_old_rec.enrt_rl
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
        fnd_message.set_name('BEN','BEN_91952_INVLD_ENRT_RL');
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
-- |------------------------< chk_enrt_cvg_strt_dt_rl >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
--   enrt_cvg_strt_dt_rl Value of formula rule id.
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
Procedure chk_enrt_cvg_strt_dt_rl(p_pgm_id                in number,
                              p_enrt_cvg_strt_dt_rl       in number,
                              p_effective_date        in date,
                              p_object_version_number in number,
                              p_business_group_id     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_cvg_strt_dt_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_enrt_cvg_strt_dt_rl
    and    ff.formula_type_id = -29
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
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_enrt_cvg_strt_dt_rl,hr_api.g_number)
      <> ben_pgm_shd.g_old_rec.enrt_cvg_strt_dt_rl
      or not l_api_updating)
      and p_enrt_cvg_strt_dt_rl is not null then
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
        fnd_message.set_name('BEN','BEN_91251_INV_ENRT_START_DT_RL');
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
end chk_enrt_cvg_strt_dt_rl;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_enrt_cvg_end_dt_rl >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
--   enrt_cvg_end_dt_rl Value of formula rule id.
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
Procedure chk_enrt_cvg_end_dt_rl(p_pgm_id             in number,
                              p_enrt_cvg_end_dt_rl    in number,
                              p_effective_date        in date,
                              p_object_version_number in number,
                              p_business_group_id     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_cvg_end_dt_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_enrt_cvg_end_dt_rl
    and    ff.formula_type_id = -30
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
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_enrt_cvg_end_dt_rl,hr_api.g_number)
      <> ben_pgm_shd.g_old_rec.enrt_cvg_end_dt_rl
      or not l_api_updating)
      and p_enrt_cvg_end_dt_rl is not null then
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
        fnd_message.set_name('BEN','BEN_91250_INV_ENRT_END_DT_RL');
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
end chk_enrt_cvg_end_dt_rl;
--


Procedure chk_vrfy_fmly_mmbr_cd(p_pgm_id                     in number,
                                p_vrfy_fmly_mmbr_cd           in varchar2,
                                p_effective_date              in date,
                                p_object_version_number       in number) is

  l_proc         varchar2(72) := g_package||'chk_vrfy_fmly_mmbr_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                     => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_vrfy_fmly_mmbr_cd
      <> nvl(ben_pgm_shd.g_old_rec.vrfy_fmly_mmbr_cd,hr_api.g_varchar2)
      or not l_api_updating)
     and p_vrfy_fmly_mmbr_cd is not null
  then
    --
    -- check if value of lookup falls within lookup type.
    --

    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_FMLY_MMBR',
           p_lookup_code    => p_vrfy_fmly_mmbr_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_vrfy_fmly_mmbr_cd');
      fnd_message.set_token('TYPE','BEN_FMLY_MMBR');
      fnd_message.raise_error;
      --
    end if;

   --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_vrfy_fmly_mmbr_cd;

-------------------------



Procedure chk_vrfy_fmly_mmbr_rl
  (p_pgm_id                in number
  ,p_vrfy_fmly_mmbr_rl     in number
  ,p_business_group_id     in number
  ,p_effective_date        in date
  ,p_object_version_number in number)
is
  --
  l_proc         varchar2(72) := g_package||'chk_vrfy_fmly_mmbr_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_pgm_id         => p_pgm_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_vrfy_fmly_mmbr_rl,hr_api.g_number)
      <> ben_pgm_shd.g_old_rec.vrfy_fmly_mmbr_rl
      or not l_api_updating)
      and p_vrfy_fmly_mmbr_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists

    (p_formula_id        => p_vrfy_fmly_mmbr_rl,
        p_formula_type_id   => -21,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_vrfy_fmly_mmbr_rl);
      fnd_message.set_token('TYPE_ID',-21);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
end chk_vrfy_fmly_mmbr_rl;
--





-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_cvg_strt_dt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
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
Procedure chk_dpnt_cvg_strt_dt_rl(p_pgm_id            in number,
                             p_dpnt_cvg_strt_dt_rl    in number,
                             p_effective_date         in date,
                             p_object_version_number  in number,
                             p_business_group_id      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_cvg_strt_dt_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_dpnt_cvg_strt_dt_rl
    and    ff.formula_type_id = -27
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
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_dpnt_cvg_strt_dt_rl,hr_api.g_number)
      <> ben_pgm_shd.g_old_rec.dpnt_cvg_strt_dt_rl
      or not l_api_updating)
      and p_dpnt_cvg_strt_dt_rl is not null then
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
        fnd_message.set_name('BEN','BEN_91252_INV_DPT_CV_ST_DT_RL');
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
end chk_dpnt_cvg_strt_dt_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rt_end_dt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
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
Procedure chk_rt_end_dt_rl(p_pgm_id            in number,
                             p_rt_end_dt_rl    in number,
                             p_effective_date         in date,
                             p_object_version_number  in number,
                             p_business_group_id      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rt_end_dt_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_rt_end_dt_rl
    and    ff.formula_type_id = -67
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
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                      => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_rt_end_dt_rl,hr_api.g_number)
      <> ben_pgm_shd.g_old_rec.rt_end_dt_rl
      or not l_api_updating)
      and p_rt_end_dt_rl is not null then
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
        fnd_message.set_token('ID',p_rt_end_dt_rl);
        fnd_message.set_token('TYPE_ID',-67);
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
end chk_rt_end_dt_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rt_strt_dt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
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
Procedure chk_rt_strt_dt_rl(p_pgm_id            in number,
                             p_rt_strt_dt_rl    in number,
                             p_effective_date         in date,
                             p_object_version_number  in number,
                             p_business_group_id      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rt_strt_dt_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_rt_strt_dt_rl
    and    ff.formula_type_id = -66
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
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                      => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_rt_strt_dt_rl,hr_api.g_number)
      <> ben_pgm_shd.g_old_rec.rt_strt_dt_rl
      or not l_api_updating)
      and p_rt_strt_dt_rl is not null then
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
        fnd_message.set_token('ID',p_rt_strt_dt_rl);
        fnd_message.set_token('TYPE_ID',-66);
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
end chk_rt_strt_dt_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_cvg_end_dt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
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
Procedure chk_dpnt_cvg_end_dt_rl
             (p_pgm_id                in number,
              p_dpnt_cvg_end_dt_rl    in number,
              p_effective_date        in date,
              p_object_version_number in number,
              p_business_group_id     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_cvg_end_dt_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_dpnt_cvg_end_dt_rl
    and    ff.formula_type_id = -28
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
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_dpnt_cvg_end_dt_rl,hr_api.g_number)
      <> ben_pgm_shd.g_old_rec.dpnt_cvg_end_dt_rl
      or not l_api_updating)
      and p_dpnt_cvg_end_dt_rl is not null then
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
        fnd_message.set_name('BEN','BEN_91253_INV_DPT_CV_EN_DT_RL');
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
end chk_dpnt_cvg_end_dt_rl;
--
/*
-- ----------------------------------------------------------------------------
-- |------< chk_prtn_end_dt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
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
Procedure chk_prtn_end_dt_rl(p_pgm_id                in number,
                             p_prtn_end_dt_rl        in number,
                             p_effective_date        in date,
                             p_object_version_number in number,
                             p_business_group_id     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtn_end_dt_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_prtn_end_dt_rl
    and    ff.formula_type_id = -83
    and    pbg.business_group_id = p_business_group_id
    and    nvl(ff.business_group_id, p_business_group_id) =
           p_business_group_id
    and    nvl(ff.legislation_code, pbg.legislation_code) =
           pbg.legislation_code
    and    p_effective_date between ff.effective_start_date
           and     ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_prtn_end_dt_rl,hr_api.g_number)
      <> ben_pgm_shd.g_old_rec.prtn_end_dt_rl
      or not l_api_updating)
      and p_prtn_end_dt_rl is not null then
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
        fnd_message.set_name('BEN','BEN_91254_INV_PRTN_END_DT_RL');
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
end chk_prtn_end_dt_rl;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_prtn_strt_dt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
--   prtn_strt_dt_rl Value of formula rule id.
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
Procedure chk_prtn_strt_dt_rl(p_pgm_id                in number,
                             p_prtn_strt_dt_rl        in number,
                             p_effective_date         in date,
                             p_object_version_number  in number,
                             p_business_group_id      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtn_strt_dt_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_prtn_strt_dt_rl
    and    ff.formula_type_id = -82
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
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_prtn_strt_dt_rl,hr_api.g_number)
      <> ben_pgm_shd.g_old_rec.prtn_strt_dt_rl
      or not l_api_updating)
      and p_prtn_strt_dt_rl is not null then
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
        fnd_message.set_name('BEN','BEN_91255_INV_PRTN_STA_DT_RL');
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
end chk_prtn_strt_dt_rl;
--
*/
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_adrs_rqd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Flag is in the allowed value set.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
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
Procedure chk_dpnt_adrs_rqd_flag(p_pgm_id                in number,
                         p_dpnt_adrs_rqd_flag  in varchar2,
                         p_effective_date              in date,
                         p_object_version_number       in number)
is
--
  l_proc         varchar2(72) := g_package||'chk_dpnt_adrs_rqd_flag';
  l_api_updating boolean;
  l_dummy        varchar2(1);
 --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dpnt_adrs_rqd_flag
      <> nvl(ben_pgm_shd.g_old_rec.dpnt_adrs_rqd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_dpnt_adrs_rqd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_dpnt_adrs_rqd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91256_INV_DPT_ADRS_RQD_FLG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_adrs_rqd_flag;
--
/*
-- ----------------------------------------------------------------------------
-- |------< chk_elig_apls_to_all_pls_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Flag is in the allowed value set.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
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
Procedure chk_elig_apls_to_all_pls_flag(p_pgm_id                in number,
                         p_elig_apls_to_all_pls_flag  in varchar2,
                         p_effective_date              in date,
                         p_object_version_number       in number)
is
--
  l_proc         varchar2(72) := g_package||'elig_apls_to_all_pls_flag';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_elig_apls_to_all_pls_flag
      <> nvl(ben_pgm_shd.g_old_rec.elig_apls_to_all_pls_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_elig_apls_to_all_pls_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_elig_apls_to_all_pls_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91257_INV_ELG_APLS_ALL_FLG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_elig_apls_to_all_pls_flag;
--
*/
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_dob_rqd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Flag is in the allowed value set.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
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
Procedure chk_dpnt_dob_rqd_flag(p_pgm_id                in number,
                         p_dpnt_dob_rqd_flag  in varchar2,
                         p_effective_date              in date,
                         p_object_version_number       in number)
is
--
  l_proc         varchar2(72) := g_package||'dpnt_dob_rqd_flag';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dpnt_dob_rqd_flag
      <> nvl(ben_pgm_shd.g_old_rec.dpnt_dob_rqd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_dpnt_dob_rqd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_dpnt_dob_rqd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91528_INV_DPT_DOB_RQD_FLG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_dob_rqd_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pgm_prvd_no_auto_enrt_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Flag is in the allowed value set.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
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
Procedure chk_pgm_prvd_no_auto_enrt_flag(p_pgm_id                in number,
                         p_pgm_prvds_no_auto_enrt_flag  in varchar2,
                         p_effective_date              in date,
                         p_object_version_number       in number)
is
--
  l_proc         varchar2(72) := g_package||'chk_pgm_prvds_no_auto_enrt_flag';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_pgm_prvds_no_auto_enrt_flag
    <> nvl(ben_pgm_shd.g_old_rec.pgm_prvds_no_auto_enrt_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pgm_prvds_no_auto_enrt_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_pgm_prvds_no_auto_enrt_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91259_INV_PGM_NO_AUTO_FLG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pgm_prvd_no_auto_enrt_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pgm_prvd_no_dflt_enrt_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Flag is in the allowed value set.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
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
Procedure chk_pgm_prvd_no_dflt_enrt_flag(p_pgm_id                in number,
                         p_pgm_prvds_no_dflt_enrt_flag  in varchar2,
                         p_effective_date              in date,
                         p_object_version_number       in number)
is
--
  l_proc         varchar2(72) := g_package||'pgm_prvd_no_dflt_enrt_flag';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_pgm_prvds_no_dflt_enrt_flag
    <> nvl(ben_pgm_shd.g_old_rec.pgm_prvds_no_dflt_enrt_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pgm_prvds_no_dflt_enrt_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_pgm_prvds_no_dflt_enrt_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91260_INV_PGM_NO_DFLT_FLG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pgm_prvd_no_dflt_enrt_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_legv_id_rqd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Flag is in the allowed value set.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
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
Procedure chk_dpnt_legv_id_rqd_flag(p_pgm_id                in number,
                         p_dpnt_legv_id_rqd_flag  in varchar2,
                         p_effective_date              in date,
                         p_object_version_number       in number)
is
--
  l_proc         varchar2(72) := g_package||'dpnt_legv_id_rqd_flag';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dpnt_legv_id_rqd_flag
      <> nvl(ben_pgm_shd.g_old_rec.dpnt_legv_id_rqd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_dpnt_legv_id_rqd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_dpnt_legv_id_rqd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91261_INV_DPT_LID_RQD_FLG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_legv_id_rqd_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_elig_apls_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Flag is in the allowed value set.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
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
Procedure chk_elig_apls_flag(p_pgm_id                in number,
                         p_elig_apls_flag  in varchar2,
                         p_effective_date              in date,
                         p_object_version_number       in number)
is
--
  l_proc         varchar2(72) := g_package||'chk_elig_apls_flag';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_elig_apls_flag
      <> nvl(ben_pgm_shd.g_old_rec.elig_apls_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_elig_apls_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_elig_apls_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91262_INV_ELIG_APLS_FLG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_elig_apls_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_uses_all_asmts_for_rts_fla >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Flag is in the allowed value set.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
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
Procedure chk_uses_all_asmts_for_rts_fla(p_pgm_id                in number,
                         p_uses_all_asmts_for_rts_flag  in varchar2,
                         p_effective_date              in date,
                         p_object_version_number       in number)
is
--
  l_proc         varchar2(72) := g_package||'chk_uses_all_asmts_for_rts_fla';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_uses_all_asmts_for_rts_flag
      <> nvl(ben_pgm_shd.g_old_rec.uses_all_asmts_for_rts_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_uses_all_asmts_for_rts_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_uses_all_asmts_for_rts_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91263_INV_PRTT_UNCRS_FLG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_uses_all_asmts_for_rts_fla;
--
-- ----------------------------------------------------------------------------
-- |------< chk_prtn_elig_ovrid_alwd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Flag is in the allowed value set.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
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
Procedure chk_prtn_elig_ovrid_alwd_flag(p_pgm_id                in number,
                         p_prtn_elig_ovrid_alwd_flag  in varchar2,
                         p_effective_date              in date,
                         p_object_version_number       in number)
is
--
  l_proc         varchar2(72) := g_package||'chk_prtn_elig_ovrid_alwd_flag';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_prtn_elig_ovrid_alwd_flag
      <> nvl(ben_pgm_shd.g_old_rec.prtn_elig_ovrid_alwd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_prtn_elig_ovrid_alwd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_prtn_elig_ovrid_alwd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91265_INV_PRTN_ELG_OVR_FLG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_prtn_elig_ovrid_alwd_flag;

--
/*
-- ----------------------------------------------------------------------------
-- |------< chk_tmprl_fctr_apls_rts_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Flag is in the allowed value set.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
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
Procedure chk_tmprl_fctr_apls_rts_flag(p_pgm_id                in number,
                         p_tmprl_fctr_apls_rts_flag  in varchar2,
                         p_effective_date              in date,
                         p_object_version_number       in number)
is
--
  l_proc         varchar2(72) := g_package||'chk_tmprl_fctr_apls_rts_flag';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_tmprl_fctr_apls_rts_flag
      <> nvl(ben_pgm_shd.g_old_rec.tmprl_fctr_apls_rts_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_tmprl_fctr_apls_rts_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_tmprl_fctr_apls_rts_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91266_INV_TMP_FCTR_RTS_FLG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_tmprl_fctr_apls_rts_flag;
*/
--
-- ----------------------------------------------------------------------------
-- |------< chk_pgm_use_all_asnt_elig_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Flag is in the allowed value set.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
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
Procedure chk_pgm_use_all_asnt_elig_flag(p_pgm_id                in number,
                         p_pgm_use_all_asnts_elig_flag  in varchar2,
                         p_effective_date              in date,
                         p_object_version_number       in number)
is
--
  l_proc         varchar2(72) := g_package||'chk_pgm_use_all_asnt_elig_flag';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_pgm_use_all_asnts_elig_flag
    <> nvl(ben_pgm_shd.g_old_rec.pgm_use_all_asnts_elig_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pgm_use_all_asnts_elig_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_pgm_use_all_asnts_elig_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91267_INV_PGM_AST_ELG_FLG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pgm_use_all_asnt_elig_flag;

--
-- ----------------------------------------------------------------------------
-- |------< chk_coord_cvg_for_all_pls_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Flag is in the allowed value set.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
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
Procedure chk_coord_cvg_for_all_pls_flg(p_pgm_id                in number,
                         p_coord_cvg_for_all_pls_flg  in varchar2,
                         p_effective_date              in date,
                         p_object_version_number       in number)
is
--
  l_proc         varchar2(72) := g_package||'chk_coord_cvg_for_all_pls_flg';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_coord_cvg_for_all_pls_flg
      <> nvl(ben_pgm_shd.g_old_rec.coord_cvg_for_all_pls_flg,hr_api.g_varchar2)
      or not l_api_updating)
      and p_coord_cvg_for_all_pls_flg is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_coord_cvg_for_all_pls_flg,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91237_INV_COORD_CVG_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_coord_cvg_for_all_pls_flg;

--
-- ----------------------------------------------------------------------------
-- |------< chk_drvbl_fctr_dpnt_elig_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Flag is in the allowed value set.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
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
Procedure chk_drvbl_fctr_dpnt_elig_flag(p_pgm_id                in number,
                         p_drvbl_fctr_dpnt_elig_flag  in varchar2,
                         p_effective_date              in date,
                         p_object_version_number       in number)
is
--
  l_proc         varchar2(72) := g_package||'chk_drvbl_fctr_dpnt_elig_flag';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_drvbl_fctr_dpnt_elig_flag
      <> nvl(ben_pgm_shd.g_old_rec.drvbl_fctr_dpnt_elig_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_drvbl_fctr_dpnt_elig_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_drvbl_fctr_dpnt_elig_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91288_INV_DRV_FCT_DPT_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_drvbl_fctr_dpnt_elig_flag;

--
/*
-- ----------------------------------------------------------------------------
-- |------< chk_mt_one_dpnt_cvg_elig_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Flag is in the allowed value set.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
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
Procedure chk_mt_one_dpnt_cvg_elig_flag(p_pgm_id                in number,
                         p_mt_one_dpnt_cvg_elig_flag  in varchar2,
                         p_effective_date              in date,
                         p_object_version_number       in number)
is
--
  l_proc         varchar2(72) := g_package||'chk_mt_one_dpnt_cvg_elig_flag';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_mt_one_dpnt_cvg_elig_flag
      <> nvl(ben_pgm_shd.g_old_rec.mt_one_dpnt_cvg_elig_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_mt_one_dpnt_cvg_elig_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_mt_one_dpnt_cvg_elig_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91289_INV_MT_ONE_ELG_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mt_one_dpnt_cvg_elig_flag;
*/
--
-- ----------------------------------------------------------------------------
-- |------< chk_drvbl_fctr_prtn_elig_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Flag is in the allowed value set.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
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
Procedure chk_drvbl_fctr_prtn_elig_flag(p_pgm_id                in number,
                         p_drvbl_fctr_prtn_elig_flag  in varchar2,
                         p_effective_date              in date,
                         p_object_version_number       in number)
is
--
  l_proc         varchar2(72) := g_package||'chk_drvbl_fctr_prtn_elig_flag';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_drvbl_fctr_prtn_elig_flag
      <> nvl(ben_pgm_shd.g_old_rec.drvbl_fctr_prtn_elig_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_drvbl_fctr_prtn_elig_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_drvbl_fctr_prtn_elig_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91290_INV_DRV_FCT_PRTN_FLG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_drvbl_fctr_prtn_elig_flag;

--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_alws_unrstrctd_enrt_flag >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Flag is in the allowed value set.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
--   alws_unrstrctd_enrt_flag value of flag being checked.
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
Procedure chk_alws_unrstrctd_enrt_flag
              (p_pgm_id                      in number,
               p_alws_unrstrctd_enrt_flag    in varchar2,
               p_effective_date              in date,
               p_object_version_number       in number)
is
--
  l_proc         varchar2(72) := g_package||'chk_alws_unrstrctd_enrt_flag';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
      and p_alws_unrstrctd_enrt_flag
      <> nvl(ben_pgm_shd.g_old_rec.alws_unrstrctd_enrt_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_alws_unrstrctd_enrt_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_alws_unrstrctd_enrt_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91949_ALWS_UNRSTR_ENRT_FLG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_alws_unrstrctd_enrt_flag;

-- ----------------------------------------------------------------------------
-- |------< chk_drvbl_fctr_apls_rts_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Flag is in the allowed value set.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
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
Procedure chk_drvbl_fctr_apls_rts_flag(p_pgm_id                in number,
                         p_drvbl_fctr_apls_rts_flag  in varchar2,
                         p_effective_date              in date,
                         p_object_version_number       in number)
is
--
  l_proc         varchar2(72) := g_package||'chk_drvbl_fctr_apls_rts_flag';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_drvbl_fctr_apls_rts_flag
      <> nvl(ben_pgm_shd.g_old_rec.drvbl_fctr_apls_rts_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_drvbl_fctr_apls_rts_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_drvbl_fctr_apls_rts_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91291_INV_DRV_FCT_RTS_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_drvbl_fctr_apls_rts_flag;

--
/*
-- ----------------------------------------------------------------------------
-- |------< chk_tmprl_fctr_dpnt_elig_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Flag is in the allowed value set.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
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
Procedure chk_tmprl_fctr_dpnt_elig_flag(p_pgm_id                in number,
                         p_tmprl_fctr_dpnt_elig_flag  in varchar2,
                         p_effective_date              in date,
                         p_object_version_number       in number)
is
--
  l_proc         varchar2(72) := g_package||'chk_tmprl_fctr_dpnt_elig_flag';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_tmprl_fctr_dpnt_elig_flag
      <> nvl(ben_pgm_shd.g_old_rec.tmprl_fctr_dpnt_elig_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_tmprl_fctr_dpnt_elig_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_tmprl_fctr_dpnt_elig_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91292_INV_TMP_FCT_DPT_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_tmprl_fctr_dpnt_elig_flag;

--
-- ----------------------------------------------------------------------------
-- |------< chk_tmprl_fctr_prtn_elig_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Flag is in the allowed value set.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
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
Procedure chk_tmprl_fctr_prtn_elig_flag(p_pgm_id                in number,
                         p_tmprl_fctr_prtn_elig_flag  in varchar2,
                         p_effective_date              in date,
                         p_object_version_number       in number)
is
--
  l_proc         varchar2(72) := g_package||'chk_tmprl_fctr_prtn_elig_flag';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_tmprl_fctr_prtn_elig_flag
      <> nvl(ben_pgm_shd.g_old_rec.tmprl_fctr_prtn_elig_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_tmprl_fctr_prtn_elig_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_tmprl_fctr_prtn_elig_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91293_INV_TMP_FCT_PRTN_FLG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_tmprl_fctr_prtn_elig_flag;
*/
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_dsgn_no_ctfn_rqd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Flag is in the allowed value set.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
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
Procedure chk_dpnt_dsgn_no_ctfn_rqd_flag(p_pgm_id                in number,
                         p_dpnt_dsgn_no_ctfn_rqd_flag  in varchar2,
                         p_effective_date              in date,
                         p_object_version_number       in number)
is
--
  l_proc         varchar2(72) := g_package||'chk_dpnt_dsg_no_ctfn_rqd_flag';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dpnt_dsgn_no_ctfn_rqd_flag
      <> nvl(ben_pgm_shd.g_old_rec.dpnt_dsgn_no_ctfn_rqd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_dpnt_dsgn_no_ctfn_rqd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_dpnt_dsgn_no_ctfn_rqd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91294_INV_NO_CTFN_RQD_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_dsgn_no_ctfn_rqd_flag;

--
-- ----------------------------------------------------------------------------
-- |------< chk_trk_inelig_per_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Flag is in the allowed value set.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
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
Procedure chk_trk_inelig_per_flag(p_pgm_id                in number,
                         p_trk_inelig_per_flag  in varchar2,
                         p_effective_date              in date,
                         p_object_version_number       in number)
is
--
  l_proc         varchar2(72) := g_package||'chk_trk_inelig_per_flag';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_trk_inelig_per_flag
      <> nvl(ben_pgm_shd.g_old_rec.trk_inelig_per_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_trk_inelig_per_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_trk_inelig_per_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91295_INV_TRK_INELG_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_trk_inelig_per_flag;

-- ----------------------------------------------------------------------------
-- |------< chk_pgm_stat_cd_not_null >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This function is used to return an "Active" program status if
--    left null upon insert
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_pgm_stat_cd is program status of record being inserted.
--   p_effective_date is effective date
--
-- Return Value
--    Pgm_stat_cd that is not null
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the function
--
-- Access Status
--   Internal table handler use only.
--
-- ----------------------------------------------------------------------------
Function chk_pgm_stat_cd_not_null( p_pgm_stat_cd in varchar2
                                  ,p_effective_date in date)
return  varchar2
is
  l_proc	    varchar2(72) := g_package||'chk_pgm_stat_cd_not_null';
  l_pgm_stat     varchar2(30);
  cursor c1 is select lookup_code
                      from hr_lookups
                      where lookup_type = 'BEN_STAT'
                          and p_effective_date between start_date_active
			  and end_date_active
                          and enabled_flag = 'Y';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  if p_pgm_stat_cd is null then
     open c1;
     fetch c1 into l_pgm_stat;
     if c1%notfound then
        close c1;
        -- raise error as problem getting pgm_stat_cd
        --
        fnd_message.set_name('BEN','BEN_91350_PGM_STATUS_RQD');
        fnd_message.raise_error;
     end if;
     close c1;
     hr_utility.set_location('Leaving:'||l_proc, 10);
     return l_pgm_stat;
  else
     hr_utility.set_location('Leaving:'||l_proc, 15);
     return p_pgm_stat_cd;
  end if;
End chk_pgm_stat_cd_not_null;
--

 -- ----------------------------------------------------------------------------
-- |------------------------< chk_name_unique >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   ensure that not two programs have the same name
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_name is program name
--     p_pgm_id is program id
--     p_business_group_id
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
-- ----------------------------------------------------------------------------
Procedure chk_name_unique
          ( p_pgm_id               in   varchar2
           ,p_name                 in   varchar2
           ,p_business_group_id    in   number)
is
l_proc	    varchar2(72) := g_package||'chk_name_unique';
l_dummy    char(1);
cursor c1 is select null
               from ben_pgm_f
              Where pgm_id <> nvl(p_pgm_id,-1)
                and name = p_name
                and business_group_id = p_business_group_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
  fetch c1 into l_dummy;
  if c1%found then
      close c1;
      fnd_message.set_name('BEN','BEN_91009_NAME_NOT_UNIQUE');
      fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_name_unique;
--
/*
-- ----------------------------------------------------------------------------
-- |-------------------< chk_eligibility_defined >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--
-- Pre Conditions
--   None.
--
-- In Parameters
--    p_elig_apls_flag
--    p_pgm_id
--    p_effective_date
--    p_business_group_id
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
-- ----------------------------------------------------------------------------
Procedure chk_eligibility_defined
          ( p_elig_apls_flag     in   varchar2
           ,p_pgm_id             in   number
           ,p_effective_date     in   date
           ,p_business_group_id  in   number)
is
  l_proc   varchar2(72) := g_package||' chk_eligibility_defined ';
  l_dummy  char(1);
  cursor c1 is select null
                 from ben_prtn_elig_f prtn
                     ,ben_prtn_elig_prfl_f prfl
                where prtn.pgm_id = p_pgm_id
                      and prtn.business_group_id = p_business_group_id
                      and p_effective_date between prtn.effective_start_date
                                               and prtn.effective_end_date
                      and prtn.prtn_elig_id = prfl.prtn_elig_id
                      and prfl.business_group_id = p_business_group_id
                      and p_effective_date between prfl.effective_start_date
                                               and prfl.effective_end_date;

  cursor c2 is select null
                 from ben_prtn_elig_f prtn
                     ,ben_eligy_rl_f   rl
                where prtn.pgm_id = p_pgm_id
                  and prtn.business_group_id = p_business_group_id
                  and p_effective_date between prtn.effective_start_date
                                           and prtn.effective_end_date
                  and prtn.prtn_elig_id = rl.prtn_elig_id
                  and rl.business_group_id = p_business_group_id
                  and p_effective_date between rl.effective_start_date
                                           and rl.effective_end_date;
--
Begin
--
hr_utility.set_location('Entering:'||l_proc, 5);
--
if p_elig_apls_flag = 'Y' then
   --
   -- check to see if there is a profile set up...if so return
   --
   open c1;
   fetch c1 into l_dummy;
   if c1%found then
      close c1;
      hr_utility.set_location('Leaving:'||l_proc, 9);
      return;
   end if;
   close c1;
   --
   -- check to see if there is a profile rule set up...if so return
   --
   open c2;
   fetch c2 into l_dummy;
   if c2%found then
      close c2;
      hr_utility.set_location('Leaving:'||l_proc, 10);
      return;
   end if;
   close c2;
   --
   --  if have not returned out then raise error
   --
   fnd_message.set_name('BEN','BEN_91351_PGM_ELIG_APLS');
   fnd_message.raise_error;
end if;
--
hr_utility.set_location('Leaving:'||l_proc, 15);
--
End chk_eligibility_defined;
--
*/
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_enrt_mthd_cd >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
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
Procedure chk_enrt_mthd_cd
              (p_pgm_id                in number,
               p_enrt_mthd_cd          in varchar2,
               p_effective_date        in date,
               p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_mthd_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_mthd_cd
      <> nvl(ben_pgm_shd.g_old_rec.enrt_mthd_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_enrt_mthd_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ENRT_MTHD',
           p_lookup_code    => p_enrt_mthd_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91951_INVLD_ENRT_MTHD_CD');
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
-- |-----------------------< chk_poe_lvl_cd >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
--   poe_lvl_cd Value of lookup code.
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
Procedure chk_poe_lvl_cd
              (p_pgm_id                in number,
               p_poe_lvl_cd            in varchar2,
               p_effective_date        in date,
               p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_poe_lvl_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
      and p_poe_lvl_cd
      <> nvl(ben_pgm_shd.g_old_rec.poe_lvl_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_poe_lvl_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_POE_LVL',
           p_lookup_code    => p_poe_lvl_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_poe_lvl_cd');
      fnd_message.set_token('TYPE','BEN_POE_LVL');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_poe_lvl_cd;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_enrt_cd >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
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
Procedure chk_enrt_cd(p_pgm_id                in number,
                      p_enrt_cd               in varchar2,
                      p_effective_date        in date,
                      p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_cd
      <> nvl(ben_pgm_shd.g_old_rec.enrt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_enrt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ENRT',
           p_lookup_code    => p_enrt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91950_INVALID_ENRT_CD');
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
-- |------< chk_pgm_stat_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
--   pgm_stat_cd Value of lookup code.
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
Procedure chk_pgm_stat_cd(p_pgm_id                in number,
                            p_pgm_stat_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pgm_stat_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_pgm_stat_cd
      <> nvl(ben_pgm_shd.g_old_rec.pgm_stat_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_STAT',
           p_lookup_code    => p_pgm_stat_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91217_INVLD_STAT_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pgm_stat_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_dsgn_lvl_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
--   dpnt_dsgn_lvl_cd Value of lookup code.
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
Procedure chk_dpnt_dsgn_lvl_cd(p_pgm_id                in number,
                            p_dpnt_dsgn_lvl_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_dsgn_lvl_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dpnt_dsgn_lvl_cd
      <> nvl(ben_pgm_shd.g_old_rec.dpnt_dsgn_lvl_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if p_dpnt_dsgn_lvl_cd is not null then
        if hr_api.not_exists_in_hr_lookups
              (p_lookup_type    => 'BEN_DPNT_DSGN_LVL',
               p_lookup_code    => p_dpnt_dsgn_lvl_cd,
               p_effective_date => p_effective_date) then
          --
          -- raise error as does not exist as lookup
          --
          fnd_message.set_name('BEN','BEN_91296_INV_DPNT_DSGN_LVL_CD');
          fnd_message.raise_error;
          --
        end if;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_dsgn_lvl_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pgm_typ_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
--   pgm_typ_cd Value of lookup code.
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
Procedure chk_pgm_typ_cd(p_pgm_id                in number,
                            p_pgm_typ_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pgm_typ_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_pgm_typ_cd
      <> nvl(ben_pgm_shd.g_old_rec.pgm_typ_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PGM_TYP',
           p_lookup_code    => p_pgm_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91297_INV_PGM_TYP_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pgm_typ_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_dsgn_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--   It also checks that
--   1. if dpnt_dsgn_cd is not null then dpnt_cvg_strt_dt_cd and dpnt_cvg_end_dt_cd
--      should also be not null.
--   2. if dpnt_dsgn_cd is null then dpnt_cvg_strt_dt_cd and dpnt_cvg_end_dt_cd
--      should also be null.
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
--   dpnt_dsgn_cd Value of lookup code.
--   dpnt_cvg_strt_dt_cd Value of lookup code.
--   dpnt_cvg_end_dt_cd Value of lookup code.
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
Procedure chk_dpnt_dsgn_cd(p_pgm_id                in number,
                            p_dpnt_dsgn_cd               in varchar2,
                            p_dpnt_cvg_strt_dt_cd        in varchar2,
                            p_dpnt_cvg_end_dt_cd         in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_dsgn_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dpnt_dsgn_cd
      <> nvl(ben_pgm_shd.g_old_rec.dpnt_dsgn_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if p_dpnt_dsgn_cd is not null then
        if hr_api.not_exists_in_hr_lookups
              (p_lookup_type    => 'BEN_DPNT_DSGN',
               p_lookup_code    => p_dpnt_dsgn_cd,
               p_effective_date => p_effective_date) then
          --
          -- raise error as does not exist as lookup
          --
          fnd_message.set_name('BEN','BEN_91236_INV_DPNT_DSGN_CD');
          fnd_message.raise_error;
          --
        end if;
    end if;
    --
  end if;
  --
  -- Commented out to Fix the bug 1403687
  /*
  if ( p_dpnt_dsgn_cd is not null) and
     (p_dpnt_cvg_strt_dt_cd is null or p_dpnt_cvg_end_dt_cd is null) then

    fnd_message.set_name('BEN','BEN_92512_DPNDNT_CVRG_DT_RQD');
    fnd_message.raise_error;
  end if;
  */

  --

  if (p_dpnt_dsgn_cd is null) and
     (p_dpnt_cvg_strt_dt_cd is not null or p_dpnt_cvg_end_dt_cd is not null) then
     null;
    --fnd_message.set_name('BEN','BEN_92512_DPNDNT_CVRG_DT_RQD');
    --fnd_message.raise_error;
  end if;
  --

  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_dsgn_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pgm_grp_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
--   pgm_grp_cd Value of lookup code.
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
Procedure chk_pgm_grp_cd(p_pgm_id                in number,
                            p_pgm_grp_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pgm_grp_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_pgm_grp_cd
      <> nvl(ben_pgm_shd.g_old_rec.pgm_grp_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if p_pgm_grp_cd is not null then
        if hr_api.not_exists_in_hr_lookups
              (p_lookup_type    => 'BEN_PGM_GRP',
               p_lookup_code    => p_pgm_grp_cd,
               p_effective_date => p_effective_date) then
          --
          -- raise error as does not exist as lookup
          --
          fnd_message.set_name('BEN','BEN_91298_INV_PGM_GRP_CD');
          fnd_message.raise_error;
          --
        end if;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pgm_grp_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_acty_ref_perd_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
--   acty_ref_perd_cd Value of lookup code.
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
Procedure chk_acty_ref_perd_cd(p_pgm_id                in number,
                            p_acty_ref_perd_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_acty_ref_perd_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_acty_ref_perd_cd
      <> nvl(ben_pgm_shd.g_old_rec.acty_ref_perd_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if p_acty_ref_perd_cd is not null then
        if hr_api.not_exists_in_hr_lookups
              (p_lookup_type    => 'BEN_ACTY_REF_PERD',
               p_lookup_code    => p_acty_ref_perd_cd,
               p_effective_date => p_effective_date) then
          --
          -- raise error as does not exist as lookup
          --
          fnd_message.set_name('BEN','BEN_91299_INV_ACTY_REF_PERD_CD');
          fnd_message.raise_error;
          --
        end if;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_acty_ref_perd_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_enrt_cvg_strt_dt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
--   enrt_cvg_strt_dt_cd Value of lookup code.
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
Procedure chk_enrt_cvg_strt_dt_cd(p_pgm_id                in number,
                            p_enrt_cvg_strt_dt_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_cvg_strt_dt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                      => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_cvg_strt_dt_cd
      <> nvl(ben_pgm_shd.g_old_rec.enrt_cvg_strt_dt_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if p_enrt_cvg_strt_dt_cd is not null then
        if hr_api.not_exists_in_hr_lookups
              (p_lookup_type    => 'BEN_ENRT_CVG_STRT',
               p_lookup_code    => p_enrt_cvg_strt_dt_cd,
               p_effective_date => p_effective_date) then
          --
          -- raise error as does not exist as lookup
          --
          fnd_message.set_name('BEN','BEN_91300_INV_ENRT_STRT_DT_CD');
          fnd_message.raise_error;
          --
        end if;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enrt_cvg_strt_dt_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_enrt_cvg_end_dt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
--   enrt_cvg_end_dt_cd Value of lookup code.
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
Procedure chk_enrt_cvg_end_dt_cd(p_pgm_id                in number,
                            p_enrt_cvg_end_dt_cd         in varchar2,
                            p_effective_date             in date,
                            p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_cvg_end_dt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_cvg_end_dt_cd
      <> nvl(ben_pgm_shd.g_old_rec.enrt_cvg_end_dt_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if p_enrt_cvg_end_dt_cd is not null then
        if hr_api.not_exists_in_hr_lookups
              (p_lookup_type    => 'BEN_ENRT_CVG_END',
               p_lookup_code    => p_enrt_cvg_end_dt_cd,
               p_effective_date => p_effective_date) then
          --
          -- raise error as does not exist as lookup
          --
          fnd_message.set_name('BEN','BEN_91301_INV_ENRT_END_DT_CD');
          fnd_message.raise_error;
          --
        end if;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enrt_cvg_end_dt_cd;
/*
--
-- ----------------------------------------------------------------------------
-- |------< chk_prtn_strt_dt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
--   prtn_strt_dt_cd Value of lookup code.
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
Procedure chk_prtn_strt_dt_cd(p_pgm_id                in number,
                            p_prtn_strt_dt_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtn_strt_dt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_prtn_strt_dt_cd
      <> nvl(ben_pgm_shd.g_old_rec.prtn_strt_dt_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if p_prtn_strt_dt_cd is not null then
        if hr_api.not_exists_in_hr_lookups
              (p_lookup_type    => 'BEN_PRTN_ELIG_STRT',
               p_lookup_code    => p_prtn_strt_dt_cd,
               p_effective_date => p_effective_date) then
          --
          -- raise error as does not exist as lookup
          --
          fnd_message.set_name('BEN','BEN_91304_INV_PRTN_STRT_DT_CD');
          fnd_message.raise_error;
          --
        end if;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_prtn_strt_dt_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_prtn_end_dt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
--   prtn_end_dt_cd Value of lookup code.
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
Procedure chk_prtn_end_dt_cd(p_pgm_id                in number,
                            p_prtn_end_dt_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtn_end_dt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_prtn_end_dt_cd
      <> nvl(ben_pgm_shd.g_old_rec.prtn_end_dt_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if p_prtn_end_dt_cd is not null then
        if hr_api.not_exists_in_hr_lookups
              (p_lookup_type    => 'BEN_PRTN_ELIG_END',
               p_lookup_code    => p_prtn_end_dt_cd,
               p_effective_date => p_effective_date) then
          --
          -- raise error as does not exist as lookup
          --
          fnd_message.set_name('BEN','BEN_91305_INV_PRTN_END_DT_CD');
          fnd_message.raise_error;
          --
        end if;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_prtn_end_dt_cd;
*/
--
-- ----------------------------------------------------------------------------
-- |------< chk_pgm_uom >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the fk to fnd_currencies is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
--   pgm_uom Value of lookup code.
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
Procedure chk_pgm_uom(p_pgm_id                in number,
                            p_pgm_uom               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  cursor c1 is select currency_code
                      from fnd_currencies_vl
                      where currency_code = p_pgm_uom
                          and enabled_flag = 'Y';
  --
  l_proc         varchar2(72) := g_package||'chk_pgm_uom';
  l_api_updating boolean;
  l_dummy varchar2(30);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_pgm_uom
      <> nvl(ben_pgm_shd.g_old_rec.pgm_uom,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pgm_uom is not null then
    --
    -- check if value of lookup falls within fnd_currencies.
    --
     open c1;
     fetch c1 into l_dummy;
     if c1%notfound then
        close c1;
        -- raise error as currency not found
        --
        fnd_message.set_name('BEN','BEN_91306_INV_PGM_UOM');
        fnd_message.raise_error;
     end if;
     close c1;
     --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pgm_uom;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_all_rules >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rules are valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id                     PK of record being inserted or updated.
--   Dflt_step_rl               Value of formula rule id.
--   Scores_calc_rl             Value of formula rule id.
--   effective_date             effective date
--   object_version_number      Object version number of record being
--                              inserted or updated.
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
Procedure chk_all_rules(p_pgm_id                      in number,
                        p_business_group_id           in number,
                        p_Dflt_step_rl                in number,
                        p_Scores_calc_rl              in number,
                        p_effective_date              in date,
                        p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_all_rules';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1(p_rule number,p_rule_type_id number) is
    select null
    from   ff_formulas_f ff,
           per_business_groups pbg
    where  ff.formula_id = p_rule
    and    ff.formula_type_id = p_rule_type_id
    and    pbg.business_group_id = p_business_group_id
    and    nvl(ff.business_group_id,p_business_group_id) =
           p_business_group_id
    and    nvl(ff.legislation_code,pbg.legislation_code) =
           pbg.legislation_code
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                      => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_Dflt_step_rl,hr_api.g_number)
      <> ben_pgm_shd.g_old_rec.Dflt_step_rl
      or not l_api_updating)
      and p_Dflt_step_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1(p_Dflt_step_rl,-449); -- BEN_DFLT_STEP
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
        fnd_message.set_token('ID',p_Dflt_step_rl);
        fnd_message.set_token('TYPE_ID',-449);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  if (l_api_updating
      and nvl(p_Scores_calc_rl,hr_api.g_number)
      <> ben_pgm_shd.g_old_rec.Scores_calc_rl
      or not l_api_updating)
      and p_Scores_calc_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1(p_Scores_calc_rl,-550); -- BEN_SCORES_CALC
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
      fnd_message.set_token('ID',p_Scores_calc_rl);
      fnd_message.set_token('TYPE_ID',-550);
      fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
end chk_all_rules;
--
-- ----------------------------------------------------------------------------
-- |------< chk_lookup_codes >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
--   enrt_info_rt_freq_cd Value of lookup code.
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
Procedure chk_lookup_codes(p_pgm_id                      in number,
                            p_Dflt_step_cd               in varchar2,
                            p_Update_salary_cd           in varchar2,
                            p_Scores_calc_mthd_cd        in varchar2,
                            p_salary_calc_mthd_cd	 in varchar2,
                            p_effective_date             in date,
                            p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_lookup_codes';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_Dflt_step_cd
      <> nvl(ben_pgm_shd.g_old_rec.Dflt_step_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if p_Dflt_step_cd is not null then
        if hr_api.not_exists_in_hr_lookups
              (p_lookup_type    => 'BEN_GL_PROG_STYLE',
               p_lookup_code    => p_dflt_step_cd,
               p_effective_date => p_effective_date) then
          --
          -- raise error as does not exist as lookup
          --
          fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
          fnd_message.set_token('VALUE', p_dflt_step_cd);
          fnd_message.set_token('FIELD', 'bnf_dflt_bnf_cd');
          fnd_message.set_token('TYPE', 'BEN_GL_PROG_STYLE');
          fnd_message.raise_error;
          --
        end if;
    end if;
    --
  end if;
  --
  --
  if (l_api_updating
      and p_Update_salary_cd
      <> nvl(ben_pgm_shd.g_old_rec.Update_salary_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if p_Update_salary_cd is not null then
        if hr_api.not_exists_in_hr_lookups
              (p_lookup_type    => 'PQH_GSP_SAL_UPD_MTHD',
               p_lookup_code    => p_Update_salary_cd,
               p_effective_date => p_effective_date) then
          --
          -- raise error as does not exist as lookup
          --
          fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
          fnd_message.set_token('VALUE', p_Update_salary_cd);
          fnd_message.set_token('FIELD', 'Update_salary_cd');
          fnd_message.set_token('TYPE', 'PQH_GSP_SAL_UPD_MTHD');
          fnd_message.raise_error;
          --
        end if;
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_Scores_calc_mthd_cd
      <> nvl(ben_pgm_shd.g_old_rec.Scores_calc_mthd_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if p_Scores_calc_mthd_cd is not null then
        if hr_api.not_exists_in_hr_lookups
              (p_lookup_type    => 'BEN_SCORES_CALC_MTHD',
               p_lookup_code    => p_Scores_calc_mthd_cd,
               p_effective_date => p_effective_date) then
          --
          -- raise error as does not exist as lookup
          --
          fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
          fnd_message.set_token('VALUE', p_Scores_calc_mthd_cd);
          fnd_message.set_token('FIELD', 'Scores_calc_mthd_cd');
          fnd_message.set_token('TYPE', 'BEN_SCORES_CALC_MTHD');
          fnd_message.raise_error;
          --
        end if;
    end if;
    --
  end if;
  --
  --
  if (l_api_updating
      and p_salary_calc_mthd_cd
      <> nvl(ben_pgm_shd.g_old_rec.salary_calc_mthd_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if p_Scores_calc_mthd_cd is not null then
        if hr_api.not_exists_in_hr_lookups
              (p_lookup_type    => 'PQH_GSP_SAL_CALC_METH',
               p_lookup_code    => p_salary_calc_mthd_cd,
               p_effective_date => p_effective_date) then
          --
          -- raise error as does not exist as lookup
          --
          fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
          fnd_message.set_token('VALUE', p_salary_calc_mthd_cd);
          fnd_message.set_token('FIELD', 'salary_calc_mthd_cd');
          fnd_message.set_token('TYPE', 'PQH_GSP_SAL_CALC_METH');
          fnd_message.raise_error;
          --
        end if;
    end if;
    --
  end if;

  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_lookup_codes;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_enrt_info_rt_freq_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
--   enrt_info_rt_freq_cd Value of lookup code.
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
Procedure chk_enrt_info_rt_freq_cd(p_pgm_id                in number,
                            p_enrt_info_rt_freq_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_info_rt_freq_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_info_rt_freq_cd
      <> nvl(ben_pgm_shd.g_old_rec.enrt_info_rt_freq_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if p_enrt_info_rt_freq_cd is not null then
        if hr_api.not_exists_in_hr_lookups
              (p_lookup_type    => 'BEN_ENRT_INFO_RT_FREQ',
               p_lookup_code    => p_enrt_info_rt_freq_cd,
               p_effective_date => p_effective_date) then
          --
          -- raise error as does not exist as lookup
          --
          fnd_message.set_name('BEN','BEN_91307_INV_ENRT_RT_FREQ_CD');
          fnd_message.raise_error;
          --
        end if;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enrt_info_rt_freq_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_cvg_strt_dt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
--   dpnt_cvg_strt_dt_cd Value of lookup code.
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
Procedure chk_dpnt_cvg_strt_dt_cd(p_pgm_id                in number,
                            p_dpnt_cvg_strt_dt_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_cvg_strt_dt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dpnt_cvg_strt_dt_cd
      <> nvl(ben_pgm_shd.g_old_rec.dpnt_cvg_strt_dt_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if p_dpnt_cvg_strt_dt_cd is not null then
        if hr_api.not_exists_in_hr_lookups
              (p_lookup_type    => 'BEN_DPNT_CVG_STRT',
               p_lookup_code    => p_dpnt_cvg_strt_dt_cd,
               p_effective_date => p_effective_date) then
          --
          -- raise error as does not exist as lookup
          --
          fnd_message.set_name('BEN','BEN_91308_INV_DPT_CV_ST_DT_CD');
          fnd_message.raise_error;
          --
        end if;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_cvg_strt_dt_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_cvg_end_dt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
--   dpnt_cvg_end_dt_cd Value of lookup code.
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
Procedure chk_dpnt_cvg_end_dt_cd(p_pgm_id                in number,
                            p_dpnt_cvg_end_dt_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_cvg_end_dt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dpnt_cvg_end_dt_cd
      <> nvl(ben_pgm_shd.g_old_rec.dpnt_cvg_end_dt_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if p_dpnt_cvg_end_dt_cd is not null then
        if hr_api.not_exists_in_hr_lookups
              (p_lookup_type    => 'BEN_DPNT_CVG_END',
               p_lookup_code    => p_dpnt_cvg_end_dt_cd,
               p_effective_date => p_effective_date) then
          --
          -- raise error as does not exist as lookup
          --
          fnd_message.set_name('BEN','BEN_91309_INV_DPT_CV_EN_DT_CD');
          fnd_message.raise_error;
          --
        end if;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_cvg_end_dt_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_enrl_strt_dt_dpndcy >------|
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
--   pgm_id PK of record being inserted or updated.
--   enrt_cvg_strt_dt_cd Value of lookup code.
--   enrt_cvg_strt_dt_rl
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
Procedure chk_enrl_strt_dt_dpndcy
                           (p_pgm_id                in number,
                            p_enrt_cvg_strt_dt_cd   in varchar2,
                            p_enrt_cvg_strt_dt_rl   in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrl_strt_dt_dpndcy ';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id      => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and (nvl(p_enrt_cvg_strt_dt_cd,hr_api.g_varchar2)
         <> nvl(ben_pgm_shd.g_old_rec.enrt_cvg_strt_dt_cd,hr_api.g_varchar2) or
          nvl(p_enrt_cvg_strt_dt_rl,hr_api.g_number)
        <> nvl(ben_pgm_shd.g_old_rec.enrt_cvg_strt_dt_rl,hr_api.g_number))
      or not l_api_updating) then
    --
    if (p_enrt_cvg_strt_dt_cd = 'RL' and p_enrt_cvg_strt_dt_rl is null) then
             --
          fnd_message.set_name('BEN','BEN_91310_ENRT_STRT_CWOR');
          fnd_message.raise_error;
             --
    end if;
    --
    if nvl(p_enrt_cvg_strt_dt_cd,hr_api.g_varchar2) <> 'RL'
       and p_enrt_cvg_strt_dt_rl is not null then
             --
          fnd_message.set_name('BEN','BEN_91311_ENRT_STRT_RWOC');
          fnd_message.raise_error;
             --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enrl_strt_dt_dpndcy;
--
-- ----------------------------------------------------------------------------
-- |------< chk_enrl_end_dt_dpndcy >------|
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
--   pgm_id PK of record being inserted or updated.
--   enrt_cvg_end_dt_cd Value of lookup code.
--   enrt_cvg_end_dt_rl
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
Procedure chk_enrl_end_dt_dpndcy
                           (p_pgm_id                in number,
                            p_enrt_cvg_end_dt_cd   in varchar2,
                            p_enrt_cvg_end_dt_rl   in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrl_end_dt_dpndcy ';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id      => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and
         (nvl(p_enrt_cvg_end_dt_cd,hr_api.g_varchar2)
     <> nvl(ben_pgm_shd.g_old_rec.enrt_cvg_end_dt_cd,hr_api.g_varchar2) or
          nvl(p_enrt_cvg_end_dt_rl,hr_api.g_number)
          <> nvl(ben_pgm_shd.g_old_rec.enrt_cvg_end_dt_rl,hr_api.g_number))
      or not l_api_updating) then
    --
    if (p_enrt_cvg_end_dt_cd = 'RL' and p_enrt_cvg_end_dt_rl is null) then
             --
          fnd_message.set_name('BEN','BEN_91378_DFLT_DENRL_END_DT1');
          fnd_message.raise_error;
  --
    end if;
    --
    if nvl(p_enrt_cvg_end_dt_cd,hr_api.g_varchar2) <> 'RL'
       and p_enrt_cvg_end_dt_rl is not null then
             --
          fnd_message.set_name('BEN','BEN_91379_DFLT_DENRL_END_DT2');
          fnd_message.raise_error;
             --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enrl_end_dt_dpndcy;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_cvg_strt_dt_dpndcy >------|
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
--   lee_rsn_id PK of record being inserted or updated.
--   dpnt_cvg_strt_cd Value of lookup code.
--   dpnt_cvg_strt_rl
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
Procedure chk_dpnt_cvg_strt_dt_dpndcy(p_pgm_id                in number,
                            p_dpnt_cvg_strt_dt_cd             in varchar2,
                            p_dpnt_cvg_strt_dt_rl             in number,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_cvg_strt_dt_dpndcy ';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id      => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and
         (nvl(p_dpnt_cvg_strt_dt_cd,hr_api.g_varchar2)
        <> nvl(ben_pgm_shd.g_old_rec.dpnt_cvg_strt_dt_cd,hr_api.g_varchar2) or
          nvl(p_dpnt_cvg_strt_dt_rl,hr_api.g_number)
            <> nvl(ben_pgm_shd.g_old_rec.dpnt_cvg_strt_dt_rl,hr_api.g_number))
      or not l_api_updating) then
    --
    if (p_dpnt_cvg_strt_dt_cd = 'RL' and p_dpnt_cvg_strt_dt_rl is null) then
             --
             fnd_message.set_name('BEN','BEN_91380_DPNT_CVG_ST_DT_1');
             fnd_message.raise_error;
             --
    end if;
    --
    if nvl(p_dpnt_cvg_strt_dt_cd,hr_api.g_varchar2) <> 'RL' and p_dpnt_cvg_strt_dt_rl is not null then
             --
             fnd_message.set_name('BEN','BEN_91381_DPNT_CVG_ST_DT_2');
             fnd_message.raise_error;
             --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_cvg_strt_dt_dpndcy;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_cvg_end_dt_dpndcy >------|
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
--   lee_rsn_id PK of record being inserted or updated.
--   dpnt_cvg_end_dt_cd Value of lookup code.
--   dpnt_cvg_end_dt_rl
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
Procedure chk_dpnt_cvg_end_dt_dpndcy(p_pgm_id                in number,
                            p_dpnt_cvg_end_dt_cd             in varchar2,
                            p_dpnt_cvg_end_dt_rl             in number,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_cvg_end_dt_dpndcy ';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id      => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and
         (nvl(p_dpnt_cvg_end_dt_cd,hr_api.g_varchar2)
          <> nvl(ben_pgm_shd.g_old_rec.dpnt_cvg_end_dt_cd,hr_api.g_varchar2) or
          nvl(p_dpnt_cvg_end_dt_rl,hr_api.g_number)
               <> nvl(ben_pgm_shd.g_old_rec.dpnt_cvg_end_dt_rl,hr_api.g_number))
      or not l_api_updating) then
    --
    if (p_dpnt_cvg_end_dt_cd = 'RL' and p_dpnt_cvg_end_dt_rl is null) then
             --
             fnd_message.set_name('BEN','BEN_91352_DPNT_CVG_END_CD_NO_R');
             fnd_message.raise_error;
             --
    end if;
    --
    if nvl(p_dpnt_cvg_end_dt_cd,hr_api.g_varchar2) <> 'RL' and p_dpnt_cvg_end_dt_rl is not null then
             --
             fnd_message.set_name('BEN','BEN_91353_DPNT_CVG_END_R_NO_CD');
             fnd_message.raise_error;
             --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_cvg_end_dt_dpndcy;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_dsgn_cd_dpndcy >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   If dependent designation code is not 'Required' or 'Optional', then the
--   following must be null:  Dpnt Coverage Start Dt code and rule,
--   Dpnt Coverage End Dt code and rule, SSN req, Addr req, DOB req, Cert req
--   Meets One Req Flag, Derivable factors apply flag.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   lee_rsn_id PK of record being inserted or updated.
--   dpnt_dsgn_cd Value of lookup code.
--   dpnt_cvg_strt_dt_cd Value of lookup code.
--   dpnt_cvg_strt_dt_rl
--   dpnt_cvg_end_dt_cd Value of lookup code.
--   dpnt_cvg_end_dt_rl
--   dpnt_adrs_rqd_flag
--   dpnt_dob_rqd_flag
--   dpnt_legv_id_rqd_flag
--   dpnt_dsgn_no_ctfn_rqd_flag
--   drvbl_fctr_dpnt_elig_flag
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
Procedure chk_dpnt_dsgn_cd_dpndcy(p_pgm_id                in number,
                            p_dpnt_dsgn_cd                    in varchar2,
                            p_dpnt_cvg_strt_dt_cd             in varchar2,
                            p_dpnt_cvg_strt_dt_rl             in number,
                            p_dpnt_cvg_end_dt_cd             in varchar2,
                            p_dpnt_cvg_end_dt_rl             in number,
				    p_dpnt_adrs_rqd_flag           in varchar2,
 				    p_dpnt_dob_rqd_flag            in varchar2,
 				    p_dpnt_legv_id_rqd_flag        in varchar2,
				    p_dpnt_dsgn_no_ctfn_rqd_flag   in varchar2,
 				    p_drvbl_fctr_dpnt_elig_flag   in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_dsgn_cd_dpndcy ';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id      => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and
         (nvl(p_dpnt_cvg_end_dt_cd,hr_api.g_varchar2)
           <> nvl(ben_pgm_shd.g_old_rec.dpnt_cvg_end_dt_cd,hr_api.g_varchar2) or
          nvl(p_dpnt_cvg_end_dt_rl,hr_api.g_number)
           <> nvl(ben_pgm_shd.g_old_rec.dpnt_cvg_end_dt_rl,hr_api.g_number) or
          nvl(p_dpnt_dsgn_cd,hr_api.g_varchar2)
               <> nvl(ben_pgm_shd.g_old_rec.dpnt_dsgn_cd,hr_api.g_varchar2) or
          nvl(p_dpnt_cvg_strt_dt_cd,hr_api.g_varchar2)
          <> nvl(ben_pgm_shd.g_old_rec.dpnt_cvg_strt_dt_cd,hr_api.g_varchar2) or
          nvl(p_dpnt_cvg_strt_dt_rl,hr_api.g_number)
            <> nvl(ben_pgm_shd.g_old_rec.dpnt_cvg_strt_dt_rl,hr_api.g_number) or
          nvl(p_dpnt_adrs_rqd_flag,hr_api.g_varchar2)
           <> nvl(ben_pgm_shd.g_old_rec.dpnt_adrs_rqd_flag,hr_api.g_varchar2) or
          nvl(p_dpnt_dob_rqd_flag,hr_api.g_varchar2)
           <> nvl(ben_pgm_shd.g_old_rec.dpnt_dob_rqd_flag,hr_api.g_varchar2) or
          nvl(p_dpnt_legv_id_rqd_flag,hr_api.g_varchar2)
        <> nvl(ben_pgm_shd.g_old_rec.dpnt_legv_id_rqd_flag,hr_api.g_varchar2) or
          nvl(p_dpnt_dsgn_no_ctfn_rqd_flag,hr_api.g_varchar2)
   <> nvl(ben_pgm_shd.g_old_rec.dpnt_dsgn_no_ctfn_rqd_flag,hr_api.g_varchar2) or
          nvl(p_drvbl_fctr_dpnt_elig_flag,hr_api.g_varchar2)
   <> nvl(ben_pgm_shd.g_old_rec.drvbl_fctr_dpnt_elig_flag,hr_api.g_varchar2)) or
       not l_api_updating) then
    --
    if nvl(p_dpnt_dsgn_cd,'X') not in ('R','O') and
          (p_dpnt_cvg_strt_dt_cd is not null or
           p_dpnt_cvg_strt_dt_rl is not null or
           p_dpnt_cvg_end_dt_cd is not null or
           p_dpnt_cvg_end_dt_rl is not null or
           p_dpnt_adrs_rqd_flag = 'Y' or
           p_dpnt_dob_rqd_flag = 'Y' or
           p_dpnt_legv_id_rqd_flag = 'Y' or
           p_dpnt_dsgn_no_ctfn_rqd_flag = 'Y' or
           p_drvbl_fctr_dpnt_elig_flag = 'Y') then
             --
             fnd_message.set_name('BEN','BEN_91375_PGM_DPNT_DSGN_RQD');
             fnd_message.raise_error;
             --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_dsgn_cd_dpndcy;
--
/*
-- ----------------------------------------------------------------------------
-- |------< chk_pgm_prvds_no_auto_dpndcy >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   If Program Provides no Automatic Enrollment Flag = 'YES' then
--   Default Enrollment Method Code in BEN_PLIP_F cannot be 'Automatic'.
--
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
--	pgm_prvds_no_auto_enrt_flag
--    pgm_id
--    business_group_id
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
Procedure chk_pgm_prvds_no_auto_dpndcy
          (p_pgm_id                      in number,
	   p_pgm_prvds_no_auto_enrt_flag in varchar2,
           p_business_group_id           in number,
           p_effective_date              in date,
           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package || 'chk_pgm_prvds_no_auto_dpndcy';
  l_api_updating boolean;
  l_dummy varchar2(30);
  --
  cursor c1 is select null
                  from ben_plip_f cpp
                  where cpp.pgm_id = p_pgm_id
                    and dflt_enrt_mthd_cd = 'A'
                    and cpp.business_group_id +0 = p_business_group_id
                    and p_effective_date between cpp.effective_start_date
                                             and cpp.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                     => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --

 if (l_api_updating
      and nvl(p_pgm_prvds_no_auto_enrt_flag,hr_api.g_varchar2)
    <> nvl(ben_pgm_shd.g_old_rec.pgm_prvds_no_auto_enrt_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
  -- If pgm provides no auto enroll flag = 'Y' then enrt mthd code can't be 'A'.
    --
      open c1;
      fetch c1 into l_dummy;
      if c1%found then
          if p_pgm_prvds_no_auto_enrt_flag = 'Y' then
            --
            close c1;
            fnd_message.set_name('BEN','BEN_91372_PGM_PRVD_NO_AUTOENRL');
            fnd_message.raise_error;
            --
          end if;
          --
      end if;
      close c1;
  --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pgm_prvds_no_auto_dpndcy;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pgm_prvds_no_dflt_dpndcy >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   If Program Provides no Default Enrollment Flag = 'YES' then
--   the following fields from ben_plip_f must be null:  Default Flag,
--   Default Enrollment Method Code, and Default Enrollment Determination
--   Rule.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
--	pgm_prvds_no_dflt_enrt_flag
--    pgm_id
--    business_group_id
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
Procedure chk_pgm_prvds_no_dflt_dpndcy(p_pgm_id                      in number,
					   p_pgm_prvds_no_dflt_enrt_flag           in varchar2,
                                 p_business_group_id           in number,
                                 p_effective_date              in date,
                                 p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package || 'chk_pgm_prvds_no_dflt_dpndcy';
  l_api_updating boolean;
  l_dummy varchar2(30);
  --
  cursor c1 is select null
                  from ben_plip_f cpp
                  where cpp.pgm_id = p_pgm_id
                    and (cpp.dflt_enrt_mthd_cd is not null or
                         cpp.dflt_enrt_det_rl is not null or
                         dflt_flag = 'Y')
                    and cpp.business_group_id +0 = p_business_group_id
                    and p_effective_date between cpp.effective_start_date
                                             and cpp.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                     => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --

 if (l_api_updating
      and nvl(p_pgm_prvds_no_dflt_enrt_flag,hr_api.g_varchar2)
    <> nvl(ben_pgm_shd.g_old_rec.pgm_prvds_no_dflt_enrt_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- If pgm provides no dflt enroll flag = 'Y' dflt fields must be null.
    --
      open c1;
      fetch c1 into l_dummy;
      if c1%found then
          --
          if p_pgm_prvds_no_dflt_enrt_flag = 'Y' then
            --
            close c1;
            fnd_message.set_name('BEN','BEN_91373_PRVD_NO_DFLT_ENRL_2');
            fnd_message.raise_error;
            --
          end if;
          --
      end if;
      close c1;
  --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pgm_prvds_no_dflt_dpndcy;
--
*/
-- ----------------------------------------------------------------------------
-- |------< chk_pgm_prvds_no_dflt_dpndcy2 >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   If Program Provides no Default Enrollment Flag = 'YES' then
--   days after event to default number from ben_lee_rsn_f must be null.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
--	pgm_prvds_no_dflt_enrt_flag
--    pgm_id
--    business_group_id
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
Procedure chk_pgm_prvds_no_dflt_dpndcy2
             (p_pgm_id                      in number,
              p_pgm_prvds_no_dflt_enrt_flag in varchar2,
              p_business_group_id           in number,
              p_effective_date              in date,
              p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package || 'chk_pgm_prvds_no_dflt_dpndcy2';
  l_api_updating boolean;
  l_dummy varchar2(30);
  --
  cursor c1 is select null
                  from ben_lee_rsn_f len,
                       ben_popl_enrt_typ_cycl_f pet
                  where pet.pgm_id = p_pgm_id
                    and len.popl_enrt_typ_cycl_id = pet.popl_enrt_typ_cycl_id
                    and pet.business_group_id +0 = p_business_group_id
                    and len.business_group_id +0 = p_business_group_id
                    and p_effective_date between pet.effective_start_date
                                             and pet.effective_end_date
                    and p_effective_date between len.effective_start_date
                                             and len.effective_end_date
                    and len.dys_aftr_end_to_dflt_num is not null;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                     => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --

  if (l_api_updating
      and nvl(p_pgm_prvds_no_dflt_enrt_flag,hr_api.g_varchar2)
    <> nvl(ben_pgm_shd.g_old_rec.pgm_prvds_no_dflt_enrt_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- If cursor is found then at least one dflt num was found.
    --
      open c1;
      fetch c1 into l_dummy;
      if c1%found then
        if p_pgm_prvds_no_dflt_enrt_flag = 'Y' then
            --
            close c1;
            fnd_message.set_name('BEN','BEN_91374_PRVD_NO_DFLT_ENRL_1');
            fnd_message.raise_error;
            --
          end if;
          --
      end if;
      close c1;
  --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pgm_prvds_no_dflt_dpndcy2;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_dsgn_lvl_cd_dpndcy >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   If dependent designation level is not 'Program' the following fields
--   must be null:  Dpnt Designation, Dpnt Coverage Start Dt code and rule,
--   Dpnt Coverage End Dt code and rule, SSN req, Addr req, DOB req, Cert req
--   Meets One Req Flag, Derivable factors apply flag.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   lee_rsn_id PK of record being inserted or updated.
--   dpnt_dsgn_lvl_cd Value of lookup code.
--   dpnt_dsgn_cd Value of lookup code.
--   dpnt_cvg_strt_dt_cd Value of lookup code.
--   dpnt_cvg_strt_dt_rl
--   dpnt_cvg_end_dt_cd Value of lookup code.
--   dpnt_cvg_end_dt_rl
--   dpnt_adrs_rqd_flag
--   dpnt_dob_rqd_flag
--   dpnt_legv_id_rqd_flag
--   dpnt_dsgn_no_ctfn_rqd_flag
--   drvbl_fctr_dpnt_elig_flag
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
Procedure chk_dpnt_dsgn_lvl_cd_dpndcy(p_pgm_id                in number,
                            p_dpnt_dsgn_lvl_cd                in varchar2,
                            p_dpnt_dsgn_cd                    in varchar2,
                            p_dpnt_cvg_strt_dt_cd             in varchar2,
                            p_dpnt_cvg_strt_dt_rl             in number,
                            p_dpnt_cvg_end_dt_cd             in varchar2,
                            p_dpnt_cvg_end_dt_rl             in number,
			    p_dpnt_adrs_rqd_flag           in varchar2,
 			    p_dpnt_dob_rqd_flag            in varchar2,
 			    p_dpnt_legv_id_rqd_flag        in varchar2,
			    p_dpnt_dsgn_no_ctfn_rqd_flag   in varchar2,
 			    p_drvbl_fctr_dpnt_elig_flag   in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_dsgn_lvl_cd_dpndcy ';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id      => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and
         (nvl(p_dpnt_cvg_end_dt_cd,hr_api.g_varchar2)
           <> nvl(ben_pgm_shd.g_old_rec.dpnt_cvg_end_dt_cd,hr_api.g_varchar2) or
          nvl(p_dpnt_cvg_end_dt_rl,hr_api.g_number)
            <> nvl(ben_pgm_shd.g_old_rec.dpnt_cvg_end_dt_rl,hr_api.g_number) or
          nvl(p_dpnt_dsgn_cd,hr_api.g_varchar2)
               <> nvl(ben_pgm_shd.g_old_rec.dpnt_dsgn_cd,hr_api.g_varchar2) or
          nvl(p_dpnt_dsgn_lvl_cd,hr_api.g_varchar2)
            <> nvl(ben_pgm_shd.g_old_rec.dpnt_dsgn_lvl_cd,hr_api.g_varchar2) or
          nvl(p_dpnt_cvg_strt_dt_cd,hr_api.g_varchar2)
          <> nvl(ben_pgm_shd.g_old_rec.dpnt_cvg_strt_dt_cd,hr_api.g_varchar2) or
          nvl(p_dpnt_cvg_strt_dt_rl,hr_api.g_number)
            <> nvl(ben_pgm_shd.g_old_rec.dpnt_cvg_strt_dt_rl,hr_api.g_number) or
          nvl(p_dpnt_adrs_rqd_flag ,hr_api.g_varchar2)
          <> nvl(ben_pgm_shd.g_old_rec.dpnt_adrs_rqd_flag ,hr_api.g_varchar2) or
          nvl(p_dpnt_dob_rqd_flag ,hr_api.g_varchar2)
           <> nvl(ben_pgm_shd.g_old_rec.dpnt_dob_rqd_flag ,hr_api.g_varchar2) or
          nvl(p_dpnt_legv_id_rqd_flag,hr_api.g_varchar2)
       <> nvl(ben_pgm_shd.g_old_rec.dpnt_legv_id_rqd_flag,hr_api.g_varchar2) or
          nvl(p_dpnt_dsgn_no_ctfn_rqd_flag,hr_api.g_varchar2)
   <> nvl(ben_pgm_shd.g_old_rec.dpnt_dsgn_no_ctfn_rqd_flag,hr_api.g_varchar2) or
          nvl(p_drvbl_fctr_dpnt_elig_flag,hr_api.g_varchar2)
    <> nvl(ben_pgm_shd.g_old_rec.drvbl_fctr_dpnt_elig_flag,hr_api.g_varchar2) or
       not l_api_updating)) then
    --
    if nvl(p_dpnt_dsgn_lvl_cd,'X') not in ('PGM') and
          (p_dpnt_dsgn_cd is not null or
           p_dpnt_cvg_strt_dt_cd is not null or
           p_dpnt_cvg_strt_dt_rl is not null or
           p_dpnt_cvg_end_dt_cd is not null or
           p_dpnt_cvg_end_dt_rl is not null or
           p_dpnt_adrs_rqd_flag = 'Y' or
           p_dpnt_dob_rqd_flag = 'Y' or
           p_dpnt_legv_id_rqd_flag = 'Y' or
           p_dpnt_dsgn_no_ctfn_rqd_flag = 'Y' or
           p_drvbl_fctr_dpnt_elig_flag = 'Y') then
             --
             if p_dpnt_dsgn_lvl_cd is null then
               fnd_message.set_name('BEN','BEN_91400_PGM_DSGN_LVL_RQD');
               fnd_message.raise_error;
             else
               fnd_message.set_name('BEN','BEN_91401_INV_DSGN_LVL_PGM');
               fnd_message.raise_error;
             end if;
             --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_dsgn_lvl_cd_dpndcy;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_dsgn_cd_detail >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   If dependent designation level is null then the following tables must
--   contain no records for that program:  BEN_LER_CHG_DPNT_CVG_F,
--   BEN_APLD_DPNT_CVG_ELIG_PRFL_F, BEN_PGM_DPNT_CVG_CTFN_F.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
--   dpnt_dsgn_cd Value of lookup code.
--    pgm_id
--    business_group_id
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
Procedure chk_dpnt_dsgn_cd_detail(p_pgm_id                in number,
                                 p_dpnt_dsgn_cd                in varchar2,
                                 p_business_group_id           in number,
                                 p_effective_date              in date,
                                 p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package || 'chk_dpnt_dsgn_cd_detail';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
  cursor c1 is select 'x'
                  from ben_ler_chg_dpnt_cvg_f ldc
                  where ldc.pgm_id = p_pgm_id
                    and ldc.business_group_id + 0 = p_business_group_id
                    and p_effective_date between ldc.effective_start_date
                                             and ldc.effective_end_date;
  --
  cursor c2 is select 'x'
                  from ben_apld_dpnt_cvg_elig_prfl_f ade
                  where ade.pgm_id = p_pgm_id
                    and ade.business_group_id + 0 = p_business_group_id
                    and p_effective_date between ade.effective_start_date
                                             and ade.effective_end_date;
  --
  cursor c3 is select 'x'
                  from ben_pgm_dpnt_cvg_ctfn_f pgc
                  where pgc.pgm_id = p_pgm_id
                    and pgc.business_group_id + 0 = p_business_group_id
                    and p_effective_date between pgc.effective_start_date
                                             and pgc.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                     => p_pgm_id,
     p_effective_date             => p_effective_date,
     p_object_version_number      => p_object_version_number);
  --

 if (l_api_updating
      and nvl(p_dpnt_dsgn_cd,hr_api.g_varchar2)
               <> nvl(ben_pgm_shd.g_old_rec.dpnt_dsgn_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    null;
    --
    -- If ldc records exists and designation is null then error
    --
    if (p_dpnt_dsgn_cd is null) then
      open c1;
      fetch c1 into l_dummy;
      if c1%found then
         --
         close c1;
         fnd_message.set_name('BEN','BEN_92519_DELETE_LDC1');
         fnd_message.raise_error;
         --
      else
        close c1;
      end if;
          --
    end if;
    --close c1;
    --
    -- If ade records exists and designation is null then error
    --
    if (p_dpnt_dsgn_cd is null) then
      open c2;
      fetch c2 into l_dummy;
      if c2%found then
         --
         close c2;
         fnd_message.set_name('BEN','BEN_92520_DELETE_ADE1');
         fnd_message.raise_error;
         --
      else
         close c2;
      end if;
       --
    end if;
    --close c2;
    --
    -- If pgc records exists and designation is null then error
    --
    if (p_dpnt_dsgn_cd is null) then
      open c3;
      fetch c3 into l_dummy;
      if c3%found then
         --
         close c3;
         fnd_message.set_name('BEN','BEN_92521_DELETE_PGC');
         fnd_message.raise_error;
         --
      else
        close c3;
      end if;
      --
    end if;
    --close c3;
    --
  --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_dsgn_cd_detail;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_dsgn_lvl_cd_dpndcy2 >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   If dependent designation level is not 'Program' the following tables must
--   contain no records for that program:  BEN_LER_CHG_DPNT_CVG_F,
--   BEN_APLD_DPNT_CVG_ELIG_PRFL_F, BEN_PGM_DPNT_CVG_CTFN_F.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
--   dpnt_dsgn_lvl_cd Value of lookup code.
--    pgm_id
--    business_group_id
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
Procedure chk_dpnt_dsgn_lvl_cd_dpndcy2(p_pgm_id                      in number,
                                 p_dpnt_dsgn_lvl_cd                in varchar2,
                                 p_business_group_id           in number,
                                 p_effective_date              in date,
                                 p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package || 'chk_dpnt_dsgn_lvl_cd_dpndcy2';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
  cursor c1 is select null
                  from ben_ler_chg_dpnt_cvg_f ldc
                  where ldc.pgm_id = p_pgm_id
                    and ldc.business_group_id + 0 = p_business_group_id
                    and p_effective_date between ldc.effective_start_date
                                             and ldc.effective_end_date;
                    --
  cursor c2 is select null
                  from ben_apld_dpnt_cvg_elig_prfl_f ade
                  where ade.pgm_id = p_pgm_id
                    and ade.business_group_id + 0 = p_business_group_id
                    and p_effective_date between ade.effective_start_date
                                             and ade.effective_end_date;
  --
  cursor c3 is select 'x'
                  from ben_pgm_dpnt_cvg_ctfn_f pgc
                  where pgc.pgm_id = p_pgm_id
                    and pgc.business_group_id + 0 = p_business_group_id
                    and p_effective_date between pgc.effective_start_date
                                             and pgc.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                     => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --

 if (l_api_updating
      and nvl(p_dpnt_dsgn_lvl_cd,hr_api.g_varchar2)
               <> nvl(ben_pgm_shd.g_old_rec.dpnt_dsgn_lvl_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    null;
    --
    -- If ldc records exists and designation level not 'PGM' then error
    --
      open c1;
      fetch c1 into l_dummy;
      if c1%found then
          if nvl(p_dpnt_dsgn_lvl_cd,'X') not in ('PGM') then
            --
            close c1;
            fnd_message.set_name('BEN','BEN_91376_DSGN_LVL_PGM_LDC');
            fnd_message.raise_error;
            --
          end if;
          --
      end if;
      close c1;
    --
    -- If ade records exists and designation level not 'PGM' then error
    --
      open c2;
      fetch c2 into l_dummy;
      if c2%found then
          if nvl(p_dpnt_dsgn_lvl_cd,'X') not in ('PGM') then
            --
            close c2;
            fnd_message.set_name('BEN','BEN_91395_DSGN_LVL_PGM_ADE');
            fnd_message.raise_error;
            --
          end if;
          --
      end if;
      close c2;
    --
    -- If pgc records exists and designation level not 'PGM' then error
    --
      open c3;
      fetch c3 into l_dummy;
      if c3%notfound then
        null;
      else
          if nvl(p_dpnt_dsgn_lvl_cd,'X') not in ('PGM') then
            --
            close c3;
            fnd_message.set_name('BEN','BEN_91396_DSGN_LVL_PGM_PGC');
            fnd_message.raise_error;
            --
          end if;
          --
      end if;
      close c3;
    --
  --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_dsgn_lvl_cd_dpndcy2;
--
/*
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_dsgn_lvl_cd_dpndcy3 >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   If dependent designation level is not 'Plan Type' the following fields
--   from BEN_PTIP_F must be null:  Dpnt Designation, Cert req
--   Derivable factors apply flag.
--
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
--   dpnt_dsgn_lvl_cd Value of lookup code.
--    pgm_id
--    business_group_id
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
Procedure chk_dpnt_dsgn_lvl_cd_dpndcy3(p_pgm_id                      in number,
                                 p_dpnt_dsgn_lvl_cd                in varchar2,
                                 p_business_group_id           in number,
                                 p_effective_date              in date,
                                 p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package || 'chk_dpnt_dsgn_lvl_cd_dpndcy3';
  l_api_updating boolean;
  l_dummy varchar2(30);
  --
  cursor c1 is select null
                  from ben_ptip_f ctp
                  where ctp.pgm_id = p_pgm_id
                    and (ctp.dpnt_dsgn_cd is not null or
                         ctp.drvd_fctr_dpnt_cvg_flag = 'Y' or
                         ctp.dpnt_dsgn_no_cvg_ctfn_rqd = 'Y')
                    and ctp.business_group_id + 0 = p_business_group_id
                    and p_effective_date between ctp.effective_start_date
                                             and ctp.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                     => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --

 if (l_api_updating
      and nvl(p_dpnt_dsgn_lvl_cd,hr_api.g_varchar2)
               <> nvl(ben_pgm_shd.g_old_rec.dpnt_dsgn_lvl_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- If dsgn_lvl not = PTIP and cursor found then error.
    --
    if nvl(p_dpnt_dsgn_lvl_cd,'X') not in ('PTIP') then
      open c1;
      fetch c1 into l_dummy;
      if c1%found then
        close c1;
         --
            fnd_message.set_name('BEN','BEN_91402_INV_DSGN_LVL_PT2');
            fnd_message.raise_error;
         --
      end if;
      close c1;
    end if;
  --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_dsgn_lvl_cd_dpndcy3;
--
*/
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_dsgn_lvl_cd_dpndcy4 >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   If dependent designation level is not 'Plan Type' the following tables must
--   contain no records for that plan type:  BEN_LER_CHG_DPNT_CVG_F,
--   BEN_APLD_DPNT_CVG_ELIG_PRFL_F, BEN_PTIP_DPNT_CVG_CTFN_F.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
--   dpnt_dsgn_lvl_cd Value of lookup code.
--    pgm_id
--    business_group_id
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
Procedure chk_dpnt_dsgn_lvl_cd_dpndcy4(p_pgm_id                      in number,
                                 p_dpnt_dsgn_lvl_cd                in varchar2,
                                 p_business_group_id           in number,
                                 p_effective_date              in date,
                                 p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package || 'chk_dpnt_dsgn_lvl_cd_dpndcy4';
  l_api_updating boolean;
  l_dummy varchar2(30);
  --
  cursor c1 is select null
                  from BEN_PTIP_F ctp,
                       BEN_LER_CHG_DPNT_CVG_F ldc
                  where ctp.pgm_id = p_pgm_id
                    and ctp.business_group_id +0 = p_business_group_id
                    and p_effective_date between ctp.effective_start_date
                                             and ctp.effective_end_date
                    and ldc.ptip_id = ctp.ptip_id
                    and ldc.business_group_id +0 = p_business_group_id
                    and p_effective_date between ldc.effective_start_date
                                             and ldc.effective_end_date;
  --
  cursor c2 is select null
                  from BEN_PTIP_F ctp,
                       BEN_APLD_DPNT_CVG_ELIG_PRFL_F ade
                  where ctp.pgm_id = p_pgm_id
                    and ctp.business_group_id +0 = p_business_group_id
                    and p_effective_date between ctp.effective_start_date
                                             and ctp.effective_end_date
                    and ade.ptip_id = ctp.ptip_id
                    and ade.business_group_id +0 = p_business_group_id
                    and p_effective_date between ade.effective_start_date
                                             and ade.effective_end_date;
  --
  cursor c3 is select null
                  from BEN_PTIP_F ctp,
                       BEN_PTIP_DPNT_CVG_CTFN_F pyd
                  where ctp.pgm_id = p_pgm_id
                    and ctp.business_group_id +0 = p_business_group_id
                    and p_effective_date between ctp.effective_start_date
                                             and ctp.effective_end_date
                    and pyd.ptip_id = ctp.ptip_id
                    and pyd.business_group_id +0 = p_business_group_id
                    and p_effective_date between pyd.effective_start_date
                                             and pyd.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                     => p_pgm_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --

 if (l_api_updating
      and nvl(p_dpnt_dsgn_lvl_cd,hr_api.g_varchar2)
               <> nvl(ben_pgm_shd.g_old_rec.dpnt_dsgn_lvl_cd,hr_api.g_varchar2)
      or not l_api_updating) then null;
    --
    -- If ldc records exists and designation level not 'PTIP' then error
    --
      open c1;
      fetch c1 into l_dummy;
      if c1%found then
          if nvl(p_dpnt_dsgn_lvl_cd,'X') not in ('PTIP') then
            --
            close c1;
            fnd_message.set_name('BEN','BEN_91397_DSGN_LVL_PTIP_LDC');
            fnd_message.raise_error;
            --
          end if;
          --
      end if;
      close c1;
    --
    -- If ade records exists and designation level not 'PTIP' then error
    --
      open c2;
      fetch c2 into l_dummy;
      if c2%found then
         if nvl(p_dpnt_dsgn_lvl_cd,'X') not in ('PTIP') then
            --
            close c2;
            fnd_message.set_name('BEN','BEN_91398_DSGN_LVL_PTIP_ADE');
            fnd_message.raise_error;
            --
          end if;
          --
      end if;
      close c2;
    --
    -- If pyd records exists and designation level not 'PTIP' then error
    --
      open c3;
      fetch c3 into l_dummy;
      if c3%found then
         if nvl(p_dpnt_dsgn_lvl_cd,'X') not in ('PTIP') then
            --
            close c3;
            fnd_message.set_name('BEN','BEN_91399_DSGN_LVL_PTIP_PYD');
            fnd_message.raise_error;
            --
          end if;
          --
      end if;
      close c3;
    --
  --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_dsgn_lvl_cd_dpndcy4;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_enrt_cd_gsp >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to ensure that lookup codes PQH_GSP_GP,
--   PQH_GSP_GSP, PQH_GSP_NP, PQH_GSP_SP  are used only for Grade Step.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
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
Procedure chk_enrt_cd_gsp
		     (p_pgm_id                in number,
		      p_pgm_typ_cd	      in varchar2,
                      p_enrt_cd               in varchar2,
                      p_effective_date        in date,
                      p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_cd_gsp';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  l_api_updating := ben_pgm_shd.api_updating
    (p_pgm_id                => p_pgm_id,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
      and (
      p_enrt_cd <> nvl(ben_pgm_shd.g_old_rec.enrt_cd,hr_api.g_varchar2)
      or p_pgm_typ_cd <> nvl(ben_pgm_shd.g_old_rec.pgm_typ_cd,hr_api.g_varchar2)
      )
      or not l_api_updating)
      and p_enrt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if (p_pgm_typ_cd <> 'GSP'
       and p_enrt_cd in ('PQH_GSP_GP', 'PQH_GSP_GSP', 'PQH_GSP_NP', 'PQH_GSP_SP')
       ) then
      --
      -- raise error as does not exist as lookup
      --
      --fnd_message.set_name('BEN','BEN_91950_INVALID_ENRT_CD');
      fnd_message.set_name('BEN','BEN_93529_GSP_ENRT_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enrt_cd_gsp;
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
            (p_dpnt_cvg_strt_dt_rl           in number default hr_api.g_number,
             p_dpnt_cvg_end_dt_rl           in number default hr_api.g_number,
	     p_datetrack_mode		     in varchar2,
             p_enrt_cvg_strt_dt_rl           in number,
             p_enrt_cvg_end_dt_rl            in number,
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

    If ((nvl(p_enrt_cvg_end_dt_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_enrt_cvg_end_dt_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_enrt_cvg_strt_dt_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_enrt_cvg_strt_dt_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_dpnt_cvg_strt_dt_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_dpnt_cvg_strt_dt_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_dpnt_cvg_end_dt_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_dpnt_cvg_end_dt_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
/*
    If ((nvl(p_prtn_end_dt_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_prtn_end_dt_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_prtn_strt_dt_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_prtn_strt_dt_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
*/
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
            (p_pgm_id		in number,
             p_datetrack_mode		in varchar2,
	     p_validation_start_date	in date,
	     p_validation_end_date	in date) Is
--
  l_proc	varchar2(72) 	:= g_package||'dt_delete_validate';
  l_rows_exist	Exception;
  l_table_name	all_tables.table_name%TYPE;
--
  l_val number;
--
  Cursor c_yr_perd_exists(p_pgm_id in number ) Is
    select 1
    from   ben_popl_yr_perd t
    where  t.pl_id       = p_pgm_id ;
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
       p_argument       => 'pgm_id',
       p_argument_value => p_pgm_id);
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_ptip_f',
           p_base_key_column => 'pgm_id',
           p_base_key_value  => p_pgm_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_ptip_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_popl_enrt_typ_cycl_f',
           p_base_key_column => 'pgm_id',
           p_base_key_value  => p_pgm_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_popl_enrt_typ_cycl_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_plip_f',
           p_base_key_column => 'pgm_id',
           p_base_key_value  => p_pgm_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_plip_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_prtn_elig_f',
           p_base_key_column => 'pgm_id',
           p_base_key_value  => p_pgm_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_prtn_elig_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_elig_to_prte_rsn_f',
           p_base_key_column => 'pgm_id',
           p_base_key_value  => p_pgm_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_elig_to_prte_rsn_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_ler_chg_dpnt_cvg_f',
           p_base_key_column => 'pgm_id',
           p_base_key_value  => p_pgm_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_ler_chg_dpnt_cvg_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_popl_org_f',
           p_base_key_column => 'pgm_id',
           p_base_key_value  => p_pgm_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_popl_org_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_elig_per_f',
           p_base_key_column => 'pgm_id',
           p_base_key_value  => p_pgm_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_elig_per_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_acty_base_rt_f',
           p_base_key_column => 'pgm_id',
           p_base_key_value  => p_pgm_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_acty_base_rt_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_pgm_dpnt_cvg_ctfn_f',
           p_base_key_column => 'pgm_id',
           p_base_key_value  => p_pgm_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_pgm_dpnt_cvg_ctfn_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_apld_dpnt_cvg_elig_prfl_f',
           p_base_key_column => 'pgm_id',
           p_base_key_value  => p_pgm_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_apld_dpnt_cvg_elig_prfl_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_popl_rptg_grp_f',
           p_base_key_column => 'pgm_id',
           p_base_key_value  => p_pgm_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_popl_rptg_grp_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_bnft_prvdr_pool_f',
           p_base_key_column => 'pgm_id',
           p_base_key_value  => p_pgm_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_bnft_prvdr_pool_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_drvbl_fctr_uom',
           p_base_key_column => 'pgm_id',
           p_base_key_value  => p_pgm_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_drvbl_fctr_uom';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_elig_cbr_quald_bnf_f',
           p_base_key_column => 'pgm_id',
           p_base_key_value  => p_pgm_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_elig_cbr_quald_bnf_f';
      Raise l_rows_exist;
    End If;
/*
hr_utility.set_location('!!!!!  18', 5);
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_elig_per_elctbl_chc',
           p_base_key_column => 'pgm_id',
           p_base_key_value  => p_pgm_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_elig_per_elctbl_chc';
      Raise l_rows_exist;
    End If;
hr_utility.set_location('!!!!!  19', 5);

    If (dt_api.rows_exist   -- Uncommented, Bug 4339842
          (p_base_table_name => 'ben_popl_yr_perd',
           p_base_key_column => 'pgm_id',
           p_base_key_value  => p_pgm_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_popl_yr_perd';
      Raise l_rows_exist;
    End If;
*/
    open c_yr_perd_exists(p_pgm_id );
    fetch c_yr_perd_exists into l_val ;
    if c_yr_perd_exists%found
    then
       close c_yr_perd_exists;
       l_table_name := 'ben_popl_yr_perd';
       Raise l_rows_exist;
    end if;
    close c_yr_perd_exists;
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
	(p_rec 			 in ben_pgm_shd.g_rec_type,
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
  chk_pgm_id
     (p_pgm_id  => p_rec.pgm_id,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cvg_end_dt_rl
     (p_pgm_id  => p_rec.pgm_id,
      p_enrt_cvg_end_dt_rl => p_rec.enrt_cvg_end_dt_rl,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number,
      p_business_group_id => p_rec.business_group_id);
  --
  chk_enrt_cvg_strt_dt_rl
     (p_pgm_id  => p_rec.pgm_id,
      p_enrt_cvg_strt_dt_rl => p_rec.enrt_cvg_strt_dt_rl,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number,
      p_business_group_id => p_rec.business_group_id);
  --
  chk_dpnt_cvg_strt_dt_rl
     (p_pgm_id  => p_rec.pgm_id,
      p_dpnt_cvg_strt_dt_rl => p_rec.dpnt_cvg_strt_dt_rl,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number,
      p_business_group_id => p_rec.business_group_id);
  --
  chk_rt_end_dt_rl
     (p_pgm_id                => p_rec.pgm_id,
      p_rt_end_dt_rl          => p_rec.rt_end_dt_rl,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_rec.object_version_number,
      p_business_group_id     => p_rec.business_group_id);
  --

  chk_cd_rl_combination
    (p_vrfy_fmly_mmbr_cd        => p_rec.vrfy_fmly_mmbr_cd,
     p_vrfy_fmly_mmbr_rl        => p_rec.vrfy_fmly_mmbr_rl);
--
  chk_rt_strt_dt_rl
     (p_pgm_id                => p_rec.pgm_id,
      p_rt_strt_dt_rl         => p_rec.rt_strt_dt_rl,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_rec.object_version_number,
      p_business_group_id     => p_rec.business_group_id);
  --
  chk_dpnt_cvg_end_dt_rl
     (p_pgm_id  => p_rec.pgm_id,
      p_dpnt_cvg_end_dt_rl => p_rec.dpnt_cvg_end_dt_rl,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number,
      p_business_group_id => p_rec.business_group_id);
  --
/*
  chk_prtn_end_dt_rl
     (p_pgm_id  => p_rec.pgm_id,
      p_prtn_end_dt_rl => p_rec.prtn_end_dt_rl,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number,
      p_business_group_id => p_rec.business_group_id);
  --
  chk_prtn_strt_dt_rl
     (p_pgm_id  => p_rec.pgm_id,
      p_prtn_strt_dt_rl => p_rec.prtn_strt_dt_rl,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number,
      p_business_group_id => p_rec.business_group_id);
*/
  --
  chk_dpnt_adrs_rqd_flag
     (p_pgm_id  => p_rec.pgm_id,
      p_dpnt_adrs_rqd_flag => p_rec.dpnt_adrs_rqd_flag,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
/*
  chk_elig_apls_to_all_pls_flag
      (p_pgm_id  => p_rec.pgm_id,
      p_elig_apls_to_all_pls_flag => p_rec.elig_apls_to_all_pls_flag,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
*/
  --
  chk_dpnt_dob_rqd_flag
      (p_pgm_id  => p_rec.pgm_id,
      p_dpnt_dob_rqd_flag => p_rec.dpnt_dob_rqd_flag,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_pgm_prvd_no_auto_enrt_flag
      (p_pgm_id  => p_rec.pgm_id,
      p_pgm_prvds_no_auto_enrt_flag  => p_rec.pgm_prvds_no_auto_enrt_flag,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_pgm_prvd_no_dflt_enrt_flag
      (p_pgm_id  => p_rec.pgm_id,
      p_pgm_prvds_no_dflt_enrt_flag => p_rec.pgm_prvds_no_dflt_enrt_flag,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_legv_id_rqd_flag
      (p_pgm_id  => p_rec.pgm_id,
      p_dpnt_legv_id_rqd_flag  => p_rec.dpnt_legv_id_rqd_flag,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_elig_apls_flag
      (p_pgm_id  => p_rec.pgm_id,
      p_elig_apls_flag => p_rec.elig_apls_flag,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_uses_all_asmts_for_rts_fla
      (p_pgm_id  => p_rec.pgm_id,
      p_uses_all_asmts_for_rts_flag => p_rec.uses_all_asmts_for_rts_flag,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_prtn_elig_ovrid_alwd_flag
      (p_pgm_id  => p_rec.pgm_id,
      p_prtn_elig_ovrid_alwd_flag  => p_rec.prtn_elig_ovrid_alwd_flag,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
/*
  chk_tmprl_fctr_apls_rts_flag
      (p_pgm_id  => p_rec.pgm_id,
      p_tmprl_fctr_apls_rts_flag => p_rec.tmprl_fctr_apls_rts_flag,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
*/
  --
  chk_pgm_use_all_asnt_elig_flag
      (p_pgm_id  => p_rec.pgm_id,
      p_pgm_use_all_asnts_elig_flag => p_rec.pgm_use_all_asnts_elig_flag,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_coord_cvg_for_all_pls_flg
      (p_pgm_id  => p_rec.pgm_id,
      p_coord_cvg_for_all_pls_flg => p_rec.coord_cvg_for_all_pls_flg,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_drvbl_fctr_dpnt_elig_flag
      (p_pgm_id  => p_rec.pgm_id,
      p_drvbl_fctr_dpnt_elig_flag => p_rec.drvbl_fctr_dpnt_elig_flag,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
/*
  chk_mt_one_dpnt_cvg_elig_flag
      (p_pgm_id  => p_rec.pgm_id,
      p_mt_one_dpnt_cvg_elig_flag  => p_rec.mt_one_dpnt_cvg_elig_flag,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
*/
  --
  chk_drvbl_fctr_prtn_elig_flag
      (p_pgm_id  => p_rec.pgm_id,
      p_drvbl_fctr_prtn_elig_flag => p_rec.drvbl_fctr_prtn_elig_flag,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_drvbl_fctr_apls_rts_flag
      (p_pgm_id  => p_rec.pgm_id,
      p_drvbl_fctr_apls_rts_flag => p_rec.drvbl_fctr_apls_rts_flag,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
/*
  chk_tmprl_fctr_dpnt_elig_flag
      (p_pgm_id  => p_rec.pgm_id,
      p_tmprl_fctr_dpnt_elig_flag => p_rec.tmprl_fctr_dpnt_elig_flag,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_tmprl_fctr_prtn_elig_flag
      (p_pgm_id  => p_rec.pgm_id,
      p_tmprl_fctr_prtn_elig_flag => p_rec.tmprl_fctr_prtn_elig_flag,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
*/
  --
  chk_dpnt_dsgn_no_ctfn_rqd_flag
      (p_pgm_id  => p_rec.pgm_id,
      p_dpnt_dsgn_no_ctfn_rqd_flag => p_rec.dpnt_dsgn_no_ctfn_rqd_flag,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_trk_inelig_per_flag
      (p_pgm_id  => p_rec.pgm_id,
      p_trk_inelig_per_flag => p_rec.trk_inelig_per_flag,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_vrfy_fmly_mmbr_cd(p_pgm_id => p_rec.pgm_id ,
                       p_vrfy_fmly_mmbr_cd => p_rec.vrfy_fmly_mmbr_cd ,
                       p_effective_date    => p_effective_date   ,
                       P_object_version_number =>p_rec.object_version_number);


  chk_vrfy_fmly_mmbr_rl
  (p_pgm_id   => p_rec.pgm_id,
   p_vrfy_fmly_mmbr_rl     => p_rec.vrfy_fmly_mmbr_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);


-----
  chk_pgm_stat_cd
     (p_pgm_id  => p_rec.pgm_id,
      p_pgm_stat_cd  => p_rec.pgm_stat_cd,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_dsgn_lvl_cd
      (p_pgm_id  => p_rec.pgm_id,
      p_dpnt_dsgn_lvl_cd => p_rec.dpnt_dsgn_lvl_cd,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_pgm_typ_cd
      (p_pgm_id  => p_rec.pgm_id,
      p_pgm_typ_cd  => p_rec.pgm_typ_cd,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_dsgn_cd
      (p_pgm_id  => p_rec.pgm_id,
      p_dpnt_dsgn_cd => p_rec.dpnt_dsgn_cd,
      p_dpnt_cvg_strt_dt_cd =>   p_rec.dpnt_cvg_strt_dt_cd,
      p_dpnt_cvg_end_dt_cd  =>   p_rec.dpnt_cvg_end_dt_cd,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_pgm_grp_cd
      (p_pgm_id  => p_rec.pgm_id,
      p_pgm_grp_cd => p_rec.pgm_grp_cd,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_acty_ref_perd_cd
      (p_pgm_id  => p_rec.pgm_id,
      p_acty_ref_perd_cd  => p_rec.acty_ref_perd_cd,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cvg_strt_dt_cd
      (p_pgm_id  => p_rec.pgm_id,
      p_enrt_cvg_strt_dt_cd => p_rec.enrt_cvg_strt_dt_cd,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cvg_end_dt_cd
      (p_pgm_id  => p_rec.pgm_id,
      p_enrt_cvg_end_dt_cd => p_rec.enrt_cvg_end_dt_cd,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
/*  chk_prtn_strt_dt_cd
      (p_pgm_id  => p_rec.pgm_id,
      p_prtn_strt_dt_cd => p_rec.prtn_strt_dt_cd,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_prtn_end_dt_cd
      (p_pgm_id  => p_rec.pgm_id,
      p_prtn_end_dt_cd => p_rec.prtn_end_dt_cd,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
*/
  --
  chk_pgm_uom
      (p_pgm_id  => p_rec.pgm_id,
      p_pgm_uom  => p_rec.pgm_uom,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_all_rules
      (p_pgm_id  => p_rec.pgm_id,
      p_business_group_id => p_rec.business_group_id,
      p_Dflt_step_rl => p_rec.Dflt_step_rl,
      p_Scores_calc_rl => p_rec.Scores_calc_rl,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_lookup_codes
      (p_pgm_id  => p_rec.pgm_id,
      p_Dflt_step_cd => p_rec.Dflt_step_cd,
      p_Update_salary_cd => p_rec.Update_salary_cd,
      p_Scores_calc_mthd_cd => p_rec.Scores_calc_mthd_cd,
      p_salary_calc_mthd_cd => p_rec.salary_calc_mthd_cd,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_info_rt_freq_cd
      (p_pgm_id  => p_rec.pgm_id,
      p_enrt_info_rt_freq_cd => p_rec.enrt_info_rt_freq_cd,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_cvg_strt_dt_cd
      (p_pgm_id  => p_rec.pgm_id,
      p_dpnt_cvg_strt_dt_cd  => p_rec.dpnt_cvg_strt_dt_cd,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_cvg_end_dt_cd
      (p_pgm_id  => p_rec.pgm_id,
      p_dpnt_cvg_end_dt_cd => p_rec.dpnt_cvg_end_dt_cd,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_name_unique
     (p_pgm_id  => p_rec.pgm_id,
      p_name  => p_rec.name,
      p_business_group_id   => p_rec.business_group_id);
  --
  /*  temporarily comment out nocopy to get ty's stuff working!
  chk_eligibility_defined
     (p_pgm_id  => p_rec.pgm_id,
      p_elig_apls_flag  => p_rec.elig_apls_flag,
      p_effective_date => p_effective_date,
      p_business_group_id   => p_rec.business_group_id);
 */
  --
  chk_enrl_strt_dt_dpndcy
     (p_pgm_id  => p_rec.pgm_id,
      p_enrt_cvg_strt_dt_cd  => p_rec.enrt_cvg_strt_dt_cd,
      p_enrt_cvg_strt_dt_rl => p_rec.enrt_cvg_strt_dt_rl,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_enrl_end_dt_dpndcy
     (p_pgm_id  => p_rec.pgm_id,
      p_enrt_cvg_end_dt_cd  => p_rec.enrt_cvg_end_dt_cd,
      p_enrt_cvg_end_dt_rl => p_rec.enrt_cvg_end_dt_rl,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_cvg_strt_dt_dpndcy
     (p_pgm_id  => p_rec.pgm_id,
      p_dpnt_cvg_strt_dt_cd  => p_rec.dpnt_cvg_strt_dt_cd,
      p_dpnt_cvg_strt_dt_rl => p_rec.dpnt_cvg_strt_dt_rl,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_cvg_end_dt_dpndcy
     (p_pgm_id  => p_rec.pgm_id,
      p_dpnt_cvg_end_dt_cd  => p_rec.dpnt_cvg_end_dt_cd,
      p_dpnt_cvg_end_dt_rl => p_rec.dpnt_cvg_end_dt_rl,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_dsgn_cd_dpndcy
     (p_pgm_id  => p_rec.pgm_id,
      p_dpnt_dsgn_cd => p_rec.dpnt_dsgn_cd,
      p_dpnt_cvg_strt_dt_cd  => p_rec.dpnt_cvg_strt_dt_cd,
      p_dpnt_cvg_strt_dt_rl => p_rec.dpnt_cvg_strt_dt_rl,
      p_dpnt_cvg_end_dt_cd  => p_rec.dpnt_cvg_end_dt_cd,
      p_dpnt_cvg_end_dt_rl => p_rec.dpnt_cvg_end_dt_rl,
      p_dpnt_adrs_rqd_flag => p_rec.dpnt_adrs_rqd_flag,
      p_dpnt_dob_rqd_flag => p_rec.dpnt_dob_rqd_flag,
      p_dpnt_legv_id_rqd_flag => p_rec.dpnt_legv_id_rqd_flag,
      p_dpnt_dsgn_no_ctfn_rqd_flag  => p_rec.dpnt_dsgn_no_ctfn_rqd_flag,
      p_drvbl_fctr_dpnt_elig_flag   => p_rec.drvbl_fctr_dpnt_elig_flag,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
/*
  chk_pgm_prvds_no_auto_dpndcy
     (p_pgm_id  => p_rec.pgm_id,
      p_pgm_prvds_no_auto_enrt_flag  => p_rec.pgm_prvds_no_auto_enrt_flag,
      p_business_group_id   => p_rec.business_group_id,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_pgm_prvds_no_dflt_dpndcy
     (p_pgm_id  => p_rec.pgm_id,
      p_pgm_prvds_no_dflt_enrt_flag  => p_rec.pgm_prvds_no_dflt_enrt_flag,
      p_business_group_id   => p_rec.business_group_id,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
*/
  --
  chk_pgm_prvds_no_dflt_dpndcy2
     (p_pgm_id  => p_rec.pgm_id,
      p_pgm_prvds_no_dflt_enrt_flag  => p_rec.pgm_prvds_no_dflt_enrt_flag,
      p_business_group_id   => p_rec.business_group_id,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_dsgn_lvl_cd_dpndcy
     (p_pgm_id  => p_rec.pgm_id,
      p_dpnt_dsgn_lvl_cd => p_rec.dpnt_dsgn_lvl_cd,
      p_dpnt_dsgn_cd => p_rec.dpnt_dsgn_cd,
      p_dpnt_cvg_strt_dt_cd  => p_rec.dpnt_cvg_strt_dt_cd,
      p_dpnt_cvg_strt_dt_rl => p_rec.dpnt_cvg_strt_dt_rl,
      p_dpnt_cvg_end_dt_cd  => p_rec.dpnt_cvg_end_dt_cd,
      p_dpnt_cvg_end_dt_rl => p_rec.dpnt_cvg_end_dt_rl,
      p_dpnt_adrs_rqd_flag => p_rec.dpnt_adrs_rqd_flag,
      p_dpnt_dob_rqd_flag => p_rec.dpnt_dob_rqd_flag,
      p_dpnt_legv_id_rqd_flag => p_rec.dpnt_legv_id_rqd_flag,
      p_dpnt_dsgn_no_ctfn_rqd_flag  => p_rec.dpnt_dsgn_no_ctfn_rqd_flag,
      p_drvbl_fctr_dpnt_elig_flag   => p_rec.drvbl_fctr_dpnt_elig_flag,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_dsgn_cd_detail
     (p_pgm_id  => p_rec.pgm_id,
      p_dpnt_dsgn_cd => p_rec.dpnt_dsgn_cd,
      p_business_group_id   => p_rec.business_group_id,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_dsgn_lvl_cd_dpndcy2
     (p_pgm_id  => p_rec.pgm_id,
      p_dpnt_dsgn_lvl_cd => p_rec.dpnt_dsgn_lvl_cd,
      p_business_group_id   => p_rec.business_group_id,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
/*
  chk_dpnt_dsgn_lvl_cd_dpndcy3
     (p_pgm_id  => p_rec.pgm_id,
      p_dpnt_dsgn_lvl_cd => p_rec.dpnt_dsgn_lvl_cd,
      p_business_group_id   => p_rec.business_group_id,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
*/
  --
  chk_dpnt_dsgn_lvl_cd_dpndcy4
     (p_pgm_id  => p_rec.pgm_id,
      p_dpnt_dsgn_lvl_cd => p_rec.dpnt_dsgn_lvl_cd,
      p_business_group_id   => p_rec.business_group_id,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_alws_unrstrctd_enrt_flag
      (p_pgm_id                   => p_rec.pgm_id,
       p_alws_unrstrctd_enrt_flag => p_rec.alws_unrstrctd_enrt_flag,
       p_effective_date           => p_effective_date,
       p_object_version_number    => p_rec.object_version_number);
  --
  chk_enrt_cd
     (p_pgm_id                 => p_rec.pgm_id,
      p_enrt_cd                => p_rec.enrt_cd,
      p_effective_date         => p_effective_date,
      p_object_version_number  => p_rec.object_version_number);
  --
  chk_enrt_mthd_cd
     (p_pgm_id                => p_rec.pgm_id,
      p_enrt_mthd_cd          => p_rec.enrt_mthd_cd,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_poe_lvl_cd
     (p_pgm_id                => p_rec.pgm_id,
      p_poe_lvl_cd            => p_rec.poe_lvl_cd,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_rl
     (p_pgm_id                => p_rec.pgm_id,
      p_enrt_rl               => p_rec.enrt_rl,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_rec.object_version_number,
      p_business_group_id     => p_rec.business_group_id);
  --
  chk_auto_enrt_mthd_rl
     (p_pgm_id                => p_rec.pgm_id,
      p_auto_enrt_mthd_rl     => p_rec.auto_enrt_mthd_rl,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_rec.object_version_number,
      p_business_group_id     => p_rec.business_group_id);
  --
  chk_enrt_cd_gsp
     (p_pgm_id                 => p_rec.pgm_id,
      p_pgm_typ_cd	       => p_rec.pgm_typ_cd,
      p_enrt_cd                => p_rec.enrt_cd,
      p_effective_date         => p_effective_date,
      p_object_version_number  => p_rec.object_version_number);

  --
  if p_rec.business_group_id is not null and p_rec.legislation_code is null then
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_pgm_shd.g_rec_type,
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
  if p_rec.business_group_id is not null and p_rec.legislation_code is null then
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  --
  chk_pgm_id
     (p_pgm_id  => p_rec.pgm_id,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cvg_end_dt_rl
     (p_pgm_id  => p_rec.pgm_id,
      p_enrt_cvg_end_dt_rl => p_rec.enrt_cvg_end_dt_rl,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number,
      p_business_group_id => p_rec.business_group_id);
  --
  chk_enrt_cvg_strt_dt_rl
     (p_pgm_id  => p_rec.pgm_id,
      p_enrt_cvg_strt_dt_rl => p_rec.enrt_cvg_strt_dt_rl,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number,
      p_business_group_id => p_rec.business_group_id);
  --
  chk_dpnt_cvg_strt_dt_rl
     (p_pgm_id  => p_rec.pgm_id,
      p_dpnt_cvg_strt_dt_rl => p_rec.dpnt_cvg_strt_dt_rl,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number,
      p_business_group_id => p_rec.business_group_id);
  --
  chk_rt_end_dt_rl
     (p_pgm_id                => p_rec.pgm_id,
      p_rt_end_dt_rl          => p_rec.rt_end_dt_rl,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_rec.object_version_number,
      p_business_group_id     => p_rec.business_group_id);
  --
  chk_rt_strt_dt_rl
     (p_pgm_id                => p_rec.pgm_id,
      p_rt_strt_dt_rl         => p_rec.rt_strt_dt_rl,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_rec.object_version_number,
      p_business_group_id     => p_rec.business_group_id);
  --

 chk_cd_rl_combination
  (p_vrfy_fmly_mmbr_cd        => p_rec.vrfy_fmly_mmbr_cd,
   p_vrfy_fmly_mmbr_rl        => p_rec.vrfy_fmly_mmbr_rl);
--
  chk_dpnt_cvg_end_dt_rl
     (p_pgm_id  => p_rec.pgm_id,
      p_dpnt_cvg_end_dt_rl => p_rec.dpnt_cvg_end_dt_rl,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number,
      p_business_group_id => p_rec.business_group_id);
  --
/*
  chk_prtn_end_dt_rl
     (p_pgm_id  => p_rec.pgm_id,
      p_prtn_end_dt_rl => p_rec.prtn_end_dt_rl,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number,
      p_business_group_id => p_rec.business_group_id);
  --
  chk_prtn_strt_dt_rl
     (p_pgm_id  => p_rec.pgm_id,
      p_prtn_strt_dt_rl => p_rec.prtn_strt_dt_rl,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number,
      p_business_group_id => p_rec.business_group_id);
*/
  --
  chk_dpnt_adrs_rqd_flag
  (p_pgm_id  => p_rec.pgm_id,
   p_dpnt_adrs_rqd_flag => p_rec.dpnt_adrs_rqd_flag,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
/*
  chk_elig_apls_to_all_pls_flag
   (p_pgm_id  => p_rec.pgm_id,
   p_elig_apls_to_all_pls_flag => p_rec.elig_apls_to_all_pls_flag,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
*/
  --
  chk_dpnt_dob_rqd_flag
   (p_pgm_id  => p_rec.pgm_id,
   p_dpnt_dob_rqd_flag => p_rec.dpnt_dob_rqd_flag,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pgm_prvd_no_auto_enrt_flag
   (p_pgm_id  => p_rec.pgm_id,
   p_pgm_prvds_no_auto_enrt_flag  => p_rec.pgm_prvds_no_auto_enrt_flag,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pgm_prvd_no_dflt_enrt_flag
   (p_pgm_id  => p_rec.pgm_id,
   p_pgm_prvds_no_dflt_enrt_flag => p_rec.pgm_prvds_no_dflt_enrt_flag,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_vrfy_fmly_mmbr_cd(p_pgm_id => p_rec.pgm_id ,
    p_vrfy_fmly_mmbr_cd => p_rec.vrfy_fmly_mmbr_cd ,
    p_effective_date    => p_effective_date   ,
    P_object_version_number =>p_rec.object_version_number);


 chk_vrfy_fmly_mmbr_rl
  (p_pgm_id   => p_rec.pgm_id,
   p_vrfy_fmly_mmbr_rl     => p_rec.vrfy_fmly_mmbr_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_legv_id_rqd_flag
   (p_pgm_id  => p_rec.pgm_id,
   p_dpnt_legv_id_rqd_flag  => p_rec.dpnt_legv_id_rqd_flag,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_elig_apls_flag
   (p_pgm_id  => p_rec.pgm_id,
   p_elig_apls_flag => p_rec.elig_apls_flag,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_uses_all_asmts_for_rts_fla
   (p_pgm_id  => p_rec.pgm_id,
   p_uses_all_asmts_for_rts_flag => p_rec.uses_all_asmts_for_rts_flag,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtn_elig_ovrid_alwd_flag
   (p_pgm_id  => p_rec.pgm_id,
   p_prtn_elig_ovrid_alwd_flag  => p_rec.prtn_elig_ovrid_alwd_flag,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
/*
  chk_tmprl_fctr_apls_rts_flag
   (p_pgm_id  => p_rec.pgm_id,
   p_tmprl_fctr_apls_rts_flag => p_rec.tmprl_fctr_apls_rts_flag,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
*/
  --
  chk_pgm_use_all_asnt_elig_flag
   (p_pgm_id  => p_rec.pgm_id,
   p_pgm_use_all_asnts_elig_flag => p_rec.pgm_use_all_asnts_elig_flag,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_coord_cvg_for_all_pls_flg
   (p_pgm_id  => p_rec.pgm_id,
   p_coord_cvg_for_all_pls_flg => p_rec.coord_cvg_for_all_pls_flg,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_drvbl_fctr_dpnt_elig_flag
   (p_pgm_id  => p_rec.pgm_id,
   p_drvbl_fctr_dpnt_elig_flag => p_rec.drvbl_fctr_dpnt_elig_flag,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
/*
  chk_mt_one_dpnt_cvg_elig_flag
   (p_pgm_id  => p_rec.pgm_id,
   p_mt_one_dpnt_cvg_elig_flag  => p_rec.mt_one_dpnt_cvg_elig_flag,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
*/
  --
  chk_drvbl_fctr_prtn_elig_flag
   (p_pgm_id  => p_rec.pgm_id,
   p_drvbl_fctr_prtn_elig_flag => p_rec.drvbl_fctr_prtn_elig_flag,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_drvbl_fctr_apls_rts_flag
   (p_pgm_id  => p_rec.pgm_id,
   p_drvbl_fctr_apls_rts_flag => p_rec.drvbl_fctr_apls_rts_flag,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
/*
  chk_tmprl_fctr_dpnt_elig_flag
   (p_pgm_id  => p_rec.pgm_id,
   p_tmprl_fctr_dpnt_elig_flag => p_rec.tmprl_fctr_dpnt_elig_flag,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_tmprl_fctr_prtn_elig_flag
   (p_pgm_id  => p_rec.pgm_id,
   p_tmprl_fctr_prtn_elig_flag => p_rec.tmprl_fctr_prtn_elig_flag,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
*/
  --
  chk_dpnt_dsgn_no_ctfn_rqd_flag
   (p_pgm_id  => p_rec.pgm_id,
   p_dpnt_dsgn_no_ctfn_rqd_flag => p_rec.dpnt_dsgn_no_ctfn_rqd_flag,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_trk_inelig_per_flag
   (p_pgm_id  => p_rec.pgm_id,
   p_trk_inelig_per_flag => p_rec.trk_inelig_per_flag,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pgm_stat_cd
  (p_pgm_id  => p_rec.pgm_id,
   p_pgm_stat_cd  => p_rec.pgm_stat_cd,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_dsgn_lvl_cd
   (p_pgm_id  => p_rec.pgm_id,
   p_dpnt_dsgn_lvl_cd => p_rec.dpnt_dsgn_lvl_cd,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pgm_typ_cd
   (p_pgm_id  => p_rec.pgm_id,
   p_pgm_typ_cd  => p_rec.pgm_typ_cd,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_dsgn_cd
   (p_pgm_id  => p_rec.pgm_id,
   p_dpnt_dsgn_cd => p_rec.dpnt_dsgn_cd,
   p_dpnt_cvg_strt_dt_cd =>   p_rec.dpnt_cvg_strt_dt_cd,
   p_dpnt_cvg_end_dt_cd  =>   p_rec.dpnt_cvg_end_dt_cd,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pgm_grp_cd
   (p_pgm_id  => p_rec.pgm_id,
   p_pgm_grp_cd => p_rec.pgm_grp_cd,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_acty_ref_perd_cd
   (p_pgm_id  => p_rec.pgm_id,
   p_acty_ref_perd_cd  => p_rec.acty_ref_perd_cd,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cvg_strt_dt_cd
   (p_pgm_id  => p_rec.pgm_id,
   p_enrt_cvg_strt_dt_cd => p_rec.enrt_cvg_strt_dt_cd,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cvg_end_dt_cd
   (p_pgm_id  => p_rec.pgm_id,
   p_enrt_cvg_end_dt_cd => p_rec.enrt_cvg_end_dt_cd,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
/*  chk_prtn_strt_dt_cd
   (p_pgm_id  => p_rec.pgm_id,
   p_prtn_strt_dt_cd => p_rec.prtn_strt_dt_cd,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtn_end_dt_cd
   (p_pgm_id  => p_rec.pgm_id,
   p_prtn_end_dt_cd => p_rec.prtn_end_dt_cd,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
*/
  --
  chk_pgm_uom
   (p_pgm_id  => p_rec.pgm_id,
   p_pgm_uom  => p_rec.pgm_uom,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_info_rt_freq_cd
   (p_pgm_id  => p_rec.pgm_id,
   p_enrt_info_rt_freq_cd => p_rec.enrt_info_rt_freq_cd,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_cvg_strt_dt_cd
   (p_pgm_id  => p_rec.pgm_id,
   p_dpnt_cvg_strt_dt_cd  => p_rec.dpnt_cvg_strt_dt_cd,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_cvg_end_dt_cd
   (p_pgm_id  => p_rec.pgm_id,
   p_dpnt_cvg_end_dt_cd => p_rec.dpnt_cvg_end_dt_cd,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_name_unique
  (p_pgm_id  => p_rec.pgm_id,
   p_name  => p_rec.name,
   p_business_group_id   => p_rec.business_group_id);
  --
  /*  temporarily comment out nocopy to get ty's stuff working!
  chk_eligibility_defined
  (p_pgm_id  => p_rec.pgm_id,
   p_elig_apls_flag  => p_rec.elig_apls_flag,
   p_effective_date => p_effective_date,
   p_business_group_id   => p_rec.business_group_id);
 */
  --
  chk_enrl_strt_dt_dpndcy
  (p_pgm_id  => p_rec.pgm_id,
   p_enrt_cvg_strt_dt_cd  => p_rec.enrt_cvg_strt_dt_cd,
   p_enrt_cvg_strt_dt_rl => p_rec.enrt_cvg_strt_dt_rl,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrl_end_dt_dpndcy
     (p_pgm_id  => p_rec.pgm_id,
      p_enrt_cvg_end_dt_cd  => p_rec.enrt_cvg_end_dt_cd,
      p_enrt_cvg_end_dt_rl => p_rec.enrt_cvg_end_dt_rl,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_cvg_strt_dt_dpndcy
  (p_pgm_id  => p_rec.pgm_id,
   p_dpnt_cvg_strt_dt_cd  => p_rec.dpnt_cvg_strt_dt_cd,
   p_dpnt_cvg_strt_dt_rl => p_rec.dpnt_cvg_strt_dt_rl,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_cvg_end_dt_dpndcy
  (p_pgm_id  => p_rec.pgm_id,
   p_dpnt_cvg_end_dt_cd  => p_rec.dpnt_cvg_end_dt_cd,
   p_dpnt_cvg_end_dt_rl => p_rec.dpnt_cvg_end_dt_rl,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_dsgn_cd_dpndcy
  (p_pgm_id  => p_rec.pgm_id,
   p_dpnt_dsgn_cd => p_rec.dpnt_dsgn_cd,
   p_dpnt_cvg_strt_dt_cd  => p_rec.dpnt_cvg_strt_dt_cd,
   p_dpnt_cvg_strt_dt_rl => p_rec.dpnt_cvg_strt_dt_rl,
   p_dpnt_cvg_end_dt_cd  => p_rec.dpnt_cvg_end_dt_cd,
   p_dpnt_cvg_end_dt_rl => p_rec.dpnt_cvg_end_dt_rl,
   p_dpnt_adrs_rqd_flag => p_rec.dpnt_adrs_rqd_flag,
   p_dpnt_dob_rqd_flag => p_rec.dpnt_dob_rqd_flag,
   p_dpnt_legv_id_rqd_flag => p_rec.dpnt_legv_id_rqd_flag,
   p_dpnt_dsgn_no_ctfn_rqd_flag  => p_rec.dpnt_dsgn_no_ctfn_rqd_flag,
   p_drvbl_fctr_dpnt_elig_flag   => p_rec.drvbl_fctr_dpnt_elig_flag,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
/*
  chk_pgm_prvds_no_auto_dpndcy
  (p_pgm_id  => p_rec.pgm_id,
   p_pgm_prvds_no_auto_enrt_flag  => p_rec.pgm_prvds_no_auto_enrt_flag,
   p_business_group_id   => p_rec.business_group_id,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pgm_prvds_no_dflt_dpndcy
  (p_pgm_id  => p_rec.pgm_id,
   p_pgm_prvds_no_dflt_enrt_flag  => p_rec.pgm_prvds_no_dflt_enrt_flag,
   p_business_group_id   => p_rec.business_group_id,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
*/
  --
  chk_pgm_prvds_no_dflt_dpndcy2
  (p_pgm_id  => p_rec.pgm_id,
   p_pgm_prvds_no_dflt_enrt_flag  => p_rec.pgm_prvds_no_dflt_enrt_flag,
   p_business_group_id   => p_rec.business_group_id,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_dsgn_lvl_cd_dpndcy
  (p_pgm_id  => p_rec.pgm_id,
   p_dpnt_dsgn_lvl_cd => p_rec.dpnt_dsgn_lvl_cd,
   p_dpnt_dsgn_cd => p_rec.dpnt_dsgn_cd,
   p_dpnt_cvg_strt_dt_cd  => p_rec.dpnt_cvg_strt_dt_cd,
   p_dpnt_cvg_strt_dt_rl => p_rec.dpnt_cvg_strt_dt_rl,
   p_dpnt_cvg_end_dt_cd  => p_rec.dpnt_cvg_end_dt_cd,
   p_dpnt_cvg_end_dt_rl => p_rec.dpnt_cvg_end_dt_rl,
   p_dpnt_adrs_rqd_flag => p_rec.dpnt_adrs_rqd_flag,
   p_dpnt_dob_rqd_flag => p_rec.dpnt_dob_rqd_flag,
   p_dpnt_legv_id_rqd_flag => p_rec.dpnt_legv_id_rqd_flag,
   p_dpnt_dsgn_no_ctfn_rqd_flag  => p_rec.dpnt_dsgn_no_ctfn_rqd_flag,
   p_drvbl_fctr_dpnt_elig_flag   => p_rec.drvbl_fctr_dpnt_elig_flag,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_dsgn_cd_detail
     (p_pgm_id  => p_rec.pgm_id,
      p_dpnt_dsgn_cd => p_rec.dpnt_dsgn_cd,
      p_business_group_id   => p_rec.business_group_id,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_dsgn_lvl_cd_dpndcy2
  (p_pgm_id  => p_rec.pgm_id,
   p_dpnt_dsgn_lvl_cd => p_rec.dpnt_dsgn_lvl_cd,
   p_business_group_id   => p_rec.business_group_id,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
/*
  chk_dpnt_dsgn_lvl_cd_dpndcy3
  (p_pgm_id  => p_rec.pgm_id,
   p_dpnt_dsgn_lvl_cd => p_rec.dpnt_dsgn_lvl_cd,
   p_business_group_id   => p_rec.business_group_id,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
*/
  --
  chk_dpnt_dsgn_lvl_cd_dpndcy4
  (p_pgm_id  => p_rec.pgm_id,
   p_dpnt_dsgn_lvl_cd => p_rec.dpnt_dsgn_lvl_cd,
   p_business_group_id   => p_rec.business_group_id,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_lookup_codes
      (p_pgm_id  => p_rec.pgm_id,
      p_Dflt_step_cd => p_rec.Dflt_step_cd,
      p_Update_salary_cd => p_rec.Update_salary_cd,
      p_Scores_calc_mthd_cd => p_rec.Scores_calc_mthd_cd,
      p_salary_calc_mthd_cd => p_rec.salary_calc_mthd_cd,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_dpnt_cvg_strt_dt_rl           => p_rec.dpnt_cvg_strt_dt_rl,
     p_dpnt_cvg_end_dt_rl           => p_rec.dpnt_cvg_end_dt_rl,
     p_datetrack_mode                => p_datetrack_mode,
     p_enrt_cvg_strt_dt_rl           => p_rec.enrt_cvg_strt_dt_rl,
     p_enrt_cvg_end_dt_rl           => p_rec.enrt_cvg_end_dt_rl,
     p_validation_start_date	     => p_validation_start_date,
     p_validation_end_date	     => p_validation_end_date);
  --
  chk_alws_unrstrctd_enrt_flag
      (p_pgm_id                   => p_rec.pgm_id,
       p_alws_unrstrctd_enrt_flag => p_rec.alws_unrstrctd_enrt_flag,
       p_effective_date           => p_effective_date,
       p_object_version_number    => p_rec.object_version_number);
  --
  chk_enrt_cd
     (p_pgm_id                 => p_rec.pgm_id,
      p_enrt_cd                => p_rec.enrt_cd,
      p_effective_date         => p_effective_date,
      p_object_version_number  => p_rec.object_version_number);
  --
  chk_enrt_mthd_cd
     (p_pgm_id                => p_rec.pgm_id,
      p_enrt_mthd_cd          => p_rec.enrt_mthd_cd,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_poe_lvl_cd
     (p_pgm_id                => p_rec.pgm_id,
      p_poe_lvl_cd            => p_rec.poe_lvl_cd,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_rl
     (p_pgm_id                => p_rec.pgm_id,
      p_enrt_rl               => p_rec.enrt_rl,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_rec.object_version_number,
      p_business_group_id     => p_rec.business_group_id);
  --
  chk_auto_enrt_mthd_rl
     (p_pgm_id                => p_rec.pgm_id,
      p_auto_enrt_mthd_rl     => p_rec.auto_enrt_mthd_rl,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_rec.object_version_number,
      p_business_group_id     => p_rec.business_group_id);
  --
  chk_enrt_cd_gsp
     (p_pgm_id                 => p_rec.pgm_id,
      p_pgm_typ_cd	       => p_rec.pgm_typ_cd,
      p_enrt_cd                => p_rec.enrt_cd,
      p_effective_date         => p_effective_date,
      p_object_version_number  => p_rec.object_version_number);
  --
  -- Call user defined business rules
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
	(p_rec 			 in ben_pgm_shd.g_rec_type,
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
     p_pgm_id		=> p_rec.pgm_id);
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
  (p_pgm_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_pgm_f b
    where b.pgm_id      = p_pgm_id
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
                             p_argument       => 'pgm_id',
                             p_argument_value => p_pgm_id);
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
end ben_pgm_bus;

/
