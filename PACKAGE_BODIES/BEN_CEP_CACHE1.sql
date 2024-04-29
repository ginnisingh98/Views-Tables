--------------------------------------------------------
--  DDL for Package Body BEN_CEP_CACHE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CEP_CACHE1" as
/* $Header: bencepc1.pkb 120.1 2006/05/04 03:48:31 abparekh noship $ */
--
procedure write_cobcep_odcache
  (p_effective_date in     date
  ,p_pgm_id         in     number default hr_api.g_number
  ,p_pl_id          in     number default hr_api.g_number
  ,p_oipl_id        in     number default hr_api.g_number
  ,p_plip_id        in     number default hr_api.g_number
  ,p_ptip_id        in     number default hr_api.g_number
  -- Grade/Step
  ,p_vrbl_rt_prfl_id           in number  default hr_api.g_number
  -- Grade/Step
  --
  ,p_hv               out nocopy  pls_integer
  )
is
  --
  l_proc varchar2(72) := 'write_cobcep_odcache';
  --
  l_copcep_odlookup_rec ben_cache.g_cache_lookup;
  --
  l_hv              pls_integer;
  l_not_hash_found  boolean;
  l_torrwnum        pls_integer;
  l_starttorele_num pls_integer;
  --
  cursor c_pgminstance
    (c_pgm_id         number
    ,c_effective_date date
    )
  is
    select  /*+ bencepch.write_cobcep_odcache.c_pgminstance */
            tab1.pgm_id,
            tab1.ptip_id,
            tab1.plip_id,
            tab1.pl_id,
            tab1.oipl_id,
            -- Grade/Step
            to_number(null) vrbl_rt_prfl_id,
            -- Grade/Step
            tab1.prtn_elig_id,
            tab1.trk_scr_for_inelg_flag,
            tab2.compute_score_flag,
            tab2.mndtry_flag,
            tab3.eligy_prfl_id,
            tab3.asmt_to_use_cd,
            tab3.elig_enrld_plip_flag,
            tab3.elig_cbr_quald_bnf_flag,
            tab3.elig_enrld_ptip_flag,
            tab3.elig_dpnt_cvrd_plip_flag,
            tab3.elig_dpnt_cvrd_ptip_flag,
            tab3.elig_dpnt_cvrd_pgm_flag,
            tab3.elig_job_flag,
            tab3.elig_hrly_slrd_flag,
            tab3.elig_pstl_cd_flag,
            tab3.elig_lbr_mmbr_flag,
            tab3.elig_lgl_enty_flag,
            tab3.elig_benfts_grp_flag,
            tab3.elig_wk_loc_flag,
            tab3.elig_brgng_unit_flag,
            tab3.elig_age_flag,
            tab3.elig_los_flag,
            tab3.elig_per_typ_flag,
            tab3.elig_fl_tm_pt_tm_flag,
            tab3.elig_ee_stat_flag,
            tab3.elig_grd_flag,
            tab3.elig_pct_fl_tm_flag,
            tab3.elig_asnt_set_flag,
            tab3.elig_hrs_wkd_flag,
            tab3.elig_comp_lvl_flag,
            tab3.elig_org_unit_flag,
            tab3.elig_loa_rsn_flag,
            tab3.elig_pyrl_flag,
            tab3.elig_schedd_hrs_flag,
            tab3.elig_py_bss_flag,
            tab3.eligy_prfl_rl_flag,
            tab3.elig_cmbn_age_los_flag,
            tab3.cntng_prtn_elig_prfl_flag,
            tab3.elig_prtt_pl_flag,
            tab3.elig_ppl_grp_flag,
            tab3.elig_svc_area_flag,
            tab3.elig_ptip_prte_flag,
            tab3.elig_no_othr_cvg_flag,
            tab3.elig_enrld_pl_flag,
            tab3.elig_enrld_oipl_flag,
            tab3.elig_enrld_pgm_flag,
            tab3.elig_dpnt_cvrd_pl_flag,
            tab3.elig_lvg_rsn_flag,
            tab3.elig_optd_mdcr_flag,
            tab3.elig_tbco_use_flag,
            tab3.elig_dpnt_othr_ptip_flag,
            tab3.ELIG_GNDR_FLAG,
            tab3.ELIG_MRTL_STS_FLAG,
            tab3.ELIG_DSBLTY_CTG_FLAG,
            tab3.ELIG_DSBLTY_RSN_FLAG,
            tab3.ELIG_DSBLTY_DGR_FLAG,
            tab3.ELIG_SUPPL_ROLE_FLAG,
            tab3.ELIG_QUAL_TITL_FLAG,
            tab3.ELIG_PSTN_FLAG,
            tab3.ELIG_PRBTN_PERD_FLAG,
            tab3.ELIG_SP_CLNG_PRG_PT_FLAG,
            tab3.BNFT_CAGR_PRTN_CD,
            tab3.ELIG_DSBLD_FLAG,
            tab3.ELIG_TTL_CVG_VOL_FLAG,
            tab3.ELIG_TTL_PRTT_FLAG,
            tab3.ELIG_COMPTNCY_FLAG,
            tab3.ELIG_HLTH_CVG_FLAG,
            tab3.ELIG_ANTHR_PL_FLAG,
            tab3.elig_qua_in_gr_flag,
            tab3.elig_perf_rtng_flag,
            tab3.elig_crit_values_flag
    from  ben_prtn_elig_f tab1,
          ben_prtn_elig_prfl_f tab2,
          ben_eligy_prfl_f tab3
    where tab1.pgm_id = c_pgm_id
    and tab1.prtn_elig_id = tab2.prtn_elig_id
    and c_effective_date
      between tab1.effective_start_date
        and tab1.effective_end_date
    and tab2.eligy_prfl_id = tab3.eligy_prfl_id
    and tab3.stat_cd = 'A'                         -- bug 2431753 -- consider only active profiles
    and c_effective_date
      between tab2.effective_start_date
        and tab2.effective_end_date
    and c_effective_date
      between tab3.effective_start_date
    and tab3.effective_end_date
    order by tab1.pgm_id,
             tab1.ptip_id,
             tab1.plip_id,
             tab1.pl_id,
             tab1.oipl_id,
             decode(tab2.mndtry_flag,'Y',1,2);
  --
  l_instance c_pgminstance%rowtype;
  --
  cursor c_ptipinstance
    (c_ptip_id        number
    ,c_effective_date date
    )
  is
    select  /*+ bencepch.write_cobcep_odcache.c_ptipinstance */
            tab1.pgm_id,
            tab1.ptip_id,
            tab1.plip_id,
            tab1.pl_id,
            tab1.oipl_id,
            -- Grade/Step
            null vrbl_rt_prfl_id,
            -- Grade/Step
            tab1.prtn_elig_id,
            tab1.trk_scr_for_inelg_flag,
            tab2.compute_score_flag,
            tab2.mndtry_flag,
            tab3.eligy_prfl_id,
            tab3.asmt_to_use_cd,
            tab3.elig_enrld_plip_flag,
            tab3.elig_cbr_quald_bnf_flag,
            tab3.elig_enrld_ptip_flag,
            tab3.elig_dpnt_cvrd_plip_flag,
            tab3.elig_dpnt_cvrd_ptip_flag,
            tab3.elig_dpnt_cvrd_pgm_flag,
            tab3.elig_job_flag,
            tab3.elig_hrly_slrd_flag,
            tab3.elig_pstl_cd_flag,
            tab3.elig_lbr_mmbr_flag,
            tab3.elig_lgl_enty_flag,
            tab3.elig_benfts_grp_flag,
            tab3.elig_wk_loc_flag,
            tab3.elig_brgng_unit_flag,
            tab3.elig_age_flag,
            tab3.elig_los_flag,
            tab3.elig_per_typ_flag,
            tab3.elig_fl_tm_pt_tm_flag,
            tab3.elig_ee_stat_flag,
            tab3.elig_grd_flag,
            tab3.elig_pct_fl_tm_flag,
            tab3.elig_asnt_set_flag,
            tab3.elig_hrs_wkd_flag,
            tab3.elig_comp_lvl_flag,
            tab3.elig_org_unit_flag,
            tab3.elig_loa_rsn_flag,
            tab3.elig_pyrl_flag,
            tab3.elig_schedd_hrs_flag,
            tab3.elig_py_bss_flag,
            tab3.eligy_prfl_rl_flag,
            tab3.elig_cmbn_age_los_flag,
            tab3.cntng_prtn_elig_prfl_flag,
            tab3.elig_prtt_pl_flag,
            tab3.elig_ppl_grp_flag,
            tab3.elig_svc_area_flag,
            tab3.elig_ptip_prte_flag,
            tab3.elig_no_othr_cvg_flag,
            tab3.elig_enrld_pl_flag,
            tab3.elig_enrld_oipl_flag,
            tab3.elig_enrld_pgm_flag,
            tab3.elig_dpnt_cvrd_pl_flag,
            tab3.elig_lvg_rsn_flag,
            tab3.elig_optd_mdcr_flag,
            tab3.elig_tbco_use_flag,
            tab3.elig_dpnt_othr_ptip_flag,
            tab3.ELIG_GNDR_FLAG,
            tab3.ELIG_MRTL_STS_FLAG,
            tab3.ELIG_DSBLTY_CTG_FLAG,
            tab3.ELIG_DSBLTY_RSN_FLAG,
            tab3.ELIG_DSBLTY_DGR_FLAG,
            tab3.ELIG_SUPPL_ROLE_FLAG,
            tab3.ELIG_QUAL_TITL_FLAG,
            tab3.ELIG_PSTN_FLAG,
            tab3.ELIG_PRBTN_PERD_FLAG,
            tab3.ELIG_SP_CLNG_PRG_PT_FLAG,
            tab3.BNFT_CAGR_PRTN_CD,
            tab3.ELIG_DSBLD_FLAG,
            tab3.ELIG_TTL_CVG_VOL_FLAG,
            tab3.ELIG_TTL_PRTT_FLAG,
            tab3.ELIG_COMPTNCY_FLAG,
            tab3.ELIG_HLTH_CVG_FLAG,
            tab3.ELIG_ANTHR_PL_FLAG,
            tab3.elig_qua_in_gr_flag,
            tab3.elig_perf_rtng_flag,
            tab3.elig_crit_values_flag
    from  ben_prtn_elig_f tab1,
          ben_prtn_elig_prfl_f tab2,
          ben_eligy_prfl_f tab3
    where tab1.ptip_id = c_ptip_id
    and tab1.prtn_elig_id = tab2.prtn_elig_id
    and c_effective_date
      between tab1.effective_start_date
        and tab1.effective_end_date
    and tab2.eligy_prfl_id = tab3.eligy_prfl_id
    and tab3.stat_cd = 'A'                         -- bug 2431753 -- consider only active profiles
    and c_effective_date
      between tab2.effective_start_date
        and tab2.effective_end_date
    and c_effective_date
      between tab3.effective_start_date
    and tab3.effective_end_date
    order by tab1.pgm_id,
             tab1.ptip_id,
             tab1.plip_id,
             tab1.pl_id,
             tab1.oipl_id,
             decode(tab2.mndtry_flag,'Y',1,2);
  --
  cursor c_plipinstance
    (c_plip_id        number
    ,c_effective_date date
    )
  is
    select  /*+ bencepch.write_cobcep_odcache.c_plipinstance */
            tab1.pgm_id,
            tab1.ptip_id,
            tab1.plip_id,
            tab1.pl_id,
            tab1.oipl_id,
            -- Grade/Step
            null vrbl_rt_prfl_id,
            -- Grade/Step
            tab1.prtn_elig_id,
            tab1.trk_scr_for_inelg_flag,
            tab2.compute_score_flag,
            tab2.mndtry_flag,
            tab3.eligy_prfl_id,
            tab3.asmt_to_use_cd,
            tab3.elig_enrld_plip_flag,
            tab3.elig_cbr_quald_bnf_flag,
            tab3.elig_enrld_ptip_flag,
            tab3.elig_dpnt_cvrd_plip_flag,
            tab3.elig_dpnt_cvrd_ptip_flag,
            tab3.elig_dpnt_cvrd_pgm_flag,
            tab3.elig_job_flag,
            tab3.elig_hrly_slrd_flag,
            tab3.elig_pstl_cd_flag,
            tab3.elig_lbr_mmbr_flag,
            tab3.elig_lgl_enty_flag,
            tab3.elig_benfts_grp_flag,
            tab3.elig_wk_loc_flag,
            tab3.elig_brgng_unit_flag,
            tab3.elig_age_flag,
            tab3.elig_los_flag,
            tab3.elig_per_typ_flag,
            tab3.elig_fl_tm_pt_tm_flag,
            tab3.elig_ee_stat_flag,
            tab3.elig_grd_flag,
            tab3.elig_pct_fl_tm_flag,
            tab3.elig_asnt_set_flag,
            tab3.elig_hrs_wkd_flag,
            tab3.elig_comp_lvl_flag,
            tab3.elig_org_unit_flag,
            tab3.elig_loa_rsn_flag,
            tab3.elig_pyrl_flag,
            tab3.elig_schedd_hrs_flag,
            tab3.elig_py_bss_flag,
            tab3.eligy_prfl_rl_flag,
            tab3.elig_cmbn_age_los_flag,
            tab3.cntng_prtn_elig_prfl_flag,
            tab3.elig_prtt_pl_flag,
            tab3.elig_ppl_grp_flag,
            tab3.elig_svc_area_flag,
            tab3.elig_ptip_prte_flag,
            tab3.elig_no_othr_cvg_flag,
            tab3.elig_enrld_pl_flag,
            tab3.elig_enrld_oipl_flag,
            tab3.elig_enrld_pgm_flag,
            tab3.elig_dpnt_cvrd_pl_flag,
            tab3.elig_lvg_rsn_flag,
            tab3.elig_optd_mdcr_flag,
            tab3.elig_tbco_use_flag,
            tab3.elig_dpnt_othr_ptip_flag,
            tab3.ELIG_GNDR_FLAG,
            tab3.ELIG_MRTL_STS_FLAG,
            tab3.ELIG_DSBLTY_CTG_FLAG,
            tab3.ELIG_DSBLTY_RSN_FLAG,
            tab3.ELIG_DSBLTY_DGR_FLAG,
            tab3.ELIG_SUPPL_ROLE_FLAG,
            tab3.ELIG_QUAL_TITL_FLAG,
            tab3.ELIG_PSTN_FLAG,
            tab3.ELIG_PRBTN_PERD_FLAG,
            tab3.ELIG_SP_CLNG_PRG_PT_FLAG,
            tab3.BNFT_CAGR_PRTN_CD,
            tab3.ELIG_DSBLD_FLAG,
            tab3.ELIG_TTL_CVG_VOL_FLAG,
            tab3.ELIG_TTL_PRTT_FLAG,
            tab3.ELIG_COMPTNCY_FLAG,
            tab3.ELIG_HLTH_CVG_FLAG,
            tab3.ELIG_ANTHR_PL_FLAG,
            tab3.elig_qua_in_gr_flag,
            tab3.elig_perf_rtng_flag,
            tab3.elig_crit_values_flag
    from  ben_prtn_elig_f tab1,
          ben_prtn_elig_prfl_f tab2,
          ben_eligy_prfl_f tab3
    where tab1.plip_id = c_plip_id
    and tab1.prtn_elig_id = tab2.prtn_elig_id
    and c_effective_date
      between tab1.effective_start_date
        and tab1.effective_end_date
    and tab2.eligy_prfl_id = tab3.eligy_prfl_id
    and tab3.stat_cd = 'A'                         -- bug 2431753 -- consider only active profiles
    and c_effective_date
      between tab2.effective_start_date
        and tab2.effective_end_date
    and c_effective_date
      between tab3.effective_start_date
    and tab3.effective_end_date
    order by tab1.pgm_id,
             tab1.ptip_id,
             tab1.plip_id,
             tab1.pl_id,
             tab1.oipl_id,
             decode(tab2.mndtry_flag,'Y',1,2);
  --
  cursor c_plinstance
    (c_pl_id          number
    ,c_effective_date date
    )
  is
    select  /*+ bencepch.write_cobcep_odcache.c_plinstance */
            tab1.pgm_id,
            tab1.ptip_id,
            tab1.plip_id,
            tab1.pl_id,
            tab1.oipl_id,
            -- Grade/Step
            null vrbl_rt_prfl_id,
            -- Grade/Step
            tab1.prtn_elig_id,
            tab1.trk_scr_for_inelg_flag,
            tab2.compute_score_flag,
            tab2.mndtry_flag,
            tab3.eligy_prfl_id,
            tab3.asmt_to_use_cd,
            tab3.elig_enrld_plip_flag,
            tab3.elig_cbr_quald_bnf_flag,
            tab3.elig_enrld_ptip_flag,
            tab3.elig_dpnt_cvrd_plip_flag,
            tab3.elig_dpnt_cvrd_ptip_flag,
            tab3.elig_dpnt_cvrd_pgm_flag,
            tab3.elig_job_flag,
            tab3.elig_hrly_slrd_flag,
            tab3.elig_pstl_cd_flag,
            tab3.elig_lbr_mmbr_flag,
            tab3.elig_lgl_enty_flag,
            tab3.elig_benfts_grp_flag,
            tab3.elig_wk_loc_flag,
            tab3.elig_brgng_unit_flag,
            tab3.elig_age_flag,
            tab3.elig_los_flag,
            tab3.elig_per_typ_flag,
            tab3.elig_fl_tm_pt_tm_flag,
            tab3.elig_ee_stat_flag,
            tab3.elig_grd_flag,
            tab3.elig_pct_fl_tm_flag,
            tab3.elig_asnt_set_flag,
            tab3.elig_hrs_wkd_flag,
            tab3.elig_comp_lvl_flag,
            tab3.elig_org_unit_flag,
            tab3.elig_loa_rsn_flag,
            tab3.elig_pyrl_flag,
            tab3.elig_schedd_hrs_flag,
            tab3.elig_py_bss_flag,
            tab3.eligy_prfl_rl_flag,
            tab3.elig_cmbn_age_los_flag,
            tab3.cntng_prtn_elig_prfl_flag,
            tab3.elig_prtt_pl_flag,
            tab3.elig_ppl_grp_flag,
            tab3.elig_svc_area_flag,
            tab3.elig_ptip_prte_flag,
            tab3.elig_no_othr_cvg_flag,
            tab3.elig_enrld_pl_flag,
            tab3.elig_enrld_oipl_flag,
            tab3.elig_enrld_pgm_flag,
            tab3.elig_dpnt_cvrd_pl_flag,
            tab3.elig_lvg_rsn_flag,
            tab3.elig_optd_mdcr_flag,
            tab3.elig_tbco_use_flag,
            tab3.elig_dpnt_othr_ptip_flag,
            tab3.ELIG_GNDR_FLAG,
            tab3.ELIG_MRTL_STS_FLAG,
            tab3.ELIG_DSBLTY_CTG_FLAG,
            tab3.ELIG_DSBLTY_RSN_FLAG,
            tab3.ELIG_DSBLTY_DGR_FLAG,
            tab3.ELIG_SUPPL_ROLE_FLAG,
            tab3.ELIG_QUAL_TITL_FLAG,
            tab3.ELIG_PSTN_FLAG,
            tab3.ELIG_PRBTN_PERD_FLAG,
            tab3.ELIG_SP_CLNG_PRG_PT_FLAG,
            tab3.BNFT_CAGR_PRTN_CD,
            tab3.ELIG_DSBLD_FLAG,
            tab3.ELIG_TTL_CVG_VOL_FLAG,
            tab3.ELIG_TTL_PRTT_FLAG,
            tab3.ELIG_COMPTNCY_FLAG,
            tab3.ELIG_HLTH_CVG_FLAG,
            tab3.ELIG_ANTHR_PL_FLAG,
            tab3.elig_qua_in_gr_flag,
            tab3.elig_perf_rtng_flag,
            tab3.elig_crit_values_flag
    from  ben_prtn_elig_f tab1,
          ben_prtn_elig_prfl_f tab2,
          ben_eligy_prfl_f tab3
    where tab1.pl_id = c_pl_id
    and tab1.prtn_elig_id = tab2.prtn_elig_id
    and c_effective_date
      between tab1.effective_start_date
        and tab1.effective_end_date
    and tab2.eligy_prfl_id = tab3.eligy_prfl_id
    and tab3.stat_cd = 'A'                         -- bug 2431753 -- consider only active profiles
    and c_effective_date
      between tab2.effective_start_date
        and tab2.effective_end_date
    and c_effective_date
      between tab3.effective_start_date
    and tab3.effective_end_date
    order by tab1.pgm_id,
             tab1.ptip_id,
             tab1.plip_id,
             tab1.pl_id,
             tab1.oipl_id,
             decode(tab2.mndtry_flag,'Y',1,2);
  --
  cursor c_oiplinstance
    (c_oipl_id        number
    ,c_effective_date date
    )
  is
    select  /*+ bencepch.write_cobcep_odcache.c_oiplinstance */
            tab1.pgm_id,
            tab1.ptip_id,
            tab1.plip_id,
            tab1.pl_id,
            tab1.oipl_id,
            -- Grade/Step
            null vrbl_rt_prfl_id,
            -- Grade/Step
            tab1.prtn_elig_id,
            tab1.trk_scr_for_inelg_flag,
            tab2.compute_score_flag,
            tab2.mndtry_flag,
            tab3.eligy_prfl_id,
            tab3.asmt_to_use_cd,
            tab3.elig_enrld_plip_flag,
            tab3.elig_cbr_quald_bnf_flag,
            tab3.elig_enrld_ptip_flag,
            tab3.elig_dpnt_cvrd_plip_flag,
            tab3.elig_dpnt_cvrd_ptip_flag,
            tab3.elig_dpnt_cvrd_pgm_flag,
            tab3.elig_job_flag,
            tab3.elig_hrly_slrd_flag,
            tab3.elig_pstl_cd_flag,
            tab3.elig_lbr_mmbr_flag,
            tab3.elig_lgl_enty_flag,
            tab3.elig_benfts_grp_flag,
            tab3.elig_wk_loc_flag,
            tab3.elig_brgng_unit_flag,
            tab3.elig_age_flag,
            tab3.elig_los_flag,
            tab3.elig_per_typ_flag,
            tab3.elig_fl_tm_pt_tm_flag,
            tab3.elig_ee_stat_flag,
            tab3.elig_grd_flag,
            tab3.elig_pct_fl_tm_flag,
            tab3.elig_asnt_set_flag,
            tab3.elig_hrs_wkd_flag,
            tab3.elig_comp_lvl_flag,
            tab3.elig_org_unit_flag,
            tab3.elig_loa_rsn_flag,
            tab3.elig_pyrl_flag,
            tab3.elig_schedd_hrs_flag,
            tab3.elig_py_bss_flag,
            tab3.eligy_prfl_rl_flag,
            tab3.elig_cmbn_age_los_flag,
            tab3.cntng_prtn_elig_prfl_flag,
            tab3.elig_prtt_pl_flag,
            tab3.elig_ppl_grp_flag,
            tab3.elig_svc_area_flag,
            tab3.elig_ptip_prte_flag,
            tab3.elig_no_othr_cvg_flag,
            tab3.elig_enrld_pl_flag,
            tab3.elig_enrld_oipl_flag,
            tab3.elig_enrld_pgm_flag,
            tab3.elig_dpnt_cvrd_pl_flag,
            tab3.elig_lvg_rsn_flag,
            tab3.elig_optd_mdcr_flag,
            tab3.elig_tbco_use_flag,
            tab3.elig_dpnt_othr_ptip_flag,
            tab3.ELIG_GNDR_FLAG,
            tab3.ELIG_MRTL_STS_FLAG,
            tab3.ELIG_DSBLTY_CTG_FLAG,
            tab3.ELIG_DSBLTY_RSN_FLAG,
            tab3.ELIG_DSBLTY_DGR_FLAG,
            tab3.ELIG_SUPPL_ROLE_FLAG,
            tab3.ELIG_QUAL_TITL_FLAG,
            tab3.ELIG_PSTN_FLAG,
            tab3.ELIG_PRBTN_PERD_FLAG,
            tab3.ELIG_SP_CLNG_PRG_PT_FLAG,
            tab3.BNFT_CAGR_PRTN_CD,
            tab3.ELIG_DSBLD_FLAG,
            tab3.ELIG_TTL_CVG_VOL_FLAG,
            tab3.ELIG_TTL_PRTT_FLAG,
            tab3.ELIG_COMPTNCY_FLAG,
            tab3.ELIG_HLTH_CVG_FLAG,
            tab3.ELIG_ANTHR_PL_FLAG,
            tab3.elig_qua_in_gr_flag,
            tab3.elig_perf_rtng_flag,
            tab3.elig_crit_values_flag
    from  ben_prtn_elig_f tab1,
          ben_prtn_elig_prfl_f tab2,
          ben_eligy_prfl_f tab3
    where tab1.oipl_id = c_oipl_id
    and tab1.prtn_elig_id = tab2.prtn_elig_id
    and c_effective_date
      between tab1.effective_start_date
        and tab1.effective_end_date
    and tab2.eligy_prfl_id = tab3.eligy_prfl_id
    and tab3.stat_cd = 'A'                         -- bug 2431753 -- consider only active profiles
    and c_effective_date
      between tab2.effective_start_date
        and tab2.effective_end_date
    and c_effective_date
      between tab3.effective_start_date
    and tab3.effective_end_date
    order by tab1.pgm_id,
             tab1.ptip_id,
             tab1.plip_id,
             tab1.pl_id,
             tab1.oipl_id,
             decode(tab2.mndtry_flag,'Y',1,2);
  --
  -- Grade/Step
  cursor c_vpfinstance
    (c_vrbl_rt_prfl_id         number
    ,c_effective_date          date
    )
  is
    select  /*+ bencepch.write_cobcep_odcache.c_vpfinstance */
            null pgm_id,
            null ptip_id,
            null plip_id,
            null pl_id,
            null oipl_id,
            tab1.vrbl_rt_prfl_id, -- 9999 Needs to be added as null to other cursors
            null prtn_elig_id, -- Modified 9999 check how it is used?
            'N' trk_scr_for_inelg_flag,
            'N' compute_score_flag,
            tab2.mndtry_flag, -- comes from ben_vrbl_rt_eligy_prfl_f
            tab3.eligy_prfl_id,
            tab3.asmt_to_use_cd,
            tab3.elig_enrld_plip_flag,
            tab3.elig_cbr_quald_bnf_flag,
            tab3.elig_enrld_ptip_flag,
            tab3.elig_dpnt_cvrd_plip_flag,
            tab3.elig_dpnt_cvrd_ptip_flag,
            tab3.elig_dpnt_cvrd_pgm_flag,
            tab3.elig_job_flag,
            tab3.elig_hrly_slrd_flag,
            tab3.elig_pstl_cd_flag,
            tab3.elig_lbr_mmbr_flag,
            tab3.elig_lgl_enty_flag,
            tab3.elig_benfts_grp_flag,
            tab3.elig_wk_loc_flag,
            tab3.elig_brgng_unit_flag,
            tab3.elig_age_flag,
            tab3.elig_los_flag,
            tab3.elig_per_typ_flag,
            tab3.elig_fl_tm_pt_tm_flag,
            tab3.elig_ee_stat_flag,
            tab3.elig_grd_flag,
            tab3.elig_pct_fl_tm_flag,
            tab3.elig_asnt_set_flag,
            tab3.elig_hrs_wkd_flag,
            tab3.elig_comp_lvl_flag,
            tab3.elig_org_unit_flag,
            tab3.elig_loa_rsn_flag,
            tab3.elig_pyrl_flag,
            tab3.elig_schedd_hrs_flag,
            tab3.elig_py_bss_flag,
            tab3.eligy_prfl_rl_flag,
            tab3.elig_cmbn_age_los_flag,
            tab3.cntng_prtn_elig_prfl_flag,
            tab3.elig_prtt_pl_flag,
            tab3.elig_ppl_grp_flag,
            tab3.elig_svc_area_flag,
            tab3.elig_ptip_prte_flag,
            tab3.elig_no_othr_cvg_flag,
            tab3.elig_enrld_pl_flag,
            tab3.elig_enrld_oipl_flag,
            tab3.elig_enrld_pgm_flag,
            tab3.elig_dpnt_cvrd_pl_flag,
            tab3.elig_lvg_rsn_flag,
            tab3.elig_optd_mdcr_flag,
            tab3.elig_tbco_use_flag,
            tab3.elig_dpnt_othr_ptip_flag,
            tab3.ELIG_GNDR_FLAG,
            tab3.ELIG_MRTL_STS_FLAG,
            tab3.ELIG_DSBLTY_CTG_FLAG,
            tab3.ELIG_DSBLTY_RSN_FLAG,
            tab3.ELIG_DSBLTY_DGR_FLAG,
            tab3.ELIG_SUPPL_ROLE_FLAG,
            tab3.ELIG_QUAL_TITL_FLAG,
            tab3.ELIG_PSTN_FLAG,
            tab3.ELIG_PRBTN_PERD_FLAG,
            tab3.ELIG_SP_CLNG_PRG_PT_FLAG,
            tab3.BNFT_CAGR_PRTN_CD,
            tab3.ELIG_DSBLD_FLAG,
            tab3.ELIG_TTL_CVG_VOL_FLAG,
            tab3.ELIG_TTL_PRTT_FLAG,
            tab3.ELIG_COMPTNCY_FLAG,
            tab3.ELIG_HLTH_CVG_FLAG,
            tab3.ELIG_ANTHR_PL_FLAG,
            tab3.elig_qua_in_gr_flag,
            tab3.elig_perf_rtng_flag,
            tab3.elig_crit_values_flag
    from  ben_vrbl_rt_prfl_f tab1,
          ben_vrbl_rt_elig_prfl_f tab2,
          ben_eligy_prfl_f tab3
    where tab1.vrbl_rt_prfl_id = c_vrbl_rt_prfl_id
    and tab1.vrbl_rt_prfl_id = tab2.vrbl_rt_prfl_id
    and c_effective_date
      between tab1.effective_start_date
        and tab1.effective_end_date
    and tab2.eligy_prfl_id = tab3.eligy_prfl_id
    and tab3.stat_cd = 'A'
    and c_effective_date
      between tab2.effective_start_date
        and tab2.effective_end_date
    and c_effective_date
      between tab3.effective_start_date
    and tab3.effective_end_date
    order by 1, -- tab1.pgm_id, -- 9999 Add similar kind of order by clause to other cursors
             2, -- tab1.ptip_id,
             3, -- tab1.plip_id,
             4, -- tab1.pl_id,
             5, -- tab1.oipl_id,
             6, -- tab1.vrbl_rt_prfl_id,
             decode(tab2.mndtry_flag,'Y',1,2);
  --
  -- Grade/Step
