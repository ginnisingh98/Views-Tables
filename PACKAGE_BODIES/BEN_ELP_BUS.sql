--------------------------------------------------------
--  DDL for Package Body BEN_ELP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELP_BUS" as
/* $Header: beelprhi.pkb 120.5 2007/01/24 05:18:55 rgajula ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_elp_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_eligy_prfl_id >--------------------------|
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
--   eligy_prfl_id PK of record being inserted or updated.
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
Procedure chk_eligy_prfl_id(p_eligy_prfl_id               in number,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_eligy_prfl_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_elp_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_eligy_prfl_id               => p_eligy_prfl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_eligy_prfl_id,hr_api.g_number)
     <>  ben_elp_shd.g_old_rec.eligy_prfl_id) then
    --
    -- raise error as PK has changed
    --
    ben_elp_shd.constraint_error('BEN_ELIGY_PRFL_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_eligy_prfl_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_elp_shd.constraint_error('BEN_ELIGY_PRFL_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_eligy_prfl_id;
--
-- ---------------------------------------------------------------------------
-- |-----------------------------< chk_name >--------------------------------|
-- ---------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the name field is unique
--   on insert and on update.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   eligy_prfl_id PK of record being inserted or updated.
--   name that is beeing inserted ot updated to.
--   effective_date Effective Date of session
--   business group ID
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
--   HR Development Internal use only.
--
Procedure chk_name(p_eligy_prfl_id               in number,
                   p_name                        in varchar2,
                   p_effective_date              in date,
                   p_validation_start_date       in date,
                   p_validation_end_date         in date,
                   p_business_group_id           in number,
                   p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_name';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  --
  cursor csr_name is
    select null
    from   ben_eligy_prfl_f
    where  name = p_name
    and    eligy_prfl_id <> nvl(p_eligy_prfl_id, hr_api.g_number)
    and    business_group_id + 0 = p_business_group_id
    and    p_validation_start_date <= effective_end_date
    and    p_validation_end_date >= effective_start_date;
  --
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_elp_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_eligy_prfl_id               => p_eligy_prfl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_name <> ben_elp_shd.g_old_rec.name) or
      not l_api_updating then
    --
    hr_utility.set_location('Entering:'||l_proc, 10);
    --
    -- check if this name already exist
    --
    open csr_name;
    fetch csr_name into l_exists;
    if csr_name%found then
      close csr_name;
      --
      -- raise error as UK1 is violated
      --
      ben_elp_shd.constraint_error('BEN_ELIGY_PRFL_UK1');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
End chk_name;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< chk_stat_cd >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   eligy_prfl_id PK of record being inserted or updated.
--   stat_cd Value of lookup code.
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
Procedure chk_stat_cd(p_eligy_prfl_id         in number,
                      p_stat_cd               in varchar2,
                      p_effective_date        in date,
                      p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_stat_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_elp_shd.api_updating
    (p_eligy_prfl_id               => p_eligy_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_stat_cd
      <> nvl(ben_elp_shd.g_old_rec.stat_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_STAT',
           p_lookup_code    => p_stat_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91626_STATUS_CD_INVALID');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_stat_cd;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< chk_asmt_to_use_cd >---------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   eligy_prfl_id PK of record being inserted or updated.
--   asmt_to_use_cd Value of lookup code.
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
Procedure chk_asmt_to_use_cd(p_eligy_prfl_id         in number,
                             p_asmt_to_use_cd        in varchar2,
                             p_effective_date        in date,
                             p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_asmt_to_use_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_elp_shd.api_updating
    (p_eligy_prfl_id               => p_eligy_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_asmt_to_use_cd
      <> nvl(ben_elp_shd.g_old_rec.asmt_to_use_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ASMT_TO_USE',
           p_lookup_code    => p_asmt_to_use_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_asmt_to_use_cd');
      fnd_message.set_token('TYPE','BEN_ASMT_TO_USE');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_asmt_to_use_cd;
--
--Bug#5248048
-- ----------------------------------------------------------------------------
-- |-------------------------------< chk_cagr_exists >----------------------------|
-- ----------------------------------------------------------------------------

Procedure chk_cagr_exists(   p_eligy_prfl_id               in number,
                             p_effective_date              in date,
                             p_validation_start_date       in date,
	                     p_validation_end_date         in date
                         ) is
  --
  Cursor c_cagr_exists
    is
    select 1
    from   per_cagr_entitlement_lines_f cagr
    where  cagr.eligy_prfl_id=p_eligy_prfl_id
 /*   and    p_effective_date between cagr.effective_start_date
           and cagr.effective_end_date;*/   --For date track updates it wont work.
    and    p_validation_start_date <= effective_end_date
    and    p_validation_end_date >= effective_start_date;
  --
  l_proc         varchar2(72) := g_package||'chk_cagr_exists';
  l_cagr_exists  number(1);
  l_return              VARCHAR2(240);
  --
  Begin
   --
   hr_utility.set_location('Entering:'||l_proc, 5);
   --
   open c_cagr_exists;
    fetch c_cagr_exists into l_cagr_exists;
   --
   if c_cagr_exists%found then
     close c_cagr_exists;
     --Start Bug 5753149
     l_return := fnd_message.get_string('BEN','BEN_94881_PCE_EXISTS');
     fnd_message.set_name('BEN','BEN_94630_PCE_EXISTS');
      fnd_message.set_token('ENTITY_NAME',l_return);
      --End Bug 5753149
      fnd_message.raise_error;

   end if;
     close c_cagr_exists;
   --
  hr_utility.set_location('Leaving:'||l_proc, 5);

