--------------------------------------------------------
--  DDL for Package BEN_ELIGIBLE_PERSON_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIGIBLE_PERSON_API" AUTHID CURRENT_USER as
/* $Header: bepepapi.pkh 120.0 2005/05/28 10:39:02 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Eligible_Person >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_business_group_id            Yes  number    Business Group of Record
--   p_pl_id                        No   number
--   p_pgm_id                       No   number
--   p_ler_id                       No   number
--   p_person_id                    Yes  number
--   p_per_in_ler_id                    Yes  number
--   p_dpnt_othr_pl_cvrd_rl_flag    Yes  varchar2
--   p_prtn_ovridn_thru_dt          No   date
--   p_pl_key_ee_flag               Yes  varchar2
--   p_pl_hghly_compd_flag          Yes  varchar2
--   p_elig_flag                    Yes  varchar2
--   p_comp_ref_amt                 No   number
--   p_cmbn_age_n_los_val           No   number
--   p_comp_ref_uom                 No   varchar2
--   p_age_val                      No   number
--   p_los_val                      No   number
--   p_prtn_end_dt                  No   date
--   p_prtn_strt_dt                 No   date
--   p_wait_perd_cmpltn_dt          No   date
--   p_wait_perd_strt_dt            No   date
--   p_wv_ctfn_typ_cd               No   varchar2
--   p_hrs_wkd_val                  No   number
--   p_hrs_wkd_bndry_perd_cd        No   varchar2
--   p_prtn_ovridn_flag             Yes  varchar2
--   p_no_mx_prtn_ovrid_thru_flag   Yes  varchar2
--   p_prtn_ovridn_rsn_cd           No   varchar2
--   p_age_uom                      No   varchar2
--   p_los_uom                      No   varchar2
--   p_ovrid_svc_dt                 No   date
--   p_frz_los_flag                 Yes  varchar2
--   p_frz_age_flag                 Yes  varchar2
--   p_frz_cmp_lvl_flag             Yes  varchar2
--   p_frz_pct_fl_tm_flag           Yes  varchar2
--   p_frz_hrs_wkd_flag             Yes  varchar2
--   p_frz_comb_age_and_los_flag    Yes  varchar2
--   p_dstr_rstcn_flag              Yes  varchar2
--   p_pct_fl_tm_val                No   number
--   p_wv_prtn_rsn_cd               No   varchar2
--   p_pl_wvd_flag                  Yes  varchar2
--   p_pep_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pep_attribute1               No   varchar2  Descriptive Flexfield
--   p_pep_attribute2               No   varchar2  Descriptive Flexfield
--   p_pep_attribute3               No   varchar2  Descriptive Flexfield
--   p_pep_attribute4               No   varchar2  Descriptive Flexfield
--   p_pep_attribute5               No   varchar2  Descriptive Flexfield
--   p_pep_attribute6               No   varchar2  Descriptive Flexfield
--   p_pep_attribute7               No   varchar2  Descriptive Flexfield
--   p_pep_attribute8               No   varchar2  Descriptive Flexfield
--   p_pep_attribute9               No   varchar2  Descriptive Flexfield
--   p_pep_attribute10              No   varchar2  Descriptive Flexfield
--   p_pep_attribute11              No   varchar2  Descriptive Flexfield
--   p_pep_attribute12              No   varchar2  Descriptive Flexfield
--   p_pep_attribute13              No   varchar2  Descriptive Flexfield
--   p_pep_attribute14              No   varchar2  Descriptive Flexfield
--   p_pep_attribute15              No   varchar2  Descriptive Flexfield
--   p_pep_attribute16              No   varchar2  Descriptive Flexfield
--   p_pep_attribute17              No   varchar2  Descriptive Flexfield
--   p_pep_attribute18              No   varchar2  Descriptive Flexfield
--   p_pep_attribute19              No   varchar2  Descriptive Flexfield
--   p_pep_attribute20              No   varchar2  Descriptive Flexfield
--   p_pep_attribute21              No   varchar2  Descriptive Flexfield
--   p_pep_attribute22              No   varchar2  Descriptive Flexfield
--   p_pep_attribute23              No   varchar2  Descriptive Flexfield
--   p_pep_attribute24              No   varchar2  Descriptive Flexfield
--   p_pep_attribute25              No   varchar2  Descriptive Flexfield
--   p_pep_attribute26              No   varchar2  Descriptive Flexfield
--   p_pep_attribute27              No   varchar2  Descriptive Flexfield
--   p_pep_attribute28              No   varchar2  Descriptive Flexfield
--   p_pep_attribute29              No   varchar2  Descriptive Flexfield
--   p_pep_attribute30              No   varchar2  Descriptive Flexfield
--   p_request_id                   No   number
--   p_program_application_id       No   number
--   p_program_id                   No   number
--   p_program_update_date          No   date
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_elig_per_id                  Yes  number    PK of record
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_Eligible_Person
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
  );
--
-- Performance cover
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
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_Eligible_Person >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_elig_per_id                  Yes  number    PK of record
--   p_business_group_id            Yes  number    Business Group of Record
--   p_pl_id                        No   number
--   p_pgm_id                       No   number
--   p_ler_id                       No   number
--   p_person_id                    Yes  number
--   p_per_in_ler_id                    Yes  number
--   p_dpnt_othr_pl_cvrd_rl_flag    Yes  varchar2
--   p_prtn_ovridn_thru_dt          No   date
--   p_pl_key_ee_flag               Yes  varchar2
--   p_pl_hghly_compd_flag          Yes  varchar2
--   p_elig_flag                    Yes  varchar2
--   p_comp_ref_amt                 No   number
--   p_cmbn_age_n_los_val           No   number
--   p_comp_ref_uom                 No   varchar2
--   p_age_val                      No   number
--   p_los_val                      No   number
--   p_prtn_end_dt                  No   date
--   p_prtn_strt_dt                 No   date
--   p_wait_perd_cmpltn_dt          No   date
--   p_wait_perd_strt_dt            No   date
--   p_wv_ctfn_typ_cd               No   varchar2
--   p_hrs_wkd_val                  No   number
--   p_hrs_wkd_bndry_perd_cd        No   varchar2
--   p_prtn_ovridn_flag             Yes  varchar2
--   p_no_mx_prtn_ovrid_thru_flag   Yes  varchar2
--   p_prtn_ovridn_rsn_cd           No   varchar2
--   p_age_uom                      No   varchar2
--   p_los_uom                      No   varchar2
--   p_ovrid_svc_dt                 No   date
--   p_frz_los_flag                 Yes  varchar2
--   p_frz_age_flag                 Yes  varchar2
--   p_frz_cmp_lvl_flag             Yes  varchar2
--   p_frz_pct_fl_tm_flag           Yes  varchar2
--   p_frz_hrs_wkd_flag             Yes  varchar2
--   p_frz_comb_age_and_los_flag    Yes  varchar2
--   p_dstr_rstcn_flag              Yes  varchar2
--   p_pct_fl_tm_val                No   number
--   p_wv_prtn_rsn_cd               No   varchar2
--   p_pl_wvd_flag                  Yes  varchar2
--   p_pep_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pep_attribute1               No   varchar2  Descriptive Flexfield
--   p_pep_attribute2               No   varchar2  Descriptive Flexfield
--   p_pep_attribute3               No   varchar2  Descriptive Flexfield
--   p_pep_attribute4               No   varchar2  Descriptive Flexfield
--   p_pep_attribute5               No   varchar2  Descriptive Flexfield
--   p_pep_attribute6               No   varchar2  Descriptive Flexfield
--   p_pep_attribute7               No   varchar2  Descriptive Flexfield
--   p_pep_attribute8               No   varchar2  Descriptive Flexfield
--   p_pep_attribute9               No   varchar2  Descriptive Flexfield
--   p_pep_attribute10              No   varchar2  Descriptive Flexfield
--   p_pep_attribute11              No   varchar2  Descriptive Flexfield
--   p_pep_attribute12              No   varchar2  Descriptive Flexfield
--   p_pep_attribute13              No   varchar2  Descriptive Flexfield
--   p_pep_attribute14              No   varchar2  Descriptive Flexfield
--   p_pep_attribute15              No   varchar2  Descriptive Flexfield
--   p_pep_attribute16              No   varchar2  Descriptive Flexfield
--   p_pep_attribute17              No   varchar2  Descriptive Flexfield
--   p_pep_attribute18              No   varchar2  Descriptive Flexfield
--   p_pep_attribute19              No   varchar2  Descriptive Flexfield
--   p_pep_attribute20              No   varchar2  Descriptive Flexfield
--   p_pep_attribute21              No   varchar2  Descriptive Flexfield
--   p_pep_attribute22              No   varchar2  Descriptive Flexfield
--   p_pep_attribute23              No   varchar2  Descriptive Flexfield
--   p_pep_attribute24              No   varchar2  Descriptive Flexfield
--   p_pep_attribute25              No   varchar2  Descriptive Flexfield
--   p_pep_attribute26              No   varchar2  Descriptive Flexfield
--   p_pep_attribute27              No   varchar2  Descriptive Flexfield
--   p_pep_attribute28              No   varchar2  Descriptive Flexfield
--   p_pep_attribute29              No   varchar2  Descriptive Flexfield
--   p_pep_attribute30              No   varchar2  Descriptive Flexfield
--   p_request_id                   No   number
--   p_program_application_id       No   number
--   p_program_id                   No   number
--   p_program_update_date          No   date
--   p_effective_date               Yes  date       Session Date.
--   p_datetrack_mode               Yes  varchar2   Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_Eligible_Person
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
  ,p_datetrack_mode                 in  varchar2);
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Eligible_Person >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_elig_per_id                  Yes  number    PK of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_Eligible_Person
  (p_validate                       in boolean        default false
  ,p_elig_per_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2);
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_elig_per_id                 Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_validation_start_date        Yes      Derived Effective Start Date.
--   p_validation_end_date          Yes      Derived Effective End Date.
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure lck
   (p_elig_per_id                 in number
   ,p_object_version_number       in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date       out nocopy date
   ,p_validation_end_date         out nocopy date);
--
end ben_Eligible_Person_api;

 

/