begin
  --
  hr_utility.set_location(' Entering  '||l_proc,10);
  --
  -- Get the instance details
  --
  l_hv := mod(nvl(p_pgm_id,1)+nvl(p_ptip_id,2)+nvl(p_plip_id,3)
          +nvl(p_pl_id,4)+nvl(p_oipl_id,5)
          +nvl(p_vrbl_rt_prfl_id,6) -- Grade/Step
          ,ben_cep_cache.g_hash_key);
  --
  -- Get a unique hash value
  --
  if ben_cep_cache.g_copcep_odlookup.exists(l_hv) then
    --
    if nvl(ben_cep_cache.g_copcep_odlookup(l_hv).id,-1)        = nvl(p_pgm_id,-1)
      and nvl(ben_cep_cache.g_copcep_odlookup(l_hv).fk_id,-1)  = nvl(p_ptip_id,-1)
      and nvl(ben_cep_cache.g_copcep_odlookup(l_hv).fk1_id,-1) = nvl(p_plip_id,-1)
      and nvl(ben_cep_cache.g_copcep_odlookup(l_hv).fk2_id,-1) = nvl(p_pl_id,-1)
      and nvl(ben_cep_cache.g_copcep_odlookup(l_hv).fk3_id,-1) = nvl(p_oipl_id,-1)
      and nvl(ben_cep_cache.g_copcep_odlookup(l_hv).fk4_id,-1) = nvl(p_vrbl_rt_prfl_id,-1)  -- Grade/Step
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
        l_hv := l_hv+ben_cep_cache.g_hash_jump;
