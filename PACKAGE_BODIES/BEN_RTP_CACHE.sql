--------------------------------------------------------
--  DDL for Package Body BEN_RTP_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_RTP_CACHE" as
/* $Header: benrtpch.pkb 120.0 2005/12/01 17:09:41 kmahendr noship $ */
--
g_package varchar2(50) := 'ben_rtp_cache.';
--
procedure write_abravr_odcache
  (p_effective_date          in     date
  ,p_acty_base_rt_id         in     number default hr_api.g_number
  ,p_cvg_amt_calc_mthd_id    in     number default hr_api.g_number
  ,p_actl_prem_id            in     number default hr_api.g_number
  ,p_hv                      out nocopy  pls_integer
  )
is
  --
  l_proc varchar2(72) := 'write_abravr_odcache';
  --
  l_copcep_odlookup_rec ben_cache.g_cache_lookup;
  --
  l_hv              pls_integer;
  l_not_hash_found  boolean;
  l_torrwnum        pls_integer;
  l_starttorele_num pls_integer;
  --
  cursor c_profile_cvg
    (c_cvg_amt_calc_mthd_id  in number,
     c_effective_date in    date
    )
  is
    select vrp.vrbl_rt_prfl_id,
           vrp.rt_hrly_slrd_flag,
           vrp.rt_pstl_cd_flag,
           vrp.rt_lbr_mmbr_flag,
           vrp.rt_lgl_enty_flag,
           vrp.rt_benfts_grp_flag,
           vrp.rt_wk_loc_flag,
           vrp.rt_brgng_unit_flag,
           vrp.rt_age_flag,
           vrp.rt_los_flag,
           vrp.rt_per_typ_flag,
           vrp.rt_fl_tm_pt_tm_flag,
           vrp.rt_ee_stat_flag,
           vrp.rt_grd_flag,
           vrp.rt_pct_fl_tm_flag,
           vrp.rt_asnt_set_flag,
           vrp.rt_hrs_wkd_flag,
           vrp.rt_comp_lvl_flag,
           vrp.rt_org_unit_flag,
           vrp.rt_loa_rsn_flag,
           vrp.rt_pyrl_flag,
           vrp.rt_schedd_hrs_flag,
           vrp.rt_py_bss_flag,
           vrp.rt_prfl_rl_flag,
           vrp.rt_cmbn_age_los_flag,
           vrp.rt_prtt_pl_flag,
           vrp.rt_svc_area_flag,
           vrp.rt_ppl_grp_flag,
           vrp.rt_dsbld_flag,
           vrp.rt_hlth_cvg_flag,
           vrp.rt_poe_flag,
           vrp.rt_ttl_cvg_vol_flag,
           vrp.rt_ttl_prtt_flag,
           vrp.rt_gndr_flag,
           vrp.rt_tbco_use_flag ,
           vrp.rt_cntng_prtn_prfl_flag ,
	   vrp.rt_cbr_quald_bnf_flag,
	   vrp.rt_optd_mdcr_flag,
	   vrp.rt_lvg_rsn_flag ,
	   vrp.rt_pstn_flag ,
	   vrp.rt_comptncy_flag ,
	   vrp.rt_job_flag ,
	   vrp.rt_qual_titl_flag ,
	   vrp.rt_dpnt_cvrd_pl_flag,
	   vrp.rt_dpnt_cvrd_plip_flag,
	   vrp.rt_dpnt_cvrd_ptip_flag,
	   vrp.rt_dpnt_cvrd_pgm_flag,
	   vrp.rt_enrld_oipl_flag,
	   vrp.rt_enrld_pl_flag,
	   vrp.rt_enrld_plip_flag,
	   vrp.rt_enrld_ptip_flag,
	   vrp.rt_enrld_pgm_flag,
	   vrp.rt_prtt_anthr_pl_flag,
	   vrp.rt_othr_ptip_flag,
	   vrp.rt_no_othr_cvg_flag,
	   vrp.rt_dpnt_othr_ptip_flag,
	   vrp.rt_qua_in_gr_flag,
	   vrp.rt_perf_rtng_flag,
           vrp.asmt_to_use_cd,
           bvr.ordr_num,
           vrp.rt_elig_prfl_flag
    from   ben_vrbl_rt_prfl_f vrp,
           ben_bnft_vrbl_rt_f bvr
    where  vrp.vrbl_rt_prfl_stat_cd = 'A'
    and    c_effective_date
           between vrp.effective_start_date
           and     vrp.effective_end_date
    and    bvr.cvg_amt_calc_mthd_id = c_cvg_amt_calc_mthd_id
    and    vrp.vrbl_rt_prfl_id = bvr.vrbl_rt_prfl_id
    and    c_effective_date
           between bvr.effective_start_date
           and     bvr.effective_end_date
    order  by bvr.ordr_num;
  --
  cursor c_profile_abr
    (c_acty_base_rt_id   in number,
     c_effective_date in    date
    )
  is
    select vrp.vrbl_rt_prfl_id,
           vrp.rt_hrly_slrd_flag,
           vrp.rt_pstl_cd_flag,
           vrp.rt_lbr_mmbr_flag,
           vrp.rt_lgl_enty_flag,
           vrp.rt_benfts_grp_flag,
           vrp.rt_wk_loc_flag,
           vrp.rt_brgng_unit_flag,
           vrp.rt_age_flag,
           vrp.rt_los_flag,
           vrp.rt_per_typ_flag,
           vrp.rt_fl_tm_pt_tm_flag,
           vrp.rt_ee_stat_flag,
           vrp.rt_grd_flag,
           vrp.rt_pct_fl_tm_flag,
           vrp.rt_asnt_set_flag,
           vrp.rt_hrs_wkd_flag,
           vrp.rt_comp_lvl_flag,
           vrp.rt_org_unit_flag,
           vrp.rt_loa_rsn_flag,
           vrp.rt_pyrl_flag,
           vrp.rt_schedd_hrs_flag,
           vrp.rt_py_bss_flag,
           vrp.rt_prfl_rl_flag,
           vrp.rt_cmbn_age_los_flag,
           vrp.rt_prtt_pl_flag,
           vrp.rt_svc_area_flag,
           vrp.rt_ppl_grp_flag,
           vrp.rt_dsbld_flag,
           vrp.rt_hlth_cvg_flag,
           vrp.rt_poe_flag,
           vrp.rt_ttl_cvg_vol_flag,
           vrp.rt_ttl_prtt_flag,
           vrp.rt_gndr_flag,
           vrp.rt_tbco_use_flag,
           vrp.rt_cntng_prtn_prfl_flag ,
	   vrp.rt_cbr_quald_bnf_flag,
	   vrp.rt_optd_mdcr_flag,
	   vrp.rt_lvg_rsn_flag ,
	   vrp.rt_pstn_flag ,
	   vrp.rt_comptncy_flag ,
	   vrp.rt_job_flag ,
	   vrp.rt_qual_titl_flag ,
	   vrp.rt_dpnt_cvrd_pl_flag,
	   vrp.rt_dpnt_cvrd_plip_flag,
	   vrp.rt_dpnt_cvrd_ptip_flag,
	   vrp.rt_dpnt_cvrd_pgm_flag,
	   vrp.rt_enrld_oipl_flag,
	   vrp.rt_enrld_pl_flag,
	   vrp.rt_enrld_plip_flag,
	   vrp.rt_enrld_ptip_flag,
	   vrp.rt_enrld_pgm_flag,
	   vrp.rt_prtt_anthr_pl_flag,
	   vrp.rt_othr_ptip_flag,
	   vrp.rt_no_othr_cvg_flag,
	   vrp.rt_dpnt_othr_ptip_flag,
	   vrp.rt_qua_in_gr_flag,
	   vrp.rt_perf_rtng_flag,
           vrp.asmt_to_use_cd,
           avr.ordr_num,
           vrp.rt_elig_prfl_flag
    from   ben_acty_vrbl_rt_f avr,
           ben_vrbl_rt_prfl_f vrp
    where  vrp.vrbl_rt_prfl_stat_cd = 'A'
    and    c_effective_date
           between vrp.effective_start_date
           and     vrp.effective_end_date
    and    avr.acty_base_rt_id = c_acty_base_rt_id
    and    vrp.vrbl_rt_prfl_id = avr.vrbl_rt_prfl_id
    and    c_effective_date
           between avr.effective_start_date
           and     avr.effective_end_date
    order  by avr.ordr_num;
  --
  l_instance c_profile_abr%rowtype;

  cursor c_profile_apr
    (c_actl_prem_id   in number,
     c_effective_date in    date
    )
  is
    select vrp.vrbl_rt_prfl_id,
           vrp.rt_hrly_slrd_flag,
           vrp.rt_pstl_cd_flag,
           vrp.rt_lbr_mmbr_flag,
           vrp.rt_lgl_enty_flag,
           vrp.rt_benfts_grp_flag,
           vrp.rt_wk_loc_flag,
           vrp.rt_brgng_unit_flag,
           vrp.rt_age_flag,
           vrp.rt_los_flag,
           vrp.rt_per_typ_flag,
           vrp.rt_fl_tm_pt_tm_flag,
           vrp.rt_ee_stat_flag,
           vrp.rt_grd_flag,
           vrp.rt_pct_fl_tm_flag,
           vrp.rt_asnt_set_flag,
           vrp.rt_hrs_wkd_flag,
           vrp.rt_comp_lvl_flag,
           vrp.rt_org_unit_flag,
           vrp.rt_loa_rsn_flag,
           vrp.rt_pyrl_flag,
           vrp.rt_schedd_hrs_flag,
           vrp.rt_py_bss_flag,
           vrp.rt_prfl_rl_flag,
           vrp.rt_cmbn_age_los_flag,
           vrp.rt_prtt_pl_flag,
           vrp.rt_svc_area_flag,
           vrp.rt_ppl_grp_flag,
           vrp.rt_dsbld_flag,
           vrp.rt_hlth_cvg_flag,
           vrp.rt_poe_flag,
           vrp.rt_ttl_cvg_vol_flag,
           vrp.rt_ttl_prtt_flag,
           vrp.rt_gndr_flag,
           vrp.rt_tbco_use_flag,
           vrp.rt_cntng_prtn_prfl_flag ,
	   vrp.rt_cbr_quald_bnf_flag,
	   vrp.rt_optd_mdcr_flag,
	   vrp.rt_lvg_rsn_flag ,
	   vrp.rt_pstn_flag ,
	   vrp.rt_comptncy_flag ,
	   vrp.rt_job_flag ,
	   vrp.rt_qual_titl_flag ,
	   vrp.rt_dpnt_cvrd_pl_flag,
	   vrp.rt_dpnt_cvrd_plip_flag,
	   vrp.rt_dpnt_cvrd_ptip_flag,
	   vrp.rt_dpnt_cvrd_pgm_flag,
	   vrp.rt_enrld_oipl_flag,
	   vrp.rt_enrld_pl_flag,
	   vrp.rt_enrld_plip_flag,
	   vrp.rt_enrld_ptip_flag,
	   vrp.rt_enrld_pgm_flag,
	   vrp.rt_prtt_anthr_pl_flag,
	   vrp.rt_othr_ptip_flag,
	   vrp.rt_no_othr_cvg_flag,
	   vrp.rt_dpnt_othr_ptip_flag,
	   vrp.rt_qua_in_gr_flag,
	   vrp.rt_perf_rtng_flag,
	   vrp.asmt_to_use_cd,
           apr.ordr_num,
           vrp.rt_elig_prfl_flag
    from   ben_actl_prem_vrbl_rt_f apr,
           ben_vrbl_rt_prfl_f vrp
    where  vrp.vrbl_rt_prfl_stat_cd = 'A'
    and    c_effective_date
           between vrp.effective_start_date
           and     vrp.effective_end_date
    and    apr.actl_prem_id  = c_actl_prem_id
    and    vrp.vrbl_rt_prfl_id = apr.vrbl_rt_prfl_id
    and    c_effective_date
           between apr.effective_start_date
           and     apr.effective_end_date
    order by apr.ordr_num;
  --
