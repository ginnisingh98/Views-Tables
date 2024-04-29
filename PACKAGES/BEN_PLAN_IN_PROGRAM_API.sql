--------------------------------------------------------
--  DDL for Package BEN_PLAN_IN_PROGRAM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_IN_PROGRAM_API" AUTHID CURRENT_USER as
/* $Header: becppapi.pkh 120.0 2005/05/28 01:16:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Plan_in_Program >------------------------|
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
--   p_dflt_flag                    Yes  varchar2
--   p_plip_stat_cd                 Yes  varchar2
--   p_dflt_enrt_cd                 No   varchar2
--   p_dflt_enrt_det_rl             No   number
--   p_ordr_num                     No   number
--   p_ivr_ident                    No   varchar2
--   p_enrt_cd                      No   varchar2
--   p_enrt_mthd_cd                 No   varchar2
--   p_auto_enrt_mthd_rl            No   number
--   p_enrt_rl                      No   number
--   p_alws_unrstrctd_enrt_flag     Yes  varchar2
--   p_enrt_cvg_strt_dt_cd          No   varchar2
--   p_enrt_cvg_strt_dt_rl          No   number
--   p_enrt_cvg_end_dt_cd           No   varchar2
--   p_enrt_cvg_end_dt_rl           No   number
--   p_rt_strt_dt_cd                No   varchar2
--   p_rt_strt_dt_rl                No   number
--   p_rt_end_dt_cd                 No   varchar2
--   p_rt_end_dt_rl                 No   number
--   p_drvbl_fctr_apls_rts_flag     Yes  varchar2
--   p_drvbl_fctr_prtn_elig_flag    Yes  varchar2
--   p_elig_apls_flag               Yes  varchar2
--   p_prtn_elig_ovrid_alwd_flag    Yes  varchar2
--   p_trk_inelig_per_flag          Yes  varchar2
--   p_postelcn_edit_rl             No   number
--   p_pgm_id                       Yes  number
--   p_pl_id                        Yes  number
--   p_cmbn_plip_id                 No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_per_cvrd_cd                  No   varchar2
--   p_short_name                  No   varchar2
--   p_short_code                  No   varchar2
--   p_legislation_code                  No   varchar2
--   p_legislation_subgroup                  No   varchar2
--   P_vrfy_fmly_mmbr_rl            No   number
--   P_vrfy_fmly_mmbr_cd            No   varchar2
--   P_use_csd_rsd_prccng_cd        No   varchar2
--   p_cpp_attribute_category       No   varchar2  Descriptive Flexfield
--   p_cpp_attribute1               No   varchar2  Descriptive Flexfield
--   p_cpp_attribute2               No   varchar2  Descriptive Flexfield
--   p_cpp_attribute3               No   varchar2  Descriptive Flexfield
--   p_cpp_attribute4               No   varchar2  Descriptive Flexfield
--   p_cpp_attribute5               No   varchar2  Descriptive Flexfield
--   p_cpp_attribute6               No   varchar2  Descriptive Flexfield
--   p_cpp_attribute7               No   varchar2  Descriptive Flexfield
--   p_cpp_attribute8               No   varchar2  Descriptive Flexfield
--   p_cpp_attribute9               No   varchar2  Descriptive Flexfield
--   p_cpp_attribute10              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute11              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute12              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute13              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute14              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute15              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute16              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute17              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute18              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute19              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute20              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute21              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute22              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute23              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute24              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute25              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute26              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute27              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute28              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute29              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute30              No   varchar2  Descriptive Flexfield
--   p_url_ref_name                 No   varchar2
--   p_dflt_to_asn_pndg_ctfn_cd     No   varchar2
--   p_dflt_to_asn_pndg_ctfn_rl     No   number
--   p_mn_cvg_amt                   No   number
--   p_mn_cvg_rl                    No   number
--   p_mx_cvg_alwd_amt              No   number
--   p_mx_cvg_incr_alwd_amt         No   number
--   p_mx_cvg_incr_wcf_alwd_amt     No   number
--   p_mx_cvg_mlt_incr_num          No   number
--   p_mx_cvg_mlt_incr_wcf_num      No   number
--   p_mx_cvg_rl                    No   number
--   p_mx_cvg_wcfn_amt              No   number
--   p_mx_cvg_wcfn_mlt_num          No   number
--   p_no_mn_cvg_amt_apls_flag      Yes  varchar2
--   p_no_mn_cvg_incr_apls_flag     Yes  varchar2
--   p_no_mx_cvg_amt_apls_flag      Yes  varchar2
--   p_no_mx_cvg_incr_apls_flag     Yes  varchar2
--   p_unsspnd_enrt_cd              No   varchar2
--   p_prort_prtl_yr_cvg_rstrn_cd   No   varchar2
--   p_prort_prtl_yr_cvg_rstrn_rl   No   number
--   p_cvg_incr_r_decr_only_cd      No   varchar2
--   p_bnft_or_option_rstrctn_cd    No   varchar2
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_plip_id                      Yes  number    PK of record
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
procedure create_Plan_in_Program
(
   p_validate                       in boolean    default false
  ,p_plip_id                        out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_dflt_flag                      in  varchar2  default null
  ,p_plip_stat_cd                   in  varchar2  default null
  ,p_dflt_enrt_cd                   in  varchar2  default null
  ,p_dflt_enrt_det_rl               in  number    default null
  ,p_ordr_num                       in  number    default null
  ,p_ivr_ident                      in  varchar2  default null
  ,p_enrt_cd                        in  varchar2  default null
  ,p_enrt_mthd_cd                   in  varchar2  default null
  ,p_auto_enrt_mthd_rl              in  number    default null
  ,p_enrt_rl                        in  number    default null
  ,p_alws_unrstrctd_enrt_flag       in  varchar2  default 'N'
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default null
  ,p_enrt_cvg_strt_dt_rl            in  number    default null
  ,p_enrt_cvg_end_dt_cd             in  varchar2  default null
  ,p_enrt_cvg_end_dt_rl             in  number    default null
  ,p_rt_strt_dt_cd                  in  varchar2  default null
  ,p_rt_strt_dt_rl                  in  number    default null
  ,p_rt_end_dt_cd                   in  varchar2  default null
  ,p_rt_end_dt_rl                   in  number    default null
  ,p_drvbl_fctr_apls_rts_flag       in  varchar2  default 'N'
  ,p_drvbl_fctr_prtn_elig_flag      in  varchar2  default 'N'
  ,p_elig_apls_flag                 in  varchar2  default 'N'
  ,p_prtn_elig_ovrid_alwd_flag      in  varchar2  default 'N'
  ,p_trk_inelig_per_flag            in  varchar2  default 'N'
  ,p_postelcn_edit_rl               in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_cmbn_plip_id                   in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_per_cvrd_cd                    in  varchar2  default null
  ,p_short_name                    in  varchar2  default null
  ,p_short_code                    in  varchar2  default null
    ,p_legislation_code                    in  varchar2  default null
    ,p_legislation_subgroup                    in  varchar2  default null
  ,P_vrfy_fmly_mmbr_rl              in  number    default null
  ,P_vrfy_fmly_mmbr_cd              in  varchar2  default null
  ,P_use_csd_rsd_prccng_cd          in  varchar2  default null
  ,p_cpp_attribute_category         in  varchar2  default null
  ,p_cpp_attribute1                 in  varchar2  default null
  ,p_cpp_attribute2                 in  varchar2  default null
  ,p_cpp_attribute3                 in  varchar2  default null
  ,p_cpp_attribute4                 in  varchar2  default null
  ,p_cpp_attribute5                 in  varchar2  default null
  ,p_cpp_attribute6                 in  varchar2  default null
  ,p_cpp_attribute7                 in  varchar2  default null
  ,p_cpp_attribute8                 in  varchar2  default null
  ,p_cpp_attribute9                 in  varchar2  default null
  ,p_cpp_attribute10                in  varchar2  default null
  ,p_cpp_attribute11                in  varchar2  default null
  ,p_cpp_attribute12                in  varchar2  default null
  ,p_cpp_attribute13                in  varchar2  default null
  ,p_cpp_attribute14                in  varchar2  default null
  ,p_cpp_attribute15                in  varchar2  default null
  ,p_cpp_attribute16                in  varchar2  default null
  ,p_cpp_attribute17                in  varchar2  default null
  ,p_cpp_attribute18                in  varchar2  default null
  ,p_cpp_attribute19                in  varchar2  default null
  ,p_cpp_attribute20                in  varchar2  default null
  ,p_cpp_attribute21                in  varchar2  default null
  ,p_cpp_attribute22                in  varchar2  default null
  ,p_cpp_attribute23                in  varchar2  default null
  ,p_cpp_attribute24                in  varchar2  default null
  ,p_cpp_attribute25                in  varchar2  default null
  ,p_cpp_attribute26                in  varchar2  default null
  ,p_cpp_attribute27                in  varchar2  default null
  ,p_cpp_attribute28                in  varchar2  default null
  ,p_cpp_attribute29                in  varchar2  default null
  ,p_cpp_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_url_ref_name                   in  varchar2  default null
  ,p_dflt_to_asn_pndg_ctfn_cd       in  varchar2  default null
  ,p_dflt_to_asn_pndg_ctfn_rl       in  number    default null
  ,p_mn_cvg_amt                     in  number    default null
  ,p_mn_cvg_rl                      in  number    default null
  ,p_mx_cvg_alwd_amt                in  number    default null
  ,p_mx_cvg_incr_alwd_amt           in  number    default null
  ,p_mx_cvg_incr_wcf_alwd_amt       in  number    default null
  ,p_mx_cvg_mlt_incr_num            in  number    default null
  ,p_mx_cvg_mlt_incr_wcf_num        in  number    default null
  ,p_mx_cvg_rl                      in  number    default null
  ,p_mx_cvg_wcfn_amt                in  number    default null
  ,p_mx_cvg_wcfn_mlt_num            in  number    default null
  ,p_no_mn_cvg_amt_apls_flag        in  varchar2  default 'N'
  ,p_no_mn_cvg_incr_apls_flag       in  varchar2  default 'N'
  ,p_no_mx_cvg_amt_apls_flag        in  varchar2  default 'N'
  ,p_no_mx_cvg_incr_apls_flag       in  varchar2  default 'N'
  ,p_unsspnd_enrt_cd                in  varchar2  default null
  ,p_prort_prtl_yr_cvg_rstrn_cd     in  varchar2  default null
  ,p_prort_prtl_yr_cvg_rstrn_rl     in  number    default null
  ,p_cvg_incr_r_decr_only_cd        in  varchar2  default null
  ,p_bnft_or_option_rstrctn_cd      in  varchar2  default null
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_Plan_in_Program >------------------------|
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
--   p_plip_id                      Yes  number    PK of record
--   p_dflt_flag                    Yes  varchar2
--   p_plip_stat_cd                 Yes  varchar2
--   p_dflt_enrt_cd                 No   varchar2
--   p_dflt_enrt_det_rl             No   number
--   p_ordr_num                     No   number
--   p_ivr_ident                    No   varchar2
--   p_enrt_cd                      No   varchar2
--   p_enrt_mthd_cd                 No   varchar2
--   p_auto_enrt_mthd_rl            No   number
--   p_enrt_rl                      No   number
--   p_alws_unrstrctd_enrt_flag     Yes  varchar2
--   p_enrt_cvg_strt_dt_cd          No   varchar2
--   p_enrt_cvg_strt_dt_rl          No   number
--   p_enrt_cvg_end_dt_cd           No   varchar2
--   p_enrt_cvg_end_dt_rl           No   number
--   p_rt_strt_dt_cd                No   varchar2
--   p_rt_strt_dt_rl                No   number
--   p_rt_end_dt_cd                 No   varchar2
--   p_rt_end_dt_rl                 No   number
--   p_drvbl_fctr_apls_rts_flag     Yes  varchar2
--   p_drvbl_fctr_prtn_elig_flag    Yes  varchar2
--   p_elig_apls_flag               Yes  varchar2
--   p_prtn_elig_ovrid_alwd_flag    Yes  varchar2
--   p_trk_inelig_per_flag          Yes  varchar2
--   p_postelcn_edit_rl             No   number
--   p_pgm_id                       Yes  number
--   p_pl_id                        Yes  number
--   p_cmbn_plip_id                 No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_per_cvrd_cd                  No   varchar2
--   p_short_name                  No   varchar2
--   p_short_code                  No   varchar2
--   p_legislation_code                  No   varchar2
--   p_legislation_subgroup                  No   varchar2
--   P_vrfy_fmly_mmbr_rl            No   number
--   P_vrfy_fmly_mmbr_cd            No   varchar2
--   P_use_csd_rsd_prccng_cd        No   varchar2
--   p_cpp_attribute_category       No   varchar2  Descriptive Flexfield
--   p_cpp_attribute1               No   varchar2  Descriptive Flexfield
--   p_cpp_attribute2               No   varchar2  Descriptive Flexfield
--   p_cpp_attribute3               No   varchar2  Descriptive Flexfield
--   p_cpp_attribute4               No   varchar2  Descriptive Flexfield
--   p_cpp_attribute5               No   varchar2  Descriptive Flexfield
--   p_cpp_attribute6               No   varchar2  Descriptive Flexfield
--   p_cpp_attribute7               No   varchar2  Descriptive Flexfield
--   p_cpp_attribute8               No   varchar2  Descriptive Flexfield
--   p_cpp_attribute9               No   varchar2  Descriptive Flexfield
--   p_cpp_attribute10              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute11              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute12              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute13              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute14              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute15              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute16              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute17              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute18              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute19              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute20              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute21              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute22              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute23              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute24              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute25              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute26              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute27              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute28              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute29              No   varchar2  Descriptive Flexfield
--   p_cpp_attribute30              No   varchar2  Descriptive Flexfield
--   p_url_ref_name                 No   varchar2
--   p_dflt_to_asn_pndg_ctfn_cd     No   varchar2
--   p_dflt_to_asn_pndg_ctfn_rl     No   number
--   p_mn_cvg_amt                   No   number
--   p_mn_cvg_rl                    No   number
--   p_mx_cvg_alwd_amt              No   number
--   p_mx_cvg_incr_alwd_amt         No   number
--   p_mx_cvg_incr_wcf_alwd_amt     No   number
--   p_mx_cvg_mlt_incr_num          No   number
--   p_mx_cvg_mlt_incr_wcf_num      No   number
--   p_mx_cvg_rl                    No   number
--   p_mx_cvg_wcfn_amt              No   number
--   p_mx_cvg_wcfn_mlt_num          No   number
--   p_no_mn_cvg_amt_apls_flag      Yes  varchar2
--   p_no_mn_cvg_incr_apls_flag     Yes  varchar2
--   p_no_mx_cvg_amt_apls_flag      Yes  varchar2
--   p_no_mx_cvg_incr_apls_flag     Yes  varchar2
--   p_unsspnd_enrt_cd              No   varchar2
--   p_prort_prtl_yr_cvg_rstrn_cd   No   varchar2
--   p_prort_prtl_yr_cvg_rstrn_rl   No   number
--   p_cvg_incr_r_decr_only_cd      No   varchar2
--   p_bnft_or_option_rstrctn_cd    No   varchar2
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
procedure update_Plan_in_Program
  (
   p_validate                       in boolean    default false
  ,p_plip_id                        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_dflt_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_plip_stat_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_dflt_enrt_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_dflt_enrt_det_rl               in  number    default hr_api.g_number
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_ivr_ident                      in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_enrt_mthd_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_auto_enrt_mthd_rl              in  number    default hr_api.g_number
  ,p_enrt_rl                        in  number    default hr_api.g_number
  ,p_alws_unrstrctd_enrt_flag       in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt_rl            in  number    default hr_api.g_number
  ,p_enrt_cvg_end_dt_cd             in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_end_dt_rl             in  number    default hr_api.g_number
  ,p_rt_strt_dt_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_rt_strt_dt_rl                  in  number    default hr_api.g_number
  ,p_rt_end_dt_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_rt_end_dt_rl                   in  number    default hr_api.g_number
  ,p_drvbl_fctr_apls_rts_flag       in  varchar2  default hr_api.g_varchar2
  ,p_drvbl_fctr_prtn_elig_flag      in  varchar2  default hr_api.g_varchar2
  ,p_elig_apls_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_prtn_elig_ovrid_alwd_flag      in  varchar2  default hr_api.g_varchar2
  ,p_trk_inelig_per_flag            in  varchar2  default hr_api.g_varchar2
  ,p_postelcn_edit_rl               in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_cmbn_plip_id                   in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_per_cvrd_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_short_name                    in  varchar2  default hr_api.g_varchar2
  ,p_short_code                    in  varchar2  default hr_api.g_varchar2
    ,p_legislation_code                    in  varchar2  default hr_api.g_varchar2
    ,p_legislation_subgroup                    in  varchar2  default hr_api.g_varchar2
  ,P_vrfy_fmly_mmbr_rl              in  number    default hr_api.g_number
  ,P_vrfy_fmly_mmbr_cd              in  varchar2  default hr_api.g_varchar2
  ,P_use_csd_rsd_prccng_cd          in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_url_ref_name                   in  varchar2  default hr_api.g_varchar2
  ,p_dflt_to_asn_pndg_ctfn_cd       in  varchar2  default hr_api.g_varchar2
  ,p_dflt_to_asn_pndg_ctfn_rl       in  number    default hr_api.g_number
  ,p_mn_cvg_amt                     in  number    default hr_api.g_number
  ,p_mn_cvg_rl                      in  number    default hr_api.g_number
  ,p_mx_cvg_alwd_amt                in  number    default hr_api.g_number
  ,p_mx_cvg_incr_alwd_amt           in  number    default hr_api.g_number
  ,p_mx_cvg_incr_wcf_alwd_amt       in  number    default hr_api.g_number
  ,p_mx_cvg_mlt_incr_num            in  number    default hr_api.g_number
  ,p_mx_cvg_mlt_incr_wcf_num        in  number    default hr_api.g_number
  ,p_mx_cvg_rl                      in  number    default hr_api.g_number
  ,p_mx_cvg_wcfn_amt                in  number    default hr_api.g_number
  ,p_mx_cvg_wcfn_mlt_num            in  number    default hr_api.g_number
  ,p_no_mn_cvg_amt_apls_flag        in  varchar2  default hr_api.g_varchar2
  ,p_no_mn_cvg_incr_apls_flag       in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_cvg_amt_apls_flag        in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_cvg_incr_apls_flag       in  varchar2  default hr_api.g_varchar2
  ,p_unsspnd_enrt_cd                in  varchar2  default hr_api.g_varchar2
  ,p_prort_prtl_yr_cvg_rstrn_cd     in  varchar2  default hr_api.g_varchar2
  ,p_prort_prtl_yr_cvg_rstrn_rl     in  number    default hr_api.g_number
  ,p_cvg_incr_r_decr_only_cd        in  varchar2  default hr_api.g_varchar2
  ,p_bnft_or_option_rstrctn_cd      in  varchar2  default hr_api.g_varchar2
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Plan_in_Program >------------------------|
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
--   p_plip_id                      Yes  number    PK of record
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
procedure delete_Plan_in_Program
  (
   p_validate                       in boolean        default false
  ,p_plip_id                        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  );
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
--   p_plip_id                 Yes  number   PK of record
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
  (
    p_plip_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end ben_Plan_in_Program_api;

 

/