/*
        l_hv := ben_hash_utility.get_next_hash_index(p_hash_index => l_hv);
*/
        --
        -- Check if the hash index exists, and compare the values
        --
        if ben_cep_cache.g_copcep_odlookup.exists(l_hv) then
          --
          if nvl(ben_cep_cache.g_copcep_odlookup(l_hv).id,-1)        = nvl(p_pgm_id,-1)
            and nvl(ben_cep_cache.g_copcep_odlookup(l_hv).fk_id,-1)  = nvl(p_ptip_id,-1)
            and nvl(ben_cep_cache.g_copcep_odlookup(l_hv).fk1_id,-1) = nvl(p_plip_id,-1)
            and nvl(ben_cep_cache.g_copcep_odlookup(l_hv).fk2_id,-1) = nvl(p_pl_id,-1)
            and nvl(ben_cep_cache.g_copcep_odlookup(l_hv).fk3_id,-1) = nvl(p_oipl_id,-1)
            and nvl(ben_cep_cache.g_copcep_odlookup(l_hv).fk4_id,-1) = nvl(p_vrbl_rt_prfl_id,-1)  -- Grade/Step
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
  ben_cep_cache.g_copcep_odlookup(l_hv).id     := p_pgm_id;
  ben_cep_cache.g_copcep_odlookup(l_hv).fk_id  := p_ptip_id;
  ben_cep_cache.g_copcep_odlookup(l_hv).fk1_id := p_plip_id;
  ben_cep_cache.g_copcep_odlookup(l_hv).fk2_id := p_pl_id;
  ben_cep_cache.g_copcep_odlookup(l_hv).fk3_id := p_oipl_id;
  ben_cep_cache.g_copcep_odlookup(l_hv).fk4_id := p_vrbl_rt_prfl_id;
  --
  hr_utility.set_location(' Dn Look  '||l_proc,10);
  --
  l_starttorele_num := nvl(ben_cep_cache.g_copcep_nxelenum,1);
  l_torrwnum        := l_starttorele_num;
  --
  hr_utility.set_location(' Bef inst loop  '||l_proc,10);
  --
  if p_pgm_id is not null then
    --
    open c_pgminstance
      (c_pgm_id         => p_pgm_id
      ,c_effective_date => p_effective_date
      );
    --
  elsif p_ptip_id is not null then
    --
    open c_ptipinstance
      (c_ptip_id        => p_ptip_id
      ,c_effective_date => p_effective_date
      );
    --
  elsif p_plip_id is not null then
    --
    open c_plipinstance
      (c_plip_id        => p_plip_id
      ,c_effective_date => p_effective_date
      );
    --
  elsif p_pl_id is not null then
    --
    open c_plinstance
      (c_pl_id          => p_pl_id
      ,c_effective_date => p_effective_date
      );
    --
  elsif p_oipl_id is not null then
    --
    open c_oiplinstance
      (c_oipl_id        => p_oipl_id
      ,c_effective_date => p_effective_date
      );
    --
  -- Grade/Step
  elsif p_vrbl_rt_prfl_id is not null then
    --
    open c_vpfinstance
      (c_vrbl_rt_prfl_id        => p_vrbl_rt_prfl_id
      ,c_effective_date => p_effective_date
      );
    --
  end if;
  --
  loop
    --
    if p_pgm_id is not null then
      --
      fetch c_pgminstance into l_instance;
      exit when c_pgminstance%NOTFOUND;
      --
    elsif p_ptip_id is not null then
      --
      fetch c_ptipinstance into l_instance;
      exit when c_ptipinstance%NOTFOUND;
      --
    elsif p_plip_id is not null then
      --
      fetch c_plipinstance into l_instance;
      exit when c_plipinstance%NOTFOUND;
      --
    elsif p_pl_id is not null then
      --
      fetch c_plinstance into l_instance;
      exit when c_plinstance%NOTFOUND;
      --
    elsif p_oipl_id is not null then
      --
      fetch c_oiplinstance into l_instance;
      exit when c_oiplinstance%NOTFOUND;
      --
    -- Grade/Step
    elsif p_vrbl_rt_prfl_id is not null then
      --
      fetch c_vpfinstance into l_instance;
      exit when c_vpfinstance%NOTFOUND;
      --
    end if;
    --
    hr_utility.set_location(' Assign inst  '||l_proc,10);
    --
    ben_cep_cache.g_copcep_odinst.extend(1);
    ben_cep_cache.g_copcep_odinst(l_torrwnum).pgm_id                   := l_instance.pgm_id;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).ptip_id                  := l_instance.ptip_id;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).plip_id                  := l_instance.plip_id;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).pl_id                    := l_instance.pl_id;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).oipl_id                  := l_instance.oipl_id;
    -- Grade/Step
    ben_cep_cache.g_copcep_odinst(l_torrwnum).vrbl_rt_prfl_id      := l_instance.vrbl_rt_prfl_id;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).prtn_elig_id             := l_instance.prtn_elig_id;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).trk_scr_for_inelg_flag   := l_instance.trk_scr_for_inelg_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).compute_score_flag       := l_instance.compute_score_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).mndtry_flag              := l_instance.mndtry_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).eligy_prfl_id            := l_instance.eligy_prfl_id;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).asmt_to_use_cd           := l_instance.asmt_to_use_cd;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_enrld_plip_flag     := l_instance.elig_enrld_plip_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_cbr_quald_bnf_flag  := l_instance.elig_cbr_quald_bnf_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_enrld_ptip_flag     := l_instance.elig_enrld_ptip_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_dpnt_cvrd_plip_flag := l_instance.elig_dpnt_cvrd_plip_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_dpnt_cvrd_ptip_flag := l_instance.elig_dpnt_cvrd_ptip_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_dpnt_cvrd_pgm_flag  := l_instance.elig_dpnt_cvrd_pgm_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_job_flag            := l_instance.elig_job_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_hrly_slrd_flag      := l_instance.elig_hrly_slrd_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_pstl_cd_flag        := l_instance.elig_pstl_cd_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_lbr_mmbr_flag       := l_instance.elig_lbr_mmbr_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_lgl_enty_flag       := l_instance.elig_lgl_enty_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_benfts_grp_flag     := l_instance.elig_benfts_grp_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_wk_loc_flag         := l_instance.elig_wk_loc_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_brgng_unit_flag     := l_instance.elig_brgng_unit_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_age_flag            := l_instance.elig_age_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_los_flag            := l_instance.elig_los_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_per_typ_flag        := l_instance.elig_per_typ_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_fl_tm_pt_tm_flag    := l_instance.elig_fl_tm_pt_tm_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_ee_stat_flag        := l_instance.elig_ee_stat_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_grd_flag            := l_instance.elig_grd_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_pct_fl_tm_flag      := l_instance.elig_pct_fl_tm_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_asnt_set_flag       := l_instance.elig_asnt_set_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_hrs_wkd_flag        := l_instance.elig_hrs_wkd_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_comp_lvl_flag       := l_instance.elig_comp_lvl_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_org_unit_flag       := l_instance.elig_org_unit_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_loa_rsn_flag        := l_instance.elig_loa_rsn_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_pyrl_flag           := l_instance.elig_pyrl_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_schedd_hrs_flag     := l_instance.elig_schedd_hrs_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_py_bss_flag         := l_instance.elig_py_bss_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).eligy_prfl_rl_flag       := l_instance.eligy_prfl_rl_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_cmbn_age_los_flag   := l_instance.elig_cmbn_age_los_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).cntng_prtn_elig_prfl_flag := l_instance.cntng_prtn_elig_prfl_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_prtt_pl_flag         := l_instance.elig_prtt_pl_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_ppl_grp_flag         := l_instance.elig_ppl_grp_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_svc_area_flag        := l_instance.elig_svc_area_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_ptip_prte_flag       := l_instance.elig_ptip_prte_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_no_othr_cvg_flag     := l_instance.elig_no_othr_cvg_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_enrld_pl_flag        := l_instance.elig_enrld_pl_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_enrld_oipl_flag      := l_instance.elig_enrld_oipl_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_enrld_pgm_flag       := l_instance.elig_enrld_pgm_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_dpnt_cvrd_pl_flag    := l_instance.elig_dpnt_cvrd_pl_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_lvg_rsn_flag         := l_instance.elig_lvg_rsn_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_optd_mdcr_flag       := l_instance.elig_optd_mdcr_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_tbco_use_flag        := l_instance.elig_tbco_use_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_dpnt_othr_ptip_flag  := l_instance.elig_dpnt_othr_ptip_flag;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).ELIG_GNDR_FLAG 		  := l_instance.ELIG_GNDR_FLAG 		;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).ELIG_MRTL_STS_FLAG 	  := l_instance.ELIG_MRTL_STS_FLAG 	;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).ELIG_DSBLTY_CTG_FLAG 	  := l_instance.ELIG_DSBLTY_CTG_FLAG 	;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).ELIG_DSBLTY_RSN_FLAG 	  := l_instance.ELIG_DSBLTY_RSN_FLAG 	;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).ELIG_DSBLTY_DGR_FLAG 	  := l_instance.ELIG_DSBLTY_DGR_FLAG 	;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).ELIG_SUPPL_ROLE_FLAG 	  := l_instance.ELIG_SUPPL_ROLE_FLAG 	;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).ELIG_QUAL_TITL_FLAG 	  := l_instance.ELIG_QUAL_TITL_FLAG 	;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).ELIG_PSTN_FLAG 		  := l_instance.ELIG_PSTN_FLAG 		;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).ELIG_PRBTN_PERD_FLAG 	  := l_instance.ELIG_PRBTN_PERD_FLAG 	;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).ELIG_SP_CLNG_PRG_PT_FLAG  := l_instance.ELIG_SP_CLNG_PRG_PT_FLAG;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).BNFT_CAGR_PRTN_CD 	  := l_instance.BNFT_CAGR_PRTN_CD 	;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_dsbld_flag 	  := l_instance.elig_dsbld_flag 	;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_ttl_cvg_vol_flag 	  := l_instance.elig_ttl_cvg_vol_flag 	;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_ttl_prtt_flag 	  := l_instance.elig_ttl_prtt_flag 	;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_comptncy_flag 	  := l_instance.elig_comptncy_flag 	;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_hlth_cvg_flag 	  := l_instance.elig_hlth_cvg_flag 	;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_anthr_pl_flag 	  := l_instance.elig_anthr_pl_flag 	;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_qua_in_gr_flag	  := l_instance.elig_qua_in_gr_flag	;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_perf_rtng_flag	  := l_instance.elig_perf_rtng_flag	;
    ben_cep_cache.g_copcep_odinst(l_torrwnum).elig_crit_values_flag       := l_instance.elig_crit_values_flag	;
    hr_utility.set_location(' Dn Assign inst  '||l_proc,10);
    --
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  if p_pgm_id is not null then
    --
    close c_pgminstance;
    --
  elsif p_ptip_id is not null then
    --
    close c_ptipinstance;
    --
  elsif p_plip_id is not null then
    --
    close c_plipinstance;
    --
  elsif p_pl_id is not null then
    --
    close c_plinstance;
    --
  elsif p_oipl_id is not null then
    --
    close c_oiplinstance;
    --
  elsif p_vrbl_rt_prfl_id is not null then
    --
    close c_vpfinstance;
    --
  end if;
  --
  -- Check if any rows were found
  --
  if l_torrwnum > nvl(ben_cep_cache.g_copcep_nxelenum,1)
  then
    --
    ben_cep_cache.g_copcep_odlookup(l_hv).starttorele_num := l_starttorele_num;
    ben_cep_cache.g_copcep_odlookup(l_hv).endtorele_num   := l_torrwnum-1;
    ben_cep_cache.g_copcep_nxelenum := l_torrwnum;
    --
    p_hv := l_hv;
    --
  else
    --
    -- Delete and free PGA with assignment
    --
    ben_cep_cache.g_copcep_odlookup.delete(l_hv);
    ben_cep_cache.g_copcep_odlookup(l_hv) := l_copcep_odlookup_rec;
    --
/*
    ben_cep_cache.g_copcep_odlookup(l_hv).starttorele_num := null;
    ben_cep_cache.g_copcep_odlookup(l_hv).endtorele_num   := null;
*/
/*
    ben_cep_cache.g_copcep_odlookup(l_hv).id              := null;
    ben_cep_cache.g_copcep_odlookup(l_hv).fk_id           := null;
    ben_cep_cache.g_copcep_odlookup(l_hv).fk1_id          := null;
    ben_cep_cache.g_copcep_odlookup(l_hv).fk2_id          := null;
    ben_cep_cache.g_copcep_odlookup(l_hv).fk3_id          := null;
    ben_cep_cache.g_copcep_odlookup(l_hv).starttorele_num := null;
    ben_cep_cache.g_copcep_odlookup(l_hv).endtorele_num   := null;
*/
    p_hv := null;
    --
  end if;
  --
  hr_utility.set_location(' Leaving  '||l_proc,10);
end write_cobcep_odcache;
--
end ben_cep_cache1;

/
