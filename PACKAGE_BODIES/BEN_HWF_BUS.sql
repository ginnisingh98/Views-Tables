--------------------------------------------------------
--  DDL for Package Body BEN_HWF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_HWF_BUS" as
/* $Header: behwfrhi.pkb 120.0 2005/05/28 03:12:16 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_hwf_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_hrs_wkd_in_perd_fctr_id >------|
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
--   hrs_wkd_in_perd_fctr_id PK of record being inserted or updated.
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
Procedure chk_hrs_wkd_in_perd_fctr_id(p_hrs_wkd_in_perd_fctr_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_hrs_wkd_in_perd_fctr_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_hwf_shd.api_updating
    (p_hrs_wkd_in_perd_fctr_id                => p_hrs_wkd_in_perd_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_hrs_wkd_in_perd_fctr_id,hr_api.g_number)
     <>  ben_hwf_shd.g_old_rec.hrs_wkd_in_perd_fctr_id) then
    --
    -- raise error as PK has changed
    --
    ben_hwf_shd.constraint_error('BEN_HRS_WKD_IN_PERD_FCTR_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_hrs_wkd_in_perd_fctr_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_hwf_shd.constraint_error('BEN_HRS_WKD_IN_PERD_FCTR_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_hrs_wkd_in_perd_fctr_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_once_r_cntug_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   hrs_wkd_in_perd_fctr_id PK of record being inserted or updated.
--   once_r_cntug_cd Value of lookup code.
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
Procedure chk_once_r_cntug_cd(p_hrs_wkd_in_perd_fctr_id                in number,
                            p_once_r_cntug_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_once_r_cntug_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_hwf_shd.api_updating
    (p_hrs_wkd_in_perd_fctr_id                => p_hrs_wkd_in_perd_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_once_r_cntug_cd
      <> nvl(ben_hwf_shd.g_old_rec.once_r_cntug_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_once_r_cntug_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ONCE_R_CNTNG',
           p_lookup_code    => p_once_r_cntug_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91060_INVLD_ONCE_R_CNTG_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_once_r_cntug_cd;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_mx_hrs_wkd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   hrs_wkd_in_perd_fctr_id PK of record being inserted or updated.
--   no_mx_hrs_wkd_flag Value of lookup code.
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
Procedure chk_no_mx_hrs_wkd_flag(p_hrs_wkd_in_perd_fctr_id                in number,
                            p_no_mx_hrs_wkd_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mx_hrs_wkd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_hwf_shd.api_updating
    (p_hrs_wkd_in_perd_fctr_id                => p_hrs_wkd_in_perd_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mx_hrs_wkd_flag
      <> nvl(ben_hwf_shd.g_old_rec.no_mx_hrs_wkd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_no_mx_hrs_wkd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mx_hrs_wkd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91052_INVALID_MAX_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mx_hrs_wkd_flag;
-- ----------------------------------------------------------------------------
-- |------< chk_no_mn_hrs_wkd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   hrs_wkd_in_perd_fctr_id PK of record being inserted or updated.
--   no_mn_hrs_wkd_flag Value of lookup code.
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
Procedure chk_no_mn_hrs_wkd_flag(p_hrs_wkd_in_perd_fctr_id                in number,
                            p_no_mn_hrs_wkd_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mn_hrs_wkd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_hwf_shd.api_updating
    (p_hrs_wkd_in_perd_fctr_id                => p_hrs_wkd_in_perd_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mn_hrs_wkd_flag
      <> nvl(ben_hwf_shd.g_old_rec.no_mn_hrs_wkd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_no_mn_hrs_wkd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mn_hrs_wkd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('PAY','91051_INVALID_MIN_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mn_hrs_wkd_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_hrs_wkd_det_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   hrs_wkd_in_perd_fctr_id PK of record being inserted or updated.
--   hrs_wkd_det_rl Value of formula rule id.
--   effective_date effective date
--   object_version_number Object version number of record being
--                                      inserted or updated.
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
Procedure chk_hrs_wkd_det_rl(p_hrs_wkd_in_perd_fctr_id     in number,
                             p_business_group_id        in number,
                             p_hrs_wkd_det_rl              in number,
                             p_hrs_wkd_det_cd              in varchar2,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_hrs_wkd_det_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_hrs_wkd_det_rl
    and    ff.formula_type_id = -155
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
  l_api_updating := ben_hwf_shd.api_updating
    (p_hrs_wkd_in_perd_fctr_id                => p_hrs_wkd_in_perd_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_hrs_wkd_det_rl,hr_api.g_number)
      <> ben_hwf_shd.g_old_rec.hrs_wkd_det_rl
      or not l_api_updating)
      and p_hrs_wkd_det_rl is not null then
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
        fnd_message.set_name('BEN','BEN_91062_INVLD_HRS_WKD_DET_RL');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  -- Unless Hours Worked Determination Code  = Rule, Hours Worked Determination rule must be blank.
  if  nvl(p_hrs_wkd_det_cd,hr_api.g_varchar2)  <> 'RL' and p_hrs_wkd_det_rl is not null then
      --
      fnd_message.set_name('BEN', 'BEN_91070_HRS_WKD_RL_NOT_NULL');
      fnd_message.raise_error;
      --
  elsif  nvl(p_hrs_wkd_det_cd,hr_api.g_varchar2) = 'RL' and p_hrs_wkd_det_rl is null then
      --
      fnd_message.set_name('BEN', 'BEN_91097_HRS_WKD_RL_NULL');
      fnd_message.raise_error;
      --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_hrs_wkd_det_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_hrs_wkd_det_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   hrs_wkd_in_perd_fctr_id PK of record being inserted or updated.
--   hrs_wkd_det_cd Value of lookup code.
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
Procedure chk_hrs_wkd_det_cd(p_hrs_wkd_in_perd_fctr_id                in number,
                            p_hrs_wkd_det_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_hrs_wkd_det_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_hwf_shd.api_updating
    (p_hrs_wkd_in_perd_fctr_id                => p_hrs_wkd_in_perd_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_hrs_wkd_det_cd
      <> nvl(ben_hwf_shd.g_old_rec.hrs_wkd_det_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_hrs_wkd_det_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_HRS_WKD_DET',
           p_lookup_code    => p_hrs_wkd_det_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91061_INVLD_HRS_WKD_DET_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_hrs_wkd_det_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rndg_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   hrs_wkd_in_perd_fctr_id PK of record being inserted or updated.
--   rndg_rl Value of formula rule id.
--   effective_date effective date
--   object_version_number Object version number of record being
--                                      inserted or updated.
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
Procedure chk_rndg_rl(p_hrs_wkd_in_perd_fctr_id                in number,
                             p_business_group_id        in number,
                             p_rndg_rl              in number,
                             p_rndg_cd              in varchar2,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rndg_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_rndg_rl
    and    ff.formula_type_id = -169
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
  l_api_updating := ben_hwf_shd.api_updating
    (p_hrs_wkd_in_perd_fctr_id                => p_hrs_wkd_in_perd_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_rndg_rl,hr_api.g_number)
      <> ben_hwf_shd.g_old_rec.rndg_rl
      or not l_api_updating)
      and p_rndg_rl is not null then
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
        fnd_message.set_name('BEN','BEN_91042_INVALID_RNDG_RL');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  -- Unless Rounding Code = Rule, Rounding rule must be blank.
  if  nvl(p_rndg_cd,hr_api.g_varchar2)  <> 'RL' and p_rndg_rl is not null then
      --
      fnd_message.set_name('BEN', 'BEN_91043_RNDG_RL_NOT_NULL');
      fnd_message.raise_error;
      --
  elsif  nvl(p_rndg_cd,hr_api.g_varchar2) = 'RL' and p_rndg_rl is null then
      --
      fnd_message.set_name('BEN', 'BEN_92340_RNDG_RL_NULL');
      fnd_message.raise_error;
      --
  end if;
  --
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rndg_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rndg_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   hrs_wkd_in_perd_fctr_id PK of record being inserted or updated.
--   rndg_cd Value of lookup code.
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
Procedure chk_rndg_cd(p_hrs_wkd_in_perd_fctr_id                in number,
                            p_rndg_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rndg_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_hwf_shd.api_updating
    (p_hrs_wkd_in_perd_fctr_id                => p_hrs_wkd_in_perd_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rndg_cd
      <> nvl(ben_hwf_shd.g_old_rec.rndg_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rndg_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RNDG',
           p_lookup_code    => p_rndg_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91041_INVALID_RNDG_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rndg_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_hrs_src_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   hrs_wkd_in_perd_fctr_id PK of record being inserted or updated.
--   hrs_src_cd Value of lookup code.
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
Procedure chk_hrs_src_cd(p_hrs_wkd_in_perd_fctr_id                in number,
                            p_hrs_src_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_hrs_src_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_hwf_shd.api_updating
    (p_hrs_wkd_in_perd_fctr_id                => p_hrs_wkd_in_perd_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_hrs_src_cd
      <> nvl(ben_hwf_shd.g_old_rec.hrs_src_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_hrs_src_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_HRS_WKD_SRC',
           p_lookup_code    => p_hrs_src_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91053_INVALID_SRC_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_hrs_src_cd;
--
-- ----------------------------------------------------------------------------
-- |-----------------< chk_hrs_alt_val_to_use_cd >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   hrs_wkd_in_perd_fctr_id PK of record being inserted or updated.
--   hrs_alt_val_to_use_cd Value of lookup code.
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
Procedure chk_hrs_alt_val_to_use_cd(p_hrs_wkd_in_perd_fctr_id    in number,
                                    p_hrs_alt_val_to_use_cd      in varchar2,
                                    p_effective_date             in date,
                                    p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_hrs_alt_val_to_use_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_hwf_shd.api_updating
    (p_hrs_wkd_in_perd_fctr_id     => p_hrs_wkd_in_perd_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_hrs_alt_val_to_use_cd
      <> nvl(ben_hwf_shd.g_old_rec.hrs_alt_val_to_use_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_hrs_alt_val_to_use_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_HRS_ALT_VAL_TO_USE',
           p_lookup_code    => p_hrs_alt_val_to_use_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN', 'BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_hrs_alt_val_to_use_cd');
      fnd_message.set_token('TYPE', 'BEN_HRS_ALT_VAL_TO_USE');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);  --
end chk_hrs_alt_val_to_use_cd;
--
-- ----------------------------------------------------------------------------
-- |-----------------< chk_pyrl_freq_cd >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   hrs_wkd_in_perd_fctr_id PK of record being inserted or updated.
--   pyrl_freq_cd Value of lookup code.
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
Procedure chk_pyrl_freq_cd(p_hrs_wkd_in_perd_fctr_id  in number,
                           p_pyrl_freq_cd             in varchar2,
                           p_effective_date           in date,
                           p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pyrl_freq_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_hwf_shd.api_updating
    (p_hrs_wkd_in_perd_fctr_id     => p_hrs_wkd_in_perd_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_pyrl_freq_cd
      <> nvl(ben_hwf_shd.g_old_rec.pyrl_freq_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pyrl_freq_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_FREQ',
           p_lookup_code    => p_pyrl_freq_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN', 'BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_pyrl_freq_cd');
      fnd_message.set_token('TYPE', 'BEN_FREQ');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);  --
end chk_pyrl_freq_cd;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_hrs_wkd_calc_rl >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   hrs_wkd_in_perd_fctr_id PK of record being inserted or updated.
--   hrs_wkd_calc_rl    Value of formula rule id.
--   effective_date effective date
--   object_version_number Object version number of record being
--                                      inserted or updated.
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
Procedure chk_hrs_wkd_calc_rl(p_hrs_wkd_in_perd_fctr_id     in number,
                              p_business_group_id           in number,
                              p_hrs_wkd_calc_rl             in number,
                              p_effective_date              in date,
                              p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_hrs_wkd_calc_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_hrs_wkd_calc_rl
    and    ff.formula_type_id = -516
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
  l_api_updating := ben_hwf_shd.api_updating
    (p_hrs_wkd_in_perd_fctr_id     => p_hrs_wkd_in_perd_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_hrs_wkd_calc_rl,hr_api.g_number)
      <> ben_hwf_shd.g_old_rec.hrs_wkd_calc_rl
      or not l_api_updating)
      and p_hrs_wkd_calc_rl is not null then
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
        fnd_message.set_token('ID',p_hrs_wkd_calc_rl);
        fnd_message.set_token('TYPE_ID',-516);
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
end chk_hrs_wkd_calc_rl;
--
------------------------------------------------------------------------
----
-- |------< chk_name >------|
--
------------------------------------------------------------------------
----
--
-- Description
--   This procedure is used to check that the Name is unique in a business group.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   hrs_wkd_in_perd_fctr_id PK of record being inserted or updated.
--   name Value of Name.
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
Procedure chk_name(p_hrs_wkd_in_perd_fctr_id                in number,
                         p_business_group_id                in number,
                         p_name                    in varchar2,
                         p_effective_date              in date,
                         p_object_version_number       in number) is
  --
  l_proc         varchar2(72):= g_package||'chk_name';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_hrs_wkd_in_perd_fctr  hwf
    where  hwf.business_group_id = p_business_group_id and
                 hwf.name = p_name;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_hwf_shd.api_updating
    (p_hrs_wkd_in_perd_fctr_id                => p_hrs_wkd_in_perd_fctr_id,
     -- p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_name,hr_api.g_varchar2)
      <> ben_hwf_shd.g_old_rec.name
      or not l_api_updating)
      and p_name is not null then
    --
    -- check if name already used.
    --
    open c1;
      --
      -- fetch value from cursor if it returns a record then the

      -- name is invalid otherwise its valid
      --
      fetch c1 into l_dummy;
      if c1%found then
        --
        close c1;
        --
        -- raise error
        --
        fnd_message.set_name('BEN','BEN_91009_NAME_NOT_UNIQUE');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_name;
  --
------------------------------------------------------------------------
----
-- |------< chk_mn_mx_hrs_num >------|
--
------------------------------------------------------------------------
----
--
-- Description
--   This procedure is used to check that minimum hours nuumber is always less than
--    max hours number.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   hrs_wkd_in_perd_fctr_id PK of record being inserted or updated.
--   mn_hrs_num Value of Minimum hours worked.
--   mx_hrs_num Value of Maximum hours worked.
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
Procedure chk_mn_mx_hrs_num(p_hrs_wkd_in_perd_fctr_id  in number,
                         p_no_mn_hrs_wkd_flag          in varchar2,
                         p_mn_hrs_num                  in number,
                         p_no_mx_hrs_wkd_flag          in varchar2,
                         p_mx_hrs_num                  in number,
                         p_hrs_wkd_calc_rl             in number,
                         p_object_version_number       in number) is
  --
  l_proc   varchar2(72)  := g_package || 'chk_mn_mx_hrs_num';
  l_api_updating   boolean;
  l_dummy  varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Minimum hours Number must be < Maximum hours Number,
  -- if both are used.
  --
  if p_mn_hrs_num is not null and p_mx_hrs_num is not null then
      --
      -- raise error if max value not greater than min value
      --
     -- Bug fix 1873685
     if  (p_mx_hrs_num < p_mn_hrs_num)  then
     -- if  (p_mx_hrs_num <= p_mn_hrs_num)  then
     -- end fix 1873685
      fnd_message.set_name('BEN','BEN_91069_INVALID_MIN_MAX');
      fnd_message.raise_error;
    end if;
      --
      --
  end if;
    --
      -- If No Minimum hours flag set to "on" (Y),
      --    then minimum hours number and calc rule must be blank.
      --
     if  p_no_mn_hrs_wkd_flag = 'Y'
         and (p_mn_hrs_num is not null) then
         --
         fnd_message.set_name('BEN','BEN_91054_MIN_VAL_NOT_NULL');
         fnd_message.raise_error;
         --
     elsif p_no_mn_hrs_wkd_flag = 'N' and
        p_mn_hrs_num is null then
        --
        fnd_message.set_name('BEN','BEN_91055_MIN_VAL_REQUIRED');
        fnd_message.raise_error;
        --
     end if;
     --
      -- If No Maximum hrs_wkd flag set to "on" (Y),
      --    then maximum hrs_wkd number and calc rule must be blank.
      --
     if  p_no_mx_hrs_wkd_flag  = 'Y'
         and (p_mx_hrs_num is not null) then
         --
         fnd_message.set_name('BEN','BEN_91056_MAX_VAL_NOT_NULL');
    fnd_message.raise_error;
    --
  elsif p_no_mx_hrs_wkd_flag = 'N' and
    p_mx_hrs_num is null then
    --
    fnd_message.set_name('BEN','BEN_91057_MAX_VAL_REQUIRED');
    fnd_message.raise_error;
    --
  end if;

   --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mn_mx_hrs_num;
--
-------------------------------------------------------------------------------
-- |--------------------------< chk_source >---------------------------------|
-------------------------------------------------------------------------------
----
--
-- Description
--  This procedure checks to make sure that the Defined Balance is not null
--  if the hrs_src_cd = BALTYP and that the Benefits Balance Type is not null
--  if the hrs_src_cd = BNFTBALTYP
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   hrs_src_cd            Source Code.
--   defined_balance_id    Defined Balance.
--   bnfts_bal_id          Benefits Balance Type.
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
Procedure chk_source(p_hrs_src_cd                  in varchar2,
                     p_defined_balance_id          in number,
                     p_bnfts_bal_id                in number) is
  --
  l_proc   varchar2(72)  := g_package || 'chk_source';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Defined Balance must be entered if "Balance Type" is selected for
  -- Source.
  --
  if p_hrs_src_cd = 'BALTYP' and p_defined_balance_id is null then
     --
     fnd_message.set_name('BEN','BEN_91975_DEFINED_BALANCE');
     fnd_message.raise_error;
     --
  elsif p_hrs_src_cd = 'BNFTBALTYP' and p_bnfts_bal_id is null then
     --
     fnd_message.set_name('BEN','BEN_91976_BNFTS_BALANCE_TYP');
     fnd_message.raise_error;
     --
  end if;
      --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_source;
--
--Bug 2978945 begin

  -- ----------------------------------------------------------------------- --
-- -----------------------< chk_child_records >-----------------------------|
-- -------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that Hours worked child records do not exist
--   when the user deletes the record in the BEN_HRS_WKD_IN_PERD_FCTR table.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   hrs_wkd_in_perd_fctr_id        PK of record being inserted or updated.
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
procedure chk_child_records(p_hrs_wkd_in_perd_fctr_id  in number) is
  --
  l_proc         varchar2(72):= g_package||'chk_child_records';

begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);

 --Used in eligibility profiles
   If (ben_batch_utils.rows_exist
             (p_base_table_name => 'BEN_ELIG_HRS_WKD_PRTE_F',
              p_base_key_column => 'hrs_wkd_in_perd_fctr_id',
              p_base_key_value  => p_hrs_wkd_in_perd_fctr_id
             )) Then
		ben_utility.child_exists_error('BEN_ELIG_HRS_WKD_PRTE_F');
   End If;

   --Used in variable rate profiles
   If (ben_batch_utils.rows_exist
             (p_base_table_name => 'BEN_HRS_WKD_IN_PERD_RT_F',
              p_base_key_column => 'hrs_wkd_in_perd_fctr_id',
              p_base_key_value  => p_hrs_wkd_in_perd_fctr_id
             )) Then
		ben_utility.child_exists_error('BEN_HRS_WKD_IN_PERD_RT_F');
  End If;

  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_child_records;

--Bug 2978945

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_hwf_shd.g_rec_type
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
  chk_hrs_wkd_in_perd_fctr_id
  (p_hrs_wkd_in_perd_fctr_id  => p_rec.hrs_wkd_in_perd_fctr_id,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_once_r_cntug_cd
  (p_hrs_wkd_in_perd_fctr_id  => p_rec.hrs_wkd_in_perd_fctr_id,
   p_once_r_cntug_cd          => p_rec.once_r_cntug_cd,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_no_mx_hrs_wkd_flag
  (p_hrs_wkd_in_perd_fctr_id  => p_rec.hrs_wkd_in_perd_fctr_id,
   p_no_mx_hrs_wkd_flag       => p_rec.no_mx_hrs_wkd_flag,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_no_mn_hrs_wkd_flag
  (p_hrs_wkd_in_perd_fctr_id  => p_rec.hrs_wkd_in_perd_fctr_id,
   p_no_mn_hrs_wkd_flag       => p_rec.no_mn_hrs_wkd_flag,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_hrs_wkd_det_rl
  (p_hrs_wkd_in_perd_fctr_id  => p_rec.hrs_wkd_in_perd_fctr_id,
   p_business_group_id        => p_rec.business_group_id,
   p_hrs_wkd_det_rl           => p_rec.hrs_wkd_det_rl,
   p_hrs_wkd_det_cd           => p_rec.hrs_wkd_det_cd,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_hrs_wkd_det_cd
  (p_hrs_wkd_in_perd_fctr_id  => p_rec.hrs_wkd_in_perd_fctr_id,
   p_hrs_wkd_det_cd           => p_rec.hrs_wkd_det_cd,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_rndg_rl
  (p_hrs_wkd_in_perd_fctr_id  => p_rec.hrs_wkd_in_perd_fctr_id,
   p_business_group_id        => p_rec.business_group_id,
   p_rndg_rl                  => p_rec.rndg_rl,
   p_rndg_cd                  => p_rec.rndg_cd,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_rndg_cd
  (p_hrs_wkd_in_perd_fctr_id  => p_rec.hrs_wkd_in_perd_fctr_id,
   p_rndg_cd                  => p_rec.rndg_cd,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_hrs_src_cd
  (p_hrs_wkd_in_perd_fctr_id  => p_rec.hrs_wkd_in_perd_fctr_id,
   p_hrs_src_cd               => p_rec.hrs_src_cd,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_hrs_alt_val_to_use_cd
  (p_hrs_wkd_in_perd_fctr_id  => p_rec.hrs_wkd_in_perd_fctr_id,
   p_hrs_alt_val_to_use_cd    => p_rec.hrs_alt_val_to_use_cd,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_pyrl_freq_cd
  (p_hrs_wkd_in_perd_fctr_id => p_rec.hrs_wkd_in_perd_fctr_id,
   p_pyrl_freq_cd            => p_rec.pyrl_freq_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_hrs_wkd_calc_rl
  (p_hrs_wkd_in_perd_fctr_id   => p_rec.hrs_wkd_in_perd_fctr_id,
   p_business_group_id         => p_rec.business_group_id,
   p_hrs_wkd_calc_rl           => p_rec.hrs_wkd_calc_rl,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_mn_mx_hrs_num
  (p_hrs_wkd_in_perd_fctr_id  => p_rec.hrs_wkd_in_perd_fctr_id,
   p_no_mn_hrs_wkd_flag       => p_rec.no_mn_hrs_wkd_flag,
   p_mn_hrs_num               => p_rec.mn_hrs_num,
   p_no_mx_hrs_wkd_flag       => p_rec.no_mx_hrs_wkd_flag,
   p_mx_hrs_num               => p_rec.mx_hrs_num,
   p_hrs_wkd_calc_rl          => p_rec.hrs_wkd_calc_rl,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_name
  (p_hrs_wkd_in_perd_fctr_id  => p_rec.hrs_wkd_in_perd_fctr_id,
   p_business_group_id        => p_rec.business_group_id,
   p_name                     => p_rec.name,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
 --
  chk_source
  (p_hrs_src_cd               => p_rec.hrs_src_cd,
   p_defined_balance_id       => p_rec.defined_balance_id,
   p_bnfts_bal_id             => p_rec.bnfts_bal_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_hwf_shd.g_rec_type
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
  chk_hrs_wkd_in_perd_fctr_id
  (p_hrs_wkd_in_perd_fctr_id  => p_rec.hrs_wkd_in_perd_fctr_id,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_once_r_cntug_cd
  (p_hrs_wkd_in_perd_fctr_id  => p_rec.hrs_wkd_in_perd_fctr_id,
   p_once_r_cntug_cd          => p_rec.once_r_cntug_cd,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_no_mx_hrs_wkd_flag
  (p_hrs_wkd_in_perd_fctr_id  => p_rec.hrs_wkd_in_perd_fctr_id,
   p_no_mx_hrs_wkd_flag       => p_rec.no_mx_hrs_wkd_flag,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_no_mn_hrs_wkd_flag
  (p_hrs_wkd_in_perd_fctr_id  => p_rec.hrs_wkd_in_perd_fctr_id,
   p_no_mn_hrs_wkd_flag       => p_rec.no_mn_hrs_wkd_flag,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_hrs_wkd_det_rl
  (p_hrs_wkd_in_perd_fctr_id  => p_rec.hrs_wkd_in_perd_fctr_id,
   p_business_group_id        => p_rec.business_group_id,
   p_hrs_wkd_det_rl           => p_rec.hrs_wkd_det_rl,
   p_hrs_wkd_det_cd           => p_rec.hrs_wkd_det_cd,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_hrs_wkd_det_cd
  (p_hrs_wkd_in_perd_fctr_id  => p_rec.hrs_wkd_in_perd_fctr_id,
   p_hrs_wkd_det_cd           => p_rec.hrs_wkd_det_cd,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_rndg_rl
  (p_hrs_wkd_in_perd_fctr_id  => p_rec.hrs_wkd_in_perd_fctr_id,
   p_business_group_id        => p_rec.business_group_id,
   p_rndg_rl                  => p_rec.rndg_rl,
   p_rndg_cd                  => p_rec.rndg_cd,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_rndg_cd
  (p_hrs_wkd_in_perd_fctr_id  => p_rec.hrs_wkd_in_perd_fctr_id,
   p_rndg_cd                  => p_rec.rndg_cd,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_hrs_src_cd
  (p_hrs_wkd_in_perd_fctr_id  => p_rec.hrs_wkd_in_perd_fctr_id,
   p_hrs_src_cd               => p_rec.hrs_src_cd,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_hrs_alt_val_to_use_cd
  (p_hrs_wkd_in_perd_fctr_id => p_rec.hrs_wkd_in_perd_fctr_id,
   p_hrs_alt_val_to_use_cd   => p_rec.hrs_alt_val_to_use_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_pyrl_freq_cd
  (p_hrs_wkd_in_perd_fctr_id => p_rec.hrs_wkd_in_perd_fctr_id,
   p_pyrl_freq_cd            => p_rec.pyrl_freq_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_hrs_wkd_calc_rl
  (p_hrs_wkd_in_perd_fctr_id   => p_rec.hrs_wkd_in_perd_fctr_id,
   p_business_group_id         => p_rec.business_group_id,
   p_hrs_wkd_calc_rl           => p_rec.hrs_wkd_calc_rl,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_mn_mx_hrs_num
  (p_hrs_wkd_in_perd_fctr_id => p_rec.hrs_wkd_in_perd_fctr_id,
   p_no_mn_hrs_wkd_flag      => p_rec.no_mn_hrs_wkd_flag,
   p_mn_hrs_num              => p_rec.mn_hrs_num,
   p_no_mx_hrs_wkd_flag      => p_rec.no_mx_hrs_wkd_flag,
   p_mx_hrs_num              => p_rec.mx_hrs_num,
   p_hrs_wkd_calc_rl         => p_rec.hrs_wkd_calc_rl,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_name
  (p_hrs_wkd_in_perd_fctr_id => p_rec.hrs_wkd_in_perd_fctr_id,
   p_business_group_id       => p_rec.business_group_id,
   p_name                    => p_rec.name,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
 --
  chk_source
  (p_hrs_src_cd              => p_rec.hrs_src_cd,
   p_defined_balance_id      => p_rec.defined_balance_id,
   p_bnfts_bal_id            => p_rec.bnfts_bal_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_hwf_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_child_records(p_hrs_wkd_in_perd_fctr_id => p_rec.hrs_wkd_in_perd_fctr_id); --Bug 2978945
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_hrs_wkd_in_perd_fctr_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_hrs_wkd_in_perd_fctr b
    where b.hrs_wkd_in_perd_fctr_id      = p_hrs_wkd_in_perd_fctr_id
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
                             p_argument       => 'hrs_wkd_in_perd_fctr_id',
                             p_argument_value => p_hrs_wkd_in_perd_fctr_id);
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
end ben_hwf_bus;

/
