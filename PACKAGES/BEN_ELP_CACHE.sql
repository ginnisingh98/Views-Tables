--------------------------------------------------------
--  DDL for Package BEN_ELP_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELP_CACHE" AUTHID CURRENT_USER AS
/* $Header: benelpch.pkh 120.0 2005/05/28 08:57:43 appldev noship $ */
type g_cobcep_cache_rec is record
(id number
,pgm_id ben_prtn_elig_f.pgm_id%type
,ptip_id ben_prtn_elig_f.ptip_id%type
,plip_id ben_prtn_elig_f.plip_id%type
,pl_id ben_prtn_elig_f.pl_id%type
,oipl_id ben_prtn_elig_f.oipl_id%type
,prtn_elig_id ben_prtn_elig_f.prtn_elig_id%type
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
,elig_gndr_flag varchar2(30)
,elig_mrtl_sts_flag varchar2(30)
,elig_dsblty_ctg_flag varchar2(30)
,elig_dsblty_rsn_flag varchar2(30)
,elig_dsblty_dgr_flag varchar2(30)
,elig_suppl_role_flag varchar2(30)
,elig_qual_titl_flag varchar2(30)
,elig_pstn_flag varchar2(30)
,elig_prbtn_perd_flag varchar2(30)
,elig_sp_clng_prg_pt_flag varchar2(30)
,bnft_cagr_prtn_cd varchar2(30)
---
,elig_dsbld_flag varchar2(30)
,elig_ttl_cvg_vol_flag varchar2(30)
,elig_ttl_prtt_flag varchar2(30)
,elig_comptncy_flag varchar2(30)
,elig_hlth_cvg_flag varchar2(30)
,elig_anthr_pl_flag varchar2(30)
,elig_qua_in_gr_flag varchar2(30)
,elig_perf_rtng_flag varchar2(30)
);
--
-- Comp object
--
type g_cobcep_cache is table of g_cobcep_cache_rec
index by binary_integer;
--
procedure cobcep_getdets
  (p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_pgm_id            in     number default hr_api.g_number
  ,p_pl_id             in     number default hr_api.g_number
  ,p_oipl_id           in     number default hr_api.g_number
  ,p_plip_id           in     number default hr_api.g_number
  ,p_ptip_id           in     number default hr_api.g_number
  --
  ,p_inst_set             out nocopy ben_elp_cache.g_cobcep_cache
  ,p_inst_count           out nocopy number
  );
--
type g_cobcep_odcache is varray(1000000) of g_cobcep_cache_rec;
--
procedure cobcep_odgetdets
  (p_effective_date in     date
  ,p_pgm_id         in     number default hr_api.g_number
  ,p_pl_id          in     number default hr_api.g_number
  ,p_oipl_id        in     number default hr_api.g_number
  ,p_plip_id        in     number default hr_api.g_number
  ,p_ptip_id        in     number default hr_api.g_number
  --
  ,p_inst_set       in out nocopy ben_elp_cache.g_cobcep_odcache
  );
--
type g_elpelc_cache_rec is record
(eligy_prfl_id number
,pk_id number
,short_code varchar2(30)
,code varchar2(100)
,id number
,id1 number
,from_value varchar2(100)
,to_value varchar2(100)
,mx_num number
,mn_num number
,no_mx_num_apls_flag varchar2(100)
,no_mn_num_apls_flag varchar2(100)
,cmbnd_min_val number
,cmbnd_max_val number
,excld_flag varchar2(100)
,criteria_score number
,criteria_weight number
);
--
type g_elpelc_cache is table of g_elpelc_cache_rec
index by binary_integer;
--
g_elpept_lookup ben_cache.g_cache_lookup_table;
g_elpept_inst   ben_elp_cache.g_elpelc_cache;
g_elpees_lookup ben_cache.g_cache_lookup_table;
g_elpees_inst   ben_elp_cache.g_elpelc_cache;
g_elpesa_lookup ben_cache.g_cache_lookup_table;
g_elpesa_inst   ben_elp_cache.g_elpelc_cache;
g_elpehs_lookup ben_cache.g_cache_lookup_table;
g_elpehs_inst   ben_elp_cache.g_elpelc_cache;
g_elpels_lookup ben_cache.g_cache_lookup_table;
g_elpels_inst   ben_elp_cache.g_elpelc_cache;
g_elpecp_lookup ben_cache.g_cache_lookup_table;
g_elpecp_inst   ben_elp_cache.g_elpelc_cache;
--
procedure elpelc_getdets
(p_business_group_id in     number
,p_effective_date    in     date
,p_eligy_prfl_id in     number default hr_api.g_number
,p_cache_code in     varchar2 default hr_api.g_varchar2
--
,p_inst_set             out nocopy ben_elp_cache.g_elpelc_cache
,p_inst_count           out nocopy number
)
;

--
-- eligibility profile person type by eligibility profile
--
type g_cache_elpesa_object_rec is record
  (eligy_prfl_id ben_eligy_prfl_f.eligy_prfl_id%type,
   pk_id             number,
   short_code        varchar2(30),
   criteria_score    ben_elig_svc_area_prte_f.criteria_score%type,
   criteria_weight   ben_elig_svc_area_prte_f.criteria_weight%type,
   from_value        ben_pstl_zip_rng_f.from_value%type,
   to_value          ben_pstl_zip_rng_f.to_value%type,
   excld_flag        ben_elig_svc_area_prte_f.excld_flag%type);
--
type g_cache_elpesa_instor is table of g_cache_elpesa_object_rec
     index by binary_integer;
