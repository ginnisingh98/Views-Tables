--------------------------------------------------------
--  DDL for Package BEN_CEP_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CEP_CACHE" AUTHID CURRENT_USER AS
/* $Header: bencepch.pkh 120.1 2006/01/12 21:00:56 mhoyes noship $ */
--
type g_cobcep_cache_rec is record
  (id number
  ,pgm_id ben_prtn_elig_f.pgm_id%type
  ,ptip_id ben_prtn_elig_f.ptip_id%type
  ,plip_id ben_prtn_elig_f.plip_id%type
  ,pl_id ben_prtn_elig_f.pl_id%type
  ,oipl_id ben_prtn_elig_f.oipl_id%type
  -- Grade/Step
  ,vrbl_rt_prfl_id       ben_vrbl_rt_prfl_f.vrbl_rt_prfl_id%type
  ,prtn_elig_id ben_prtn_elig_f.prtn_elig_id%type
  ,trk_scr_for_inelg_flag ben_prtn_elig_f.trk_scr_for_inelg_flag%type
  ,compute_score_flag ben_prtn_elig_prfl_f.compute_score_flag%type
  ,mndtry_flag ben_prtn_elig_prfl_f.mndtry_flag%type
  ,eligy_prfl_id ben_eligy_prfl_f.eligy_prfl_id%type
  ,asmt_to_use_cd ben_eligy_prfl_f.asmt_to_use_cd%type
  ,elig_enrld_plip_flag varchar2(30)
  ,elig_cbr_quald_bnf_flag varchar2(30)
  ,elig_enrld_ptip_flag varchar2(30)
  ,elig_dpnt_cvrd_plip_flag varchar2(30)
  ,elig_dpnt_cvrd_ptip_flag varchar2(30)
  ,elig_dpnt_cvrd_pgm_flag varchar2(30)
  ,elig_job_flag varchar2(30)
  ,elig_hrly_slrd_flag varchar2(30)
  ,elig_pstl_cd_flag varchar2(30)
  ,elig_lbr_mmbr_flag varchar2(30)
  ,elig_lgl_enty_flag varchar2(30)
  ,elig_benfts_grp_flag varchar2(30)
  ,elig_wk_loc_flag varchar2(30)
  ,elig_brgng_unit_flag varchar2(30)
  ,elig_age_flag varchar2(30)
  ,elig_los_flag varchar2(30)
  ,elig_per_typ_flag varchar2(30)
  ,elig_fl_tm_pt_tm_flag varchar2(30)
  ,elig_ee_stat_flag varchar2(30)
  ,elig_grd_flag varchar2(30)
  ,elig_pct_fl_tm_flag varchar2(30)
  ,elig_asnt_set_flag varchar2(30)
  ,elig_hrs_wkd_flag varchar2(30)
  ,elig_comp_lvl_flag varchar2(30)
  ,elig_org_unit_flag varchar2(30)
  ,elig_loa_rsn_flag varchar2(30)
  ,elig_pyrl_flag varchar2(30)
  ,elig_schedd_hrs_flag varchar2(30)
  ,elig_py_bss_flag varchar2(30)
  ,eligy_prfl_rl_flag varchar2(30)
  ,elig_cmbn_age_los_flag varchar2(30)
  ,cntng_prtn_elig_prfl_flag varchar2(30)
  ,elig_prtt_pl_flag varchar2(30)
  ,elig_ppl_grp_flag varchar2(30)
  ,elig_svc_area_flag varchar2(30)
  ,elig_ptip_prte_flag varchar2(30)
  ,elig_no_othr_cvg_flag varchar2(30)
  ,elig_enrld_pl_flag varchar2(30)
  ,elig_enrld_oipl_flag varchar2(30)
  ,elig_enrld_pgm_flag varchar2(30)
  ,elig_dpnt_cvrd_pl_flag varchar2(30)
  ,elig_lvg_rsn_flag varchar2(30)
  ,elig_optd_mdcr_flag varchar2(30)
  ,elig_tbco_use_flag varchar2(30)
  ,elig_dpnt_othr_ptip_flag varchar2(30)
  ,ELIG_GNDR_FLAG varchar2(30)
  ,ELIG_MRTL_STS_FLAG varchar2(30)
  ,ELIG_DSBLTY_CTG_FLAG varchar2(30)
  ,ELIG_DSBLTY_RSN_FLAG varchar2(30)
  ,ELIG_DSBLTY_DGR_FLAG varchar2(30)
  ,ELIG_SUPPL_ROLE_FLAG varchar2(30)
  ,ELIG_QUAL_TITL_FLAG varchar2(30)
  ,ELIG_PSTN_FLAG varchar2(30)
  ,ELIG_PRBTN_PERD_FLAG varchar2(30)
  ,ELIG_SP_CLNG_PRG_PT_FLAG varchar2(30)
  ,BNFT_CAGR_PRTN_CD varchar2(30)
  ,elig_dsbld_flag varchar2(30)
  ,elig_ttl_cvg_vol_flag varchar2(30)
  ,elig_ttl_prtt_flag varchar2(30)
  ,elig_comptncy_flag varchar2(30)
  ,elig_hlth_cvg_flag varchar2(30)
  ,elig_anthr_pl_flag varchar2(30)
  ,elig_qua_in_gr_flag varchar2(30)
  ,elig_perf_rtng_flag varchar2(30)
  ,elig_crit_values_flag varchar2(30)
  );
--
type g_cobcep_odcache is varray(1000000) of g_cobcep_cache_rec;
--
g_copcep_odlookup ben_cache.g_cache_lookup_table;
g_copcep_nxelenum number;
g_copcep_odinst    g_cobcep_odcache :=  g_cobcep_odcache();
g_copcep_odcached pls_integer := 0;
--
g_hash_key  pls_integer := 1299827;
g_hash_jump pls_integer := 100;
--
procedure clear_down_cache;
--
procedure cobcep_odgetdets
  (p_effective_date  in     date
  ,p_pgm_id          in     number
  ,p_pl_id           in     number
  ,p_oipl_id         in     number
  ,p_plip_id         in     number
  ,p_ptip_id         in     number
  -- Grade/Step
  ,p_vrbl_rt_prfl_id in     number
  --
  ,p_inst_set        in out nocopy  g_cobcep_odcache
  );
--
END ben_cep_cache;

 

/
