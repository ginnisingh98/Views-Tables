--------------------------------------------------------
--  DDL for Package Body BEN_EPO_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EPO_BUS" as
/* $Header: beeporhi.pkb 120.0 2005/05/28 02:42:27 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)    := '  ben_epo_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_elig_per_opt_id >----------------------|
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
--   elig_per_opt_id PK of record being inserted or updated.
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
Procedure chk_elig_per_opt_id(p_elig_per_opt_id         in number,
                              p_elig_per_id             in number,
                              p_opt_id                  in number,
                              p_effective_date          in date,
                              p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_elig_per_opt_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_elig_per_f e,
           ben_oipl_f o
    where  e.elig_per_id = p_elig_per_id
    and    p_opt_id = o.opt_id
    and    p_effective_date
           between e.effective_start_date
           and     e.effective_end_date
    and    o.pl_id = e.pl_id
    and    p_effective_date
           between o.effective_start_date
           and     o.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_epo_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_elig_per_opt_id             => p_elig_per_opt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_elig_per_opt_id,hr_api.g_number)
     <>  ben_epo_shd.g_old_rec.elig_per_opt_id) then
    --
    -- raise error as PK has changed
    --
    ben_epo_shd.constraint_error('BEN_ELIG_PER_F_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_elig_per_opt_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_epo_shd.constraint_error('BEN_ELIG_PER_F_PK');
      --
    end if;
    --
  end if;

  hr_utility.set_location('In:'||l_proc, 7);

  if (l_api_updating
      and p_elig_per_opt_id
      <> nvl(ben_epo_shd.g_old_rec.elig_per_opt_id,hr_api.g_number)
      or not l_api_updating) then
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        fnd_message.set_name('BEN','BEN_91275_ELIG_PER_OPT_ONP');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_elig_per_opt_id;
--
-- ---------------------------------------------------------------------------
-- |--------------------------<chk_comp_ref_uom>------------------------------|
-- ---------------------------------------------------------------------------
--
-- Description:
--  This procedure checks that a referenced foreign key actually exists
--  in the referenced table.
--
-- Pre Conditions
--  None.
--
-- In Parameters
--  p_elig_per_opt_id PK
--  p_comp_ref_uom ID of FK column
--  p_effective_date Session Date of record
--  p_object_version_number object version number
--
-- Post Success
--  Processing continues
--
-- Post Failure
--  Error raised
--
-- Access Status
--  Internal table handler use only.
--
Procedure chk_comp_ref_uom (p_elig_per_opt_id       in number,
                            p_comp_ref_val          in number,
                            p_comp_ref_uom          in varchar2,
                            p_rt_comp_ref_val       in number,
                            p_rt_comp_ref_uom       in varchar2,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc                varchar2(72) := g_package||'chk_comp_ref_uom';
  l_api_updating        boolean;
  l_dummy               varchar2(1);
  --
  cursor c1 is
    select null
    from   fnd_currencies_vl a
    where  a.currency_code = p_comp_ref_uom;
  --
  cursor c2 is
    select null
    from   fnd_currencies_vl a
    where  a.currency_code = p_rt_comp_ref_uom;
  --
begin
  --
  hr_utility.set_location('Entering :'||l_proc,5);
  --
  if (p_comp_ref_val is null and p_comp_ref_uom is not null) or
     (p_comp_ref_uom is null and p_comp_ref_val is not null) then
    --
    fnd_message.set_name('BEN','BEN_91277_ELIG_PER_PRD_FLD_CMP');
    fnd_message.raise_error;
    --
  end if;
  --
  if (p_rt_comp_ref_val is null and p_rt_comp_ref_uom is not null) or
     (p_rt_comp_ref_uom is null and p_rt_comp_ref_val is not null) then
    --
    fnd_message.set_name('BEN','BEN_91277_ELIG_PER_PRD_FLD_CMP');
    fnd_message.raise_error;
    --
  end if;
  --
  l_api_updating:= ben_epo_shd.api_updating
     (p_elig_per_opt_id       => p_elig_per_opt_id,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
      and p_comp_ref_uom
      <> nvl(ben_epo_shd.g_old_rec.comp_ref_uom,hr_api.g_varchar2)
      or not l_api_updating) and p_comp_ref_uom IS NOT NULL then
    --
    -- check if comp_ref_uom value exists in hr_lookups table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        fnd_message.set_name('BEN','MUPPET');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  if (l_api_updating
      and p_rt_comp_ref_uom
      <> nvl(ben_epo_shd.g_old_rec.rt_comp_ref_uom,hr_api.g_varchar2)
      or not l_api_updating) and p_rt_comp_ref_uom IS NOT NULL then
    --
    -- check if rt_comp_ref_uom value exists in hr_lookups table
    --
    open c2;
      --
      fetch c2 into l_dummy;
      if c2%notfound then
        --
        close c2;
        fnd_message.set_name('BEN','MUPPET');
        fnd_message.raise_error;
        --
      end if;
      --
    close c2;
    --
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc,10);
  --
end chk_comp_ref_uom;
-- ---------------------------------------------------------------------------
-- |-------------------<chk_hrs_wkd_bndry_perd_cd>---------------------------|
-- ---------------------------------------------------------------------------
--
-- Description:
--  This procedure checks that a referenced foreign key actually exists
--  in the referenced table.
--
-- Pre Conditions
--  None.
--
-- In Parameters
--  p_elig_per_id PK
--  p_wv_prtn_rsn_cd ID of FK column
--  p_effective_date Session Date of record
--  p_object_version_number object version number
--
-- Post Success
--  Processing continues
--
-- Post Failure
--  Error raised
--
-- Access Status
--  Internal table handler use only.
--
Procedure chk_hrs_wkd_bndry_perd_cd (p_elig_per_opt_id       in number,
                                     p_hrs_wkd_bndry_perd_cd in varchar2,
                                     p_rt_hrs_wkd_bndry_perd_cd in varchar2,
                                     p_effective_date        in date,
                                     p_object_version_number in number) is
  --
  l_proc                varchar2(72) := g_package||'chk_hrs_wkd_bndry_perd_cd';
  l_api_updating        boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_epo_shd.api_updating
    (p_elig_per_opt_id             => p_elig_per_opt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_hrs_wkd_bndry_perd_cd,hr_api.g_varchar2)
      <> nvl(ben_epo_shd.g_old_rec.hrs_wkd_bndry_perd_cd,hr_api.g_varchar2)
      or not l_api_updating) and p_hrs_wkd_bndry_perd_cd IS NOT NULL then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_BNDRY_PERD',
           p_lookup_code    => p_hrs_wkd_bndry_perd_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_hrs_wkd_bndry_perd_cd');
      fnd_message.set_token('TYPE','BEN_BNDRY_PERD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and nvl(p_rt_hrs_wkd_bndry_perd_cd,hr_api.g_varchar2)
      <> nvl(ben_epo_shd.g_old_rec.rt_hrs_wkd_bndry_perd_cd,hr_api.g_varchar2)
      or not l_api_updating) and p_rt_hrs_wkd_bndry_perd_cd IS NOT NULL then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_BNDRY_PERD',
           p_lookup_code    => p_rt_hrs_wkd_bndry_perd_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_rt_hrs_wkd_bndry_perd_cd');
      fnd_message.set_token('TYPE','BEN_BNDRY_PERD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_hrs_wkd_bndry_perd_cd;
-- ---------------------------------------------------------------------------
-- |---------------------------------<chk_pct_val>---------------------------|
-- ---------------------------------------------------------------------------
--
-- Description:
--  This procedure checks that a percentage value is between 0 and 100
--
-- Pre Conditions
--  None.
--
-- In Parameters
--     p_pct_val percentage value to be checked
--
-- Post Success
--  Processing continues
--
-- Post Failure
--  Error raised
--
-- Access Status
--  Internal table handler use only.
--
Procedure chk_pct_val (p_pct_val    in number,
                       p_rt_pct_val in number) is
  --
  l_proc                varchar2(72) := g_package||'chk_chk_pct_val';
  l_api_updating        boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if (p_pct_val IS NOT NULL and (p_pct_val < 0 OR p_pct_val > 100)) then
    --
    fnd_message.set_name('BEN','BEN_91257_INV_PCT_VAL');
    fnd_message.raise_error;
    --
  end if;
  --
  if (p_rt_pct_val IS NOT NULL and (p_rt_pct_val < 0 OR p_rt_pct_val > 100)) then
    --
    fnd_message.set_name('BEN','BEN_91257_INV_PCT_VAL');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pct_val;
-- ---------------------------------------------------------------------------
-- |--------------------------<chk_age_uom>----------------------------------|
-- ---------------------------------------------------------------------------
--
-- Description:
--  This procedure checks that a referenced foreign key actually exists
--  in the referenced table.
--
-- Pre Conditions
--  None.
--
-- In Parameters
--  p_elig_per_id PK
--  p_age_uom ID of FK column
--  p_effective_date Session Date of record
--  p_object_version_number object version number
--
-- Post Success
--  Processing continues
--
-- Post Failure
--  Error raised
--
-- Access Status
--  Internal table handler use only.
--
Procedure chk_age_uom (p_elig_per_opt_id       in number,
                       p_age_val               in number,
                       p_age_uom               in varchar2,
                       p_rt_age_val            in number,
                       p_rt_age_uom            in varchar2,
                       p_effective_date        in date,
                       p_object_version_number in number) is
  --
  l_proc                varchar2(72) := g_package||'chk_age_uom';
  l_api_updating        boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if (p_age_val is null and p_age_uom is not null) or
     (p_age_uom is null and p_age_val is not null) then
    --
    fnd_message.set_name('BEN','BEN_91276_ELIG_PER_PRD_FLD_AGE');
    fnd_message.raise_error;
    --
  end if;
  --
  if (p_rt_age_val is null and p_rt_age_uom is not null) or
     (p_rt_age_uom is null and p_rt_age_val is not null) then
    --
    fnd_message.set_name('BEN','BEN_91276_ELIG_PER_PRD_FLD_AGE');
    fnd_message.raise_error;
    --
  end if;
  --
  l_api_updating := ben_epo_shd.api_updating
    (p_elig_per_opt_id            => p_elig_per_opt_id,
     p_effective_date             => p_effective_date,
     p_object_version_number      => p_object_version_number);
  --
  if (l_api_updating
      and p_age_uom
      <> nvl(ben_epo_shd.g_old_rec.age_uom,hr_api.g_varchar2)
      or not l_api_updating) and p_age_uom IS NOT NULL then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_TM_UOM',
           p_lookup_code    => p_age_uom,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_age_uom');
      fnd_message.set_token('TYPE','BEN_TM_UOM');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_rt_age_uom
      <> nvl(ben_epo_shd.g_old_rec.rt_age_uom,hr_api.g_varchar2)
      or not l_api_updating) and p_rt_age_uom IS NOT NULL then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_TM_UOM',
           p_lookup_code    => p_rt_age_uom,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_rt_age_uom');
      fnd_message.set_token('TYPE','BEN_TM_UOM');
      fnd_message.raise_error;
     --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_age_uom;
-- ---------------------------------------------------------------------------
-- |--------------------------<chk_once_r_cntug_cd>--------------------------|
-- ---------------------------------------------------------------------------
--
-- Description:
--  This procedure checks that a referenced foreign key actually exists
--  in the referenced table.
--
-- Pre Conditions
--  None.
--
-- In Parameters
--  p_elig_per_id PK
--  p_once_r_cntug_cd lookup
--  p_effective_date Session Date of record
--  p_object_version_number object version number
--
-- Post Success
--  Processing continues
--
-- Post Failure
--  Error raised
--
-- Access Status
--  Internal table handler use only.
--
Procedure chk_once_r_cntug_cd (p_elig_per_opt_id       in number,
                               p_once_r_cntug_cd       in varchar2,
                               p_effective_date        in date,
                               p_object_version_number in number) is
  --
  l_proc                varchar2(72) := g_package||'chk_once_r_cntug_cd';
  l_api_updating        boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_epo_shd.api_updating
    (p_elig_per_opt_id            => p_elig_per_opt_id,
     p_effective_date             => p_effective_date,
     p_object_version_number      => p_object_version_number);
  --
  if (l_api_updating
      and p_once_r_cntug_cd
      <> nvl(ben_epo_shd.g_old_rec.once_r_cntug_cd,hr_api.g_varchar2)
      or not l_api_updating) and p_once_r_cntug_cd IS NOT NULL then
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
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_once_r_cntug_cd');
      fnd_message.set_token('TYPE','BEN_ONCE_R_CNTNG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_once_r_cntug_cd;
-- ---------------------------------------------------------------------------
-- |--------------------------<chk_inelg_rsn_cd>-----------------------------|
-- ---------------------------------------------------------------------------
--
-- Description:
--  This procedure checks that a referenced foreign key actually exists
--  in the referenced table.
--
-- Pre Conditions
--  None.
--
-- In Parameters
--  p_elig_per_id PK
--  p_inelg_rsn_cd   lookup
--  p_effective_date Session Date of record
--  p_object_version_number object version number
--
-- Post Success
--  Processing continues
--
-- Post Failure
--  Error raised
--
-- Access Status
--  Internal table handler use only.
--
Procedure chk_inelg_rsn_cd (p_elig_per_opt_id       in number,
                            p_inelg_rsn_cd          in varchar2,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc                varchar2(72) := g_package||'chk_inelg_rsn_cd';
  l_api_updating        boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_epo_shd.api_updating
    (p_elig_per_opt_id            => p_elig_per_opt_id,
     p_effective_date             => p_effective_date,
     p_object_version_number      => p_object_version_number);
  --
  if (l_api_updating
      and p_inelg_rsn_cd
      <> nvl(ben_epo_shd.g_old_rec.inelg_rsn_cd,hr_api.g_varchar2)
      or not l_api_updating) and p_inelg_rsn_cd IS NOT NULL then
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
      fnd_message.set_token('FIELD','p_inelg_rsn_cd');
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
-- ---------------------------------------------------------------------------
-- |--------------------------<chk_los_uom>----------------------------------|
-- ---------------------------------------------------------------------------
--
-- Description:
--  This procedure checks that a referenced foreign key actually exists
--  in the referenced table.
--
-- Pre Conditions
--  None.
--
-- In Parameters
--  p_elig_per_id PK
--  p_los_uom ID of FK column
--  p_effective_date Session Date of record
--  p_object_version_number object version number
--
-- Post Success
--  Processing continues
--
-- Post Failure
--  Error raised
--
-- Access Status
--  Internal table handler use only.
--
Procedure chk_los_uom (p_elig_per_opt_id       in number,
                       p_los_val               in number,
                       p_los_uom               in varchar2,
                       p_rt_los_val            in number,
                       p_rt_los_uom            in varchar2,
                       p_effective_date        in date,
                       p_object_version_number in number) is
  --
  l_proc                varchar2(72) := g_package||'chk_los_uom';
  l_api_updating        boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if (p_los_val is null and p_los_uom is not null) or
     (p_los_uom is null and p_los_val is not null) then
    --
    fnd_message.set_name('BEN','BEN_91278_ELIG_PER_PRD_FLD_LOS');
    fnd_message.raise_error;
    --
  end if;
  --
  if (p_rt_los_val is null and p_rt_los_uom is not null) or
     (p_rt_los_uom is null and p_rt_los_val is not null) then
    --
    fnd_message.set_name('BEN','BEN_91278_ELIG_PER_PRD_FLD_LOS');
    fnd_message.raise_error;
    --
  end if;
  --
  l_api_updating := ben_epo_shd.api_updating
    (p_elig_per_opt_id            => p_elig_per_opt_id,
     p_effective_date             => p_effective_date,
     p_object_version_number      => p_object_version_number);
  --
  if (l_api_updating
      and p_los_uom
      <> nvl(ben_epo_shd.g_old_rec.los_uom,hr_api.g_varchar2)
      or not l_api_updating) and p_los_uom IS NOT NULL then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_TM_UOM',
           p_lookup_code    => p_los_uom,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_los_uom');
      fnd_message.set_token('TYPE','BEN_TM_UOM');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_rt_los_uom
      <> nvl(ben_epo_shd.g_old_rec.rt_los_uom,hr_api.g_varchar2)
      or not l_api_updating) and p_rt_los_uom IS NOT NULL then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_TM_UOM',
           p_lookup_code    => p_rt_los_uom,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_rt_los_uom');
      fnd_message.set_token('TYPE','BEN_TM_UOM');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_los_uom;
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_prtn_ovridn_rsn_cd >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_per_opt_id PK of record being inserted or updated.
--   prtn_ovridn_rsn_cd Value of lookup code.
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
Procedure chk_prtn_ovridn_rsn_cd(p_elig_per_opt_id             in number,
                                 p_prtn_ovridn_rsn_cd          in varchar2,
                                 p_effective_date              in date,
                                 p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtn_ovridn_rsn_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_epo_shd.api_updating
    (p_elig_per_opt_id             => p_elig_per_opt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_prtn_ovridn_rsn_cd
      <> nvl(ben_epo_shd.g_old_rec.prtn_ovridn_rsn_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_prtn_ovridn_rsn_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PRTN_OVRRIDN_RSN',
           p_lookup_code    => p_prtn_ovridn_rsn_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_prtn_ovridn_rsn_cd');
      fnd_message.set_token('TYPE','BEN_PRTN_OVRRIDN_RSN');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_prtn_ovridn_rsn_cd;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_elig_flag >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_per_opt_id PK of record being inserted or updated.
--   elig_flag Value of lookup code.
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
Procedure chk_elig_flag(p_elig_per_opt_id         in number,
                        p_elig_flag               in varchar2,
                        p_effective_date          in date,
                        p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_elig_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_epo_shd.api_updating
    (p_elig_per_opt_id             => p_elig_per_opt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_elig_flag
      <> nvl(ben_epo_shd.g_old_rec.elig_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_elig_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_elig_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_elig_flag;
--
-- ----------------------------------------------------------------------------
-- |-----------------< chk_no_mx_prtn_ovrid_thru_flag >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_per_opt_id PK of record being inserted or updated.
--   no_mx_prtn_ovrid_thru_flag Value of lookup code.
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
Procedure chk_no_mx_prtn_ovrid_thru_flag
             (p_elig_per_opt_id             in number,
              p_no_mx_prtn_ovrid_thru_flag  in varchar2,
              p_effective_date              in date,
              p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mx_prtn_ovrid_thru_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_epo_shd.api_updating
    (p_elig_per_opt_id             => p_elig_per_opt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mx_prtn_ovrid_thru_flag
      <> nvl(ben_epo_shd.g_old_rec.no_mx_prtn_ovrid_thru_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mx_prtn_ovrid_thru_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_no_mx_prtn_ovrid_thru_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mx_prtn_ovrid_thru_flag;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_all_freeze_flags >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_per_opt_id              PK of record being inserted or updated.
--   rt_frz_los_flag              Value of lookup code.
--   rt_frz_age_flag              Value of lookup code.
--   rt_frz_cmp_lvl_flag          Value of lookup code.
--   rt_frz_pct_fl_tm_flag        Value of lookup code.
--   rt_frz_hrs_wkd_flag          Value of lookup code.
--   rt_frz_comb_age_and_los_flag Value of lookup code.
--   frz_los_flag                 Value of lookup code.
--   frz_age_flag                 Value of lookup code.
--   frz_cmp_lvl_flag             Value of lookup code.
--   frz_pct_fl_tm_flag           Value of lookup code.
--   frz_hrs_wkd_flag             Value of lookup code.
--   frz_comb_age_and_los_flag    Value of lookup code.
--   effective_date               effective date
--   object_version_number        Object version number of record being
--                                inserted or updated.
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
Procedure chk_all_freeze_flags
             (p_elig_per_opt_id              in number,
              p_rt_frz_los_flag              in varchar2,
              p_rt_frz_age_flag              in varchar2,
              p_rt_frz_cmp_lvl_flag          in varchar2,
              p_rt_frz_pct_fl_tm_flag        in varchar2,
              p_rt_frz_hrs_wkd_flag          in varchar2,
              p_rt_frz_comb_age_and_los_flag in varchar2,
              p_frz_los_flag                 in varchar2,
              p_frz_age_flag                 in varchar2,
              p_frz_cmp_lvl_flag             in varchar2,
              p_frz_pct_fl_tm_flag           in varchar2,
              p_frz_hrs_wkd_flag             in varchar2,
              p_frz_comb_age_and_los_flag    in varchar2,
              p_effective_date               in date,
              p_object_version_number        in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_all_freeze_flags';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_epo_shd.api_updating
    (p_elig_per_opt_id             => p_elig_per_opt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  hr_utility.set_location('RFLF:'||l_proc, 5);
  if (l_api_updating
      and p_rt_frz_los_flag
      <> nvl(ben_epo_shd.g_old_rec.rt_frz_los_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    hr_utility.set_location('HRAPI_NEIHL:'||l_proc, 5);
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_rt_frz_los_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_rt_frz_los_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('RFAF:'||l_proc, 5);
  if (l_api_updating
      and p_rt_frz_age_flag
      <> nvl(ben_epo_shd.g_old_rec.rt_frz_age_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_rt_frz_age_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_rt_frz_age_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('RFCLF:'||l_proc, 5);
  if (l_api_updating
      and p_rt_frz_cmp_lvl_flag
      <> nvl(ben_epo_shd.g_old_rec.rt_frz_cmp_lvl_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_rt_frz_cmp_lvl_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_rt_cmp_lvl_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('RFPFTF:'||l_proc, 5);
  if (l_api_updating
      and p_rt_frz_pct_fl_tm_flag
      <> nvl(ben_epo_shd.g_old_rec.rt_frz_pct_fl_tm_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_rt_frz_pct_fl_tm_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_rt_frz_pct_fl_tm_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('RFHWF:'||l_proc, 5);
  if (l_api_updating
      and p_rt_frz_hrs_wkd_flag
      <> nvl(ben_epo_shd.g_old_rec.rt_frz_hrs_wkd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_rt_frz_hrs_wkd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_rt_frz_hrs_wkd_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('RFCAALF:'||l_proc, 5);
  if (l_api_updating
      and p_rt_frz_comb_age_and_los_flag
      <> nvl(ben_epo_shd.g_old_rec.rt_frz_comb_age_and_los_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_rt_frz_comb_age_and_los_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_rt_frz_comb_age_and_los_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('FLF:'||l_proc, 5);
  if (l_api_updating
      and p_frz_los_flag
      <> nvl(ben_epo_shd.g_old_rec.frz_los_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_frz_los_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_frz_los_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('FAF:'||l_proc, 5);
  if (l_api_updating
      and p_frz_age_flag
      <> nvl(ben_epo_shd.g_old_rec.frz_age_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_frz_age_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_frz_age_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('FCLF:'||l_proc, 5);
  if (l_api_updating
      and p_frz_cmp_lvl_flag
      <> nvl(ben_epo_shd.g_old_rec.frz_cmp_lvl_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_frz_cmp_lvl_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_frz_cmp_lvl_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('FPFTF:'||l_proc, 5);
  if (l_api_updating
      and p_frz_pct_fl_tm_flag
      <> nvl(ben_epo_shd.g_old_rec.frz_pct_fl_tm_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_frz_pct_fl_tm_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_frz_pct_fl_tm_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('FHWFF:'||l_proc, 5);
  if (l_api_updating
      and p_frz_hrs_wkd_flag
      <> nvl(ben_epo_shd.g_old_rec.frz_hrs_wkd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_frz_hrs_wkd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_frz_hrs_wkd_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_all_freeze_flags;
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_prtn_ovridn_flag >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_per_opt_id PK of record being inserted or updated.
--   prtn_ovridn_flag Value of lookup code.
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
Procedure chk_prtn_ovridn_flag(p_elig_per_opt_id             in number,
                               p_prtn_ovridn_flag            in varchar2,
                               p_effective_date              in date,
                               p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtn_ovridn_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_epo_shd.api_updating
    (p_elig_per_opt_id             => p_elig_per_opt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_prtn_ovridn_flag
      <> nvl(ben_epo_shd.g_old_rec.prtn_ovridn_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_prtn_ovridn_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_prtn_ovridn_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_prtn_ovridn_flag;
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
            (p_elig_per_id                   in number default hr_api.g_number,
             p_opt_id                        in number default hr_api.g_number,
         p_datetrack_mode             in varchar2,
             p_validation_start_date         in date,
         p_validation_end_date         in date) Is
--
  l_proc        varchar2(72) := g_package||'dt_update_validate';
  l_integrity_error Exception;
  l_table_name        all_tables.table_name%TYPE;
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
    If ((nvl(p_elig_per_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_elig_per_f',
             p_base_key_column => 'elig_per_id',
             p_base_key_value  => p_elig_per_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_elig_per_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_opt_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_opt_f',
             p_base_key_column => 'opt_id',
             p_base_key_value  => p_opt_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_opt_f';
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
    fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
    fnd_message.set_token('TABLE_NAME', l_table_name);
    fnd_message.raise_error;
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
            (p_elig_per_opt_id        in number,
             p_datetrack_mode        in varchar2,
         p_validation_start_date    in date,
         p_validation_end_date    in date) Is
--
  l_proc    varchar2(72)     := g_package||'dt_delete_validate';
  l_rows_exist    Exception;
  l_table_name    all_tables.table_name%TYPE;
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
       p_argument       => 'elig_per_opt_id',
       p_argument_value => p_elig_per_opt_id);
    --
    --
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
    fnd_message.set_name('PAY', 'HR_7215_DT_CHILD_EXISTS');
    fnd_message.set_token('TABLE_NAME', l_table_name);
    fnd_message.raise_error;
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
    (p_rec              in ben_epo_shd.g_rec_type,
     p_effective_date     in date,
     p_datetrack_mode     in varchar2,
     p_validation_start_date in date,
     p_validation_end_date     in date) is
--
  l_proc    varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_elig_per_opt_id
  (p_elig_per_opt_id       => p_rec.elig_per_opt_id,
   p_elig_per_id           => p_rec.elig_per_id,
   p_opt_id                => p_rec.opt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtn_ovridn_rsn_cd
  (p_elig_per_opt_id       => p_rec.elig_per_opt_id,
   p_prtn_ovridn_rsn_cd    => p_rec.prtn_ovridn_rsn_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_elig_flag
  (p_elig_per_opt_id       => p_rec.elig_per_opt_id,
   p_elig_flag             => p_rec.elig_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_prtn_ovrid_thru_flag
  (p_elig_per_opt_id            => p_rec.elig_per_opt_id,
   p_no_mx_prtn_ovrid_thru_flag => p_rec.no_mx_prtn_ovrid_thru_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_once_r_cntug_cd
  (p_elig_per_opt_id            => p_rec.elig_per_opt_id,
   p_once_r_cntug_cd            => p_rec.once_r_cntug_cd,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_prtn_ovridn_flag
  (p_elig_per_opt_id       => p_rec.elig_per_opt_id,
   p_prtn_ovridn_flag      => p_rec.prtn_ovridn_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_all_freeze_flags
  (p_elig_per_opt_id              => p_rec.elig_per_opt_id,
   p_rt_frz_los_flag              => p_rec.rt_frz_los_flag,
   p_rt_frz_age_flag              => p_rec.rt_frz_age_flag,
   p_rt_frz_cmp_lvl_flag          => p_rec.rt_frz_cmp_lvl_flag,
   p_rt_frz_pct_fl_tm_flag        => p_rec.rt_frz_pct_fl_tm_flag,
   p_rt_frz_hrs_wkd_flag          => p_rec.rt_frz_hrs_wkd_flag,
   p_rt_frz_comb_age_and_los_flag => p_rec.rt_frz_comb_age_and_los_flag,
   p_frz_los_flag                 => p_rec.frz_los_flag,
   p_frz_age_flag                 => p_rec.frz_age_flag,
   p_frz_cmp_lvl_flag             => p_rec.frz_cmp_lvl_flag,
   p_frz_pct_fl_tm_flag           => p_rec.frz_pct_fl_tm_flag,
   p_frz_hrs_wkd_flag             => p_rec.frz_hrs_wkd_flag,
   p_frz_comb_age_and_los_flag    => p_rec.frz_comb_age_and_los_flag,
   p_effective_date               => p_effective_date,
   p_object_version_number        => p_rec.object_version_number);
  --
  chk_comp_ref_uom
    (p_elig_per_opt_id       => p_rec.elig_per_opt_id,
     p_comp_ref_val          => p_rec.comp_ref_amt,
     p_comp_ref_uom          => p_rec.comp_ref_uom,
     p_rt_comp_ref_val       => p_rec.rt_comp_ref_amt,
     p_rt_comp_ref_uom       => p_rec.rt_comp_ref_uom,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
  --
  chk_hrs_wkd_bndry_perd_cd
    (p_elig_per_opt_id          => p_rec.elig_per_opt_id,
     p_hrs_wkd_bndry_perd_cd    => p_rec.hrs_wkd_bndry_perd_cd,
     p_rt_hrs_wkd_bndry_perd_cd => p_rec.rt_hrs_wkd_bndry_perd_cd,
     p_effective_date           => p_effective_date,
     p_object_version_number    => p_rec.object_version_number);
  --
  chk_pct_val
    (p_pct_val               => p_rec.pct_fl_tm_val,
     p_rt_pct_val            => p_rec.rt_pct_fl_tm_val);
  --
  chk_age_uom
    (p_elig_per_opt_id       => p_rec.elig_per_opt_id,
     p_age_val               => p_rec.age_val,
     p_age_uom               => p_rec.age_uom,
     p_rt_age_val            => p_rec.rt_age_val,
     p_rt_age_uom            => p_rec.rt_age_uom,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
  --
  chk_los_uom
    (p_elig_per_opt_id       => p_rec.elig_per_opt_id,
     p_los_val               => p_rec.los_val,
     p_los_uom               => p_rec.los_uom,
     p_rt_los_val            => p_rec.rt_los_val,
     p_rt_los_uom            => p_rec.rt_los_uom,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
  --
  chk_inelg_rsn_cd
    (p_elig_per_opt_id       => p_rec.elig_per_opt_id,
     p_inelg_rsn_cd          => p_rec.inelg_rsn_cd,
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
    (p_rec              in ben_epo_shd.g_rec_type,
     p_effective_date     in date,
     p_datetrack_mode     in varchar2,
     p_validation_start_date in date,
     p_validation_end_date     in date) is
--
  l_proc    varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_elig_per_opt_id
  (p_elig_per_opt_id       => p_rec.elig_per_opt_id,
   p_elig_per_id           => p_rec.elig_per_id,
   p_opt_id                => p_rec.opt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtn_ovridn_rsn_cd
  (p_elig_per_opt_id       => p_rec.elig_per_opt_id,
   p_prtn_ovridn_rsn_cd    => p_rec.prtn_ovridn_rsn_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_elig_flag
  (p_elig_per_opt_id       => p_rec.elig_per_opt_id,
   p_elig_flag             => p_rec.elig_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_prtn_ovrid_thru_flag
  (p_elig_per_opt_id            => p_rec.elig_per_opt_id,
   p_no_mx_prtn_ovrid_thru_flag => p_rec.no_mx_prtn_ovrid_thru_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_once_r_cntug_cd
  (p_elig_per_opt_id            => p_rec.elig_per_opt_id,
   p_once_r_cntug_cd            => p_rec.once_r_cntug_cd,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_prtn_ovridn_flag
  (p_elig_per_opt_id       => p_rec.elig_per_opt_id,
   p_prtn_ovridn_flag      => p_rec.prtn_ovridn_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_all_freeze_flags
  (p_elig_per_opt_id              => p_rec.elig_per_opt_id,
   p_rt_frz_los_flag              => p_rec.rt_frz_los_flag,
   p_rt_frz_age_flag              => p_rec.rt_frz_age_flag,
   p_rt_frz_cmp_lvl_flag          => p_rec.rt_frz_cmp_lvl_flag,
   p_rt_frz_pct_fl_tm_flag        => p_rec.rt_frz_pct_fl_tm_flag,
   p_rt_frz_hrs_wkd_flag          => p_rec.rt_frz_hrs_wkd_flag,
   p_rt_frz_comb_age_and_los_flag => p_rec.rt_frz_comb_age_and_los_flag,
   p_frz_los_flag                 => p_rec.frz_los_flag,
   p_frz_age_flag                 => p_rec.frz_age_flag,
   p_frz_cmp_lvl_flag             => p_rec.frz_cmp_lvl_flag,
   p_frz_pct_fl_tm_flag           => p_rec.frz_pct_fl_tm_flag,
   p_frz_hrs_wkd_flag             => p_rec.frz_hrs_wkd_flag,
   p_frz_comb_age_and_los_flag    => p_rec.frz_comb_age_and_los_flag,
   p_effective_date               => p_effective_date,
   p_object_version_number        => p_rec.object_version_number);
  --
  chk_comp_ref_uom
    (p_elig_per_opt_id       => p_rec.elig_per_opt_id,
     p_comp_ref_val          => p_rec.comp_ref_amt,
     p_comp_ref_uom          => p_rec.comp_ref_uom,
     p_rt_comp_ref_val       => p_rec.rt_comp_ref_amt,
     p_rt_comp_ref_uom       => p_rec.rt_comp_ref_uom,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
  --
  chk_hrs_wkd_bndry_perd_cd
    (p_elig_per_opt_id          => p_rec.elig_per_opt_id,
     p_hrs_wkd_bndry_perd_cd    => p_rec.hrs_wkd_bndry_perd_cd,
     p_rt_hrs_wkd_bndry_perd_cd => p_rec.rt_hrs_wkd_bndry_perd_cd,
     p_effective_date           => p_effective_date,
     p_object_version_number    => p_rec.object_version_number);
  --
  chk_pct_val
    (p_pct_val               => p_rec.pct_fl_tm_val,
     p_rt_pct_val            => p_rec.rt_pct_fl_tm_val);
  --
  chk_age_uom
    (p_elig_per_opt_id       => p_rec.elig_per_opt_id,
     p_age_val               => p_rec.age_val,
     p_age_uom               => p_rec.age_uom,
     p_rt_age_val            => p_rec.rt_age_val,
     p_rt_age_uom            => p_rec.rt_age_uom,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
  --
  chk_los_uom
    (p_elig_per_opt_id       => p_rec.elig_per_opt_id,
     p_los_val               => p_rec.los_val,
     p_los_uom               => p_rec.los_uom,
     p_rt_los_val            => p_rec.rt_los_val,
     p_rt_los_uom            => p_rec.rt_los_uom,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
  --
  chk_inelg_rsn_cd
    (p_elig_per_opt_id       => p_rec.elig_per_opt_id,
     p_inelg_rsn_cd          => p_rec.inelg_rsn_cd,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_elig_per_id                   => p_rec.elig_per_id,
     p_opt_id                        => p_rec.opt_id,
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date         => p_validation_start_date,
     p_validation_end_date         => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
    (p_rec              in ben_epo_shd.g_rec_type,
     p_effective_date     in date,
     p_datetrack_mode     in varchar2,
     p_validation_start_date in date,
     p_validation_end_date     in date) is
--
  l_proc    varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode        => p_datetrack_mode,
     p_validation_start_date    => p_validation_start_date,
     p_validation_end_date    => p_validation_end_date,
     p_elig_per_opt_id        => p_rec.elig_per_opt_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_elig_per_opt_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_elig_per_opt_f b
    where b.elig_per_opt_id      = p_elig_per_opt_id
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
                             p_argument       => 'elig_per_opt_id',
                             p_argument_value => p_elig_per_opt_id);
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
end ben_epo_bus;

/
