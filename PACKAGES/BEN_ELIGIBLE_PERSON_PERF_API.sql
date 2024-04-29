--------------------------------------------------------
--  DDL for Package BEN_ELIGIBLE_PERSON_PERF_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIGIBLE_PERSON_PERF_API" AUTHID CURRENT_USER as
/* $Header: bepepppi.pkh 120.2 2005/06/23 00:18:01 abparekh noship $ */
--
-- Performance cover

Type g_pepapi_rectyp Is Record
  (p_validate                     boolean
  ,p_business_group_id            number
  ,p_pl_id                        number
  ,p_pgm_id                       number
  ,p_plip_id                      number
  ,p_ptip_id                      number
  ,p_ler_id                       number
  ,p_person_id                    number
  ,p_per_in_ler_id                number
  ,p_dpnt_othr_pl_cvrd_rl_flag    varchar2(30)
  ,p_prtn_ovridn_thru_dt          date
  ,p_pl_key_ee_flag               varchar2(30)
  ,p_pl_hghly_compd_flag          varchar2(30)
  ,p_elig_flag                    varchar2(30)
  ,p_comp_ref_amt                 number
  ,p_cmbn_age_n_los_val           number
  ,p_comp_ref_uom                 varchar2(30)
  ,p_age_val                      number
  ,p_los_val                      number
  ,p_prtn_end_dt                  date
  ,p_prtn_strt_dt                 date
  ,p_wait_perd_cmpltn_dt          date
  ,p_wait_perd_strt_dt            date
  ,p_wv_ctfn_typ_cd               varchar2(30)
  ,p_hrs_wkd_val                  number
  ,p_hrs_wkd_bndry_perd_cd        varchar2(30)
  ,p_prtn_ovridn_flag             varchar2(30)
  ,p_no_mx_prtn_ovrid_thru_flag   varchar2(30)
  ,p_prtn_ovridn_rsn_cd           varchar2(30)
  ,p_age_uom                      varchar2(30)
  ,p_los_uom                      varchar2(30)
  ,p_ovrid_svc_dt                 date
  ,p_inelg_rsn_cd                 varchar2(30)
  ,p_frz_los_flag                 varchar2(30)
  ,p_frz_age_flag                 varchar2(30)
  ,p_frz_cmp_lvl_flag             varchar2(30)
  ,p_frz_pct_fl_tm_flag           varchar2(30)
  ,p_frz_hrs_wkd_flag             varchar2(30)
  ,p_frz_comb_age_and_los_flag    varchar2(30)
  ,p_dstr_rstcn_flag              varchar2(30)
  ,p_pct_fl_tm_val                number
  ,p_wv_prtn_rsn_cd               varchar2(30)
  ,p_pl_wvd_flag                  varchar2(30)
  ,p_rt_comp_ref_amt              number
  ,p_rt_cmbn_age_n_los_val        number
  ,p_rt_comp_ref_uom              varchar2(30)
  ,p_rt_age_val                   number
  ,p_rt_los_val                   number
  ,p_rt_hrs_wkd_val               number
  ,p_rt_hrs_wkd_bndry_perd_cd     varchar2(30)
  ,p_rt_age_uom                   varchar2(30)
  ,p_rt_los_uom                   varchar2(30)
  ,p_rt_pct_fl_tm_val             number
  ,p_rt_frz_los_flag              varchar2(30)
  ,p_rt_frz_age_flag              varchar2(30)
  ,p_rt_frz_cmp_lvl_flag          varchar2(30)
  ,p_rt_frz_pct_fl_tm_flag        varchar2(30)
  ,p_rt_frz_hrs_wkd_flag          varchar2(30)
  ,p_rt_frz_comb_age_and_los_flag varchar2(30)
  ,p_once_r_cntug_cd              varchar2(30)
  ,p_pl_ordr_num                  number
  ,p_plip_ordr_num                number
  ,p_ptip_ordr_num                number
  ,p_pep_attribute_category       varchar2(30)
  ,p_pep_attribute1               varchar2(30)
  ,p_pep_attribute2               varchar2(30)
  ,p_pep_attribute3               varchar2(30)
  ,p_pep_attribute4               varchar2(30)
  ,p_pep_attribute5               varchar2(30)
  ,p_pep_attribute6               varchar2(30)
  ,p_pep_attribute7               varchar2(30)
  ,p_pep_attribute8               varchar2(30)
  ,p_pep_attribute9               varchar2(30)
  ,p_pep_attribute10              varchar2(30)
  ,p_pep_attribute11              varchar2(30)
  ,p_pep_attribute12              varchar2(30)
  ,p_pep_attribute13              varchar2(30)
  ,p_pep_attribute14              varchar2(30)
  ,p_pep_attribute15              varchar2(30)
  ,p_pep_attribute16              varchar2(30)
  ,p_pep_attribute17              varchar2(30)
  ,p_pep_attribute18              varchar2(30)
  ,p_pep_attribute19              varchar2(30)
  ,p_pep_attribute20              varchar2(30)
  ,p_pep_attribute21              varchar2(30)
  ,p_pep_attribute22              varchar2(30)
  ,p_pep_attribute23              varchar2(30)
  ,p_pep_attribute24              varchar2(30)
  ,p_pep_attribute25              varchar2(30)
  ,p_pep_attribute26              varchar2(30)
  ,p_pep_attribute27              varchar2(30)
  ,p_pep_attribute28              varchar2(30)
  ,p_pep_attribute29              varchar2(30)
  ,p_pep_attribute30              varchar2(30)
  ,p_request_id                   number
  ,p_program_application_id       number
  ,p_program_id                   number
  ,p_program_update_date          date
  ,p_effective_date               date
  ,p_override_validation          boolean
  --
  ,p_elig_per_id                  number
  ,p_datetrack_mode               varchar2(30)
  ,p_object_version_number        number
  );
  --
  g_pepinsplip            g_pepapi_rectyp;
  g_pepinsplip_score_tab          ben_evaluate_elig_profiles.scoreTab;  /* Bug 4438430 */