--
-- eligibility profile person type by eligibility profile
--
type g_cache_elpept_object_rec is record
  (eligy_prfl_id ben_eligy_prfl_f.eligy_prfl_id%type,
   pk_id             number,
   short_code        varchar2(30),
   criteria_score    ben_elig_per_typ_prte_f.criteria_score%type,
   criteria_weight   ben_elig_per_typ_prte_f.criteria_weight%type,
   -- per_typ_cd     ben_elig_per_typ_prte_f.per_typ_cd%type,
   -- Not supporting per_typ_cd, instead use person_typ_id
   person_type_id    ben_elig_per_typ_prte_f.person_type_id%type,
   excld_flag        ben_elig_per_typ_prte_f.excld_flag%type);
--
type g_cache_elpept_instor is table of g_cache_elpept_object_rec
     index by binary_integer;
--
-- eligibility profile people group by eligibility profile
--
type g_cache_elpepg_object_rec is record
  (eligy_prfl_id   ben_eligy_prfl_f.eligy_prfl_id%type,
   pk_id           number,
   short_code      varchar2(30),
   people_group_id ben_elig_ppl_grp_prte_f.people_group_id%type,
   excld_flag      ben_elig_ppl_grp_prte_f.excld_flag%type,
   criteria_score  ben_elig_ppl_grp_prte_f.criteria_score%type,
   criteria_weight ben_elig_ppl_grp_prte_f.criteria_weight%type,
   segment1        varchar2(60),
   segment2        varchar2(60),
   segment3        varchar2(60),
   segment4        varchar2(60),
   segment5        varchar2(60),
   segment6        varchar2(60),
   segment7        varchar2(60),
   segment8        varchar2(60),
   segment9        varchar2(60),
   segment10       varchar2(60),
   segment11       varchar2(60),
   segment12       varchar2(60),
   segment13       varchar2(60),
   segment14       varchar2(60),
   segment15       varchar2(60),
   segment16       varchar2(60),
   segment17       varchar2(60),
   segment18       varchar2(60),
   segment19       varchar2(60),
   segment20       varchar2(60),
   segment21       varchar2(60),
   segment22       varchar2(60),
   segment23       varchar2(60),
   segment24       varchar2(60),
   segment25       varchar2(60),
   segment26       varchar2(60),
   segment27       varchar2(60),
   segment28       varchar2(60),
   segment29       varchar2(60),
   segment30       varchar2(60)  );
--
type g_cache_elpepg_instor is table of g_cache_elpepg_object_rec
     index by binary_integer;
--
-- eligibility profile assignment status type by eligibility profile
--
type g_cache_elpees_object_rec is record
  (eligy_prfl_id             ben_eligy_prfl_f.eligy_prfl_id%type,
   pk_id                     number,
   short_code                varchar2(30),
   assignment_status_type_id ben_elig_ee_stat_prte_f.
                             assignment_status_type_id%type,
   excld_flag                ben_elig_ee_stat_prte_f.excld_flag%type,
   criteria_score            ben_elig_ee_stat_prte_f.criteria_score%type,
   criteria_weight           ben_elig_ee_stat_prte_f.criteria_weight%type
);
--
type g_cache_elpees_instor is table of g_cache_elpees_object_rec
     index by binary_integer;
--
-- eligibility profile length of service by eligibility profile
--
type g_cache_elpels_object_rec is record
  (eligy_prfl_id           ben_eligy_prfl_f.eligy_prfl_id%type,
   pk_id                   number,
   short_code              varchar2(30),
   excld_flag              ben_elig_los_prte_f.excld_flag%type,
   criteria_score          ben_elig_los_prte_f.criteria_score%type,
   criteria_weight         ben_elig_los_prte_f.criteria_weight%type,
   mx_los_num              ben_los_fctr.mx_los_num%type,
   mn_los_num              ben_los_fctr.mn_los_num%type,
   no_mx_los_num_apls_flag ben_los_fctr.no_mx_los_num_apls_flag%type,
   no_mn_los_num_apls_flag ben_los_fctr.no_mn_los_num_apls_flag%type,
   los_fctr_id             ben_los_fctr.los_fctr_id%type);
--
type g_cache_elpels_instor is table of g_cache_elpels_object_rec
     index by binary_integer;
--
-- eligibility profile age/los combination by eligibility profile
--
type g_cache_elpecp_object_rec is record
  (eligy_prfl_id     ben_eligy_prfl_f.eligy_prfl_id%type,
   pk_id             number,
   short_code        varchar2(30),
   excld_flag        ben_elig_cmbn_age_los_prte_f.excld_flag%type,
   criteria_score    ben_elig_cmbn_age_los_prte_f.criteria_score%type,
   criteria_weight   ben_elig_cmbn_age_los_prte_f.criteria_weight%type,
   cmbnd_min_val     ben_cmbn_age_los_fctr.cmbnd_min_val%type,
   cmbnd_max_val     ben_cmbn_age_los_fctr.cmbnd_max_val%type,
   los_fctr_id       ben_cmbn_age_los_fctr.los_fctr_id%type,
   age_fctr_id       ben_cmbn_age_los_fctr.age_fctr_id%type,
   cmbn_age_los_fctr_id   ben_cmbn_age_los_fctr.cmbn_age_los_fctr_id%type);
--
type g_cache_elpecp_instor is table of g_cache_elpecp_object_rec
     index by binary_integer;
--
-- eligibility profile location by eligibility profile
--
type g_cache_elpewl_object_rec is record
  (eligy_prfl_id           ben_eligy_prfl_f.eligy_prfl_id%type,
   pk_id                   number,
   short_code              varchar2(30),
   location_id             ben_elig_wk_loc_prte_f.location_id%type,
   excld_flag              ben_elig_wk_loc_prte_f.excld_flag%type,
   criteria_score          ben_elig_wk_loc_prte_f.criteria_score%type,
   criteria_weight         ben_elig_wk_loc_prte_f.criteria_weight%type);
