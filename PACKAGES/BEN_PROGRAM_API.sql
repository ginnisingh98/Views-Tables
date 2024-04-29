--------------------------------------------------------
--  DDL for Package BEN_PROGRAM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PROGRAM_API" AUTHID CURRENT_USER as
/* $Header: bepgmapi.pkh 120.0 2005/05/28 10:46:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Program >------------------------|
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
--   p_name                         Yes  varchar2
--   p_dpnt_adrs_rqd_flag           Yes  varchar2
--   p_pgm_prvds_no_auto_enrt_flag  Yes  varchar2
--   p_dpnt_dob_rqd_flag            Yes  varchar2
--   p_pgm_prvds_no_dflt_enrt_flag  Yes  varchar2
--   p_dpnt_legv_id_rqd_flag        Yes  varchar2
--   p_dpnt_dsgn_lvl_cd             No   varchar2
--   p_pgm_stat_cd                  No   varchar2
--   p_ivr_ident                    No   varchar2
--   p_pgm_typ_cd                   No   varchar2
--   p_elig_apls_flag               Yes  varchar2
--   p_uses_all_asmts_for_rts_flag  Yes  varchar2
--   p_url_ref_name                 No   varchar2
--   p_pgm_desc                     No   varchar2
--   p_prtn_elig_ovrid_alwd_flag    Yes  varchar2
--   p_pgm_use_all_asnts_elig_flag  Yes  varchar2
--   p_dpnt_dsgn_cd                 No   varchar2
--   p_mx_dpnt_pct_prtt_lf_amt      No   number
--   p_mx_sps_pct_prtt_lf_amt       No   number
--   p_acty_ref_perd_cd             No   varchar2
--   p_coord_cvg_for_all_pls_flg    Yes  varchar2
--   p_enrt_cvg_end_dt_cd           No   varchar2
--   p_enrt_cvg_end_dt_rl           No   number
--   p_dpnt_cvg_end_dt_cd           No   varchar2
--   p_dpnt_cvg_end_dt_rl           No   number
--   p_dpnt_cvg_strt_dt_cd          No   varchar2
--   p_dpnt_cvg_strt_dt_rl          No   number
--   p_per_cvrd_cd                  No   varchar2
--   P_vrfy_fmly_mmbr_rl            No   number
--   P_vrfy_fmly_mmbr_cd            No   varchar2
--   p_dpnt_dsgn_no_ctfn_rqd_flag   Yes  varchar2
--   p_drvbl_fctr_dpnt_elig_flag    Yes  varchar2
--   p_drvbl_fctr_prtn_elig_flag    Yes  varchar2
--   p_enrt_cvg_strt_dt_cd          No   varchar2
--   p_enrt_cvg_strt_dt_rl          No   number
--   p_enrt_info_rt_freq_cd         No   varchar2
--   p_rt_strt_dt_cd                No   varchar2
--   p_rt_strt_dt_rl                No   number
--   p_rt_end_dt_cd                 No   varchar2
--   p_rt_end_dt_rl                 No   number
--   p_pgm_grp_cd                   No   varchar2
--   p_pgm_uom                      No   varchar2
--   p_drvbl_fctr_apls_rts_flag     Yes  varchar2
--   p_alws_unrstrctd_enrt_flag     Yes  varchar2
--   p_enrt_cd                      No   varchar2
--   p_enrt_mthd_cd                 No   varchar2
--   p_poe_lvl_cd                   No   varchar2
--   p_enrt_rl                      No   number
--   p_auto_enrt_mthd_rl            No   number
--   p_trk_inelig_per_flag          Yes  varchar2
--   p_business_group_id            Yes  number    Business Group of Record
--   p_short_name                   No   varchar2  				FHR
--   p_short_code                   No   varchar2 				FHR
--   p_legislation_code                   No   varchar2 				FHR
--   p_legislation_subgroup                   No   varchar2 				FHR
--   p_Dflt_pgm_flag                Yes  Varchar2
--   p_Use_prog_points_flag         Yes  Varchar2
--   p_Dflt_step_cd                 No   Varchar2
--   p_Dflt_step_rl                 No   number
--   p_Update_salary_cd             No   Varchar2
--   p_Use_multi_pay_rates_flag     Yes  Varchar2
--   p_dflt_element_type_id         No   number
--   p_Dflt_input_value_id          No   number
--   p_Use_scores_cd                No   Varchar2
--   p_Scores_calc_mthd_cd          No   Varchar2
--   p_Scores_calc_rl               No   number
--   p_gsp_allow_override_flag       No   varchar2  Descriptive Flexfield
--   p_use_variable_rates_flag       No   varchar2  Descriptive Flexfield
--   p_salary_calc_mthd_cd       No   varchar2  Descriptive Flexfield
--   p_salary_calc_mthd_rl       No   number  Descriptive Flexfield
--   p_pgm_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pgm_attribute1               No   varchar2  Descriptive Flexfield
--   p_pgm_attribute2               No   varchar2  Descriptive Flexfield
--   p_pgm_attribute3               No   varchar2  Descriptive Flexfield
--   p_pgm_attribute4               No   varchar2  Descriptive Flexfield
--   p_pgm_attribute5               No   varchar2  Descriptive Flexfield
--   p_pgm_attribute6               No   varchar2  Descriptive Flexfield
--   p_pgm_attribute7               No   varchar2  Descriptive Flexfield
--   p_pgm_attribute8               No   varchar2  Descriptive Flexfield
--   p_pgm_attribute9               No   varchar2  Descriptive Flexfield
--   p_pgm_attribute10              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute11              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute12              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute13              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute14              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute15              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute16              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute17              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute18              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute19              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute20              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute21              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute22              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute23              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute24              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute25              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute26              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute27              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute28              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute29              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_pgm_id                       Yes  number    PK of record
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
procedure create_Program
(
   p_validate                       in boolean    default false
  ,p_pgm_id                         out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default null
  ,p_dpnt_adrs_rqd_flag             in  varchar2  default null
  ,p_pgm_prvds_no_auto_enrt_flag    in  varchar2  default null
  ,p_dpnt_dob_rqd_flag              in  varchar2  default null
  ,p_pgm_prvds_no_dflt_enrt_flag    in  varchar2  default null
  ,p_dpnt_legv_id_rqd_flag          in  varchar2  default null
  ,p_dpnt_dsgn_lvl_cd               in  varchar2  default null
  ,p_pgm_stat_cd                    in  varchar2  default null
  ,p_ivr_ident                      in  varchar2  default null
  ,p_pgm_typ_cd                     in  varchar2  default null
  ,p_elig_apls_flag                 in  varchar2  default 'N'
  ,p_uses_all_asmts_for_rts_flag    in  varchar2  default null
  ,p_url_ref_name                   in  varchar2  default null
  ,p_pgm_desc                       in  varchar2  default null
  ,p_prtn_elig_ovrid_alwd_flag      in  varchar2  default null
  ,p_pgm_use_all_asnts_elig_flag    in  varchar2  default null
  ,p_dpnt_dsgn_cd                   in  varchar2  default null
  ,p_mx_dpnt_pct_prtt_lf_amt        in  number    default null
  ,p_mx_sps_pct_prtt_lf_amt         in  number    default null
  ,p_acty_ref_perd_cd               in  varchar2  default null
  ,p_coord_cvg_for_all_pls_flg      in  varchar2  default null
  ,p_enrt_cvg_end_dt_cd             in  varchar2  default null
  ,p_enrt_cvg_end_dt_rl             in  number    default null
  ,p_dpnt_cvg_end_dt_cd             in  varchar2  default null
  ,p_dpnt_cvg_end_dt_rl             in  number    default null
  ,p_dpnt_cvg_strt_dt_cd            in  varchar2  default null
  ,p_dpnt_cvg_strt_dt_rl            in  number    default null
  ,p_dpnt_dsgn_no_ctfn_rqd_flag     in  varchar2  default null
  ,p_drvbl_fctr_dpnt_elig_flag      in  varchar2  default null
  ,p_drvbl_fctr_prtn_elig_flag      in  varchar2  default null
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default null
  ,p_enrt_cvg_strt_dt_rl            in  number    default null
  ,p_enrt_info_rt_freq_cd           in  varchar2  default null
  ,p_rt_strt_dt_cd                  in  varchar2  default null
  ,p_rt_strt_dt_rl                  in  number    default null
  ,p_rt_end_dt_cd                   in  varchar2  default null
  ,p_rt_end_dt_rl                   in  number    default null
  ,p_pgm_grp_cd                     in  varchar2  default null
  ,p_pgm_uom                        in  varchar2  default null
  ,p_drvbl_fctr_apls_rts_flag       in  varchar2  default null
  ,p_alws_unrstrctd_enrt_flag       in  varchar2  default null
  ,p_enrt_cd                        in  varchar2  default null
  ,p_enrt_mthd_cd                   in  varchar2  default null
  ,p_poe_lvl_cd                     in  varchar2  default null
  ,p_enrt_rl                        in  number    default null
  ,p_auto_enrt_mthd_rl              in  number    default null
  ,p_trk_inelig_per_flag            in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_per_cvrd_cd                    in  varchar2  default null
  ,P_vrfy_fmly_mmbr_rl              in  number    default null
  ,P_vrfy_fmly_mmbr_cd              in  varchar2  default null
  ,p_short_name			    in  varchar2  default null
  ,p_short_code			    in  varchar2  default null
    ,p_legislation_code			    in  varchar2  default null
    ,p_legislation_subgroup			    in  varchar2  default null
  ,p_Dflt_pgm_flag                  in  Varchar2  default null
  ,p_Use_prog_points_flag           in  Varchar2  default null
  ,p_Dflt_step_cd                   in  Varchar2  default null
  ,p_Dflt_step_rl                   in  number    default null
  ,p_Update_salary_cd               in  Varchar2  default null
  ,p_Use_multi_pay_rates_flag       in  Varchar2  default null
  ,p_dflt_element_type_id           in  number    default null
  ,p_Dflt_input_value_id            in  number    default null
  ,p_Use_scores_cd                  in  Varchar2  default null
  ,p_Scores_calc_mthd_cd            in  Varchar2  default null
  ,p_Scores_calc_rl                 in  number    default null
  ,p_gsp_allow_override_flag         in  varchar2  default null
  ,p_use_variable_rates_flag         in  varchar2  default null
  ,p_salary_calc_mthd_cd         in  varchar2  default null
  ,p_salary_calc_mthd_rl         in  number  default null
  ,p_susp_if_dpnt_ssn_nt_prv_cd    in  varchar2  default null
  ,p_susp_if_dpnt_dob_nt_prv_cd    in  varchar2  default null
  ,p_susp_if_dpnt_adr_nt_prv_cd    in  varchar2  default null
  ,p_susp_if_ctfn_not_dpnt_flag    in  varchar2  default 'Y'
  ,p_dpnt_ctfn_determine_cd        in  varchar2  default null
  ,p_pgm_attribute_category         in  varchar2  default null
  ,p_pgm_attribute1                 in  varchar2  default null
  ,p_pgm_attribute2                 in  varchar2  default null
  ,p_pgm_attribute3                 in  varchar2  default null
  ,p_pgm_attribute4                 in  varchar2  default null
  ,p_pgm_attribute5                 in  varchar2  default null
  ,p_pgm_attribute6                 in  varchar2  default null
  ,p_pgm_attribute7                 in  varchar2  default null
  ,p_pgm_attribute8                 in  varchar2  default null
  ,p_pgm_attribute9                 in  varchar2  default null
  ,p_pgm_attribute10                in  varchar2  default null
  ,p_pgm_attribute11                in  varchar2  default null
  ,p_pgm_attribute12                in  varchar2  default null
  ,p_pgm_attribute13                in  varchar2  default null
  ,p_pgm_attribute14                in  varchar2  default null
  ,p_pgm_attribute15                in  varchar2  default null
  ,p_pgm_attribute16                in  varchar2  default null
  ,p_pgm_attribute17                in  varchar2  default null
  ,p_pgm_attribute18                in  varchar2  default null
  ,p_pgm_attribute19                in  varchar2  default null
  ,p_pgm_attribute20                in  varchar2  default null
  ,p_pgm_attribute21                in  varchar2  default null
  ,p_pgm_attribute22                in  varchar2  default null
  ,p_pgm_attribute23                in  varchar2  default null
  ,p_pgm_attribute24                in  varchar2  default null
  ,p_pgm_attribute25                in  varchar2  default null
  ,p_pgm_attribute26                in  varchar2  default null
  ,p_pgm_attribute27                in  varchar2  default null
  ,p_pgm_attribute28                in  varchar2  default null
  ,p_pgm_attribute29                in  varchar2  default null
  ,p_pgm_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_Program >------------------------|
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
--   p_pgm_id                       Yes  number    PK of record
--   p_name                         Yes  varchar2
--   p_dpnt_adrs_rqd_flag           Yes  varchar2
--   p_pgm_prvds_no_auto_enrt_flag  Yes  varchar2
--   p_dpnt_dob_rqd_flag            Yes  varchar2
--   p_pgm_prvds_no_dflt_enrt_flag  Yes  varchar2
--   p_dpnt_legv_id_rqd_flag        Yes  varchar2
--   p_dpnt_dsgn_lvl_cd             No   varchar2
--   p_pgm_stat_cd                  No   varchar2
--   p_ivr_ident                    No   varchar2
--   p_pgm_typ_cd                   No   varchar2
--   p_elig_apls_flag               Yes  varchar2
--   p_uses_all_asmts_for_rts_flag  Yes  varchar2
--   p_url_ref_name                 No   varchar2
--   p_pgm_desc                     No   varchar2
--   p_prtn_elig_ovrid_alwd_flag    Yes  varchar2
--   p_pgm_use_all_asnts_elig_flag  Yes  varchar2
--   p_dpnt_dsgn_cd                 No   varchar2
--   p_mx_dpnt_pct_prtt_lf_amt      No   number
--   p_mx_sps_pct_prtt_lf_amt       No   number
--   p_acty_ref_perd_cd             No   varchar2
--   p_coord_cvg_for_all_pls_flg    Yes  varchar2
--   p_enrt_cvg_end_dt_cd           No   varchar2
--   p_enrt_cvg_end_dt_rl           No   number
--   p_dpnt_cvg_end_dt_cd           No   varchar2
--   p_dpnt_cvg_end_dt_rl           No   number
--   p_dpnt_cvg_strt_dt_cd          No   varchar2
--   p_dpnt_cvg_strt_dt_rl          No   number
--   p_dpnt_dsgn_no_ctfn_rqd_flag   Yes  varchar2
--   p_drvbl_fctr_dpnt_elig_flag    Yes  varchar2
--   p_drvbl_fctr_prtn_elig_flag    Yes  varchar2
--   p_enrt_cvg_strt_dt_cd          No   varchar2
--   p_enrt_cvg_strt_dt_rl          No   number
--   p_enrt_info_rt_freq_cd         No   varchar2
--   p_rt_strt_dt_cd                No   varchar2
--   p_rt_strt_dt_rl                No   number
--   p_rt_end_dt_cd                 No   varchar2
--   p_rt_end_dt_rl                 No   number
--   p_pgm_grp_cd                   No   varchar2
--   p_pgm_uom                      No   varchar2
--   p_drvbl_fctr_apls_rts_flag     Yes  varchar2
--   p_alws_unrstrctd_enrt_flag     Yes  varchar2
--   p_enrt_cd                      No   varchar2
--   p_enrt_mthd_cd                 No   varchar2
--   p_poe_lvl_cd                   No   varchar2
--   p_enrt_rl                      No   number
--   p_auto_enrt_mthd_rl            No   number
--   p_trk_inelig_per_flag          Yes  varchar2
--   p_business_group_id            Yes  number    Business Group of Record
--   p_per_cvrd_cd                  No   varchar2
--   P_vrfy_fmly_mmbr_rl            No   number
--   P_vrfy_fmly_mmbr_cd            No   varchar2
--   p_short_name		    No   varchar2                              FHR
--   p_short_code		    No   varchar2			       FHR
--   p_legislation_code		    No   varchar2			       FHR
--   p_legislation_subgroup		    No   varchar2			       FHR
--   p_Dflt_pgm_flag                Yes  Varchar2
--   p_Use_prog_points_flag         Yes  Varchar2
--   p_Dflt_step_cd                 No   Varchar2
--   p_Dflt_step_rl                 No   number
--   p_Update_salary_cd             No   Varchar2
--   p_Use_multi_pay_rates_flag     Yes  Varchar2
--   p_dflt_element_type_id         No   number
--   p_Dflt_input_value_id          No   number
--   p_Use_scores_cd                No   Varchar2
--   p_Scores_calc_mthd_cd          No   Varchar2
--   p_Scores_calc_rl               No   number
--   p_gsp_allow_override_flag       No   varchar2  Descriptive Flexfield
--   p_use_variable_rates_flag       No   varchar2  Descriptive Flexfield
--   p_salary_calc_mthd_cd       No   varchar2  Descriptive Flexfield
--   p_salary_calc_mthd_rl       No   number  Descriptive Flexfield
--   p_pgm_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pgm_attribute1               No   varchar2  Descriptive Flexfield
--   p_pgm_attribute2               No   varchar2  Descriptive Flexfield
--   p_pgm_attribute3               No   varchar2  Descriptive Flexfield
--   p_pgm_attribute4               No   varchar2  Descriptive Flexfield
--   p_pgm_attribute5               No   varchar2  Descriptive Flexfield
--   p_pgm_attribute6               No   varchar2  Descriptive Flexfield
--   p_pgm_attribute7               No   varchar2  Descriptive Flexfield
--   p_pgm_attribute8               No   varchar2  Descriptive Flexfield
--   p_pgm_attribute9               No   varchar2  Descriptive Flexfield
--   p_pgm_attribute10              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute11              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute12              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute13              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute14              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute15              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute16              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute17              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute18              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute19              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute20              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute21              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute22              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute23              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute24              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute25              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute26              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute27              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute28              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute29              No   varchar2  Descriptive Flexfield
--   p_pgm_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_Program
  (
   p_validate                       in boolean    default false
  ,p_pgm_id                         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_adrs_rqd_flag             in  varchar2  default hr_api.g_varchar2
  ,p_pgm_prvds_no_auto_enrt_flag    in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_dob_rqd_flag              in  varchar2  default hr_api.g_varchar2
  ,p_pgm_prvds_no_dflt_enrt_flag    in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_legv_id_rqd_flag          in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_dsgn_lvl_cd               in  varchar2  default hr_api.g_varchar2
  ,p_pgm_stat_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_ivr_ident                      in  varchar2  default hr_api.g_varchar2
  ,p_pgm_typ_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_elig_apls_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_uses_all_asmts_for_rts_flag    in  varchar2  default hr_api.g_varchar2
  ,p_url_ref_name                   in  varchar2  default hr_api.g_varchar2
  ,p_pgm_desc                       in  varchar2  default hr_api.g_varchar2
  ,p_prtn_elig_ovrid_alwd_flag      in  varchar2  default hr_api.g_varchar2
  ,p_pgm_use_all_asnts_elig_flag    in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_dsgn_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_mx_dpnt_pct_prtt_lf_amt        in  number    default hr_api.g_number
  ,p_mx_sps_pct_prtt_lf_amt         in  number    default hr_api.g_number
  ,p_acty_ref_perd_cd               in  varchar2  default hr_api.g_varchar2
  ,p_coord_cvg_for_all_pls_flg      in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_end_dt_cd             in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_end_dt_rl             in  number    default hr_api.g_number
  ,p_dpnt_cvg_end_dt_cd             in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_cvg_end_dt_rl             in  number    default hr_api.g_number
  ,p_dpnt_cvg_strt_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_cvg_strt_dt_rl            in  number    default hr_api.g_number
  ,p_dpnt_dsgn_no_ctfn_rqd_flag     in  varchar2  default hr_api.g_varchar2
  ,p_drvbl_fctr_dpnt_elig_flag      in  varchar2  default hr_api.g_varchar2
  ,p_drvbl_fctr_prtn_elig_flag      in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt_rl            in  number    default hr_api.g_number
  ,p_enrt_info_rt_freq_cd           in  varchar2  default hr_api.g_varchar2
  ,p_rt_strt_dt_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_rt_strt_dt_rl                  in  number    default hr_api.g_number
  ,p_rt_end_dt_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_rt_end_dt_rl                   in  number    default hr_api.g_number
  ,p_pgm_grp_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_pgm_uom                        in  varchar2  default hr_api.g_varchar2
  ,p_drvbl_fctr_apls_rts_flag       in  varchar2  default hr_api.g_varchar2
  ,p_alws_unrstrctd_enrt_flag       in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_enrt_mthd_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_poe_lvl_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_enrt_rl                        in  number    default hr_api.g_number
  ,p_auto_enrt_mthd_rl              in  number    default hr_api.g_number
  ,p_trk_inelig_per_flag            in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_per_cvrd_cd                    in  varchar2  default hr_api.g_varchar2
  ,P_vrfy_fmly_mmbr_rl              in  number    default hr_api.g_number
  ,P_vrfy_fmly_mmbr_cd              in  varchar2  default hr_api.g_varchar2
  ,P_short_name                     in  varchar2  default hr_api.g_varchar2
  ,P_short_code                     in  varchar2  default hr_api.g_varchar2
    ,P_legislation_code                     in  varchar2  default hr_api.g_varchar2
    ,P_legislation_subgroup                     in  varchar2  default hr_api.g_varchar2
  ,p_Dflt_pgm_flag                  in  Varchar2  default hr_api.g_varchar2
  ,p_Use_prog_points_flag           in  Varchar2  default hr_api.g_varchar2
  ,p_Dflt_step_cd                   in  Varchar2  default hr_api.g_varchar2
  ,p_Dflt_step_rl                   in  number    default hr_api.g_number
  ,p_Update_salary_cd               in  Varchar2  default hr_api.g_varchar2
  ,p_Use_multi_pay_rates_flag       in  Varchar2  default hr_api.g_varchar2
  ,p_dflt_element_type_id           in  number    default hr_api.g_number
  ,p_Dflt_input_value_id            in  number    default hr_api.g_number
  ,p_Use_scores_cd                  in  Varchar2  default hr_api.g_varchar2
  ,p_Scores_calc_mthd_cd            in  Varchar2  default hr_api.g_varchar2
  ,p_Scores_calc_rl                 in  number    default hr_api.g_number
  ,p_gsp_allow_override_flag         in  varchar2  default hr_api.g_varchar2
  ,p_use_variable_rates_flag         in  varchar2  default hr_api.g_varchar2
  ,p_salary_calc_mthd_cd         in  varchar2  default hr_api.g_varchar2
  ,p_salary_calc_mthd_rl         in  number  default hr_api.g_number
  ,p_susp_if_dpnt_ssn_nt_prv_cd      in  varchar2   default hr_api.g_varchar2
  ,p_susp_if_dpnt_dob_nt_prv_cd      in  varchar2   default hr_api.g_varchar2
  ,p_susp_if_dpnt_adr_nt_prv_cd      in  varchar2   default hr_api.g_varchar2
  ,p_susp_if_ctfn_not_dpnt_flag      in  varchar2   default hr_api.g_varchar2
  ,p_dpnt_ctfn_determine_cd          in  varchar2   default hr_api.g_varchar2
  ,p_pgm_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Program >------------------------|
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
--   p_pgm_id                       Yes  number    PK of record
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
procedure delete_Program
  (
   p_validate                       in boolean        default false
  ,p_pgm_id                         in  number
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
--   p_pgm_id                 Yes  number   PK of record
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
    p_pgm_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end ben_Program_api;

 

/
