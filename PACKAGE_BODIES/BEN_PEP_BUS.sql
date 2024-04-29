--------------------------------------------------------
--  DDL for Package Body BEN_PEP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PEP_BUS" as
/* $Header: bepeprhi.pkb 120.0 2005/05/28 10:39:57 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)    := '  ben_pep_bus.';  -- Global package name
--
-- ---------------------------------------------------------------------------
-- |------------------------- <return_legislation_code>-----------------------|
-- ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_elig_per_id in number) return varchar2 is
  --
  --Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from per_business_groups a,
         ben_elig_per_f b
    where b.elig_per_id = p_elig_per_id
    and   a.business_group_id = b.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code varchar2(150);
  l_proc varchar2(72) := g_package||'return_legislation_code';
  --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc, 10);
    --
    --Ensure that all the mandatory parameters are not null
    --
    hr_api.mandatory_arg_error(p_api_name => l_proc,
                               p_argument => 'elig_per_id',
                               p_argument_value => p_elig_per_id);
    --
    open csr_leg_code;
      --
      fetch csr_leg_code into l_legislation_code;
      --
      if csr_leg_code%notfound then
        --
        close csr_leg_code;
        --
        --The primary key is invalid therefore we must error
        --
        hr_utility.set_message (801, 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
        --
      end if;
      --
    close csr_leg_code;
    --
    hr_utility.set_location('Leaving :'||l_proc,20);
    --
    return l_legislation_code;
    --
 end return_legislation_code;
-- ----------------------------------------------------------------------------
-- |--------------------------<chk_elig_per_id>-------------------------------|
-- ---------------------------------------------------------------------------
--
-- Description
--  This procedure is used to check that the primary key for the table
--  is created properly.  It should be null on insert and
--  should not be able to be updated.
--
-- Pre Conditions
--
--  None.
--
-- In Parameters
--  elig_per_id        PK of record being inserted or updated
--  effective_date      Effective Date of Session
--  object_version_number Object version number of record being
--                      inserted or updated.
--
-- Post Success
--  Processing continues
--
-- Post Failure
--  Errors handled by the procedure.
--
-- Access Status
--  Internal table handler use only.
--
Procedure chk_elig_per_id (p_elig_per_id in number,
                           p_effective_date in date,
                           p_object_version_number in number) is
  --
  l_proc  varchar2(72) := g_package||'chk_elig_per_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering: '||l_proc,5);
  --
  l_api_updating := ben_pep_shd.api_updating
    (p_effective_date    => p_effective_date,
     p_elig_per_id       => p_elig_per_id,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_elig_per_id, hr_api.g_number)
     <> ben_pep_shd.g_old_rec.elig_per_id) then
    --
    -- raise error as PK as changed
    --
    ben_pep_shd.constraint_error('BEN_ELIG_PER_F_PK');
    --
  elsif not l_api_updating then
    --
    --check if PK is null
    --
    if p_elig_per_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_pep_shd.constraint_error('BEN_ELIG_PER_F_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc,10);
  --
end chk_elig_per_id;
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
--  p_elig_per_id PK
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
Procedure chk_comp_ref_uom (p_elig_per_id in number,
                            p_comp_ref_val in number,
                            p_comp_ref_uom in varchar2,
                            p_rt_comp_ref_val in number,
                            p_rt_comp_ref_uom in varchar2,
                            p_effective_date in date,
                            p_object_version_number in number) is
  --
  l_proc        varchar2(72) := g_package||'chk_comp_ref_uom';
  l_api_updating    boolean;
  l_dummy        varchar2(1);
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
  l_api_updating:= ben_pep_shd.api_updating
     (p_elig_per_id           => p_elig_per_id,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
      and p_comp_ref_uom
      <> nvl(ben_pep_shd.g_old_rec.comp_ref_uom,hr_api.g_varchar2)
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
        --
        --raise error as FK does not relate to PK in hr_lookups
        --table.
        --
        ben_pep_shd.constraint_error('BEN_ELIG_PER_HL1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  if (l_api_updating
      and p_rt_comp_ref_uom
      <> nvl(ben_pep_shd.g_old_rec.rt_comp_ref_uom,hr_api.g_varchar2)
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
        --
        --raise error as FK does not relate to PK in hr_lookups
        --table.
        --
        ben_pep_shd.constraint_error('BEN_ELIG_PER_HL1');
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
--
-- ---------------------------------------------------------------------------
-- |--------------------------<chk_at_least_one_fk_set>----------------------|
-- ---------------------------------------------------------------------------
--
-- Description:
--  This procedure checks that either the plan
--                                        plan and program
--                                        plan type in program
--                                        plan in program
--                                        is populated.
--
-- Pre Conditions
--  None.
--
-- In Parameters
--  p_pl_id ID of FK column
--  p_pgm_id ID of FK column
--  p_plip_id ID of FK column
--  p_ptip_id ID of FK column
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
Procedure chk_at_least_one_fk_set(p_pl_id             in number,
                                  p_pgm_id            in number,
                                  p_plip_id           in number,
                                  p_ptip_id           in number,
                                  p_effective_date    in date,
                                p_business_group_id in number) is
  --
  l_proc        varchar2(72) := g_package||'chk_at_least_one_fk_set';
  l_api_updating    boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select pgm_id
    from   ben_plip_f plip
    where  plip.pl_id = p_pl_id
    and    business_group_id + 0 = p_business_group_id
    and    p_effective_date
           between plip.effective_start_date
           and     plip.effective_end_date;
  --
  l_pgm_id        ben_pgm_f.pgm_id%type;
  --
begin
  --
  hr_utility.set_location('Entering :'||l_proc,5);
  --
  if p_pl_id is null and
     p_pgm_id is null and
     p_plip_id is null and
     p_ptip_id is null then
    --
    fnd_message.set_name('BEN','BEN_91312_ELIG_PER_PL_PGM');
    fnd_message.raise_error;
    --
  end if;
  --
  open c1;
    --
    fetch c1 into l_pgm_id;
    --
    if p_pgm_id is null and l_pgm_id is not null then
      --
      close c1;
      fnd_message.set_name('BEN','BEN_92121_PL_IN_PGM');
      fnd_message.raise_error;
      --
    end if;
    --
  close c1;
  --
  hr_utility.set_location('Leaving :'||l_proc,10);
  --
end chk_at_least_one_fk_set;
--
-- ---------------------------------------------------------------------------
-- |--------------------------<chk_wv_prtn_rsn_cd>---------------------------|
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
Procedure chk_wv_prtn_rsn_cd(p_elig_per_id in number,
                             p_pl_wvd_flag in varchar2,
                             p_wv_prtn_rsn_cd in varchar2,
                             p_effective_date in date,
                             p_object_version_number in number) is
  --
  l_proc        varchar2(72) := g_package||'chk_wv_prtn_rsn_cd';
  l_api_updating    boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if (p_pl_wvd_flag = 'N' and p_wv_prtn_rsn_cd is not null) then
    --
    fnd_message.set_name('BEN','BEN_91280_ELIG_PER_PRD_FLD_WV');
    fnd_message.raise_error;
    --
  end if;
  --
  l_api_updating := ben_pep_shd.api_updating
    (p_elig_per_id                => p_elig_per_id,
     p_effective_date             => p_effective_date,
     p_object_version_number      => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_wv_prtn_rsn_cd,hr_api.g_varchar2)
      <> nvl(ben_pep_shd.g_old_rec.wv_prtn_rsn_cd,hr_api.g_varchar2)
      or not l_api_updating) and p_wv_prtn_rsn_cd IS NOT NULL then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_WV_PRTN_RSN',
           p_lookup_code    => p_wv_prtn_rsn_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_wv_prtn_rsn_cd');
      fnd_message.set_token('TYPE','BEN_WV_PRTN_RSN');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_wv_prtn_rsn_cd;
--
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
Procedure chk_hrs_wkd_bndry_perd_cd (p_elig_per_id           in number,
                                     p_hrs_wkd_bndry_perd_cd in varchar2,
                                     p_rt_hrs_wkd_bndry_perd_cd in varchar2,
                                     p_effective_date        in date,
                                     p_object_version_number in number) is
  --
  l_proc        varchar2(72) := g_package||'chk_hrs_wkd_bndry_perd_cd';
  l_api_updating    boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pep_shd.api_updating
    (p_elig_per_id                 => p_elig_per_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_hrs_wkd_bndry_perd_cd,hr_api.g_varchar2)
      <> nvl(ben_pep_shd.g_old_rec.hrs_wkd_bndry_perd_cd,hr_api.g_varchar2)
      or not l_api_updating) and p_hrs_wkd_bndry_perd_cd IS NOT NULL then
    --
    -- check if value of lookup falls within lookup type.
    --
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
      <> nvl(ben_pep_shd.g_old_rec.rt_hrs_wkd_bndry_perd_cd,hr_api.g_varchar2)
      or not l_api_updating) and p_rt_hrs_wkd_bndry_perd_cd IS NOT NULL then
    --
    -- check if value of lookup falls within lookup type.
    --
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
--
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
  l_proc        varchar2(72) := g_package||'chk_chk_pct_val';
  l_api_updating    boolean;
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
-- |--------------------------<chk_wv_ctfn_typ_cd>---------------------------|
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
--  p_wv_ctfn_typ_cd ID of FK column
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
Procedure chk_wv_ctfn_typ_cd (p_elig_per_id           in number,
                              p_pl_wvd_flag           in varchar2,
                              p_wv_ctfn_typ_cd        in varchar2,
                              p_effective_date        in date,
                              p_object_version_number in number) is
  --
  l_proc        varchar2(72) := g_package||'chk_wv_ctfn_typ_cd';
  l_api_updating    boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if (p_pl_wvd_flag = 'N' and p_wv_ctfn_typ_cd is not null) then
        fnd_message.set_name('BEN','BEN_91280_ELIG_PER_PRD_FLD_WV');
        fnd_message.raise_error;
  end if;
  --
  l_api_updating := ben_pep_shd.api_updating
    (p_elig_per_id                => p_elig_per_id,
     p_effective_date             => p_effective_date,
     p_object_version_number      => p_object_version_number);
  --
  if (l_api_updating
      and p_wv_ctfn_typ_cd
      <> nvl(ben_pep_shd.g_old_rec.wv_ctfn_typ_cd,hr_api.g_varchar2)
      or not l_api_updating) and p_wv_ctfn_typ_cd IS NOT NULL then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_WV_PRTN_CTFN_TYP',
           p_lookup_code    => p_wv_ctfn_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_wv_ctfn_typ_cd');
      fnd_message.set_token('TYPE','BEN_WV_PRTN_CTFN_TYP');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_wv_ctfn_typ_cd;
--
-- ---------------------------------------------------------------------------
-- |--------------------------<chk_prtn_ovridn_rsn_cd>-----------------------|
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
--  p_prtn_ovridn_rsn_cd ID of FK column
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
Procedure chk_prtn_ovridn_rsn_cd (p_elig_per_id           in number,
                                  p_prtn_ovridn_thru_dt   in date,
                                  p_prtn_ovridn_flag      in varchar2,
                                  p_prtn_ovridn_rsn_cd    in varchar2,
                                  p_effective_date        in date,
                                  p_object_version_number in number) is
  --
  l_proc        varchar2(72) := g_package||'chk_prtn_ovridn_rsn_cd';
  l_api_updating    boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  /*if (p_prtn_ovridn_flag = 'N' and p_prtn_ovridn_rsn_cd is not null) or
     (p_prtn_ovridn_flag = 'N' and p_prtn_ovridn_thru_dt is not null) then
        fnd_message.set_name('BEN','BEN_91279_ELIG_PER_PRD_FLD_OVR');
        fnd_message.raise_error;
  end if;*/
  --
  l_api_updating := ben_pep_shd.api_updating
    (p_elig_per_id                => p_elig_per_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_prtn_ovridn_rsn_cd
      <> nvl(ben_pep_shd.g_old_rec.prtn_ovridn_rsn_cd,hr_api.g_varchar2)
      or not l_api_updating) and p_prtn_ovridn_rsn_cd IS NOT NULL then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_OVRID_RSN',
           p_lookup_code    => p_prtn_ovridn_rsn_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_prtn_ovridn_rsn_cd');
      fnd_message.set_token('TYPE','BEN_OVRID_RSN');
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
Procedure chk_age_uom (p_elig_per_id           in number,
                       p_age_val               in number,
                       p_age_uom               in varchar2,
                       p_rt_age_val            in number,
                       p_rt_age_uom            in varchar2,
                       p_effective_date        in date,
                       p_object_version_number in number) is
  --
  l_proc        varchar2(72) := g_package||'chk_age_uom';
  l_api_updating    boolean;
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
  l_api_updating := ben_pep_shd.api_updating
    (p_elig_per_id                => p_elig_per_id,
     p_effective_date             => p_effective_date,
     p_object_version_number      => p_object_version_number);
  --
  if (l_api_updating
      and p_age_uom
      <> nvl(ben_pep_shd.g_old_rec.age_uom,hr_api.g_varchar2)
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
      <> nvl(ben_pep_shd.g_old_rec.rt_age_uom,hr_api.g_varchar2)
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
--
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
Procedure chk_los_uom (p_elig_per_id           in number,
                       p_los_val               in number,
                       p_los_uom               in varchar2,
                       p_rt_los_val            in number,
                       p_rt_los_uom            in varchar2,
                       p_effective_date        in date,
                       p_object_version_number in number) is
  --
  l_proc        varchar2(72) := g_package||'chk_los_uom';
  l_api_updating    boolean;
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
  l_api_updating := ben_pep_shd.api_updating
    (p_elig_per_id                => p_elig_per_id,
     p_effective_date             => p_effective_date,
     p_object_version_number      => p_object_version_number);
  --
  if (l_api_updating
      and p_los_uom
      <> nvl(ben_pep_shd.g_old_rec.los_uom,hr_api.g_varchar2)
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
      <> nvl(ben_pep_shd.g_old_rec.rt_los_uom,hr_api.g_varchar2)
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
--
-- ----------------------------------------------------------------------------
-- |--------------------------<chk_once_r_cntug_cd>---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure is used to check that the Flags are valid.
--
-- Pre Conditions
--  None.
--
-- In Parameters
--  <primarykey>PK of record being inserted into or updated.
--  <code name> Name of the flag column.
--  <effective date> effective date
--  <object version number> Object version number of record being inserted
--   or updated.
--
-- Post Success
--  Process conintues
--
-- Post Failure
--  Error handled by procedure
--
-- Access Status
--  Internal table handler use only.
--
Procedure chk_once_r_cntug_cd
             (p_elig_per_id                in number,
              p_once_r_cntug_cd            in varchar2,
              p_effective_date             in date,
              p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_once_r_cntug_cd';
  l_api_updating boolean;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc,5);
  --
  l_api_updating := ben_pep_shd.api_updating
    (p_elig_per_id           => p_elig_per_id,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating and p_once_r_cntug_cd
      <> nvl(ben_pep_shd.g_old_rec.once_r_cntug_cd,hr_api.g_varchar2)
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
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_once_r_cntug_cd');
      fnd_message.set_token('TYPE','BEN_ONCE_R_CNTNG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc, 10);
  --
end chk_once_r_cntug_cd;
-- ----------------------------------------------------------------------------
-- |--------------------------<chk_no_mx_prtn_ovrid_thru_flag>----------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure is used to check that the Flags are valid.
--
-- Pre Conditions
--  None.
--
-- In Parameters
--  <primarykey>PK of record being inserted into or updated.
--  <flag name> Name of the flag column.
--  <effective date> effective date
--  <object version number> Object version number of record being inserted
--   or updated.
--
-- Post Success
--  Process conintues
--
-- Post Failure
--  Error handled by procedure
--
-- Access Status
--  Internal table handler use only.
--
Procedure chk_no_mx_prtn_ovrid_thru_flag
             (p_elig_per_id                in number,
              p_no_mx_prtn_ovrid_thru_flag in varchar2,
              p_effective_date             in date,
              p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mx_prtn_ovrid_thru_flag';
  l_api_updating boolean;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc,5);
  --
  l_api_updating := ben_pep_shd.api_updating
    (p_elig_per_id           => p_elig_per_id,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating and p_no_mx_prtn_ovrid_thru_flag
      <> nvl(ben_pep_shd.g_old_rec.no_mx_prtn_ovrid_thru_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_no_mx_prtn_ovrid_thru_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
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
  hr_utility.set_location('Leaving: '||l_proc, 10);
  --
end chk_no_mx_prtn_ovrid_thru_flag;
--
-- ---------------------------------------------------------------------------
-- |--------------------------<chk_frz_comb_age_and_los_flag>----------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure is used to check that the Flags are valid.
--
-- Pre Conditions
--  None.
--
-- In Parameters
--  <primarykey>PK of record being inserted into or updated.
--  <flag name> Name of the flag column.
--  <effective date> effective date
--  <object version number> Object version number of record being inserted
--   or updated.
--
-- Post Success
--  Process conintues
--
-- Post Failure
--  Error handled by procedure
--
-- Access Status
--  Internal table handler use only.
--
Procedure chk_frz_comb_age_and_los_flag
             (p_elig_per_id                  in number,
              p_frz_comb_age_and_los_flag    in varchar2,
              p_rt_frz_comb_age_and_los_flag in varchar2,
              p_effective_date               in date,
              p_object_version_number        in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_frz_comb_age_and_los_flag';
  l_api_updating boolean;
  --
begin
  --
/*
  hr_utility.set_location('Entering: '||l_proc,5);
*/
  --
  l_api_updating := ben_pep_shd.api_updating
    (p_elig_per_id           => p_elig_per_id,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating and p_frz_comb_age_and_los_flag
      <> nvl(ben_pep_shd.g_old_rec.frz_comb_age_and_los_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_frz_comb_age_and_los_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
/*
    hr_utility.set_location('HRAPI_NEIHL:'||l_proc, 5);
*/
    if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_frz_comb_age_and_los_flag,
        p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_frz_comb_age_and_los_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
/*
    hr_utility.set_location('Dn HRAPI_NEIHL:'||l_proc, 5);
*/
    --
  end if;
  --
  if (l_api_updating and p_rt_frz_comb_age_and_los_flag
      <> nvl(ben_pep_shd.g_old_rec.rt_frz_comb_age_and_los_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rt_frz_comb_age_and_los_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
/*
    hr_utility.set_location('HRAPI_NEIHL:'||l_proc, 5);
*/
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
/*
    hr_utility.set_location('Dn HRAPI_NEIHL:'||l_proc, 5);
*/
    --
  end if;
  --
/*
  hr_utility.set_location('Leaving: '||l_proc, 10);
*/
  --
end chk_frz_comb_age_and_los_flag;
--
-- ----------------------------------------------------------------------------
-- |--------------------------<chk_dpnt_othr_pl_cvrd_rl_flag>----------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure is used to check that the Flags are valid.
--
-- Pre Conditions
--  None.
--
-- In Parameters
--  <primarykey>PK of record being inserted into or updated.
--  <flag name> Name of the flag column.
--  <effective date> effective date
--  <object version number> Object version number of record being inserted
--   or updated.
--
-- Post Success
--  Process conintues
--
-- Post Failure
--  Error handled by procedure
--
-- Access Status
--  Internal table handler use only.
--
Procedure chk_dpnt_othr_pl_cvrd_rl_flag
          (p_elig_per_id               in number,
           p_dpnt_othr_pl_cvrd_rl_flag in varchar2,
           p_effective_date            in date,
           p_object_version_number     in number) is
  --
  l_proc  varchar2(72) := g_package||'chk_dpnt_othr_pl_cvrd_rl_flag';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
Begin
  --
/*
  hr_utility.set_location('Entering: '||l_proc,5);
*/
  --
  l_api_updating := ben_pep_shd.api_updating
  (p_elig_per_id => p_elig_per_id,
   p_effective_date => p_effective_date,
   p_object_version_number => p_object_version_number);
  --
  if (l_api_updating and p_dpnt_othr_pl_cvrd_rl_flag
      <> nvl(ben_pep_shd.g_old_rec.dpnt_othr_pl_cvrd_rl_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_dpnt_othr_pl_cvrd_rl_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_dpnt_othr_pl_cvrd_rl_flag,
         p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_dpnt_othr_pl_cvrd_rl_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc, 10);
  --
end chk_dpnt_othr_pl_cvrd_rl_flag;
--
-- ----------------------------------------------------------------------------
-- |--------------------------<chk_pl_key_ee_flag>---------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure is used to check that the Flags are valid.
--
-- Pre Conditions
--  None.
--
-- In Parameters
--  <primarykey>PK of record being inserted into or updated.
--  <flag name> Name of the flag column.
--  <effective date> effective date
--  <object version number> Object version number of record being inserted
--   or updated.
--
-- Post Success
--  Process conintues
--
-- Post Failure
--  Error handled by procedure
--
-- Access Status
--  Internal table handler use only.
--
Procedure chk_pl_key_ee_flag(p_elig_per_id           in number,
                             p_pl_key_ee_flag        in varchar2,
                             p_effective_date        in date,
                             p_object_version_number in number) is
  --
  l_proc  varchar2(72) := g_package||'chk_pl_key_ee_flag';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering: '||l_proc,5);
  --
  l_api_updating := ben_pep_shd.api_updating
  (p_elig_per_id => p_elig_per_id,
   p_effective_date => p_effective_date,
   p_object_version_number => p_object_version_number);
  --
  if (l_api_updating and p_pl_key_ee_flag
      <> nvl(ben_pep_shd.g_old_rec.pl_key_ee_flag, hr_api.g_varchar2)
      or not l_api_updating)
      and p_pl_key_ee_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
      (p_lookup_type    => 'YES_NO',
       p_lookup_code    => p_pl_key_ee_flag,
       p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_pl_key_ee_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc, 10);
  --
end chk_pl_key_ee_flag;
--
-- ----------------------------------------------------------------------------
-- |--------------------------<chk_prtn_ovridn_flag>-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure is used to check that the Flags are valid.
--
-- Pre Conditions
--  None.
--
-- In Parameters
--  <primarykey>PK of record being inserted into or updated.
--  <flag name> Name of the flag column.
--  <effective date> effective date
--  <object version number> Object version number of record being inserted
--   or updated.
--
-- Post Success
--  Process conintues
--
-- Post Failure
--  Error handled by procedure
--
-- Access Status
--  Internal table handler use only.
--
Procedure chk_prtn_ovridn_flag(p_elig_per_id           in number,
                               p_prtn_ovridn_flag      in varchar2,
                               p_effective_date        in date,
                               p_object_version_number in number) is
  --
  l_proc  varchar2(72) := g_package||'chk_prtn_ovridn_flag';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering: '||l_proc,5);
  --
  l_api_updating := ben_pep_shd.api_updating
  (p_elig_per_id => p_elig_per_id,
   p_effective_date => p_effective_date,
   p_object_version_number => p_object_version_number);
  --
  if (l_api_updating and p_prtn_ovridn_flag
      <> nvl(ben_pep_shd.g_old_rec.prtn_ovridn_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_prtn_ovridn_flag is not null then
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
  hr_utility.set_location('Leaving: '||l_proc, 10);
  --
end chk_prtn_ovridn_flag;
--
-- ----------------------------------------------------------------------------
-- |--------------------------<chk_pl_hghly_compd_flag>-----------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure is used to check that the Flags are valid.
--
-- Pre Conditions
--  None.
--
-- In Parameters
--  <primarykey>PK of record being inserted into or updated.
--  <flag name> Name of the flag column.
--  <effective date> effective date
--  <object version number> Object version number of record being inserted
--   or updated.
--
-- Post Success
--  Process conintues
--
-- Post Failure
--  Error handled by procedure
--
-- Access Status
--  Internal table handler use only.
--
Procedure chk_pl_hghly_compd_flag(p_elig_per_id           in number,
                                  p_pl_hghly_compd_flag   in varchar2,
                                  p_effective_date        in date,
                                  p_object_version_number in number) is
  --
  l_proc  varchar2(72) := g_package||'chk_pl_hghly_compd_flag';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering: '||l_proc,5);
  --
  l_api_updating := ben_pep_shd.api_updating
  (p_elig_per_id => p_elig_per_id,
   p_effective_date => p_effective_date,
   p_object_version_number => p_object_version_number);
  --
  if (l_api_updating and p_pl_hghly_compd_flag
      <> nvl(ben_pep_shd.g_old_rec.pl_hghly_compd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pl_hghly_compd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    hr_utility.set_location('HRAPI_NEIHL:'||l_proc, 5);
    if hr_api.not_exists_in_hr_lookups
      (p_lookup_type    => 'YES_NO',
       p_lookup_code    => p_pl_hghly_compd_flag,
       p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_pl_hghly_compd_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    hr_utility.set_location('Dn HRAPI_NEIHL:'||l_proc, 5);
    --
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc, 10);
  --
end chk_pl_hghly_compd_flag;
--
-- ----------------------------------------------------------------------------
-- |--------------------------<chk_frz_los_flag>------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure is used to check that the Flags are valid.
--
-- Pre Conditions
--  None.
--
-- In Parameters
--  <primarykey>PK of record being inserted into or updated.
--  <flag name> Name of the flag column.
--  <effective date> effective date
--  <object version number> Object version number of record being inserted
--   or updated.
--
-- Post Success
--  Process conintues
--
-- Post Failure
--  Error handled by procedure
--
-- Access Status
--  Internal table handler use only.
--
Procedure chk_frz_los_flag(p_elig_per_id           in number,
                           p_frz_los_flag          in varchar2,
                           p_rt_frz_los_flag       in varchar2,
                           p_effective_date        in date,
                           p_object_version_number in number) is
  --
  l_proc  varchar2(72) := g_package||'chk_frz_los_flag';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
Begin
  --
/*
  hr_utility.set_location('Entering: '||l_proc,5);
*/
  --
  l_api_updating := ben_pep_shd.api_updating
  (p_elig_per_id => p_elig_per_id,
   p_effective_date => p_effective_date,
   p_object_version_number => p_object_version_number);
  --
  if (l_api_updating and p_frz_los_flag
      <> nvl(ben_pep_shd.g_old_rec.frz_los_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_frz_los_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
/*
    hr_utility.set_location('HRAPI_NEIHL:'||l_proc, 5);
*/
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
/*
    hr_utility.set_location('Dn HRAPI_NEIHL:'||l_proc, 5);
*/
    --
  end if;
  --
  if (l_api_updating and p_rt_frz_los_flag
      <> nvl(ben_pep_shd.g_old_rec.rt_frz_los_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rt_frz_los_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
/*
    hr_utility.set_location('HRAPI_NEIHL:'||l_proc, 5);
*/
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
/*
    hr_utility.set_location('Dn HRAPI_NEIHL:'||l_proc, 5);
*/
    --
  end if;
  --
/*
  hr_utility.set_location('Leaving: '||l_proc, 10);
*/
  --
end chk_frz_los_flag;
--
-- ----------------------------------------------------------------------------
-- |--------------------------<chk_frz_age_flag>------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure is used to check that the Flags are valid.
--
-- Pre Conditions
--  None.
--
-- In Parameters
--  <primarykey>PK of record being inserted into or updated.
--  <flag name> Name of the flag column.
--  <effective date> effective date
--  <object version number> Object version number of record being inserted
--   or updated.
--
-- Post Success
--  Process conintues
--
-- Post Failure
--  Error handled by procedure
--
-- Access Status
--  Internal table handler use only.
--
Procedure chk_frz_age_flag(p_elig_per_id           in number,
                           p_frz_age_flag          in varchar2,
                           p_rt_frz_age_flag       in varchar2,
                           p_effective_date        in date,
                           p_object_version_number in number) is
  --
  l_proc  varchar2(72) := g_package||'chk_frz_age_flag';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
Begin
  --
/*
  hr_utility.set_location('Entering: '||l_proc,5);
*/
  --
  l_api_updating := ben_pep_shd.api_updating
  (p_elig_per_id => p_elig_per_id,
   p_effective_date => p_effective_date,
   p_object_version_number => p_object_version_number);
  --
  if (l_api_updating and p_frz_age_flag
      <> nvl(ben_pep_shd.g_old_rec.frz_age_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_frz_age_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
/*
    hr_utility.set_location('HRAPI_NEIHL:'||l_proc, 5);
*/
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
/*
    hr_utility.set_location('Dn HRAPI_NEIHL:'||l_proc, 5);
*/
    --
  end if;
  --
  if (l_api_updating and p_rt_frz_age_flag
      <> nvl(ben_pep_shd.g_old_rec.rt_frz_age_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rt_frz_age_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
/*
    hr_utility.set_location('HRAPI_NEIHL:'||l_proc, 5);
*/
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
/*
    hr_utility.set_location('Dn HRAPI_NEIHL:'||l_proc, 5);
*/
    --
  end if;
  --
/*
  hr_utility.set_location('Leaving: '||l_proc, 10);
*/
  --
end chk_frz_age_flag;
--
-- ---------------------------------------------------------------------------
-- |---------------------<chk_frz_cmp_lvl_flag>------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure is used to check that the Flags are valid.
--
-- Pre Conditions
--  None.
--
-- In Parameters
--  <primarykey>PK of record being inserted into or updated.
--  <flag name> Name of the flag column.
--  <effective date> effective date
--  <object version number> Object version number of record being inserted
--   or updated.
--
-- Post Success
--  Process conintues
--
-- Post Failure
--  Error handled by procedure
--
-- Access Status
--  Internal table handler use only.
--
Procedure chk_frz_cmp_lvl_flag(p_elig_per_id           in number,
                               p_frz_cmp_lvl_flag      in varchar2,
                               p_rt_frz_cmp_lvl_flag   in varchar2,
                               p_effective_date        in date,
                               p_object_version_number in number) is
  --
  l_proc  varchar2(72) := g_package||'chk_frz_cmp_lvl_flag';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
Begin
  --
/*
  hr_utility.set_location('Entering: '||l_proc,5);
*/
  --
  l_api_updating := ben_pep_shd.api_updating
  (p_elig_per_id => p_elig_per_id,
   p_effective_date => p_effective_date,
   p_object_version_number => p_object_version_number);
  --
  if (l_api_updating and p_frz_cmp_lvl_flag
      <> nvl(ben_pep_shd.g_old_rec.frz_cmp_lvl_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_frz_cmp_lvl_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
/*
    hr_utility.set_location('HRAPI_NEIHL:'||l_proc, 5);
*/
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
/*
    hr_utility.set_location('Dn HRAPI_NEIHL:'||l_proc, 5);
*/
    --
  end if;
  --
  if (l_api_updating and p_rt_frz_cmp_lvl_flag
      <> nvl(ben_pep_shd.g_old_rec.rt_frz_cmp_lvl_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rt_frz_cmp_lvl_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
/*
    hr_utility.set_location('HRAPI_NEIHL:'||l_proc, 5);
*/
    if hr_api.not_exists_in_hr_lookups
      (p_lookup_type    => 'YES_NO',
       p_lookup_code    => p_rt_frz_cmp_lvl_flag,
       p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_rt_frz_cmp_lvl_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
/*
    hr_utility.set_location('Dn HRAPI_NEIHL:'||l_proc, 5);
*/
    --
  end if;
  --
/*
  hr_utility.set_location('Leaving: '||l_proc, 10);
*/
  --
end chk_frz_cmp_lvl_flag;
--
-- ---------------------------------------------------------------------------
-- |-------------------<chk_frz_pct_fl_tm_flag>------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure is used to check that the Flags are valid.
--
-- Pre Conditions
--  None.
--
-- In Parameters
--  <primarykey>PK of record being inserted into or updated.
--  <flag name> Name of the flag column.
--  <effective date> effective date
--  <object version number> Object version number of record being inserted
--   or updated.
--
-- Post Success
--  Process conintues
--
-- Post Failure
--  Error handled by procedure
--
-- Access Status
--  Internal table handler use only.
--
Procedure chk_frz_pct_fl_tm_flag(p_elig_per_id           in number,
                                 p_frz_pct_fl_tm_flag    in varchar2,
                                 p_rt_frz_pct_fl_tm_flag in varchar2,
                                 p_effective_date        in date,
                                 p_object_version_number in number) is
  --
  l_proc  varchar2(72) := g_package||'chk_frz_pct_fl_tm_flag';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
Begin
  --
/*
  hr_utility.set_location('Entering: '||l_proc,5);
*/
  --
  l_api_updating := ben_pep_shd.api_updating
  (p_elig_per_id => p_elig_per_id,
   p_effective_date => p_effective_date,
   p_object_version_number => p_object_version_number);
  --
  if (l_api_updating and p_frz_pct_fl_tm_flag
      <> nvl(ben_pep_shd.g_old_rec.frz_pct_fl_tm_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_frz_pct_fl_tm_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
/*
    hr_utility.set_location('HRAPI_NEIHL:'||l_proc, 5);
*/
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
/*
    hr_utility.set_location('Dn HRAPI_NEIHL:'||l_proc, 5);
*/
    --
  end if;
  --
  if (l_api_updating and p_rt_frz_pct_fl_tm_flag
      <> nvl(ben_pep_shd.g_old_rec.rt_frz_pct_fl_tm_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rt_frz_pct_fl_tm_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
/*
    hr_utility.set_location('HRAPI_NEIHL:'||l_proc, 5);
*/
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
/*
    hr_utility.set_location('Dn HRAPI_NEIHL:'||l_proc, 5);
*/
    --
  end if;
  --
/*
  hr_utility.set_location('Leaving: '||l_proc, 10);
*/
  --
end chk_frz_pct_fl_tm_flag;
--
-- ---------------------------------------------------------------------------
-- |---------------------<chk_frz_hrs_wkd_flag>------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure is used to check that the Flags are valid.
--
-- Pre Conditions
--  None.
--
-- In Parameters
--  <primarykey>PK of record being inserted into or updated.
--  <flag name> Name of the flag column.
--  <effective date> effective date
--  <object version number> Object version number of record being inserted
--   or updated.
--
-- Post Success
--  Process conintues
--
-- Post Failure
--  Error handled by procedure
--
-- Access Status
--  Internal table handler use only.
--
Procedure chk_frz_hrs_wkd_flag(p_elig_per_id           in number,
                               p_frz_hrs_wkd_flag      in varchar2,
                               p_rt_frz_hrs_wkd_flag   in varchar2,
                               p_effective_date        in date,
                               p_object_version_number in number) is
  --
  l_proc  varchar2(72) := g_package||'chk_frz_hrs_wkd_flag';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering: '||l_proc,5);
  --
  l_api_updating := ben_pep_shd.api_updating
  (p_elig_per_id => p_elig_per_id,
   p_effective_date => p_effective_date,
   p_object_version_number => p_object_version_number);
  --
  if (l_api_updating and p_frz_hrs_wkd_flag
      <> nvl(ben_pep_shd.g_old_rec.frz_hrs_wkd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_frz_hrs_wkd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    hr_utility.set_location('HRAPI_NEIHL:'||l_proc, 5);
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
    hr_utility.set_location('Dn HRAPI_NEIHL:'||l_proc, 5);
    --
  end if;
  --
  if (l_api_updating and p_rt_frz_hrs_wkd_flag
      <> nvl(ben_pep_shd.g_old_rec.rt_frz_hrs_wkd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rt_frz_hrs_wkd_flag is not null then
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
  hr_utility.set_location('Leaving: '||l_proc, 10);
  --
end chk_frz_hrs_wkd_flag;
--
-- ---------------------------------------------------------------------------
-- |----------------------<chk_dstr_rstcn_flag>------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure is used to check that the Flags are valid.
--
-- Pre Conditions
--  None.
--
-- In Parameters
--  <primarykey>PK of record being inserted into or updated.
--  <flag name> Name of the flag column.
--  <effective date> effective date
--  <object version number> Object version number of record being inserted
--   or updated.
--
-- Post Success
--  Process conintues
--
-- Post Failure
--  Error handled by procedure
--
-- Access Status
--  Internal table handler use only.
--
Procedure chk_dstr_rstcn_flag(p_elig_per_id           in number,
                              p_dstr_rstcn_flag       in varchar2,
                              p_effective_date        in date,
                              p_object_version_number in number) is
  --
  l_proc  varchar2(72) := g_package||'chk_dstr_rstcn_flag';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering: '||l_proc,5);
  --
  l_api_updating := ben_pep_shd.api_updating
  (p_elig_per_id => p_elig_per_id,
   p_effective_date => p_effective_date,
   p_object_version_number => p_object_version_number);
  --
  if (l_api_updating and p_dstr_rstcn_flag
      <> nvl(ben_pep_shd.g_old_rec.dstr_rstcn_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_dstr_rstcn_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
      (p_lookup_type    => 'YES_NO',
       p_lookup_code    => p_dstr_rstcn_flag,
       p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_dstr_rstrn_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc, 10);
  --
end chk_dstr_rstcn_flag;
--
-- ---------------------------------------------------------------------------
-- |----------------------------<chk_elig_flag>------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure is used to check that the Flags are valid.
--
-- Pre Conditions
--  None.
--
-- In Parameters
--  <primarykey>PK of record being inserted into or updated.
--  <flag name> Name of the flag column.
--  <effective date> effective date
--  <object version number> Object version number of record being inserted
--   or updated.
--
-- Post Success
--  Process conintues
--
-- Post Failure
--  Error handled by procedure
--
-- Access Status
--  Internal table handler use only.
--
Procedure chk_elig_flag(p_elig_per_id           in number,
                        p_elig_flag             in varchar2,
                        p_effective_date        in date,
                        p_object_version_number in number) is
  --
  l_proc  varchar2(72) := g_package||'chk_elig_flag';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering: '||l_proc,5);
  --
  l_api_updating := ben_pep_shd.api_updating
  (p_elig_per_id => p_elig_per_id,
   p_effective_date => p_effective_date,
   p_object_version_number => p_object_version_number);
  --
  if (l_api_updating and p_elig_flag
      <> nvl(ben_pep_shd.g_old_rec.elig_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_elig_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
      (p_lookup_type => 'YES_NO',
       p_lookup_code => p_elig_flag,
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
  hr_utility.set_location('Leaving: '||l_proc, 10);
  --
end chk_elig_flag;
--
-- ---------------------------------------------------------------------------
-- |----------------------------<chk_inelg_rsn_cd>---------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure is used to check that the Flags are valid.
--
-- Pre Conditions
--  None.
--
-- In Parameters
--  <primarykey>PK of record being inserted into or updated.
--  <inelg_rdn_cd> Name of the lookup column.
--  <effective date> effective date
--  <object version number> Object version number of record being inserted
--   or updated.
--
-- Post Success
--  Process conintues
--
-- Post Failure
--  Error handled by procedure
--
-- Access Status
--  Internal table handler use only.
--
Procedure chk_inelg_rsn_cd(p_elig_per_id           in number,
                           p_inelg_rsn_cd          in varchar2,
                           p_effective_date        in date,
                           p_object_version_number in number) is
  --
  l_proc  varchar2(72) := g_package||'chk_inelg_rsn_cd';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering: '||l_proc,5);
  --
  l_api_updating := ben_pep_shd.api_updating
  (p_elig_per_id => p_elig_per_id,
   p_effective_date => p_effective_date,
   p_object_version_number => p_object_version_number);
  --
  if (l_api_updating and p_inelg_rsn_cd
      <> nvl(ben_pep_shd.g_old_rec.inelg_rsn_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_inelg_rsn_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
      (p_lookup_type => 'BEN_INELG_RSN',
       p_lookup_code => p_inelg_rsn_cd,
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
  hr_utility.set_location('Leaving: '||l_proc, 10);
  --
end chk_inelg_rsn_cd;
--
-- ---------------------------------------------------------------------------
-- |--------------------------<chk_pl_wvd_flag>------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure is used to check that the Flags are valid.
--
-- Pre Conditions
--  None.
--
-- In Parameters
--  <primarykey>PK of record being inserted into or updated.
--  <flag name> Name of the flag column.
--  <effective date> effective date
--  <object version number> Object version number of record being inserted
--   or updated.
--
-- Post Success
--  Process conintues
--
-- Post Failure
--  Error handled by procedure
--
-- Access Status
--  Internal table handler use only.
--
Procedure chk_pl_wvd_flag(p_elig_per_id           in number,
                          p_pl_wvd_flag           in varchar2,
                          p_effective_date        in date,
                          p_object_version_number in number) is
  --
  l_proc  varchar2(72) := g_package||'chk_pl_wvd_flag';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering: '||l_proc,5);
  --
  l_api_updating := ben_pep_shd.api_updating
  (p_elig_per_id => p_elig_per_id,
   p_effective_date => p_effective_date,
   p_object_version_number => p_object_version_number);
  --
  if (l_api_updating and p_pl_wvd_flag
      <> nvl(ben_pep_shd.g_old_rec.pl_wvd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pl_wvd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
      (p_lookup_type => 'YES_NO',
       p_lookup_code => p_pl_wvd_flag,
       p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_pl_wvd_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc, 10);
  --
end chk_pl_wvd_flag;
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
             p_pgm_id                        in number default hr_api.g_number,
             p_plip_id                       in number default hr_api.g_number,
             p_ptip_id                       in number default hr_api.g_number,
             p_pl_id                         in number default hr_api.g_number,
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
            (p_elig_per_id        in number,
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
       p_argument       => 'elig_per_id',
       p_argument_value => p_elig_per_id);
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_elig_per_opt_f',
           p_base_key_column => 'elig_per_id',
           p_base_key_value  => p_elig_per_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_elig_per_opt_f';
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
    (p_rec              in ben_pep_shd.g_rec_type,
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
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_elig_per_id
    (p_elig_per_id           => p_rec.elig_per_id,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
  --
  chk_comp_ref_uom
    (p_elig_per_id           => p_rec.elig_per_id,
     p_comp_ref_val          => p_rec.comp_ref_amt,
     p_comp_ref_uom          => p_rec.comp_ref_uom,
     p_rt_comp_ref_val       => p_rec.rt_comp_ref_amt,
     p_rt_comp_ref_uom       => p_rec.rt_comp_ref_uom,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
  --
  chk_at_least_one_fk_set
    (p_pl_id                 => p_rec.pl_id,
     p_pgm_id                => p_rec.pgm_id,
     p_plip_id               => p_rec.plip_id,
     p_ptip_id               => p_rec.ptip_id,
     p_effective_date        => p_effective_date,
     p_business_group_id     => p_rec.business_group_id);
  --
  chk_wv_prtn_rsn_cd
    (p_elig_per_id           => p_rec.elig_per_id,
     p_pl_wvd_flag           => p_rec.pl_wvd_flag,
     p_wv_prtn_rsn_cd        => p_rec.wv_prtn_rsn_cd,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
  --
  chk_hrs_wkd_bndry_perd_cd
    (p_elig_per_id              => p_rec.elig_per_id,
     p_hrs_wkd_bndry_perd_cd    => p_rec.hrs_wkd_bndry_perd_cd,
     p_rt_hrs_wkd_bndry_perd_cd => p_rec.rt_hrs_wkd_bndry_perd_cd,
     p_effective_date           => p_effective_date,
     p_object_version_number    => p_rec.object_version_number);
  --
  chk_pct_val
    (p_pct_val               => p_rec.pct_fl_tm_val,
     p_rt_pct_val            => p_rec.rt_pct_fl_tm_val);
  --
  chk_wv_ctfn_typ_cd
    (p_elig_per_id           => p_rec.elig_per_id,
     p_pl_wvd_flag           => p_rec.pl_wvd_flag,
     p_wv_ctfn_typ_cd        => p_rec.wv_ctfn_typ_cd,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
  --
  chk_prtn_ovridn_rsn_cd
    (p_elig_per_id           => p_rec.elig_per_id,
     p_prtn_ovridn_thru_dt   => p_rec.prtn_ovridn_thru_dt,
     p_prtn_ovridn_flag      => p_rec.prtn_ovridn_flag,
     p_prtn_ovridn_rsn_cd    => p_rec.prtn_ovridn_rsn_cd,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
  --
  chk_age_uom
    (p_elig_per_id           => p_rec.elig_per_id,
     p_age_val               => p_rec.age_val,
     p_age_uom               => p_rec.age_uom,
     p_rt_age_val            => p_rec.rt_age_val,
     p_rt_age_uom            => p_rec.rt_age_uom,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
  --
  chk_los_uom
    (p_elig_per_id           => p_rec.elig_per_id,
     p_los_val               => p_rec.los_val,
     p_los_uom               => p_rec.los_uom,
     p_rt_los_val            => p_rec.rt_los_val,
     p_rt_los_uom            => p_rec.rt_los_uom,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_prtn_ovrid_thru_flag
    (p_elig_per_id                => p_rec.elig_per_id,
     p_no_mx_prtn_ovrid_thru_flag => p_rec.no_mx_prtn_ovrid_thru_flag,
     p_effective_date             => p_effective_date,
     p_object_version_number      => p_rec.object_version_number);
  --
  chk_once_r_cntug_cd
    (p_elig_per_id                => p_rec.elig_per_id,
     p_once_r_cntug_cd            => p_rec.once_r_cntug_cd,
     p_effective_date             => p_effective_date,
     p_object_version_number      => p_rec.object_version_number);
  --
  chk_frz_comb_age_and_los_flag
    (p_elig_per_id                  => p_rec.elig_per_id,
     p_frz_comb_age_and_los_flag    => p_rec.frz_comb_age_and_los_flag,
     p_rt_frz_comb_age_and_los_flag => p_rec.rt_frz_comb_age_and_los_flag,
     p_effective_date               => p_effective_date,
     p_object_version_number        => p_rec.object_version_number);
  --
  chk_dpnt_othr_pl_cvrd_rl_flag
    (p_elig_per_id               => p_rec.elig_per_id,
     p_dpnt_othr_pl_cvrd_rl_flag => p_rec.dpnt_othr_pl_cvrd_rl_flag,
     p_effective_date            => p_effective_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  chk_pl_key_ee_flag
    (p_elig_per_id               => p_rec.elig_per_id,
     p_pl_key_ee_flag            => p_rec.pl_key_ee_flag,
     p_effective_date            => p_effective_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  chk_inelg_rsn_cd
    (p_elig_per_id               => p_rec.elig_per_id,
     p_inelg_rsn_cd              => p_rec.inelg_rsn_cd,
     p_effective_date            => p_effective_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  chk_prtn_ovridn_flag
    (p_elig_per_id               => p_rec.elig_per_id,
     p_prtn_ovridn_flag          => p_rec.prtn_ovridn_flag,
     p_effective_date            => p_effective_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  chk_pl_hghly_compd_flag
    (p_elig_per_id               => p_rec.elig_per_id,
     p_pl_hghly_compd_flag       => p_rec.pl_hghly_compd_flag,
     p_effective_date            => p_effective_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  chk_frz_los_flag
    (p_elig_per_id               => p_rec.elig_per_id,
     p_frz_los_flag              => p_rec.frz_los_flag,
     p_rt_frz_los_flag           => p_rec.rt_frz_los_flag,
     p_effective_date            => p_effective_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  chk_frz_age_flag
    (p_elig_per_id               => p_rec.elig_per_id,
     p_frz_age_flag              => p_rec.frz_age_flag,
     p_rt_frz_age_flag           => p_rec.rt_frz_age_flag,
     p_effective_date            => p_effective_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  chk_frz_cmp_lvl_flag
    (p_elig_per_id               => p_rec.elig_per_id,
     p_frz_cmp_lvl_flag          => p_rec.frz_cmp_lvl_flag,
     p_rt_frz_cmp_lvl_flag       => p_rec.rt_frz_cmp_lvl_flag,
     p_effective_date            => p_effective_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  chk_frz_pct_fl_tm_flag
    (p_elig_per_id               => p_rec.elig_per_id,
     p_frz_pct_fl_tm_flag        => p_rec.frz_pct_fl_tm_flag,
     p_rt_frz_pct_fl_tm_flag     => p_rec.rt_frz_pct_fl_tm_flag,
     p_effective_date            => p_effective_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  chk_frz_hrs_wkd_flag
    (p_elig_per_id               => p_rec.elig_per_id,
     p_frz_hrs_wkd_flag          => p_rec.frz_hrs_wkd_flag,
     p_rt_frz_hrs_wkd_flag       => p_rec.rt_frz_hrs_wkd_flag,
     p_effective_date            => p_effective_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  chk_dstr_rstcn_flag
    (p_elig_per_id               => p_rec.elig_per_id,
     p_dstr_rstcn_flag           => p_rec.dstr_rstcn_flag,
     p_effective_date            => p_effective_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  chk_elig_flag
    (p_elig_per_id               => p_rec.elig_per_id,
     p_elig_flag                 => p_rec.elig_flag,
     p_effective_date            => p_effective_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  chk_pl_wvd_flag
    (p_elig_per_id               => p_rec.elig_per_id,
     p_pl_wvd_flag               => p_rec.pl_wvd_flag,
     p_effective_date            => p_effective_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
    (p_rec              in ben_pep_shd.g_rec_type,
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
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_elig_per_id
    (p_elig_per_id           => p_rec.elig_per_id,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
  --
  chk_comp_ref_uom
    (p_elig_per_id           => p_rec.elig_per_id,
     p_comp_ref_val          => p_rec.comp_ref_amt,
     p_comp_ref_uom          => p_rec.comp_ref_uom,
     p_rt_comp_ref_val       => p_rec.rt_comp_ref_amt,
     p_rt_comp_ref_uom       => p_rec.rt_comp_ref_uom,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
  --
  chk_at_least_one_fk_set
    (p_pl_id                 => p_rec.pl_id,
     p_pgm_id                => p_rec.pgm_id,
     p_plip_id               => p_rec.plip_id,
     p_ptip_id               => p_rec.ptip_id,
     p_effective_date        => p_effective_date,
     p_business_group_id     => p_rec.business_group_id);
  --
  chk_wv_prtn_rsn_cd
    (p_elig_per_id           => p_rec.elig_per_id,
     p_pl_wvd_flag           => p_rec.pl_wvd_flag,
     p_wv_prtn_rsn_cd        => p_rec.wv_prtn_rsn_cd,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
  --
  chk_hrs_wkd_bndry_perd_cd
    (p_elig_per_id              => p_rec.elig_per_id,
     p_hrs_wkd_bndry_perd_cd    => p_rec.hrs_wkd_bndry_perd_cd,
     p_rt_hrs_wkd_bndry_perd_cd => p_rec.rt_hrs_wkd_bndry_perd_cd,
     p_effective_date           => p_effective_date,
     p_object_version_number    => p_rec.object_version_number);
  --
  chk_pct_val
    (p_pct_val               => p_rec.pct_fl_tm_val,
     p_rt_pct_val            => p_rec.rt_pct_fl_tm_val);
  --
  chk_wv_ctfn_typ_cd
    (p_elig_per_id           => p_rec.elig_per_id,
     p_pl_wvd_flag           => p_rec.pl_wvd_flag,
     p_wv_ctfn_typ_cd        => p_rec.wv_ctfn_typ_cd,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
  --
  chk_prtn_ovridn_rsn_cd
    (p_elig_per_id           => p_rec.elig_per_id,
     p_prtn_ovridn_thru_dt   => p_rec.prtn_ovridn_thru_dt,
     p_prtn_ovridn_flag      => p_rec.prtn_ovridn_flag,
     p_prtn_ovridn_rsn_cd    => p_rec.prtn_ovridn_rsn_cd,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
  --
  chk_age_uom
    (p_elig_per_id           => p_rec.elig_per_id,
     p_age_val               => p_rec.age_val,
     p_age_uom               => p_rec.age_uom,
     p_rt_age_val            => p_rec.rt_age_val,
     p_rt_age_uom            => p_rec.rt_age_uom,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
  --
  chk_los_uom
    (p_elig_per_id           => p_rec.elig_per_id,
     p_los_val               => p_rec.los_val,
     p_los_uom               => p_rec.los_uom,
     p_rt_los_val            => p_rec.rt_los_val,
     p_rt_los_uom            => p_rec.rt_los_uom,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_prtn_ovrid_thru_flag
    (p_elig_per_id                => p_rec.elig_per_id,
     p_no_mx_prtn_ovrid_thru_flag => p_rec.no_mx_prtn_ovrid_thru_flag,
     p_effective_date             => p_effective_date,
     p_object_version_number      => p_rec.object_version_number);
  --
  chk_once_r_cntug_cd
    (p_elig_per_id                => p_rec.elig_per_id,
     p_once_r_cntug_cd            => p_rec.once_r_cntug_cd,
     p_effective_date             => p_effective_date,
     p_object_version_number      => p_rec.object_version_number);
  --
  chk_frz_comb_age_and_los_flag
    (p_elig_per_id                  => p_rec.elig_per_id,
     p_frz_comb_age_and_los_flag    => p_rec.frz_comb_age_and_los_flag,
     p_rt_frz_comb_age_and_los_flag => p_rec.rt_frz_comb_age_and_los_flag,
     p_effective_date               => p_effective_date,
     p_object_version_number        => p_rec.object_version_number);
  --
  chk_dpnt_othr_pl_cvrd_rl_flag
    (p_elig_per_id               => p_rec.elig_per_id,
     p_dpnt_othr_pl_cvrd_rl_flag => p_rec.dpnt_othr_pl_cvrd_rl_flag,
     p_effective_date            => p_effective_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  chk_pl_key_ee_flag
    (p_elig_per_id               => p_rec.elig_per_id,
     p_pl_key_ee_flag            => p_rec.pl_key_ee_flag,
     p_effective_date            => p_effective_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  chk_inelg_rsn_cd
    (p_elig_per_id               => p_rec.elig_per_id,
     p_inelg_rsn_cd              => p_rec.inelg_rsn_cd,
     p_effective_date            => p_effective_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  chk_prtn_ovridn_flag
    (p_elig_per_id               => p_rec.elig_per_id,
     p_prtn_ovridn_flag          => p_rec.prtn_ovridn_flag,
     p_effective_date            => p_effective_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  chk_pl_hghly_compd_flag
    (p_elig_per_id               => p_rec.elig_per_id,
     p_pl_hghly_compd_flag       => p_rec.pl_hghly_compd_flag,
     p_effective_date            => p_effective_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  chk_frz_los_flag
    (p_elig_per_id               => p_rec.elig_per_id,
     p_frz_los_flag              => p_rec.frz_los_flag,
     p_rt_frz_los_flag           => p_rec.rt_frz_los_flag,
     p_effective_date            => p_effective_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  chk_frz_age_flag
    (p_elig_per_id               => p_rec.elig_per_id,
     p_frz_age_flag              => p_rec.frz_age_flag,
     p_rt_frz_age_flag           => p_rec.rt_frz_age_flag,
     p_effective_date            => p_effective_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  chk_frz_cmp_lvl_flag
    (p_elig_per_id               => p_rec.elig_per_id,
     p_frz_cmp_lvl_flag          => p_rec.frz_cmp_lvl_flag,
     p_rt_frz_cmp_lvl_flag       => p_rec.rt_frz_cmp_lvl_flag,
     p_effective_date            => p_effective_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  chk_frz_pct_fl_tm_flag
    (p_elig_per_id               => p_rec.elig_per_id,
     p_frz_pct_fl_tm_flag        => p_rec.frz_pct_fl_tm_flag,
     p_rt_frz_pct_fl_tm_flag     => p_rec.rt_frz_pct_fl_tm_flag,
     p_effective_date            => p_effective_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  chk_frz_hrs_wkd_flag
    (p_elig_per_id               => p_rec.elig_per_id,
     p_frz_hrs_wkd_flag          => p_rec.frz_hrs_wkd_flag,
     p_rt_frz_hrs_wkd_flag       => p_rec.rt_frz_hrs_wkd_flag,
     p_effective_date            => p_effective_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  chk_dstr_rstcn_flag
    (p_elig_per_id               => p_rec.elig_per_id,
     p_dstr_rstcn_flag           => p_rec.dstr_rstcn_flag,
     p_effective_date            => p_effective_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  chk_elig_flag
    (p_elig_per_id               => p_rec.elig_per_id,
     p_elig_flag                 => p_rec.elig_flag,
     p_effective_date            => p_effective_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  chk_pl_wvd_flag
    (p_elig_per_id               => p_rec.elig_per_id,
     p_pl_wvd_flag               => p_rec.pl_wvd_flag,
     p_effective_date            => p_effective_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_ler_id                        => p_rec.ler_id,
     p_pgm_id                        => p_rec.pgm_id,
     p_pl_id                         => p_rec.pl_id,
     p_plip_id                       => p_rec.plip_id,
     p_ptip_id                       => p_rec.ptip_id,
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
    (p_rec              in ben_pep_shd.g_rec_type,
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
     p_elig_per_id        => p_rec.elig_per_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ben_pep_bus;

/