--
type g_cache_elpewl_instor is table of g_cache_elpewl_object_rec
     index by binary_integer;
--
-- eligibility profile organization by eligibility profile
--
type g_cache_elpeou_object_rec is record
  (eligy_prfl_id   ben_eligy_prfl_f.eligy_prfl_id%type,
   pk_id           number,
   short_code      varchar2(30),
   organization_id ben_elig_org_unit_prte_f.organization_id%type,
   excld_flag      ben_elig_org_unit_prte_f.excld_flag%type,
   criteria_score  ben_elig_org_unit_prte_f.criteria_score%type,
   criteria_weight ben_elig_org_unit_prte_f.criteria_weight%type);
--
type g_cache_elpeou_instor is table of g_cache_elpeou_object_rec
     index by binary_integer;
--
-- eligibility profile pay frequency by eligibility profile
--
type g_cache_elpehs_object_rec is record
  (eligy_prfl_id   ben_eligy_prfl_f.eligy_prfl_id%type,
   pk_id           number,
   short_code      varchar2(30),
   hrly_slrd_cd    ben_elig_hrly_slrd_prte_f.hrly_slrd_cd%type,
   excld_flag      ben_elig_hrly_slrd_prte_f.excld_flag%type,
   criteria_score  ben_elig_hrly_slrd_prte_f.criteria_score%type,
   criteria_weight ben_elig_hrly_slrd_prte_f.criteria_weight%type);
--
type g_cache_elpehs_instor is table of g_cache_elpehs_object_rec
     index by binary_integer;
--
-- eligibility profile full/part time by eligibility profile
--
type g_cache_elpefp_object_rec is record
  (eligy_prfl_id   ben_eligy_prfl_f.eligy_prfl_id%type,
   pk_id           number,
   short_code      varchar2(30),
   fl_tm_pt_tm_cd  ben_elig_fl_tm_pt_tm_prte_f.fl_tm_pt_tm_cd%type,
   excld_flag      ben_elig_fl_tm_pt_tm_prte_f.excld_flag%type,
   criteria_score  ben_elig_fl_tm_pt_tm_prte_f.criteria_score%type,
   criteria_weight ben_elig_fl_tm_pt_tm_prte_f.criteria_weight%type);
--
type g_cache_elpefp_instor is table of g_cache_elpefp_object_rec
     index by binary_integer;
--
-- eligibility profile rules by eligibility profile
--
type g_cache_elperl_object_rec is record
  (eligy_prfl_id     ben_eligy_prfl_f.eligy_prfl_id%type,
   pk_id             number,
   short_code        varchar2(30),
   formula_id        ben_eligy_prfl_rl_f.formula_id%type,
   criteria_score    ben_eligy_prfl_rl_f.criteria_score%type,
   criteria_weight   ben_eligy_prfl_rl_f.criteria_weight%type);
--
type g_cache_elperl_instor is table of g_cache_elperl_object_rec
     index by binary_integer;
--
-- eligibility profile scheduled hours by eligibility profile
--
type g_cache_elpesh_object_rec is record
  (eligy_prfl_id 	ben_eligy_prfl_f.eligy_prfl_id%type,
   pk_id                number,
   short_code           varchar2(30),
   hrs_num       	ben_elig_schedd_hrs_prte_f.hrs_num%type,
   determination_cd	ben_elig_schedd_hrs_prte_f.determination_cd%type,
   determination_rl	ben_elig_schedd_hrs_prte_f.determination_rl%type,
   rounding_cd		ben_elig_schedd_hrs_prte_f.rounding_cd%type,
   rounding_rl		ben_elig_schedd_hrs_prte_f.rounding_rl%type,
   max_hrs_num		ben_elig_schedd_hrs_prte_f.max_hrs_num%type,
   schedd_hrs_rl	ben_elig_schedd_hrs_prte_f.schedd_hrs_rl%type,
   freq_cd       	ben_elig_schedd_hrs_prte_f.freq_cd%type,
   excld_flag    	ben_elig_schedd_hrs_prte_f.excld_flag%type,
   criteria_score       ben_elig_schedd_hrs_prte_f.criteria_score%type,
   criteria_weight      ben_elig_schedd_hrs_prte_f.criteria_weight%type);
--
type g_cache_elpesh_instor is table of g_cache_elpesh_object_rec
     index by binary_integer;
--
-- eligibility profile compensation level by eligibility profile
--
type g_cache_elpecl_object_rec is record
  (eligy_prfl_id    ben_eligy_prfl_f.eligy_prfl_id%type,
   pk_id            number,
   short_code       varchar2(30),
   excld_flag       ben_elig_comp_lvl_prte_f.excld_flag%type,
   criteria_score   ben_elig_comp_lvl_prte_f.criteria_score%type,
   criteria_weight  ben_elig_comp_lvl_prte_f.criteria_weight%type,
   mn_comp_val      ben_comp_lvl_fctr.mn_comp_val%type,
   mx_comp_val      ben_comp_lvl_fctr.mx_comp_val%type,
   no_mn_comp_flag  ben_comp_lvl_fctr.no_mn_comp_flag%type,
   no_mx_comp_flag  ben_comp_lvl_fctr.no_mx_comp_flag%type,
   comp_src_cd      ben_comp_lvl_fctr.comp_src_cd%type,
   comp_lvl_fctr_id ben_comp_lvl_fctr.comp_lvl_fctr_id%type
   );
--
type g_cache_elpecl_instor is table of g_cache_elpecl_object_rec
     index by binary_integer;
