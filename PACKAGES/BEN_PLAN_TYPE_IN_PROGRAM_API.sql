--------------------------------------------------------
--  DDL for Package BEN_PLAN_TYPE_IN_PROGRAM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_TYPE_IN_PROGRAM_API" AUTHID CURRENT_USER as
/* $Header: bectpapi.pkh 120.0 2005/05/28 01:25:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Plan_Type_In_Program >------------------------|
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
--   p_coord_cvg_for_all_pls_flag   Yes  varchar2
--   p_dpnt_dsgn_cd                 No   varchar2
--   p_dpnt_cvg_no_ctfn_rqd_flag    Yes  varchar2
--   p_dpnt_cvg_strt_dt_cd          No   varchar2
--   p_rt_end_dt_cd          No   varchar2
--   p_rt_strt_dt_cd          No   varchar2
--   p_enrt_cvg_end_dt_cd          No   varchar2
--   p_enrt_cvg_strt_dt_cd          No   varchar2
--   p_dpnt_cvg_strt_dt_rl          No   number
--   p_dpnt_cvg_end_dt_cd           No   varchar2
--   p_dpnt_cvg_end_dt_rl           No   number
--   p_dpnt_adrs_rqd_flag           Yes  varchar2
--   p_dpnt_legv_id_rqd_flag        Yes  varchar2
--   p_susp_if_dpnt_ssn_nt_prv_cd   No  varchar2
--   p_susp_if_dpnt_dob_nt_prv_cd   No  varchar2
--   p_susp_if_dpnt_adr_nt_prv_cd   No  varchar2
--   p_susp_if_ctfn_not_dpnt_flag   No  varchar2
--   p_dpnt_ctfn_determine_cd       No  varchar2
--   p_postelcn_edit_rl             No   number
--   p_rt_end_dt_rl             No   number
--   p_rt_strt_dt_rl             No   number
--   p_enrt_cvg_end_dt_rl             No   number
--   p_enrt_cvg_strt_dt_rl             No   number
--   p_rqd_perd_enrt_nenrt_rl             No   number
--   p_auto_enrt_mthd_rl            No   number
--   p_enrt_mthd_cd                 No   varchar2
--   p_enrt_cd                      No   varchar2
--   p_enrt_rl                      No   number
--   p_dflt_enrt_cd                 No   varchar2
--   p_dflt_enrt_det_rl             No   number
--   p_drvbl_fctr_apls_rts_flag     Yes  varchar2
--   p_drvbl_fctr_prtn_elig_flag    Yes  varchar2
--   p_elig_apls_flag               Yes  varchar2
--   p_prtn_elig_ovrid_alwd_flag    Yes  varchar2
--   p_trk_inelig_per_flag          Yes  varchar2
--   p_dpnt_dob_rqd_flag            Yes  varchar2
--   p_crs_this_pl_typ_only_flag    Yes  varchar2
--   p_ptip_stat_cd                 Yes  varchar2
--   p_mx_cvg_alwd_amt              No   number
--   p_mx_enrd_alwd_ovrid_num       No   number
--   p_mn_enrd_rqd_ovrid_num        No   number
--   p_no_mx_pl_typ_ovrid_flag      Yes  varchar2
--   p_ordr_num                     No   number
--   p_prvds_cr_flag                Yes  varchar2
--   p_rqd_perd_enrt_nenrt_val      No   number
--   p_rqd_perd_enrt_nenrt_tm_uom   No   varchar2
--   p_wvbl_flag                    Yes  varchar2
--   p_drvd_fctr_dpnt_cvg_flag      Yes  varchar2
--   p_no_mn_pl_typ_overid_flag     Yes  varchar2
--   p_sbj_to_sps_lf_ins_mx_flag    Yes  varchar2
--   p_sbj_to_dpnt_lf_ins_mx_flag   Yes  varchar2
--   p_use_to_sum_ee_lf_ins_flag    Yes  varchar2
--   p_per_cvrd_cd                  No   varchar2
--   p_short_name                  No   varchar2
--   p_short_code                  No   varchar2
--   p_legislation_code                  No   varchar2
--   p_legislation_subgroup                  No   varchar2
--   p_vrfy_fmly_mmbr_cd            No   varchar2
--   p_vrfy_fmly_mmbr_rl            No   number
--   p_ivr_ident                    No   varchar2
--   p_url_ref_name                 No   varchar2
--   p_rqd_enrt_perd_tco_cd         No   varchar2
--   p_pgm_id                       Yes  number
--   p_pl_typ_id                    Yes  number
--   p_cmbn_ptip_id                 No   number
--   p_cmbn_ptip_opt_id             No   number
--   p_acrs_ptip_cvg_id             No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_ctp_attribute_category       No   varchar2  Descriptive Flexfield
--   p_ctp_attribute1               No   varchar2  Descriptive Flexfield
--   p_ctp_attribute2               No   varchar2  Descriptive Flexfield
--   p_ctp_attribute3               No   varchar2  Descriptive Flexfield
--   p_ctp_attribute4               No   varchar2  Descriptive Flexfield
--   p_ctp_attribute5               No   varchar2  Descriptive Flexfield
--   p_ctp_attribute6               No   varchar2  Descriptive Flexfield
--   p_ctp_attribute7               No   varchar2  Descriptive Flexfield
--   p_ctp_attribute8               No   varchar2  Descriptive Flexfield
--   p_ctp_attribute9               No   varchar2  Descriptive Flexfield
--   p_ctp_attribute10              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute11              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute12              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute13              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute14              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute15              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute16              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute17              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute18              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute19              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute20              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute21              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute22              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute23              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute24              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute25              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute26              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute27              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute28              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute29              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_ptip_id                      Yes  number    PK of record
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
procedure create_Plan_Type_In_Program
(
   p_validate                       in boolean    default false
  ,p_ptip_id                        out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_coord_cvg_for_all_pls_flag     in  varchar2  default 'N'
  ,p_dpnt_dsgn_cd                   in  varchar2  default null
  ,p_dpnt_cvg_no_ctfn_rqd_flag      in  varchar2  default 'N'
  ,p_dpnt_cvg_strt_dt_cd            in  varchar2  default null
  ,p_rt_end_dt_cd                   in  varchar2  default null
  ,p_rt_strt_dt_cd                  in  varchar2  default null
  ,p_enrt_cvg_end_dt_cd             in  varchar2  default null
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default null
  ,p_dpnt_cvg_strt_dt_rl            in  number    default null
  ,p_dpnt_cvg_end_dt_cd             in  varchar2  default null
  ,p_dpnt_cvg_end_dt_rl             in  number    default null
  ,p_dpnt_adrs_rqd_flag             in  varchar2  default 'N'
  ,p_dpnt_legv_id_rqd_flag          in  varchar2  default 'N'
  ,p_susp_if_dpnt_ssn_nt_prv_cd     in  varchar2   default null
  ,p_susp_if_dpnt_dob_nt_prv_cd     in  varchar2   default null
  ,p_susp_if_dpnt_adr_nt_prv_cd     in  varchar2   default null
  ,p_susp_if_ctfn_not_dpnt_flag     in  varchar2   default 'Y'
  ,p_dpnt_ctfn_determine_cd         in  varchar2   default null
  ,p_postelcn_edit_rl               in  number    default null
  ,p_rt_end_dt_rl                   in  number    default null
  ,p_rt_strt_dt_rl                  in  number    default null
  ,p_enrt_cvg_end_dt_rl             in  number    default null
  ,p_enrt_cvg_strt_dt_rl            in  number    default null
  ,p_rqd_perd_enrt_nenrt_rl         in  number    default null
  ,p_auto_enrt_mthd_rl              in  number    default null
  ,p_enrt_mthd_cd                   in  varchar2  default null
  ,p_enrt_cd                        in  varchar2  default null
  ,p_enrt_rl                        in  number    default null
  ,p_dflt_enrt_cd                   in  varchar2  default null
  ,p_dflt_enrt_det_rl               in  number    default null
  ,p_drvbl_fctr_apls_rts_flag       in  varchar2  default 'N'
  ,p_drvbl_fctr_prtn_elig_flag      in  varchar2  default 'N'
  ,p_elig_apls_flag                 in  varchar2  default 'N'
  ,p_prtn_elig_ovrid_alwd_flag      in  varchar2  default 'N'
  ,p_trk_inelig_per_flag            in  varchar2  default 'N'
  ,p_dpnt_dob_rqd_flag              in  varchar2  default 'N'
  ,p_crs_this_pl_typ_only_flag      in  varchar2  default 'N'
  ,p_ptip_stat_cd                   in  varchar2  default null
  ,p_mx_cvg_alwd_amt                in  number    default null
  ,p_mx_enrd_alwd_ovrid_num         in  number    default null
  ,p_mn_enrd_rqd_ovrid_num          in  number    default null
  ,p_no_mx_pl_typ_ovrid_flag        in  varchar2  default 'N'
  ,p_ordr_num                       in  number    default null
  ,p_prvds_cr_flag                  in  varchar2  default 'N'
  ,p_rqd_perd_enrt_nenrt_val        in  number    default null
  ,p_rqd_perd_enrt_nenrt_tm_uom     in  varchar2  default null
  ,p_wvbl_flag                      in  varchar2  default 'N'
  ,p_drvd_fctr_dpnt_cvg_flag        in  varchar2  default 'N'
  ,p_no_mn_pl_typ_overid_flag       in  varchar2  default 'N'
  ,p_sbj_to_sps_lf_ins_mx_flag      in  varchar2  default 'N'
  ,p_sbj_to_dpnt_lf_ins_mx_flag     in  varchar2  default 'N'
  ,p_use_to_sum_ee_lf_ins_flag      in  varchar2  default 'N'
  ,p_per_cvrd_cd                    in  varchar2  default null
  ,p_short_name                    in  varchar2  default null
  ,p_short_code                    in  varchar2  default null
    ,p_legislation_code                    in  varchar2  default null
    ,p_legislation_subgroup                    in  varchar2  default null
  ,p_vrfy_fmly_mmbr_cd              in  varchar2  default null
  ,p_vrfy_fmly_mmbr_rl              in  number    default null
  ,p_ivr_ident                      in  varchar2  default null
  ,p_url_ref_name                   in  varchar2  default null
  ,p_rqd_enrt_perd_tco_cd           in  varchar2  default null
  ,p_pgm_id                         in  number    default null
  ,p_pl_typ_id                      in  number    default null
  ,p_cmbn_ptip_id                   in  number    default null
  ,p_cmbn_ptip_opt_id               in  number    default null
  ,p_acrs_ptip_cvg_id               in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_ctp_attribute_category         in  varchar2  default null
  ,p_ctp_attribute1                 in  varchar2  default null
  ,p_ctp_attribute2                 in  varchar2  default null
  ,p_ctp_attribute3                 in  varchar2  default null
  ,p_ctp_attribute4                 in  varchar2  default null
  ,p_ctp_attribute5                 in  varchar2  default null
  ,p_ctp_attribute6                 in  varchar2  default null
  ,p_ctp_attribute7                 in  varchar2  default null
  ,p_ctp_attribute8                 in  varchar2  default null
  ,p_ctp_attribute9                 in  varchar2  default null
  ,p_ctp_attribute10                in  varchar2  default null
  ,p_ctp_attribute11                in  varchar2  default null
  ,p_ctp_attribute12                in  varchar2  default null
  ,p_ctp_attribute13                in  varchar2  default null
  ,p_ctp_attribute14                in  varchar2  default null
  ,p_ctp_attribute15                in  varchar2  default null
  ,p_ctp_attribute16                in  varchar2  default null
  ,p_ctp_attribute17                in  varchar2  default null
  ,p_ctp_attribute18                in  varchar2  default null
  ,p_ctp_attribute19                in  varchar2  default null
  ,p_ctp_attribute20                in  varchar2  default null
  ,p_ctp_attribute21                in  varchar2  default null
  ,p_ctp_attribute22                in  varchar2  default null
  ,p_ctp_attribute23                in  varchar2  default null
  ,p_ctp_attribute24                in  varchar2  default null
  ,p_ctp_attribute25                in  varchar2  default null
  ,p_ctp_attribute26                in  varchar2  default null
  ,p_ctp_attribute27                in  varchar2  default null
  ,p_ctp_attribute28                in  varchar2  default null
  ,p_ctp_attribute29                in  varchar2  default null
  ,p_ctp_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_Plan_Type_In_Program >------------------------|
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
--   p_ptip_id                      Yes  number    PK of record
--   p_coord_cvg_for_all_pls_flag   Yes  varchar2
--   p_dpnt_dsgn_cd                 No   varchar2
--   p_dpnt_cvg_no_ctfn_rqd_flag    Yes  varchar2
--   p_dpnt_cvg_strt_dt_cd          No   varchar2
--   p_rt_end_dt_cd          No   varchar2
--   p_rt_strt_dt_cd          No   varchar2
--   p_enrt_cvg_end_dt_cd          No   varchar2
--   p_enrt_cvg_strt_dt_cd          No   varchar2
--   p_dpnt_cvg_strt_dt_rl          No   number
--   p_dpnt_cvg_end_dt_cd           No   varchar2
--   p_dpnt_cvg_end_dt_rl           No   number
--   p_dpnt_adrs_rqd_flag           Yes  varchar2
--   p_dpnt_legv_id_rqd_flag        Yes  varchar2
--   p_susp_if_dpnt_ssn_nt_prv_cd   No  varchar2
--   p_susp_if_dpnt_dob_nt_prv_cd   No  varchar2
--   p_susp_if_dpnt_adr_nt_prv_cd   No  varchar2
--   p_susp_if_ctfn_not_dpnt_flag   No  varchar2
--   p_dpnt_ctfn_determine_cd       No  varchar2
--   p_postelcn_edit_rl             No   number
--   p_rt_end_dt_rl             No   number
--   p_rt_strt_dt_rl             No   number
--   p_enrt_cvg_end_dt_rl             No   number
--   p_enrt_cvg_strt_dt_rl             No   number
--   p_rqd_perd_enrt_nenrt_rl             No   number
--   p_auto_enrt_mthd_rl            No   number
--   p_enrt_mthd_cd                 No   varchar2
--   p_enrt_cd                      No   varchar2
--   p_enrt_rl                      No   number
--   p_dflt_enrt_cd                 No   varchar2
--   p_dflt_enrt_det_rl             No   number
--   p_drvbl_fctr_apls_rts_flag     Yes  varchar2
--   p_drvbl_fctr_prtn_elig_flag    Yes  varchar2
--   p_elig_apls_flag               Yes  varchar2
--   p_prtn_elig_ovrid_alwd_flag    Yes  varchar2
--   p_trk_inelig_per_flag          Yes  varchar2
--   p_dpnt_dob_rqd_flag            Yes  varchar2
--   p_crs_this_pl_typ_only_flag    Yes  varchar2
--   p_ptip_stat_cd                 Yes  varchar2
--   p_mx_cvg_alwd_amt              No   number
--   p_mx_enrd_alwd_ovrid_num       No   number
--   p_mn_enrd_rqd_ovrid_num        No   number
--   p_no_mx_pl_typ_ovrid_flag      Yes  varchar2
--   p_ordr_num                     No   number
--   p_prvds_cr_flag                Yes  varchar2
--   p_rqd_perd_enrt_nenrt_val      No   number
--   p_rqd_perd_enrt_nenrt_tm_uom   No   varchar2
--   p_wvbl_flag                    Yes  varchar2
--   p_drvd_fctr_dpnt_cvg_flag      Yes  varchar2
--   p_no_mn_pl_typ_overid_flag     Yes  varchar2
--   p_sbj_to_sps_lf_ins_mx_flag    Yes  varchar2
--   p_sbj_to_dpnt_lf_ins_mx_flag   Yes  varchar2
--   p_use_to_sum_ee_lf_ins_flag    Yes  varchar2
--   p_per_cvrd_cd                  No   varchar2
--   p_short_name                  No   varchar2
--   p_short_code                  No   varchar2
--   p_legislation_code                  No   varchar2
--   p_legislation_subgroup                  No   varchar2
--   p_vrfy_fmly_mmbr_cd            No   varchar2
--   p_vrfy_fmly_mmbr_rl            No   number
--   p_ivr_ident                    No   varchar2
--   p_url_ref_name                 No   varchar2
--   p_rqd_enrt_perd_tco_cd         No   varchar2
--   p_pgm_id                       Yes  number
--   p_pl_typ_id                    Yes  number
--   p_cmbn_ptip_id                 No   number
--   p_cmbn_ptip_opt_id             No   number
--   p_acrs_ptip_cvg_id             No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_ctp_attribute_category       No   varchar2  Descriptive Flexfield
--   p_ctp_attribute1               No   varchar2  Descriptive Flexfield
--   p_ctp_attribute2               No   varchar2  Descriptive Flexfield
--   p_ctp_attribute3               No   varchar2  Descriptive Flexfield
--   p_ctp_attribute4               No   varchar2  Descriptive Flexfield
--   p_ctp_attribute5               No   varchar2  Descriptive Flexfield
--   p_ctp_attribute6               No   varchar2  Descriptive Flexfield
--   p_ctp_attribute7               No   varchar2  Descriptive Flexfield
--   p_ctp_attribute8               No   varchar2  Descriptive Flexfield
--   p_ctp_attribute9               No   varchar2  Descriptive Flexfield
--   p_ctp_attribute10              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute11              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute12              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute13              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute14              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute15              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute16              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute17              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute18              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute19              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute20              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute21              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute22              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute23              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute24              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute25              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute26              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute27              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute28              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute29              No   varchar2  Descriptive Flexfield
--   p_ctp_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_Plan_Type_In_Program
  (
   p_validate                       in boolean    default false
  ,p_ptip_id                        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_coord_cvg_for_all_pls_flag     in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_dsgn_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_cvg_no_ctfn_rqd_flag      in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_cvg_strt_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_rt_end_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_rt_strt_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_end_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_cvg_strt_dt_rl            in  number    default hr_api.g_number
  ,p_dpnt_cvg_end_dt_cd             in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_cvg_end_dt_rl             in  number    default hr_api.g_number
  ,p_dpnt_adrs_rqd_flag             in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_legv_id_rqd_flag          in  varchar2  default hr_api.g_varchar2
  ,p_susp_if_dpnt_ssn_nt_prv_cd      in  varchar2   default hr_api.g_varchar2
  ,p_susp_if_dpnt_dob_nt_prv_cd      in  varchar2   default hr_api.g_varchar2
  ,p_susp_if_dpnt_adr_nt_prv_cd      in  varchar2   default hr_api.g_varchar2
  ,p_susp_if_ctfn_not_dpnt_flag      in  varchar2   default hr_api.g_varchar2
  ,p_dpnt_ctfn_determine_cd          in  varchar2   default hr_api.g_varchar2
  ,p_postelcn_edit_rl               in  number    default hr_api.g_number
  ,p_rt_end_dt_rl               in  number    default hr_api.g_number
  ,p_rt_strt_dt_rl               in  number    default hr_api.g_number
  ,p_enrt_cvg_end_dt_rl               in  number    default hr_api.g_number
  ,p_enrt_cvg_strt_dt_rl               in  number    default hr_api.g_number
  ,p_rqd_perd_enrt_nenrt_rl               in  number    default hr_api.g_number
  ,p_auto_enrt_mthd_rl              in  number    default hr_api.g_number
  ,p_enrt_mthd_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_enrt_rl                        in  number    default hr_api.g_number
  ,p_dflt_enrt_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_dflt_enrt_det_rl               in  number    default hr_api.g_number
  ,p_drvbl_fctr_apls_rts_flag       in  varchar2  default hr_api.g_varchar2
  ,p_drvbl_fctr_prtn_elig_flag      in  varchar2  default hr_api.g_varchar2
  ,p_elig_apls_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_prtn_elig_ovrid_alwd_flag      in  varchar2  default hr_api.g_varchar2
  ,p_trk_inelig_per_flag            in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_dob_rqd_flag              in  varchar2  default hr_api.g_varchar2
  ,p_crs_this_pl_typ_only_flag      in  varchar2  default hr_api.g_varchar2
  ,p_ptip_stat_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_mx_cvg_alwd_amt                in  number    default hr_api.g_number
  ,p_mx_enrd_alwd_ovrid_num         in  number    default hr_api.g_number
  ,p_mn_enrd_rqd_ovrid_num          in  number    default hr_api.g_number
  ,p_no_mx_pl_typ_ovrid_flag        in  varchar2  default hr_api.g_varchar2
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_prvds_cr_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_rqd_perd_enrt_nenrt_val        in  number    default hr_api.g_number
  ,p_rqd_perd_enrt_nenrt_tm_uom     in  varchar2  default hr_api.g_varchar2
  ,p_wvbl_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_drvd_fctr_dpnt_cvg_flag        in  varchar2  default hr_api.g_varchar2
  ,p_no_mn_pl_typ_overid_flag       in  varchar2  default hr_api.g_varchar2
  ,p_sbj_to_sps_lf_ins_mx_flag      in  varchar2  default hr_api.g_varchar2
  ,p_sbj_to_dpnt_lf_ins_mx_flag     in  varchar2  default hr_api.g_varchar2
  ,p_use_to_sum_ee_lf_ins_flag      in  varchar2  default hr_api.g_varchar2
  ,p_per_cvrd_cd                    in varchar2   default hr_api.g_varchar2
  ,p_short_name                    in varchar2   default hr_api.g_varchar2
  ,p_short_code                    in varchar2   default hr_api.g_varchar2
    ,p_legislation_code                    in varchar2   default hr_api.g_varchar2
    ,p_legislation_subgroup                    in varchar2   default hr_api.g_varchar2
  ,p_vrfy_fmly_mmbr_cd              in varchar2   default hr_api.g_varchar2
  ,p_vrfy_fmly_mmbr_rl              in number     default hr_api.g_number
  ,p_ivr_ident                      in  varchar2  default hr_api.g_varchar2
  ,p_url_ref_name                   in  varchar2  default hr_api.g_varchar2
  ,p_rqd_enrt_perd_tco_cd           in  varchar2  default hr_api.g_varchar2
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_pl_typ_id                      in  number    default hr_api.g_number
  ,p_cmbn_ptip_id                   in  number    default hr_api.g_number
  ,p_cmbn_ptip_opt_id               in  number    default hr_api.g_number
  ,p_acrs_ptip_cvg_id               in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_ctp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_ctp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_ctp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_ctp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_ctp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_ctp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_ctp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_ctp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_ctp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_ctp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_ctp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_ctp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_ctp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_ctp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_ctp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_ctp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_ctp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_ctp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_ctp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_ctp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_ctp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_ctp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_ctp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_ctp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_ctp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_ctp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_ctp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_ctp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_ctp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_ctp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_ctp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Plan_Type_In_Program >------------------------|
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
--   p_ptip_id                      Yes  number    PK of record
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
procedure delete_Plan_Type_In_Program
  (
   p_validate                       in boolean        default false
  ,p_ptip_id                        in  number
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
--   p_ptip_id                 Yes  number   PK of record
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
    p_ptip_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end ben_Plan_Type_In_Program_api;

 

/