begin
  --
  hr_utility.set_location(' Entering  '||l_proc,10);
  hr_utility.set_location(' p_acty_base_rt_id  '||p_acty_base_rt_id,10);
  hr_utility.set_location(' p_cvg_amt_calc_mthd_id  '||p_cvg_amt_calc_mthd_id,10);
  hr_utility.set_location(' p_actl_prem_id  '||p_actl_prem_id,10);
  --
  -- Get the instance details
  --
  l_hv := mod(nvl(p_acty_base_rt_id,1)+
              nvl(p_cvg_amt_calc_mthd_id,2)+
              nvl(p_actl_prem_id,3) ,g_hash_key);
  --
  -- Get a unique hash value
  --
  if g_copcep_odlookup.exists(l_hv) then
    --
    if nvl(g_copcep_odlookup(l_hv).id,-1)        = nvl(p_acty_base_rt_id,-1)
      and nvl(g_copcep_odlookup(l_hv).fk_id,-1)  = nvl(p_cvg_amt_calc_mthd_id,-1)
      and nvl(g_copcep_odlookup(l_hv).fk1_id,-1) = nvl(p_actl_prem_id,-1)
    then
      --
      null;
      --
    else
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_hv := l_hv+g_hash_jump;
        --
        -- Check if the hash index exists, and compare the values
        --
        if g_copcep_odlookup.exists(l_hv) then
          --
          if nvl(g_copcep_odlookup(l_hv).id,-1)        = nvl(p_acty_base_rt_id,-1)
            and nvl(g_copcep_odlookup(l_hv).fk_id,-1)  = nvl(p_cvg_amt_calc_mthd_id,-1)
            and nvl(g_copcep_odlookup(l_hv).fk1_id,-1) = nvl(p_actl_prem_id,-1)
          then
            --
            l_not_hash_found := true;
            exit;
            --
          else
            --
            l_not_hash_found := false;
            --
          end if;
          --
        else
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  g_copcep_odlookup(l_hv).id     := p_acty_base_rt_id;
  g_copcep_odlookup(l_hv).fk_id  := p_cvg_amt_calc_mthd_id;
  g_copcep_odlookup(l_hv).fk1_id := p_actl_prem_id;
  --
  hr_utility.set_location(' Dn Look  '||l_proc,10);
  --
  l_starttorele_num := nvl(g_copcep_nxelenum,1);
  l_torrwnum        := l_starttorele_num;
  --
  hr_utility.set_location(' Bef inst loop  '||l_proc,10);
  --
  if p_acty_base_rt_id is not null then
    --
    open c_profile_abr
      (c_acty_base_rt_id => p_acty_base_rt_id
      ,c_effective_date => p_effective_date
      );
    --
  elsif p_cvg_amt_calc_mthd_id is not null then
    --
    open c_profile_cvg
      (c_cvg_amt_calc_mthd_id => p_cvg_amt_calc_mthd_id
      ,c_effective_date => p_effective_date
      );
    --
  elsif p_actl_prem_id is not null then
    --
    open c_profile_apr
      (c_actl_prem_id   => p_actl_prem_id
      ,c_effective_date => p_effective_date
      );
    --
  end if;
  --
  loop
    --
    if p_acty_base_rt_id is not null then
      --
      fetch c_profile_abr into l_instance;
      exit when c_profile_abr%NOTFOUND;
      --
    elsif p_cvg_amt_calc_mthd_id is not null then
      --
      fetch c_profile_cvg into l_instance;
      exit when c_profile_cvg%NOTFOUND;
      --
    elsif p_actl_prem_id is not null then
      --
      fetch c_profile_apr into l_instance;
      exit when c_profile_apr%NOTFOUND;
      --
    end if;
    --
    hr_utility.set_location(' Assign inst  '||l_proc,10);
    --
    g_copcep_odinst.extend(1);
    g_copcep_odinst(l_torrwnum).acty_base_rt_id         := p_acty_base_rt_id;
    g_copcep_odinst(l_torrwnum).cvg_amt_calc_mthd_id         := p_cvg_amt_calc_mthd_id;
    g_copcep_odinst(l_torrwnum).actl_prem_id         := p_actl_prem_id;
    g_copcep_odinst(l_torrwnum).vrbl_rt_prfl_id         := l_instance.vrbl_rt_prfl_id;
    g_copcep_odinst(l_torrwnum).rt_hrly_slrd_flag         := l_instance.rt_hrly_slrd_flag;
    g_copcep_odinst(l_torrwnum).rt_pstl_cd_flag         := l_instance.rt_pstl_cd_flag;
    g_copcep_odinst(l_torrwnum).rt_lbr_mmbr_flag         := l_instance.rt_lbr_mmbr_flag;
    g_copcep_odinst(l_torrwnum).rt_lgl_enty_flag         := l_instance.rt_lgl_enty_flag;
    g_copcep_odinst(l_torrwnum).rt_benfts_grp_flag         := l_instance.rt_benfts_grp_flag;
    g_copcep_odinst(l_torrwnum).rt_wk_loc_flag         := l_instance.rt_wk_loc_flag;
    g_copcep_odinst(l_torrwnum).rt_brgng_unit_flag         := l_instance.rt_brgng_unit_flag;
    g_copcep_odinst(l_torrwnum).rt_age_flag         := l_instance.rt_age_flag;
    g_copcep_odinst(l_torrwnum).rt_los_flag         := l_instance.rt_los_flag;
    g_copcep_odinst(l_torrwnum).rt_per_typ_flag         := l_instance.rt_per_typ_flag;
    g_copcep_odinst(l_torrwnum).rt_fl_tm_pt_tm_flag         := l_instance.rt_fl_tm_pt_tm_flag;
    g_copcep_odinst(l_torrwnum).rt_ee_stat_flag         := l_instance.rt_ee_stat_flag;
    g_copcep_odinst(l_torrwnum).rt_grd_flag         := l_instance.rt_grd_flag;
    g_copcep_odinst(l_torrwnum).rt_pct_fl_tm_flag         := l_instance.rt_pct_fl_tm_flag;
    g_copcep_odinst(l_torrwnum).rt_asnt_set_flag         := l_instance.rt_asnt_set_flag;
    g_copcep_odinst(l_torrwnum).rt_hrs_wkd_flag         := l_instance.rt_hrs_wkd_flag;
    g_copcep_odinst(l_torrwnum).rt_comp_lvl_flag         := l_instance.rt_comp_lvl_flag;
    g_copcep_odinst(l_torrwnum).rt_org_unit_flag         := l_instance.rt_org_unit_flag;
    g_copcep_odinst(l_torrwnum).rt_loa_rsn_flag         := l_instance.rt_loa_rsn_flag;
    g_copcep_odinst(l_torrwnum).rt_pyrl_flag         := l_instance.rt_pyrl_flag;
    g_copcep_odinst(l_torrwnum).rt_schedd_hrs_flag         := l_instance.rt_schedd_hrs_flag;
    g_copcep_odinst(l_torrwnum).rt_py_bss_flag         := l_instance.rt_py_bss_flag;
    g_copcep_odinst(l_torrwnum).rt_prfl_rl_flag         := l_instance.rt_prfl_rl_flag;
    g_copcep_odinst(l_torrwnum).rt_cmbn_age_los_flag         := l_instance.rt_cmbn_age_los_flag;
    g_copcep_odinst(l_torrwnum).rt_prtt_pl_flag         := l_instance.rt_prtt_pl_flag;
    g_copcep_odinst(l_torrwnum).rt_svc_area_flag         := l_instance.rt_svc_area_flag;
    g_copcep_odinst(l_torrwnum).rt_ppl_grp_flag         := l_instance.rt_ppl_grp_flag;
    g_copcep_odinst(l_torrwnum).rt_dsbld_flag         := l_instance.rt_dsbld_flag;
    g_copcep_odinst(l_torrwnum).rt_hlth_cvg_flag         := l_instance.rt_hlth_cvg_flag;
    g_copcep_odinst(l_torrwnum).rt_poe_flag         := l_instance.rt_poe_flag;
    g_copcep_odinst(l_torrwnum).rt_ttl_cvg_vol_flag         := l_instance.rt_ttl_cvg_vol_flag;
    g_copcep_odinst(l_torrwnum).rt_ttl_prtt_flag         := l_instance.rt_ttl_prtt_flag;
    g_copcep_odinst(l_torrwnum).rt_gndr_flag         := l_instance.rt_gndr_flag;
    g_copcep_odinst(l_torrwnum).rt_tbco_use_flag         := l_instance.rt_tbco_use_flag;
    g_copcep_odinst(l_torrwnum).rt_cntng_prtn_prfl_flag         := l_instance.rt_cntng_prtn_prfl_flag;
    g_copcep_odinst(l_torrwnum).rt_cbr_quald_bnf_flag         := l_instance.rt_cbr_quald_bnf_flag;
    g_copcep_odinst(l_torrwnum).rt_optd_mdcr_flag         := l_instance.rt_optd_mdcr_flag;
    g_copcep_odinst(l_torrwnum).rt_lvg_rsn_flag         := l_instance.rt_lvg_rsn_flag;
    g_copcep_odinst(l_torrwnum).rt_pstn_flag         := l_instance.rt_pstn_flag;
    g_copcep_odinst(l_torrwnum).rt_comptncy_flag         := l_instance.rt_comptncy_flag;
    g_copcep_odinst(l_torrwnum).rt_job_flag         := l_instance.rt_job_flag;
    g_copcep_odinst(l_torrwnum).rt_qual_titl_flag         := l_instance.rt_qual_titl_flag;
    g_copcep_odinst(l_torrwnum).rt_dpnt_cvrd_pl_flag         := l_instance.rt_dpnt_cvrd_pl_flag;
    g_copcep_odinst(l_torrwnum).rt_dpnt_cvrd_plip_flag         := l_instance.rt_dpnt_cvrd_plip_flag;
    g_copcep_odinst(l_torrwnum).rt_dpnt_cvrd_ptip_flag         := l_instance.rt_dpnt_cvrd_ptip_flag;
    g_copcep_odinst(l_torrwnum).rt_dpnt_cvrd_pgm_flag         := l_instance.rt_dpnt_cvrd_pgm_flag;
    g_copcep_odinst(l_torrwnum).rt_enrld_oipl_flag         := l_instance.rt_enrld_oipl_flag;
    g_copcep_odinst(l_torrwnum).rt_enrld_pl_flag         := l_instance.rt_enrld_pl_flag;
    g_copcep_odinst(l_torrwnum).rt_enrld_plip_flag         := l_instance.rt_enrld_plip_flag;
    g_copcep_odinst(l_torrwnum).rt_enrld_ptip_flag         := l_instance.rt_enrld_ptip_flag;
    g_copcep_odinst(l_torrwnum).rt_enrld_pgm_flag         := l_instance.rt_enrld_pgm_flag;
    g_copcep_odinst(l_torrwnum).rt_prtt_anthr_pl_flag         := l_instance.rt_prtt_anthr_pl_flag;
    g_copcep_odinst(l_torrwnum).rt_othr_ptip_flag         := l_instance.rt_othr_ptip_flag;
    g_copcep_odinst(l_torrwnum).rt_no_othr_cvg_flag         := l_instance.rt_no_othr_cvg_flag;
    g_copcep_odinst(l_torrwnum).rt_dpnt_othr_ptip_flag         := l_instance.rt_dpnt_othr_ptip_flag;
    g_copcep_odinst(l_torrwnum).rt_qua_in_gr_flag         := l_instance.rt_qua_in_gr_flag;
    g_copcep_odinst(l_torrwnum).rt_perf_rtng_flag         := l_instance.rt_perf_rtng_flag;
    g_copcep_odinst(l_torrwnum).asmt_to_use_cd         := l_instance.asmt_to_use_cd;
    g_copcep_odinst(l_torrwnum).ordr_num         := l_instance.ordr_num;
    g_copcep_odinst(l_torrwnum).rt_elig_prfl_flag         := l_instance.rt_elig_prfl_flag;
    hr_utility.set_location(' Dn Assign inst  '||l_proc,10);
    --
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  if p_acty_base_rt_id is not null then
    --
    close c_profile_abr;
    --
  elsif p_cvg_amt_calc_mthd_id is not null then
    --
    close c_profile_cvg;
    --
  elsif p_actl_prem_id is not null then
    --
    close c_profile_apr;
    --
  end if;
  --
  -- Check if any rows were found
  --
  if l_torrwnum > nvl(g_copcep_nxelenum,1)
  then
    --
    g_copcep_odlookup(l_hv).starttorele_num := l_starttorele_num;
    g_copcep_odlookup(l_hv).endtorele_num   := l_torrwnum-1;
    g_copcep_nxelenum := l_torrwnum;
    --
    p_hv := l_hv;
    --
  else
    --
    -- Delete and free PGA with assignment
    --
    g_copcep_odlookup.delete(l_hv);
    g_copcep_odlookup(l_hv) := l_copcep_odlookup_rec;
    --
    p_hv := null;
    --
  end if;
  --
  hr_utility.set_location(' Leaving  '||l_proc,10);