--
-- eligibility profile hours worked by eligibility profile
--
type g_cache_elpehw_object_rec is record
  (eligy_prfl_id      ben_eligy_prfl_f.eligy_prfl_id%type,
   pk_id              number,
   short_code         varchar2(30),
   hrs_wkd_in_perd_fctr_id ben_elig_hrs_wkd_prte_f.hrs_wkd_in_perd_fctr_id%type,
   excld_flag         ben_elig_hrs_wkd_prte_f.excld_flag%type,
   criteria_score     ben_elig_hrs_wkd_prte_f.criteria_score%type,
   criteria_weight    ben_elig_hrs_wkd_prte_f.criteria_weight%type,
   mn_hrs_num         ben_hrs_wkd_in_perd_fctr.mn_hrs_num%type,
   mx_hrs_num         ben_hrs_wkd_in_perd_fctr.mx_hrs_num%type,
   no_mn_hrs_wkd_flag ben_hrs_wkd_in_perd_fctr.no_mn_hrs_wkd_flag%type,
   no_mx_hrs_wkd_flag ben_hrs_wkd_in_perd_fctr.no_mx_hrs_wkd_flag%type,
   hrs_src_cd         ben_hrs_wkd_in_perd_fctr.hrs_src_cd%type);
--
type g_cache_elpehw_instor is table of g_cache_elpehw_object_rec
     index by binary_integer;
--
-- eligibility profile hours worked by eligibility profile
--
type g_cache_elpean_object_rec is record
  (eligy_prfl_id      ben_eligy_prfl_f.eligy_prfl_id%type,
   pk_id              number,
   short_code         varchar2(30),
   excld_flag         ben_elig_hrs_wkd_prte_f.excld_flag%type,
   criteria_score     ben_elig_hrs_wkd_prte_f.criteria_score%type,
   criteria_weight    ben_elig_hrs_wkd_prte_f.criteria_weight%type,
   formula_id         hr_assignment_sets.formula_id%type);
--
type g_cache_elpean_instor is table of g_cache_elpean_object_rec
     index by binary_integer;
--
-- eligibility profile full time by eligibility profile
--
type g_cache_elpepf_object_rec is record
  (eligy_prfl_id      ben_eligy_prfl_f.eligy_prfl_id%type,
   pk_id              number,
   short_code         varchar2(30),
   pct_fl_tm_fctr_id  ben_elig_pct_fl_tm_prte_f.pct_fl_tm_fctr_id%type,
   excld_flag         ben_elig_pct_fl_tm_prte_f.excld_flag%type,
   criteria_score     ben_elig_pct_fl_tm_prte_f.criteria_score%type,
   criteria_weight    ben_elig_pct_fl_tm_prte_f.criteria_weight%type,
   mx_pct_val         ben_pct_fl_tm_fctr.mx_pct_val%type,
   mn_pct_val         ben_pct_fl_tm_fctr.mn_pct_val%type,
   no_mn_pct_val_flag ben_pct_fl_tm_fctr.no_mn_pct_val_flag%type,
   no_mx_pct_val_flag ben_pct_fl_tm_fctr.no_mx_pct_val_flag%type);
--
type g_cache_elpepf_instor is table of g_cache_elpepf_object_rec
     index by binary_integer;
--
-- eligibility profile grade by eligibility profile
--
type g_cache_elpegr_object_rec is record
  (eligy_prfl_id      ben_eligy_prfl_f.eligy_prfl_id%type,
   pk_id              number,
   short_code         varchar2(30),
   grade_id           ben_elig_grd_prte_f.grade_id%type,
   excld_flag         ben_elig_grd_prte_f.excld_flag%type,
   criteria_score     ben_elig_grd_prte_f.criteria_score%type,
   criteria_weight    ben_elig_grd_prte_f.criteria_weight%type);
--
type g_cache_elpegr_instor is table of g_cache_elpegr_object_rec
     index by binary_integer;
--
-- eligibility profile based on person's sex
--
type g_cache_elpegn_object_rec is record
  (eligy_prfl_id    ben_eligy_prfl_f.eligy_prfl_id%type,
   pk_id            number,
   short_code       varchar2(30),
   sex              ben_elig_gndr_prte_f.sex%type,
   excld_flag       ben_elig_gndr_prte_f.excld_flag%type,
   criteria_score   ben_elig_gndr_prte_f.criteria_score%type,
   criteria_weight  ben_elig_gndr_prte_f.criteria_weight%type);
--
type g_cache_elpegn_instor is table of g_cache_elpegn_object_rec
     index by binary_integer;
--
-- eligibility profile job by eligibility profile
--
type g_cache_elpejp_object_rec is record
  (eligy_prfl_id    ben_eligy_prfl_f.eligy_prfl_id%type,
   pk_id            number,
   short_code       varchar2(30),
   job_id           ben_elig_job_prte_f.job_id%type,
   excld_flag       ben_elig_job_prte_f.excld_flag%type,
   criteria_score   ben_elig_job_prte_f.criteria_score%type,
   criteria_weight  ben_elig_job_prte_f.criteria_weight%type);
--
type g_cache_elpejp_instor is table of g_cache_elpejp_object_rec
     index by binary_integer;
--
-- eligibility profile pay basis by eligibility profile
--
type g_cache_elpepb_object_rec is record
  (eligy_prfl_id    ben_eligy_prfl_f.eligy_prfl_id%type,
   pk_id            number,
   short_code       varchar2(30),
   pay_basis_id     ben_elig_py_bss_prte_f.pay_basis_id%type,
   excld_flag       ben_elig_py_bss_prte_f.excld_flag%type,
   criteria_score   ben_elig_py_bss_prte_f.criteria_score%type,
   criteria_weight  ben_elig_py_bss_prte_f.criteria_weight%type);