--
--
procedure create_perf_Eligible_Person
  (p_validate                       in boolean    default false
  ,p_elig_per_id                    out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_plip_id                        in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_person_id                      in  number    default null
  ,p_per_in_ler_id                      in  number    default null
  ,p_dpnt_othr_pl_cvrd_rl_flag      in  varchar2  default 'N'
  ,p_prtn_ovridn_thru_dt            in  date      default null
  ,p_pl_key_ee_flag                 in  varchar2  default 'N'
  ,p_pl_hghly_compd_flag            in  varchar2  default 'N'
  ,p_elig_flag                      in  varchar2  default 'N'
  ,p_comp_ref_amt                   in  number    default null
  ,p_cmbn_age_n_los_val             in  number    default null
  ,p_comp_ref_uom                   in  varchar2  default null
  ,p_age_val                        in  number    default null
  ,p_los_val                        in  number    default null
  ,p_prtn_end_dt                    in  date      default null
  ,p_prtn_strt_dt                   in  date      default null
  ,p_wait_perd_cmpltn_dt            in  date      default null
  ,p_wait_perd_strt_dt              in  date      default null
  ,p_wv_ctfn_typ_cd                 in  varchar2  default null
  ,p_hrs_wkd_val                    in  number    default null
  ,p_hrs_wkd_bndry_perd_cd          in  varchar2  default null
  ,p_prtn_ovridn_flag               in  varchar2  default null
  ,p_no_mx_prtn_ovrid_thru_flag     in  varchar2  default 'N'
  ,p_prtn_ovridn_rsn_cd             in  varchar2  default null
  ,p_age_uom                        in  varchar2  default null
  ,p_los_uom                        in  varchar2  default null
  ,p_ovrid_svc_dt                   in  date      default null
  ,p_inelg_rsn_cd                   in  varchar2  default null
  ,p_frz_los_flag                   in  varchar2  default 'N'
  ,p_frz_age_flag                   in  varchar2  default 'N'
  ,p_frz_cmp_lvl_flag               in  varchar2  default 'N'
  ,p_frz_pct_fl_tm_flag             in  varchar2  default 'N'
  ,p_frz_hrs_wkd_flag               in  varchar2  default 'N'
  ,p_frz_comb_age_and_los_flag      in  varchar2  default 'N'
  ,p_dstr_rstcn_flag                in  varchar2  default 'N'
  ,p_pct_fl_tm_val                  in  number    default null
  ,p_wv_prtn_rsn_cd                 in  varchar2  default null
  ,p_pl_wvd_flag                    in  varchar2  default 'N'
  ,p_rt_comp_ref_amt                in  number    default null
  ,p_rt_cmbn_age_n_los_val          in  number    default null
  ,p_rt_comp_ref_uom                in  varchar2  default null
  ,p_rt_age_val                     in  number    default null
  ,p_rt_los_val                     in  number    default null
  ,p_rt_hrs_wkd_val                 in  number    default null
  ,p_rt_hrs_wkd_bndry_perd_cd       in  varchar2  default null
  ,p_rt_age_uom                     in  varchar2  default null
  ,p_rt_los_uom                     in  varchar2  default null
  ,p_rt_pct_fl_tm_val               in  number    default null
  ,p_rt_frz_los_flag                in  varchar2  default 'N'
  ,p_rt_frz_age_flag                in  varchar2  default 'N'
  ,p_rt_frz_cmp_lvl_flag            in  varchar2  default 'N'
  ,p_rt_frz_pct_fl_tm_flag          in  varchar2  default 'N'
  ,p_rt_frz_hrs_wkd_flag            in  varchar2  default 'N'
  ,p_rt_frz_comb_age_and_los_flag   in  varchar2  default 'N'
  ,p_once_r_cntug_cd                in  varchar2  default null
  ,p_pl_ordr_num                    in  number    default null
  ,p_plip_ordr_num                  in  number    default null
  ,p_ptip_ordr_num                  in  number    default null
  ,p_pep_attribute_category         in  varchar2  default null
  ,p_pep_attribute1                 in  varchar2  default null
  ,p_pep_attribute2                 in  varchar2  default null
  ,p_pep_attribute3                 in  varchar2  default null
  ,p_pep_attribute4                 in  varchar2  default null
  ,p_pep_attribute5                 in  varchar2  default null
  ,p_pep_attribute6                 in  varchar2  default null
  ,p_pep_attribute7                 in  varchar2  default null
  ,p_pep_attribute8                 in  varchar2  default null
  ,p_pep_attribute9                 in  varchar2  default null
  ,p_pep_attribute10                in  varchar2  default null
  ,p_pep_attribute11                in  varchar2  default null
  ,p_pep_attribute12                in  varchar2  default null
  ,p_pep_attribute13                in  varchar2  default null
  ,p_pep_attribute14                in  varchar2  default null
  ,p_pep_attribute15                in  varchar2  default null
  ,p_pep_attribute16                in  varchar2  default null
  ,p_pep_attribute17                in  varchar2  default null
  ,p_pep_attribute18                in  varchar2  default null
  ,p_pep_attribute19                in  varchar2  default null
  ,p_pep_attribute20                in  varchar2  default null
  ,p_pep_attribute21                in  varchar2  default null
  ,p_pep_attribute22                in  varchar2  default null
  ,p_pep_attribute23                in  varchar2  default null
  ,p_pep_attribute24                in  varchar2  default null
  ,p_pep_attribute25                in  varchar2  default null
  ,p_pep_attribute26                in  varchar2  default null
  ,p_pep_attribute27                in  varchar2  default null
  ,p_pep_attribute28                in  varchar2  default null
  ,p_pep_attribute29                in  varchar2  default null
  ,p_pep_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_override_validation            in  boolean   default false
  ,p_defer                          in  boolean   default true
  );
