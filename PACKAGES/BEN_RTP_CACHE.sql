--------------------------------------------------------
--  DDL for Package BEN_RTP_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_RTP_CACHE" AUTHID CURRENT_USER AS
/* $Header: benrtpch.pkh 120.0 2005/12/01 17:24:48 kmahendr noship $ */
--
type g_cobcep_cache_rec is record
  (vrbl_rt_prfl_id number
  ,acty_base_rt_id     number
  ,cvg_amt_calc_mthd_id number
  ,actl_prem_id         number
  ,rt_hrly_slrd_flag     varchar2(30)
  ,rt_pstl_cd_flag     varchar2(30)
  ,rt_lbr_mmbr_flag     varchar2(30)
  ,rt_lgl_enty_flag     varchar2(30)
  ,rt_benfts_grp_flag     varchar2(30)
  ,rt_wk_loc_flag     varchar2(30)
  ,rt_brgng_unit_flag     varchar2(30)
  ,rt_age_flag     varchar2(30)
  ,rt_los_flag     varchar2(30)
  ,rt_per_typ_flag     varchar2(30)
  ,rt_fl_tm_pt_tm_flag     varchar2(30)
  ,rt_ee_stat_flag     varchar2(30)
  ,rt_grd_flag     varchar2(30)
  ,rt_pct_fl_tm_flag     varchar2(30)
  ,rt_asnt_set_flag     varchar2(30)
  ,rt_hrs_wkd_flag     varchar2(30)
  ,rt_comp_lvl_flag     varchar2(30)
  ,rt_org_unit_flag     varchar2(30)
  ,rt_loa_rsn_flag     varchar2(30)
  ,rt_pyrl_flag     varchar2(30)
  ,rt_schedd_hrs_flag     varchar2(30)
  ,rt_py_bss_flag     varchar2(30)
  ,rt_prfl_rl_flag     varchar2(30)
  ,rt_cmbn_age_los_flag     varchar2(30)
  ,rt_prtt_pl_flag     varchar2(30)
  ,rt_svc_area_flag     varchar2(30)
  ,rt_ppl_grp_flag     varchar2(30)
  ,rt_dsbld_flag     varchar2(30)
  ,rt_hlth_cvg_flag     varchar2(30)
  ,rt_poe_flag     varchar2(30)
  ,rt_ttl_cvg_vol_flag     varchar2(30)
  ,rt_ttl_prtt_flag     varchar2(30)
  ,rt_gndr_flag     varchar2(30)
  ,rt_tbco_use_flag      varchar2(30)
  ,rt_cntng_prtn_prfl_flag      varchar2(30)
  ,rt_cbr_quald_bnf_flag     varchar2(30)
  ,rt_optd_mdcr_flag     varchar2(30)
  ,rt_lvg_rsn_flag      varchar2(30)
  ,rt_pstn_flag      varchar2(30)
  ,rt_comptncy_flag      varchar2(30)
  ,rt_job_flag      varchar2(30)
  ,rt_qual_titl_flag      varchar2(30)
  ,rt_dpnt_cvrd_pl_flag     varchar2(30)
  ,rt_dpnt_cvrd_plip_flag     varchar2(30)
  ,rt_dpnt_cvrd_ptip_flag     varchar2(30)
  ,rt_dpnt_cvrd_pgm_flag     varchar2(30)
  ,rt_enrld_oipl_flag     varchar2(30)
  ,rt_enrld_pl_flag     varchar2(30)
  ,rt_enrld_plip_flag     varchar2(30)
  ,rt_enrld_ptip_flag     varchar2(30)
  ,rt_enrld_pgm_flag     varchar2(30)
  ,rt_prtt_anthr_pl_flag     varchar2(30)
  ,rt_othr_ptip_flag     varchar2(30)
  ,rt_no_othr_cvg_flag     varchar2(30)
  ,rt_dpnt_othr_ptip_flag     varchar2(30)
  ,rt_qua_in_gr_flag     varchar2(30)
  ,rt_perf_rtng_flag     varchar2(30)
  ,asmt_to_use_cd     varchar2(30)
  ,ordr_num           number
  ,rt_elig_prfl_flag     varchar2(30)
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
procedure abravr_odgetdets
  (p_effective_date          in     date
  ,p_acty_base_rt_id         in     number default hr_api.g_number
  ,p_cvg_amt_calc_mthd_id    in     number default hr_api.g_number
  ,p_actl_prem_id            in     number default hr_api.g_number
  ,p_inst_set                in out nocopy  g_cobcep_odcache
  );
--
END ben_rtp_cache;

 

/