--
type g_cache_elpepb_instor is table of g_cache_elpepb_object_rec
     index by binary_integer;
--
-- eligibility profile payroll by eligibility profile
--
type g_cache_elpepy_object_rec is record
  (eligy_prfl_id     ben_eligy_prfl_f.eligy_prfl_id%type,
   pk_id             number,
   short_code        varchar2(30),
   payroll_id        ben_elig_pyrl_prte_f.payroll_id%type,
   excld_flag        ben_elig_pyrl_prte_f.excld_flag%type,
   criteria_score    ben_elig_pyrl_prte_f.criteria_score%type,
   criteria_weight   ben_elig_pyrl_prte_f.criteria_weight%type);
--
type g_cache_elpepy_instor is table of g_cache_elpepy_object_rec
     index by binary_integer;
--
-- eligibility profile bargaining unit by eligibility profile
--
type g_cache_elpebu_object_rec is record
  (eligy_prfl_id    ben_eligy_prfl_f.eligy_prfl_id%type,
   pk_id            number,
   short_code       varchar2(30),
   brgng_unit_cd    ben_elig_brgng_unit_prte_f.brgng_unit_cd%type,
   excld_flag       ben_elig_brgng_unit_prte_f.excld_flag%type,
   criteria_score   ben_elig_brgng_unit_prte_f.criteria_score%type,
   criteria_weight  ben_elig_brgng_unit_prte_f.criteria_weight%type);
--
type g_cache_elpebu_instor is table of g_cache_elpebu_object_rec
     index by binary_integer;
--
-- eligibility profile labour union membership by eligibility profile
--
type g_cache_elpelu_object_rec is record
  (eligy_prfl_id    ben_eligy_prfl_f.eligy_prfl_id%type,
   pk_id            number,
   short_code       varchar2(30),
   lbr_mmbr_flag    ben_elig_lbr_mmbr_prte_f.lbr_mmbr_flag%type,
   excld_flag       ben_elig_lbr_mmbr_prte_f.excld_flag%type,
   criteria_score   ben_elig_los_prte_f.criteria_score%type,
   criteria_weight  ben_elig_los_prte_f.criteria_weight%type);
--
type g_cache_elpelu_instor is table of g_cache_elpelu_object_rec
     index by binary_integer;
--
-- eligibility profile leave of absence reason by eligibility profile
--
type g_cache_elpelr_object_rec is record
  (eligy_prfl_id ben_eligy_prfl_f.eligy_prfl_id%type,
   pk_id                   number,
   short_code              varchar2(30),
   absence_attendance_type_id ben_elig_loa_rsn_prte_f.absence_attendance_type_id%type,
   abs_attendance_reason_id ben_elig_loa_rsn_prte_f.abs_attendance_reason_id%type,
   excld_flag              ben_elig_loa_rsn_prte_f.excld_flag%type,
   criteria_score          ben_elig_loa_rsn_prte_f.criteria_score%type,
   criteria_weight         ben_elig_loa_rsn_prte_f.criteria_weight%type);
--
type g_cache_elpelr_instor is table of g_cache_elpelr_object_rec
     index by binary_integer;
--
-- eligibility profile age details by eligibility profile
--
type g_cache_elpeap_object_rec is record
  (eligy_prfl_id   ben_eligy_prfl_f.eligy_prfl_id%type,
   pk_id           number,
   short_code      varchar2(30),
   age_fctr_id     ben_age_fctr.age_fctr_id%type,
   excld_flag      ben_elig_age_prte_f.excld_flag%type,
   criteria_score  ben_elig_age_prte_f.criteria_score%type,
   criteria_weight ben_elig_age_prte_f.criteria_weight%type,
   mx_age_num      ben_age_fctr.mx_age_num%type,
   mn_age_num      ben_age_fctr.mn_age_num%type,
   no_mn_age_flag  ben_age_fctr.no_mn_age_flag%type,
   no_mx_age_flag  ben_age_fctr.no_mx_age_flag%type);
--
type g_cache_elpeap_instor is table of g_cache_elpeap_object_rec
     index by binary_integer;
--
-- eligibility profile zip code range by eligibility profile
--
type g_cache_elpepz_object_rec is record
  (eligy_prfl_id   ben_eligy_prfl_f.eligy_prfl_id%type,
   pk_id           number,
   short_code      varchar2(30),
   excld_flag      ben_elig_pstl_cd_r_rng_prte_f.excld_flag%type,
   criteria_score  ben_elig_pstl_cd_r_rng_prte_f.criteria_score%type,
   criteria_weight ben_elig_pstl_cd_r_rng_prte_f.criteria_weight%type,
   from_value      ben_pstl_zip_rng_f.from_value%type,
   to_value        ben_pstl_zip_rng_f.to_value%type);
--
type g_cache_elpepz_instor is table of g_cache_elpepz_object_rec
     index by binary_integer;
--
-- eligibility profile benefits group by eligibility profile
--
type g_cache_elpebn_object_rec is record
  (eligy_prfl_id   ben_eligy_prfl_f.eligy_prfl_id%type,
   pk_id           number,
   short_code      varchar2(30),
   benfts_grp_id   ben_elig_benfts_grp_prte_f.benfts_grp_id%type,
   excld_flag      ben_elig_benfts_grp_prte_f.excld_flag%type,
   criteria_score  ben_elig_benfts_grp_prte_f.criteria_score%type,
   criteria_weight ben_elig_benfts_grp_prte_f.criteria_weight%type);
--
type g_cache_elpebn_instor is table of g_cache_elpebn_object_rec
     index by binary_integer;