end chk_cagr_exists;
--
--Bug#5248048

--Start Bug 5753149
-- ----------------------------------------------------------------------------
-- |-------------------------------< chk_eoep_exists >----------------------------|
-- ----------------------------------------------------------------------------

Procedure chk_eoep_exists(   p_eligy_prfl_id               in number,
			     p_elp_name  in varchar2,
                             p_validation_start_date       in date,
	                     p_validation_end_date         in date
                         ) is
  --
  Cursor c_eoep_exists
    is
    select 1
    from   BEN_ELIG_OBJ_ELIG_PROFL_F eoep
    where  eoep.elig_prfl_id=p_eligy_prfl_id
    and    p_validation_start_date <= effective_end_date
    and    p_validation_end_date >= effective_start_date;
  --
  l_proc         varchar2(72) := g_package||'chk_eoep_exists';
  l_eoep_exists  number(1);
  l_return              VARCHAR2(240);
  --
  Begin
   --
   hr_utility.set_location('Entering:'||l_proc, 5);
   --
   open c_eoep_exists;
    fetch c_eoep_exists into l_eoep_exists;
   --
   if c_eoep_exists%found then
     close c_eoep_exists;
     l_return := fnd_message.get_string('BEN','BEN_94882_CSC_EXISTS');
     fnd_message.set_name('BEN','BEN_94630_PCE_EXISTS');
      fnd_message.set_token('ENTITY_NAME',l_return);
      fnd_message.raise_error;
   end if;
     close c_eoep_exists;
   --
  hr_utility.set_location('Leaving:'||l_proc, 5);