end write_abravr_odcache;
--
procedure clear_down_cache
is
  --
  l_copcep_odlookup ben_cache.g_cache_lookup_table;
  l_copcep_odinst   g_cobcep_odcache :=  g_cobcep_odcache();
  --
begin
  --
  -- On demand cache structures
  --
  g_copcep_odlookup := l_copcep_odlookup;
  g_copcep_odinst   := l_copcep_odinst;
  g_copcep_odcached := 0;
  g_copcep_nxelenum := null;
  --
  -- Grab back memory
  --
  begin
    --
    dbms_session.free_unused_user_memory;
    --
  end;
  --
end clear_down_cache;
--
procedure abravr_odgetdets
  (p_effective_date          in     date
  ,p_acty_base_rt_id         in     number default hr_api.g_number
  ,p_cvg_amt_calc_mthd_id    in     number default hr_api.g_number
  ,p_actl_prem_id            in     number default hr_api.g_number
  ,p_inst_set                in out nocopy  g_cobcep_odcache
  )
is
  l_proc varchar2(72) := 'abravr_odgetdets';
  --
  l_inst_set        g_cobcep_odcache :=  g_cobcep_odcache();
  --
  l_hv             pls_integer;
  l_hash_found     boolean;
  l_insttorrw_num  pls_integer;
  l_torrwnum       pls_integer;
  --
  l_clash_count    pls_integer;
  --