--
-- eligibility profile legal entity by eligibility profile
--
type g_cache_elpeln_object_rec is record
  (eligy_prfl_id    ben_eligy_prfl_f.eligy_prfl_id%type,
   pk_id            number,
   short_code       varchar2(30),
   excld_flag       ben_elig_los_prte_f.excld_flag%type,
   criteria_score   ben_elig_los_prte_f.criteria_score%type,
   criteria_weight  ben_elig_los_prte_f.criteria_weight%type,
   name             hr_all_organization_units.name%type);
--
type g_cache_elpeln_instor is table of g_cache_elpeln_object_rec
     index by binary_integer;
--
-- eligibility profile other plan by eligibility profile
--
type g_cache_elpepp_object_rec is record
  (eligy_prfl_id    ben_eligy_prfl_f.eligy_prfl_id%type,
   pl_id            ben_elig_prtt_anthr_pl_prte_f.pl_id%type,
   excld_flag       ben_elig_prtt_anthr_pl_prte_f.excld_flag%type);
--
type g_cache_elpepp_instor is table of g_cache_elpepp_object_rec
     index by binary_integer;
--
-- eligibility profile people group by eligibility profile
--
type g_cache_elpeoy_object_rec is record
  (eligy_prfl_id            ben_eligy_prfl_f.eligy_prfl_id%type,
   ptip_id                  ben_elig_othr_ptip_prte_f.ptip_id%type,
   only_pls_subj_cobra_flag ben_elig_othr_ptip_prte_f.
                            only_pls_subj_cobra_flag%type,
   excld_flag               ben_elig_othr_ptip_prte_f.excld_flag%type);
--
type g_cache_elpeoy_instor is table of g_cache_elpeoy_object_rec
     index by binary_integer;
--
-- eligibility profile plan type in program participate by eligibility profile
--
type g_cache_elpetd_object_rec is record
  (eligy_prfl_id            ben_eligy_prfl_f.eligy_prfl_id%type,
   ptip_id                  ben_elig_dpnt_othr_ptip_f.ptip_id%type,
   excld_flag               ben_elig_dpnt_othr_ptip_f.excld_flag%type);
--
type g_cache_elpetd_instor is table of g_cache_elpetd_object_rec
     index by binary_integer;
--
-- eligibility profile(dpnt) plan type in program participate by eligibility profile
--
type g_cache_elpeno_object_rec is record
  (eligy_prfl_id         ben_eligy_prfl_f.eligy_prfl_id%type,
   coord_ben_no_cvg_flag ben_elig_no_othr_cvg_prte_f.
                         coord_ben_no_cvg_flag%type);
--
type g_cache_elpeno_instor is table of g_cache_elpeno_object_rec
     index by binary_integer;
--
-- eligibility profile no other coverage particpation by eligibility profile
--
type g_cache_elpeep_object_rec is record
  (eligy_prfl_id         ben_eligy_prfl_f.eligy_prfl_id%type,
   excld_flag            ben_elig_enrld_anthr_pl_f.excld_flag%type,
   enrl_det_dt_cd        ben_elig_enrld_anthr_pl_f.enrl_det_dt_cd%type,
   pl_id                 ben_elig_enrld_anthr_pl_f.pl_id%type);
--
type g_cache_elpeep_instor is table of g_cache_elpeep_object_rec
     index by binary_integer;
--
-- eligibility profile enrolled another plan by eligibility profile
--
type g_cache_elpeei_object_rec is record
  (eligy_prfl_id         ben_eligy_prfl_f.eligy_prfl_id%type,
   excld_flag            ben_elig_enrld_anthr_oipl_f.excld_flag%type,
   enrl_det_dt_cd        ben_elig_enrld_anthr_oipl_f.enrl_det_dt_cd%type,
   oipl_id               ben_elig_enrld_anthr_oipl_f.oipl_id%type);
--
type g_cache_elpeei_instor is table of g_cache_elpeei_object_rec
     index by binary_integer;
--
-- eligibility profile enrolled another option in plan by eligibility profile
--
type g_cache_elpeeg_object_rec is record
  (eligy_prfl_id         ben_eligy_prfl_f.eligy_prfl_id%type,
   excld_flag            ben_elig_enrld_anthr_pgm_f.excld_flag%type,
   enrl_det_dt_cd        ben_elig_enrld_anthr_pgm_f.enrl_det_dt_cd%type,
   pgm_id                ben_elig_enrld_anthr_pgm_f.pgm_id%type);
--
type g_cache_elpeeg_instor is table of g_cache_elpeeg_object_rec
     index by binary_integer;
--
-- eligibility profile enrolled another program by eligibility profile
--
type g_cache_elpedp_object_rec is record
  (eligy_prfl_id         ben_eligy_prfl_f.eligy_prfl_id%type,
   excld_flag            ben_elig_dpnt_cvrd_othr_pl_f.excld_flag%type,
   cvg_det_dt_cd         ben_elig_dpnt_cvrd_othr_pl_f.cvg_det_dt_cd%type,
   pl_id                 ben_elig_dpnt_cvrd_othr_pl_f.pl_id%type);
--
type g_cache_elpedp_instor is table of g_cache_elpedp_object_rec
     index by binary_integer;
--
-- eligibility profile dependent covered another plan by eligibility profile
--
type g_cache_elpelv_object_rec is record
  (eligy_prfl_id         ben_eligy_prfl_f.eligy_prfl_id%type,
   pk_id                 number,
   short_code            varchar2(30),
   excld_flag            ben_elig_lvg_rsn_prte_f.excld_flag%type,
   criteria_score        ben_elig_lvg_rsn_prte_f.criteria_score%type,
   criteria_weight       ben_elig_lvg_rsn_prte_f.criteria_weight%type,
   lvg_rsn_cd            ben_elig_lvg_rsn_prte_f.lvg_rsn_cd%type);