--
Procedure convert_defs
  (p_rec in out nocopy ben_pep_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_perf_Eligible_Person  >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_perf_Eligible_Person
  (p_validate                       in boolean    default false
  ,p_elig_per_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_plip_id                        in  number    default hr_api.g_number
  ,p_ptip_id                        in  number    default hr_api.g_number
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_per_in_ler_id                      in  number    default hr_api.g_number
  ,p_dpnt_othr_pl_cvrd_rl_flag      in  varchar2  default hr_api.g_varchar2
  ,p_prtn_ovridn_thru_dt            in  date      default hr_api.g_date
  ,p_pl_key_ee_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_pl_hghly_compd_flag            in  varchar2  default hr_api.g_varchar2
  ,p_elig_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_comp_ref_amt                   in  number    default hr_api.g_number
  ,p_cmbn_age_n_los_val             in  number    default hr_api.g_number
  ,p_comp_ref_uom                   in  varchar2  default hr_api.g_varchar2
  ,p_age_val                        in  number    default hr_api.g_number
  ,p_los_val                        in  number    default hr_api.g_number
  ,p_prtn_end_dt                    in  date      default hr_api.g_date
  ,p_prtn_strt_dt                   in  date      default hr_api.g_date
  ,p_wait_perd_cmpltn_dt            in  date      default hr_api.g_date
  ,p_wait_perd_strt_dt               in  date      default hr_api.g_date
  ,p_wv_ctfn_typ_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_hrs_wkd_val                    in  number    default hr_api.g_number
  ,p_hrs_wkd_bndry_perd_cd          in  varchar2  default hr_api.g_varchar2
  ,p_prtn_ovridn_flag               in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_prtn_ovrid_thru_flag     in  varchar2  default hr_api.g_varchar2
  ,p_prtn_ovridn_rsn_cd             in  varchar2  default hr_api.g_varchar2
  ,p_age_uom                        in  varchar2  default hr_api.g_varchar2
  ,p_los_uom                        in  varchar2  default hr_api.g_varchar2
  ,p_ovrid_svc_dt                   in  date      default hr_api.g_date
  ,p_inelg_rsn_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_frz_los_flag                   in  varchar2  default hr_api.g_varchar2
  ,p_frz_age_flag                   in  varchar2  default hr_api.g_varchar2
  ,p_frz_cmp_lvl_flag               in  varchar2  default hr_api.g_varchar2
  ,p_frz_pct_fl_tm_flag             in  varchar2  default hr_api.g_varchar2
  ,p_frz_hrs_wkd_flag               in  varchar2  default hr_api.g_varchar2
  ,p_frz_comb_age_and_los_flag      in  varchar2  default hr_api.g_varchar2
  ,p_dstr_rstcn_flag                in  varchar2  default hr_api.g_varchar2
  ,p_pct_fl_tm_val                  in  number    default hr_api.g_number
  ,p_wv_prtn_rsn_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_pl_wvd_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_rt_comp_ref_amt                in  number    default hr_api.g_number
  ,p_rt_cmbn_age_n_los_val          in  number    default hr_api.g_number
  ,p_rt_comp_ref_uom                in  varchar2  default hr_api.g_varchar2
  ,p_rt_age_val                     in  number    default hr_api.g_number
  ,p_rt_los_val                     in  number    default hr_api.g_number
  ,p_rt_hrs_wkd_val                 in  number    default hr_api.g_number
  ,p_rt_hrs_wkd_bndry_perd_cd       in  varchar2  default hr_api.g_varchar2
  ,p_rt_age_uom                     in  varchar2  default hr_api.g_varchar2
  ,p_rt_los_uom                     in  varchar2  default hr_api.g_varchar2
  ,p_rt_pct_fl_tm_val               in  number    default hr_api.g_number
  ,p_rt_frz_los_flag                in  varchar2  default hr_api.g_varchar2
  ,p_rt_frz_age_flag                in  varchar2  default hr_api.g_varchar2
  ,p_rt_frz_cmp_lvl_flag            in  varchar2  default hr_api.g_varchar2
  ,p_rt_frz_pct_fl_tm_flag          in  varchar2  default hr_api.g_varchar2
  ,p_rt_frz_hrs_wkd_flag            in  varchar2  default hr_api.g_varchar2
  ,p_rt_frz_comb_age_and_los_flag   in  varchar2  default hr_api.g_varchar2
  ,p_once_r_cntug_cd                in  varchar2  default hr_api.g_varchar2
  ,p_pl_ordr_num                    in  number    default hr_api.g_number
  ,p_plip_ordr_num                    in  number    default hr_api.g_number
  ,p_ptip_ordr_num                    in  number    default hr_api.g_number
  ,p_pep_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------< create_perf_Elig_Person_Option >----------------------|
-- ----------------------------------------------------------------------------
--
--
-- ----------------------------------------------------------------------------
-- |------------------< create_perf_Elig_Person_Option >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_perf_Elig_Person_Option
  (p_validate                       in boolean    default false
  ,p_elig_per_opt_id                out nocopy number
  ,p_elig_per_id                    in  number    default null
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_prtn_ovridn_flag               in  varchar2  default null
  ,p_prtn_ovridn_thru_dt            in  date      default null
  ,p_no_mx_prtn_ovrid_thru_flag     in  varchar2  default null
  ,p_elig_flag                      in  varchar2  default null
  ,p_prtn_strt_dt                   in  date      default null
  ,p_prtn_end_dt                    in  date      default null
  --,p_wait_perd_cmpltn_dt            in  date      default null
  ,p_wait_perd_cmpltn_date            in  date      default null
  ,p_wait_perd_strt_dt              in  date      default null
  ,p_prtn_ovridn_rsn_cd             in  varchar2  default null
  ,p_pct_fl_tm_val                  in  number    default null
  ,p_opt_id                         in  number    default null
  ,p_per_in_ler_id                  in  number    default null
  ,p_rt_comp_ref_amt                in  number    default null
  ,p_rt_cmbn_age_n_los_val          in  number    default null
  ,p_rt_comp_ref_uom                in  varchar2  default null
  ,p_rt_age_val                     in  number    default null
  ,p_rt_los_val                     in  number    default null
  ,p_rt_hrs_wkd_val                 in  number    default null
  ,p_rt_hrs_wkd_bndry_perd_cd       in  varchar2  default null
  ,p_rt_age_uom                     in  varchar2  default null
  ,p_rt_los_uom                     in  varchar2  default null
  ,p_rt_pct_fl_tm_val               in  number    default null
  ,p_rt_frz_los_flag                in  varchar2  default 'N'
  ,p_rt_frz_age_flag                in  varchar2  default 'N'
  ,p_rt_frz_cmp_lvl_flag            in  varchar2  default 'N'
  ,p_rt_frz_pct_fl_tm_flag          in  varchar2  default 'N'
  ,p_rt_frz_hrs_wkd_flag            in  varchar2  default 'N'
  ,p_rt_frz_comb_age_and_los_flag   in  varchar2  default 'N'
  ,p_comp_ref_amt                   in  number    default null
  ,p_cmbn_age_n_los_val             in  number    default null
  ,p_comp_ref_uom                   in  varchar2  default null
  ,p_age_val                        in  number    default null
  ,p_los_val                        in  number    default null
  ,p_hrs_wkd_val                    in  number    default null
  ,p_hrs_wkd_bndry_perd_cd          in  varchar2  default null
  ,p_age_uom                        in  varchar2  default null
  ,p_los_uom                        in  varchar2  default null
  ,p_frz_los_flag                   in  varchar2  default 'N'
  ,p_frz_age_flag                   in  varchar2  default 'N'
  ,p_frz_cmp_lvl_flag               in  varchar2  default 'N'
  ,p_frz_pct_fl_tm_flag             in  varchar2  default 'N'
  ,p_frz_hrs_wkd_flag               in  varchar2  default 'N'
  ,p_frz_comb_age_and_los_flag      in  varchar2  default 'N'
  ,p_ovrid_svc_dt                   in  date      default null
  ,p_inelg_rsn_cd                   in  varchar2  default null
  ,p_once_r_cntug_cd                in  varchar2  default null
  ,p_oipl_ordr_num                  in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_epo_attribute_category         in  varchar2  default null
  ,p_epo_attribute1                 in  varchar2  default null
  ,p_epo_attribute2                 in  varchar2  default null
  ,p_epo_attribute3                 in  varchar2  default null
  ,p_epo_attribute4                 in  varchar2  default null
  ,p_epo_attribute5                 in  varchar2  default null
  ,p_epo_attribute6                 in  varchar2  default null
  ,p_epo_attribute7                 in  varchar2  default null
  ,p_epo_attribute8                 in  varchar2  default null
  ,p_epo_attribute9                 in  varchar2  default null
  ,p_epo_attribute10                in  varchar2  default null
  ,p_epo_attribute11                in  varchar2  default null
  ,p_epo_attribute12                in  varchar2  default null
  ,p_epo_attribute13                in  varchar2  default null
  ,p_epo_attribute14                in  varchar2  default null
  ,p_epo_attribute15                in  varchar2  default null
  ,p_epo_attribute16                in  varchar2  default null
  ,p_epo_attribute17                in  varchar2  default null
  ,p_epo_attribute18                in  varchar2  default null
  ,p_epo_attribute19                in  varchar2  default null
  ,p_epo_attribute20                in  varchar2  default null
  ,p_epo_attribute21                in  varchar2  default null
  ,p_epo_attribute22                in  varchar2  default null
  ,p_epo_attribute23                in  varchar2  default null
  ,p_epo_attribute24                in  varchar2  default null
  ,p_epo_attribute25                in  varchar2  default null
  ,p_epo_attribute26                in  varchar2  default null
  ,p_epo_attribute27                in  varchar2  default null
  ,p_epo_attribute28                in  varchar2  default null
  ,p_epo_attribute29                in  varchar2  default null
  ,p_epo_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_override_validation            in  boolean   default false
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_Elig_Person_Option >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_perf_Elig_Person_Option
  (p_validate                       in  boolean   default false
  ,p_elig_per_opt_id                in  number
  ,p_elig_per_id                    in  number    default hr_api.g_number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_prtn_ovridn_flag               in  varchar2  default hr_api.g_varchar2
  ,p_prtn_ovridn_thru_dt            in  date      default hr_api.g_date
  ,p_no_mx_prtn_ovrid_thru_flag     in  varchar2  default hr_api.g_varchar2
  ,p_elig_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_prtn_strt_dt                   in  date      default hr_api.g_date
  ,p_prtn_end_dt                    in  date      default hr_api.g_date
  -- ,p_wait_perd_cmpltn_dt            in  date      default hr_api.g_date
  ,p_wait_perd_cmpltn_date          in  date      default hr_api.g_date
  ,p_wait_perd_strt_dt              in  date      default hr_api.g_date
  ,p_prtn_ovridn_rsn_cd             in  varchar2  default hr_api.g_varchar2
  ,p_pct_fl_tm_val                  in  number    default hr_api.g_number
  ,p_opt_id                         in  number    default hr_api.g_number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_rt_comp_ref_amt                in  number    default hr_api.g_number
  ,p_rt_cmbn_age_n_los_val          in  number    default hr_api.g_number
  ,p_rt_comp_ref_uom                in  varchar2  default hr_api.g_varchar2
  ,p_rt_age_val                     in  number    default hr_api.g_number
  ,p_rt_los_val                     in  number    default hr_api.g_number
  ,p_rt_hrs_wkd_val                 in  number    default hr_api.g_number
  ,p_rt_hrs_wkd_bndry_perd_cd       in  varchar2  default hr_api.g_varchar2
  ,p_rt_age_uom                     in  varchar2  default hr_api.g_varchar2
  ,p_rt_los_uom                     in  varchar2  default hr_api.g_varchar2
  ,p_rt_pct_fl_tm_val               in  number    default hr_api.g_number
  ,p_rt_frz_los_flag                in  varchar2  default hr_api.g_varchar2
  ,p_rt_frz_age_flag                in  varchar2  default hr_api.g_varchar2
  ,p_rt_frz_cmp_lvl_flag            in  varchar2  default hr_api.g_varchar2
  ,p_rt_frz_pct_fl_tm_flag          in  varchar2  default hr_api.g_varchar2
  ,p_rt_frz_hrs_wkd_flag            in  varchar2  default hr_api.g_varchar2
  ,p_rt_frz_comb_age_and_los_flag   in  varchar2  default hr_api.g_varchar2
  ,p_comp_ref_amt                   in  number    default hr_api.g_number
  ,p_cmbn_age_n_los_val             in  number    default hr_api.g_number
  ,p_comp_ref_uom                   in  varchar2  default hr_api.g_varchar2
  ,p_age_val                        in  number    default hr_api.g_number
  ,p_los_val                        in  number    default hr_api.g_number
  ,p_hrs_wkd_val                    in  number    default hr_api.g_number
  ,p_hrs_wkd_bndry_perd_cd          in  varchar2  default hr_api.g_varchar2
  ,p_age_uom                        in  varchar2  default hr_api.g_varchar2
  ,p_los_uom                        in  varchar2  default hr_api.g_varchar2
  ,p_frz_los_flag                   in  varchar2  default hr_api.g_varchar2
  ,p_frz_age_flag                   in  varchar2  default hr_api.g_varchar2
  ,p_frz_cmp_lvl_flag               in  varchar2  default hr_api.g_varchar2
  ,p_frz_pct_fl_tm_flag             in  varchar2  default hr_api.g_varchar2
  ,p_frz_hrs_wkd_flag               in  varchar2  default hr_api.g_varchar2
  ,p_frz_comb_age_and_los_flag      in  varchar2  default hr_api.g_varchar2
  ,p_ovrid_svc_dt                   in  date      default hr_api.g_date
  ,p_inelg_rsn_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_once_r_cntug_cd                in  varchar2  default hr_api.g_varchar2
  ,p_oipl_ordr_num                  in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_epo_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
PROCEDURE epecleanup(p_start_rowid     IN            rowid,
                     p_end_rowid       IN            rowid,
                     p_rows_processed OUT nocopy number);
--
end ben_Eligible_Person_perf_api;

 

/