end chk_eoep_exists;
--End Bug 5753149
-- ----------------------------------------------------------------------------
-- |-------------------------------< chk_lookups >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   eligy_prfl_id PK of record being inserted or updated.
--   elig_enrld_plip_flag Value of lookup code
--   elig_cbr_quald_bnf_flag Value of lookup code
--   elig_enrld_ptip_flag Value of lookup code
--   elig_dpnt_cvrd_plip_flag Value of lookup code
--   elig_dpnt_cvrd_ptip_flag Value of lookup code
--   elig_dpnt_cvrd_pgm_flag Value of lookup code
--   elig_job_flag Value of lookup code
--   elig_hrly_slrd_flag Value of lookup code
--   elig_pstl_cd_flag  Value of lookup code
--   elig_lbr_mmbr_flag Value of lookup code
--   elig_lgl_enty_flag Value of lookup code
--   elig_benfts_grp_flag Value of lookup code
--   elig_wk_loc_flag Value of lookup code
--   elig_brgng_unit_flag Value of lookup code
--   elig_age_flag Value of lookup code
--   elig_los_flag Value of lookup code
--   elig_per_typ_flag Value of lookup code
--   elig_fl_tm_pt_tm_flag Value of lookup code
--   elig_ee_stat_flag Value of lookup code
--   elig_grd_flag Value of lookup code
--   elig_pct_fl_tm_flag Value of lookup code
--   elig_asnt_set_flag Value of lookup code
--   elig_hrs_wkd_flag Value of lookup code
--   elig_comp_lvl_flag Value of lookup code
--   elig_org_unit_flag Value of lookup code
--   elig_loa_rsn_flag Value of lookup code
--   elig_pyrl_flag Value of lookup code
--   elig_schedd_hrs_flag Value of lookup code
--   elig_py_bss_flag Value of lookup code
--   eligy_prfl_rl_flag Value of lookup code
--   elig_cmbn_age_los_flag Value of lookup code
--   cntng_prtn_elig_prfl_flag Value of lookup code
--   elig_prtt_pl_flag Value of lookup code
--   elig_ppl_grp_flag Value of lookup code
--   elig_svc_area_flag Value of lookup code
--   elig_ptip_prte_flag Value of lookup code
--   elig_no_othr_cvg_flag Value of lookup code
--   elig_enrld_pl_flag Value of lookup code
--   elig_enrld_oipl_flag Value of lookup code
--   elig_enrld_pgm_flag Value of lookup code
--   elig_dpnt_cvrd_pl_flag Value of lookup code
--   elig_lvg_rsn_flag Value of lookup code
--   elig_optd_mdcr_flag Value of lookup code
--   elig_tbco_use_flag Value of lookup code
--   asmt_to_use_cd Value of lookup code.
--   elig_dsbld_flag Value of lookup code
--   elig_ttl_cvg_vol_flag Value of lookup code
--   elig_ttl_prtt_flag Value of lookup code
--   elig_comptncy_flag Value of lookup code
--   elig_hlth_cvg_flag Value of lookup code
--   elig_anthr_pl_flag Value of lookup code
--   elig_qua_in_gr_flag  Value of lookup code
--   elig_perf_rtng_flag  Value of lookup code
--   elig_crit_values_flag Value of lookup code   /* RBC */
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
Procedure chk_lookups(p_eligy_prfl_id             in number,
                      p_elig_enrld_plip_flag      in varchar2,
                      p_elig_cbr_quald_bnf_flag   in varchar2,
                      p_elig_enrld_ptip_flag      in varchar2,
                      p_elig_dpnt_cvrd_plip_flag  in varchar2,
                      p_elig_dpnt_cvrd_ptip_flag  in varchar2,
                      p_elig_dpnt_cvrd_pgm_flag   in varchar2,
                      p_elig_job_flag             in varchar2,
                      p_elig_hrly_slrd_flag       in varchar2,
                      p_elig_pstl_cd_flag         in varchar2,
                      p_elig_lbr_mmbr_flag        in varchar2,
                      p_elig_lgl_enty_flag        in varchar2,
                      p_elig_benfts_grp_flag      in varchar2,
                      p_elig_wk_loc_flag          in varchar2,
                      p_elig_brgng_unit_flag      in varchar2,
                      p_elig_age_flag             in varchar2,
                      p_elig_los_flag             in varchar2,
                      p_elig_per_typ_flag         in varchar2,
                      p_elig_fl_tm_pt_tm_flag     in varchar2,
                      p_elig_ee_stat_flag         in varchar2,
                      p_elig_grd_flag             in varchar2,
                      p_elig_pct_fl_tm_flag       in varchar2,
                      p_elig_asnt_set_flag        in varchar2,
                      p_elig_hrs_wkd_flag         in varchar2,
                      p_elig_comp_lvl_flag        in varchar2,
                      p_elig_org_unit_flag        in varchar2,
                      p_elig_loa_rsn_flag         in varchar2,
                      p_elig_pyrl_flag            in varchar2,
                      p_elig_schedd_hrs_flag      in varchar2,
                      p_elig_py_bss_flag          in varchar2,
                      p_eligy_prfl_rl_flag        in varchar2,
                      p_elig_cmbn_age_los_flag    in varchar2,
                      p_cntng_prtn_elig_prfl_flag in varchar2,
                      p_elig_prtt_pl_flag         in varchar2,
                      p_elig_ppl_grp_flag         in varchar2,
                      p_elig_svc_area_flag        in varchar2,
                      p_elig_ptip_prte_flag       in varchar2,
                      p_elig_no_othr_cvg_flag     in varchar2,
                      p_elig_enrld_pl_flag        in varchar2,
                      p_elig_enrld_oipl_flag      in varchar2,
                      p_elig_enrld_pgm_flag       in varchar2,
                      p_elig_dpnt_cvrd_pl_flag    in varchar2,
                      p_elig_lvg_rsn_flag         in varchar2,
                      p_elig_optd_mdcr_flag       in varchar2,
                      p_elig_tbco_use_flag        in varchar2,
                      p_elig_dpnt_othr_ptip_flag  in varchar2,
                      p_elig_mrtl_sts_flag        in varchar2,
                      p_elig_gndr_flag            in varchar2,
                      p_elig_dsblty_ctg_flag      in varchar2,
                      p_elig_dsblty_rsn_flag      in varchar2,
                      p_elig_dsblty_dgr_flag      in varchar2,
                      p_elig_suppl_role_flag      in varchar2,
                      p_elig_qual_titl_flag       in varchar2,
                      p_elig_pstn_flag            in varchar2,
                      p_elig_prbtn_perd_flag      in varchar2,
                      p_elig_sp_clng_prg_pt_flag  in varchar2,
                      p_bnft_cagr_prtn_cd         in varchar2,
 	              p_elig_dsbld_flag           in varchar2,
	              p_elig_ttl_cvg_vol_flag     in varchar2,
	              p_elig_ttl_prtt_flag        in varchar2,
	              p_elig_comptncy_flag        in varchar2,
	              p_elig_hlth_cvg_flag	  in varchar2,
	              p_elig_anthr_pl_flag	  in varchar2,
		      p_elig_qua_in_gr_flag	  in varchar2,
		      p_elig_perf_rtng_flag	  in varchar2,
                      p_elig_crit_values_flag     in varchar2,   /* RBC */
                      p_effective_date            in date,
                      p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_lookups';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_elp_shd.api_updating
    (p_eligy_prfl_id               => p_eligy_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  -- We are testing flags only, it makes no sense to do tests whether an
  -- update has occurred since its probably quicker to just call the routine
  -- since no select is done for YES_NO lookups.
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_enrld_plip_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_enrld_plip_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_cbr_quald_bnf_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_cbr_quald_bnf_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_enrld_ptip_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_enrld_ptip_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_dpnt_cvrd_plip_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_dpnt_cvrd_plip_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_dpnt_cvrd_ptip_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_dpnt_cvrd_ptip_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_dpnt_cvrd_pgm_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_dpnt_cvrd_pgm_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_job_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_job_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_hrly_slrd_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_hrly_slrd_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_pstl_cd_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_pstl_cd_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_lbr_mmbr_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_lbr_mmbr_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_lgl_enty_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_lgl_enty_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_benfts_grp_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_benfts_grp_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_wk_loc_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_wk_loc_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_brgng_unit_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_brgng_unit_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_age_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_age_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_los_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_los_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_per_typ_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_per_typ_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_fl_tm_pt_tm_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_fl_tm_pt_tm_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_ee_stat_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_ee_stat_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_grd_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_grd_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_pct_fl_tm_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_pct_fl_tm_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_asnt_set_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_asnt_set_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_hrs_wkd_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_hrs_wkd_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_comp_lvl_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_comp_lvl_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_org_unit_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_org_unit_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_loa_rsn_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_loa_rsn_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_pyrl_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_pyrl_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_schedd_hrs_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_schedd_hrs_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_py_bss_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_py_bss_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_eligy_prfl_rl_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_eligy_prfl_rl_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_cmbn_age_los_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_cmbn_age_los_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_cntng_prtn_elig_prfl_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_cntng_prtn_elig_prfl_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_prtt_pl_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_prtt_pl_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_ppl_grp_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_ppl_grp_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_svc_area_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_svc_area_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_ptip_prte_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_ptip_prte_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_no_othr_cvg_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_no_othr_cvg_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_enrld_pl_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_enrld_pl_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_enrld_oipl_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_enrld_oipl_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_enrld_pgm_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_enrld_pgm_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_dpnt_cvrd_pl_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_dpnt_cvrd_pl_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_lvg_rsn_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_lvg_rsn_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_optd_mdcr_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_optd_mdcr_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_tbco_use_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_tbco_use_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_dpnt_othr_ptip_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_dpnt_othr_ptip_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_dsbld_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_dsbld_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_ttl_cvg_vol_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_ttl_cvg_vol_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_ttl_prtt_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_ttl_prtt_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_comptncy_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_comptncy_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_hlth_cvg_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_hlth_cvg_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_anthr_pl_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_anthr_pl_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_qua_in_gr_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_qua_in_gr_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_perf_rtng_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_perf_rtng_flag');
    fnd_message.raise_error;
    --
  end if;
  --
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    => p_elig_crit_values_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','p_elig_crit_values_flag');
    fnd_message.raise_error;
    --
  end if;
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_lookups;
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
            (p_datetrack_mode		     in varchar2,
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
    --
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
            (p_eligy_prfl_id		in number,
             p_datetrack_mode		in varchar2,
	     p_validation_start_date	in date,
	     p_validation_end_date	in date,
             p_name                     in varchar2) Is
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
       p_argument       => 'eligy_prfl_id',
       p_argument_value => p_eligy_prfl_id);
    --
     If (dt_api.rows_exist
          (p_base_table_name => 'BEN_VRBL_RT_ELIG_PRFL_F',
           p_base_key_column => 'eligy_prfl_id',
           p_base_key_value  => p_eligy_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'BEN_VRBL_RT_ELIG_PRFL_F';
      Raise l_rows_exist;
    End If;
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
    --
  When l_rows_exist Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    ben_utility.child_exists_error(p_table_name               => l_table_name,
                                   p_parent_table_name        => 'BEN_ELIGY_PRFL_F',      /* Bug 4057566 */
                                   p_parent_entity_name       => p_name);                 /* Bug 4057566 */
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
	(p_rec 			 in ben_elp_shd.g_rec_type,
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
  chk_eligy_prfl_id
  (p_eligy_prfl_id         => p_rec.eligy_prfl_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_name
  (p_eligy_prfl_id         => p_rec.eligy_prfl_id,
   p_name                  => p_rec.name,
   p_effective_date        => p_effective_date,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_stat_cd
  (p_eligy_prfl_id         => p_rec.eligy_prfl_id,
   p_stat_cd               => p_rec.stat_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_asmt_to_use_cd
  (p_eligy_prfl_id         => p_rec.eligy_prfl_id,
   p_asmt_to_use_cd        => p_rec.asmt_to_use_cd,
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
	(p_rec 			 in ben_elp_shd.g_rec_type,
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
  chk_eligy_prfl_id
  (p_eligy_prfl_id         => p_rec.eligy_prfl_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_stat_cd
  (p_eligy_prfl_id         => p_rec.eligy_prfl_id,
   p_stat_cd               => p_rec.stat_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_asmt_to_use_cd
  (p_eligy_prfl_id         => p_rec.eligy_prfl_id,
   p_asmt_to_use_cd        => p_rec.asmt_to_use_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_name
  (p_eligy_prfl_id         => p_rec.eligy_prfl_id,
   p_name                  => p_rec.name,
   p_effective_date        => p_effective_date,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_datetrack_mode                => p_datetrack_mode,
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
	(p_rec 			 in ben_elp_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'delete_validate';
   --
   CURSOR c_elp_name
   IS
      SELECT elp.NAME
        FROM ben_eligy_prfl_f elp
       WHERE elp.eligy_prfl_id = p_rec.eligy_prfl_id
         AND p_effective_date BETWEEN elp.effective_start_date
                                  AND elp.effective_end_date;
   --
   l_elp_name            ben_eligy_prfl_f.name%type;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  OPEN c_elp_name;
    --
    FETCH c_elp_name INTO l_elp_name;
    --
  CLOSE c_elp_name;
  --
--Bug#5248048
  chk_cagr_exists
      (p_eligy_prfl_id =>  p_rec.eligy_prfl_id,
       p_effective_date => p_effective_date,
       p_validation_start_date => p_validation_start_date,
       p_validation_end_date   => p_validation_end_date
      );
--Bug#5248048

--Start Bug 5753149
--Restrict deletion of ELPRO if attached to a work schedule
  chk_eoep_exists
      (p_eligy_prfl_id =>  p_rec.eligy_prfl_id,
       p_elp_name =>  l_elp_name,
       p_validation_start_date => p_validation_start_date,
       p_validation_end_date   => p_validation_end_date
      );
--End Bug 5753149

  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode		=> p_datetrack_mode,
     p_validation_start_date	=> p_validation_start_date,
     p_validation_end_date	=> p_validation_end_date,
     p_eligy_prfl_id		=> p_rec.eligy_prfl_id,
     p_name                     => l_elp_name);
  --
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
   IF (p_datetrack_mode = 'DELETE' OR p_datetrack_mode = 'ZAP')
   THEN
      --
      IF (   p_rec.elig_enrld_plip_flag = 'Y'
          OR p_rec.elig_cbr_quald_bnf_flag = 'Y'
          OR p_rec.elig_enrld_ptip_flag = 'Y'
          OR p_rec.elig_dpnt_cvrd_plip_flag = 'Y'
          OR p_rec.elig_dpnt_cvrd_ptip_flag = 'Y'
          OR p_rec.elig_dpnt_cvrd_pgm_flag = 'Y'
          OR p_rec.elig_job_flag = 'Y'
          OR p_rec.elig_hrly_slrd_flag = 'Y'
          OR p_rec.elig_pstl_cd_flag = 'Y'
          OR p_rec.elig_lbr_mmbr_flag = 'Y'
          OR p_rec.elig_lgl_enty_flag = 'Y'
          OR p_rec.elig_benfts_grp_flag = 'Y'
          OR p_rec.elig_wk_loc_flag = 'Y'
          OR p_rec.elig_brgng_unit_flag = 'Y'
          OR p_rec.elig_age_flag = 'Y'
          OR p_rec.elig_los_flag = 'Y'
          OR p_rec.elig_per_typ_flag = 'Y'
          OR p_rec.elig_fl_tm_pt_tm_flag = 'Y'
          OR p_rec.elig_ee_stat_flag = 'Y'
          OR p_rec.elig_grd_flag = 'Y'
          OR p_rec.elig_pct_fl_tm_flag = 'Y'
          OR p_rec.elig_asnt_set_flag = 'Y'
          OR p_rec.elig_hrs_wkd_flag = 'Y'
          OR p_rec.elig_comp_lvl_flag = 'Y'
          OR p_rec.elig_org_unit_flag = 'Y'
          OR p_rec.elig_loa_rsn_flag = 'Y'
          OR p_rec.elig_pyrl_flag = 'Y'
          OR p_rec.elig_schedd_hrs_flag = 'Y'
          OR p_rec.elig_py_bss_flag = 'Y'
          OR p_rec.eligy_prfl_rl_flag = 'Y'
          OR p_rec.elig_cmbn_age_los_flag = 'Y'
          OR p_rec.cntng_prtn_elig_prfl_flag = 'Y'
          OR p_rec.elig_prtt_pl_flag = 'Y'
          OR p_rec.elig_ppl_grp_flag = 'Y'
          OR p_rec.elig_svc_area_flag = 'Y'
          OR p_rec.elig_ptip_prte_flag = 'Y'
          OR p_rec.elig_no_othr_cvg_flag = 'Y'
          OR p_rec.elig_enrld_pl_flag = 'Y'
          OR p_rec.elig_enrld_oipl_flag = 'Y'
          OR p_rec.elig_enrld_pgm_flag = 'Y'
          OR p_rec.elig_dpnt_cvrd_pl_flag = 'Y'
          OR p_rec.elig_lvg_rsn_flag = 'Y'
          OR p_rec.elig_optd_mdcr_flag = 'Y'
          OR p_rec.elig_tbco_use_flag = 'Y'
          OR p_rec.elig_dpnt_othr_ptip_flag = 'Y'
          OR p_rec.elig_gndr_flag = 'Y'
          OR p_rec.elig_dsblty_ctg_flag = 'Y'
          OR p_rec.elig_dsblty_dgr_flag = 'Y'
          OR p_rec.elig_dsblty_rsn_flag = 'Y'
          OR p_rec.elig_mrtl_sts_flag = 'Y'
          OR p_rec.elig_prbtn_perd_flag = 'Y'
          OR p_rec.elig_sp_clng_prg_pt_flag = 'Y'
          OR p_rec.elig_suppl_role_flag = 'Y'
          OR p_rec.elig_qual_titl_flag = 'Y'
          OR p_rec.elig_pstn_flag = 'Y'
          OR p_rec.elig_dsbld_flag = 'Y'
          OR p_rec.elig_ttl_cvg_vol_flag = 'Y'
          OR p_rec.elig_ttl_prtt_flag = 'Y'
          OR p_rec.elig_comptncy_flag = 'Y'
          OR p_rec.elig_hlth_cvg_flag = 'Y'
          OR p_rec.elig_anthr_pl_flag = 'Y'
          OR p_rec.elig_perf_rtng_flag = 'Y'
          OR p_rec.elig_qua_in_gr_flag = 'Y'
          OR p_rec.elig_crit_values_flag = 'Y'
         )
      THEN
         --
         -- Bug 4057566
         --
         -- hr_utility.set_message (801, 'PAY_52681_BHT_CHILD_EXISTS');
         -- hr_utility.raise_error;
         ben_utility.child_exists_error(p_table_name               => 'BEN_ELIGY_PRFL_CRITERIA',
                                        p_parent_table_name        => 'BEN_ELIGY_PRFL_F',
                                        p_parent_entity_name       => l_elp_name);
         --
         -- Bug 4057566
         --
      END IF;
      --
   END IF;
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
  (p_eligy_prfl_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_eligy_prfl_f b
    where b.eligy_prfl_id      = p_eligy_prfl_id
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
                             p_argument       => 'eligy_prfl_id',
                             p_argument_value => p_eligy_prfl_id);
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
end ben_elp_bus;

/