--
type g_cache_elpelv_instor is table of g_cache_elpelv_object_rec
     index by binary_integer;
--
-- eligibility profile leaving reason by eligibility profile
--
type g_cache_elpeom_object_rec is record
  (eligy_prfl_id         ben_eligy_prfl_f.eligy_prfl_id%type,
   excld_flag            ben_elig_optd_mdcr_prte_f.exlcd_flag%type,
   optd_mdcr_flag        ben_elig_optd_mdcr_prte_f.optd_mdcr_flag%type);
--
type g_cache_elpeom_instor is table of g_cache_elpeom_object_rec
     index by binary_integer;
--
-- eligibility profile enrolled in another plan in program by
-- eligibility profile
--
type g_cache_elpeai_object_rec is record
  (eligy_prfl_id         ben_eligy_prfl_f.eligy_prfl_id%type,
   excld_flag            ben_elig_enrld_anthr_plip_f.excld_flag%type,
   enrl_det_dt_cd        ben_elig_enrld_anthr_plip_f.enrl_det_dt_cd%type,
   plip_id               ben_elig_enrld_anthr_plip_f.plip_id%type);
--
type g_cache_elpeai_instor is table of g_cache_elpeai_object_rec
     index by binary_integer;
--
-- eligibility profile dependent covered in another plan in program by
-- eligibility profile
--
type g_cache_elpedi_object_rec is record
  (eligy_prfl_id         ben_eligy_prfl_f.eligy_prfl_id%type,
   excld_flag            ben_elig_dpnt_cvrd_plip_f.excld_flag%type,
   enrl_det_dt_cd        ben_elig_dpnt_cvrd_plip_f.enrl_det_dt_cd%type,
   plip_id               ben_elig_dpnt_cvrd_plip_f.plip_id%type);
--
type g_cache_elpedi_instor is table of g_cache_elpedi_object_rec
     index by binary_integer;
--
-- eligibility profile enrolled in another plan type in program by
-- eligibility profile
--
type g_cache_elpeet_object_rec is record
  (eligy_prfl_id            ben_eligy_prfl_f.eligy_prfl_id%type,
   excld_flag               ben_elig_enrld_anthr_ptip_f.excld_flag%type,
   enrl_det_dt_cd           ben_elig_enrld_anthr_ptip_f.enrl_det_dt_cd%type,
   only_pls_subj_cobra_flag ben_elig_enrld_anthr_ptip_f.
                            only_pls_subj_cobra_flag%type,
   ptip_id                  ben_elig_enrld_anthr_ptip_f.ptip_id%type);
--
type g_cache_elpeet_instor is table of g_cache_elpeet_object_rec
     index by binary_integer;
--
-- eligibility profile enrolled in another plan type in program by
-- eligibility profile
--
type g_cache_elpedt_object_rec is record
  (eligy_prfl_id            ben_eligy_prfl_f.eligy_prfl_id%type,
   excld_flag               ben_elig_dpnt_cvrd_othr_ptip_f.excld_flag%type,
   enrl_det_dt_cd           ben_elig_dpnt_cvrd_othr_ptip_f.enrl_det_dt_cd%type,
   only_pls_subj_cobra_flag ben_elig_dpnt_cvrd_othr_ptip_f.
                            only_pls_subj_cobra_flag%type,
   ptip_id                  ben_elig_dpnt_cvrd_othr_ptip_f.ptip_id%type);
--
type g_cache_elpedt_instor is table of g_cache_elpedt_object_rec
     index by binary_integer;
--
-- eligibility profile covered in another program by eligibility profile
--
type g_cache_elpedg_object_rec is record
  (eligy_prfl_id            ben_eligy_prfl_f.eligy_prfl_id%type,
   excld_flag               ben_elig_dpnt_cvrd_othr_pgm_f.excld_flag%type,
   enrl_det_dt_cd           ben_elig_dpnt_cvrd_othr_pgm_f.enrl_det_dt_cd%type,
   pgm_id                   ben_elig_dpnt_cvrd_othr_pgm_f.pgm_id%type);
--
type g_cache_elpedg_instor is table of g_cache_elpedg_object_rec
     index by binary_integer;
--
-- eligibility profile cobra qualified beneficiary by eligibility profile
--
type g_cache_elpecq_object_rec is record
  (eligy_prfl_id            ben_eligy_prfl_f.eligy_prfl_id%type,
   pk_id                    number,
   short_code               varchar2(30),
   quald_bnf_flag           ben_elig_cbr_quald_bnf_f.quald_bnf_flag%type,
   -- lamc added these 2 lines:
   pgm_id                   ben_elig_cbr_quald_bnf_f.pgm_id%type,
   ptip_id                  ben_elig_cbr_quald_bnf_f.ptip_id%type,
   criteria_score           ben_elig_cbr_quald_bnf_f.criteria_score%type,
   criteria_weight          ben_elig_cbr_quald_bnf_f.criteria_weight%type);
--
type g_cache_elpecq_instor is table of g_cache_elpecq_object_rec
     index by binary_integer;