begin
  --
  hr_utility.set_location(' Entering  '||l_proc,10);
  --
  if g_copcep_odcached = 0
  then
    --
    -- Build the cache
    --
    clear_down_cache;
    --
    g_copcep_odcached := 1;
    --
  end if;
  --
  -- Get the instance details
  --
  l_hv := mod(nvl(p_acty_base_rt_id,1)+
              nvl(p_cvg_amt_calc_mthd_id,2)+
              nvl(p_actl_prem_id,3) ,g_hash_key);
  --
  -- Check if hashed value is already allocated
  --
  l_hash_found := false;
  --
  if g_copcep_odlookup.exists(l_hv) then
    --
    if nvl(g_copcep_odlookup(l_hv).id,-1)        = nvl(p_acty_base_rt_id,-1)
      and nvl(g_copcep_odlookup(l_hv).fk_id,-1)  = nvl(p_cvg_amt_calc_mthd_id,-1)
      and nvl(g_copcep_odlookup(l_hv).fk1_id,-1) = nvl(p_actl_prem_id,-1)
    then
      --
      null;
      --
    else
      --
      l_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      l_clash_count := 0;
      --
      while not l_hash_found loop
        --
        l_hv := l_hv+g_hash_jump;
        --
        if g_copcep_odlookup.exists(l_hv) then
          --
          -- Check if the hash index exists, and compare the values
          --
          if nvl(g_copcep_odlookup(l_hv).id,-1)        = nvl(p_acty_base_rt_id,-1)
            and nvl(g_copcep_odlookup(l_hv).fk_id,-1)  = nvl(p_cvg_amt_calc_mthd_id,-1)
            and nvl(g_copcep_odlookup(l_hv).fk1_id,-1) = nvl(p_actl_prem_id,-1)
          then
            --
            l_hash_found := true;
            exit;
            --
          else
            --
            l_clash_count := l_clash_count+1;
            l_hash_found := false;
            --
          end if;
          --
          -- Check for high clash counts and defrag
          --
          if l_clash_count > 50
          then
            --
            l_hv := null;
            clear_down_cache;
            exit;
            --
          end if;
          --
        else
          --
          l_hv := null;
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  else
    --
    l_hv := null;
    --
  end if;

  if l_hv is null
  then
    --
    write_abravr_odcache
      (p_effective_date          => p_effective_date
      ,p_acty_base_rt_id         => p_acty_base_rt_id
      ,p_cvg_amt_calc_mthd_id    => p_cvg_amt_calc_mthd_id
      ,p_actl_prem_id            => p_actl_prem_id
      ,p_hv                      => l_hv
      );
    --
  end if;
  --
  if l_hv is not null then
    --
    l_torrwnum := 1;
    --
    hr_utility.set_location(' Get loop  '||l_proc,10);
    for l_insttorrw_num in g_copcep_odlookup(l_hv).starttorele_num ..
      g_copcep_odlookup(l_hv).endtorele_num
    loop
      --
      l_inst_set.extend(1);
      l_inst_set(l_torrwnum) := g_copcep_odinst(l_insttorrw_num);
      l_torrwnum := l_torrwnum+1;
      --
    end loop;
    --
  end if;
  --
  p_inst_set := l_inst_set;
  --
  hr_utility.set_location(' Leaving  '||l_proc,10);
exception
  --
  when no_data_found then
    --
    p_inst_set := l_inst_set;
    --
end abravr_odgetdets;
--
end ben_rtp_cache;

/