--
procedure elpepg_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpepg_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpepg_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile person type by eligibility profile
--
procedure elpept_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpept_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpept_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile assignment set by eligibility profile
--
procedure elpean_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpean_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpean_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile rule by eligibility profile
--
procedure elperl_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elperl_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elperl_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile assignment status type by eligibility profile
--
procedure elpees_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpees_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpees_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile length of service by eligibility profile
--
procedure elpels_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpels_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpels_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile age/los combination by eligibility profile
--
procedure elpecp_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpecp_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpecp_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile location by eligibility profile
--
procedure elpewl_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpewl_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpewl_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile organization by eligibility profile
--
procedure elpeou_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpeou_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpeou_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile pay frequency by eligibility profile
--
procedure elpehs_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpehs_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpehs_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile full/part time by eligibility profile
--
procedure elpefp_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpefp_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpefp_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile scheduled hours by eligibility profile
--
procedure elpesh_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpesh_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpesh_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile compensation level by eligibility profile
--
procedure elpecl_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpecl_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_comp_src_cd       in  varchar2 default null,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpecl_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile hours worked by eligibility profile
--
procedure elpehw_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpehw_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_hrs_src_cd        in  varchar2 default null,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpehw_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile full time by eligibility profile
--
procedure elpepf_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpepf_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpepf_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile grade by eligibility profile *
--
procedure elpegr_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpegr_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpegr_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile sex by eligibility profile *
--
procedure elpegn_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpegn_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpegn_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile job by eligibility profile *
--
procedure elpejp_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpejp_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpejp_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile pay basis by eligibility profile
--
procedure elpepb_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpepb_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpepb_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile payroll by eligibility profile
--
procedure elpepy_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpepy_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpepy_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile bargaining unit by eligibility profile
--
procedure elpebu_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpebu_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpebu_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile labour union membership by eligibility profile
--
procedure elpelu_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpelu_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpelu_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile leave of absence reason by eligibility profile
--
procedure elpelr_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpelr_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpelr_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile age details by eligibility profile
--
procedure elpeap_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpeap_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpeap_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile zip code range by eligibility profile
--
procedure elpepz_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpepz_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpepz_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile benefits group by eligibility profile
--
procedure elpebn_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpebn_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpebn_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile legal entity by eligibility profile
--
procedure elpeln_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpeln_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpeln_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile other plan by eligibility profile
--
procedure elpepp_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpepp_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpepp_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile service area by eligibility profile
--
procedure elpesa_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpesa_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpesa_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile other PTIP participate by eligibility profile
--
procedure elpeoy_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpeoy_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpeoy_instor,
   p_inst_count        out nocopy number);
--
procedure elpetd_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpetd_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpetd_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile no other coverage participate by eligibility profile
--
procedure elpeno_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpeno_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpeno_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile eligibility enrolled another plan by eligibility profile
--
procedure elpeep_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpeep_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpeep_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile eligibility enrolled another oipl by eligibility profile
--
procedure elpeei_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpeei_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpeei_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile eligibility enrolled another pgm by eligibility profile
--
procedure elpeeg_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpeeg_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpeeg_instor,
   p_inst_count        out nocopy number);
--
procedure elpedp_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpedp_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpedp_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile eligibility leaving reason part by eligibility profile
--
procedure elpelv_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpelv_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpelv_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile eligibility opted medicare part by eligibility profile
--
procedure elpeom_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpeom_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpeom_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile enrolled in another plip by eligibility profile
--
procedure elpeai_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpeai_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpeai_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile covered in another plip by eligibility profile
--
procedure elpedi_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpedi_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpedi_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile enrolled in another ptip by eligibility profile
--
procedure elpeet_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpeet_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpeet_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile covered in another ptip by eligibility profile
--
procedure elpedt_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpedt_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpedt_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile covered in another program by eligibility profile
--
procedure elpedg_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpedg_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpedg_instor,
   p_inst_count        out nocopy number);
--
-- eligibility profile covered in another program by eligibility profile
--
procedure elpecq_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure elpecq_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpecq_instor,
   p_inst_count        out nocopy number);
--
-- GENERIC ARRAY to cater to all profiles
--
type g_elp_cache_rec is record
  (eligy_prfl_id   number
  ,pk_id           number
  ,short_code      varchar2(30)
  ,criteria_score  number
  ,criteria_weight number
  ,v230_val        varchar2(30)
  ,v230_val1       varchar2(30)
  ,num_val         number
  ,num_val1        number
  ,excld_flag      varchar2(100)
  );
--
type g_elp_cache is varray(1000000) of g_elp_cache_rec;

-- ---------------------------------------------------------------------
-- eligibility profile - disability
-- ---------------------------------------------------------------------
--
procedure elpeds_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  );

-- ---------------------------------------------------------------------
-- eligibility profile - tobacco use
-- ---------------------------------------------------------------------
procedure elpetu_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  );

-- ---------------------------------------------------------------------
-- eligibility profile - total coverage volume
-- ---------------------------------------------------------------------
--
procedure elpetc_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  );

-- ---------------------------------------------------------------------
-- eligibility profile - total participants
-- ---------------------------------------------------------------------
--
procedure elpetp_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  );

-- ---------------------------------------------------------------------
-- eligibility profile - Participation in another plan
-- ---------------------------------------------------------------------
--
procedure elpeop_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  );

-- ---------------------------------------------------------------------
-- eligibility profile - Health Coverage Selected
-- ---------------------------------------------------------------------
--
procedure elpehc_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  );

-- ---------------------------------------------------------------------
-- eligibility profile - Competency
-- ---------------------------------------------------------------------
--
procedure elpecy_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  );
-- ---------------------------------------------------------------------
-- eligibility profile - Quartile in Grade
-- ---------------------------------------------------------------------
--
procedure elpeqg_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  );
-- ---------------------------------------------------------------------
-- eligibility profile - Performance Rating
-- ---------------------------------------------------------------------
--
procedure elpepr_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  );

--
procedure clear_down_cache;
--
END ben_elp_cache;

 

/
