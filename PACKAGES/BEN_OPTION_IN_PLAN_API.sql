--------------------------------------------------------
--  DDL for Package BEN_OPTION_IN_PLAN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_OPTION_IN_PLAN_API" AUTHID CURRENT_USER as
/* $Header: becopapi.pkh 120.0 2005/05/28 01:09:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Option_in_Plan >-------------------------|
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
--   p_ivr_ident                    No   varchar2
--   p_url_ref_name                 No   varchar2
--   p_opt_id                       Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_pl_id                        Yes  number
--   p_ordr_num                     No   number
--   p_rqd_perd_enrt_nenrt_val                     No   number
--   p_dflt_flag                    Yes  varchar2
--   p_actl_prem_id                 No   number
--   p_mndtry_flag                  Yes  varchar2
--   p_oipl_stat_cd                 Yes  varchar2
--   p_pcp_dsgn_cd                  Yes  varchar2
--   p_pcp_dpnt_dsgn_cd             Yes  varchar2
--   p_rqd_perd_enrt_nenrt_uom                 Yes  varchar2
--   p_elig_apls_flag               Yes  varchar2
--   p_dflt_enrt_det_rl             No   number
--   p_trk_inelig_per_flag          Yes  varchar2
--   p_drvbl_fctr_prtn_elig_flag    Yes  varchar2
--   p_mndtry_rl                    No   number
--   p_rqd_perd_enrt_nenrt_rl                    No   number
--   p_dflt_enrt_cd                 No   varchar2
--   p_prtn_elig_ovrid_alwd_flag    Yes  varchar2
--   p_drvbl_fctr_apls_rts_flag     Yes  varchar2
--   p_per_cvrd_cd                  No   varchar2
--   p_postelcn_edit_rl             No   number
--   p_vrfy_fmly_mmbr_cd            No   varchar2
--   p_vrfy_fmly_mmbr_rl            No   number
--   p_enrt_cd                      No   varchar2
--   p_enrt_rl                      No   number
--   p_auto_enrt_flag               No   varchar2
--   p_auto_enrt_mthd_rl            No   number
--   p_short_name		    No   varchar2   				FHR
--   p_short_code		    No   varchar2  				FHR
--   p_legislation_code		    No   varchar2  				FHR
--   p_legislation_subgroup		    No   varchar2  				FHR
--   p_hidden_flag		    Yes  varchar2
--   p_cop_attribute_category       No   varchar2  Descriptive Flexfield
--   p_cop_attribute1               No   varchar2  Descriptive Flexfield
--   p_cop_attribute2               No   varchar2  Descriptive Flexfield
--   p_cop_attribute3               No   varchar2  Descriptive Flexfield
--   p_cop_attribute4               No   varchar2  Descriptive Flexfield
--   p_cop_attribute5               No   varchar2  Descriptive Flexfield
--   p_cop_attribute6               No   varchar2  Descriptive Flexfield
--   p_cop_attribute7               No   varchar2  Descriptive Flexfield
--   p_cop_attribute8               No   varchar2  Descriptive Flexfield
--   p_cop_attribute9               No   varchar2  Descriptive Flexfield
--   p_cop_attribute10              No   varchar2  Descriptive Flexfield
--   p_cop_attribute11              No   varchar2  Descriptive Flexfield
--   p_cop_attribute12              No   varchar2  Descriptive Flexfield
--   p_cop_attribute13              No   varchar2  Descriptive Flexfield
--   p_cop_attribute14              No   varchar2  Descriptive Flexfield
--   p_cop_attribute15              No   varchar2  Descriptive Flexfield
--   p_cop_attribute16              No   varchar2  Descriptive Flexfield
--   p_cop_attribute17              No   varchar2  Descriptive Flexfield
--   p_cop_attribute18              No   varchar2  Descriptive Flexfield
--   p_cop_attribute19              No   varchar2  Descriptive Flexfield
--   p_cop_attribute20              No   varchar2  Descriptive Flexfield
--   p_cop_attribute21              No   varchar2  Descriptive Flexfield
--   p_cop_attribute22              No   varchar2  Descriptive Flexfield
--   p_cop_attribute23              No   varchar2  Descriptive Flexfield
--   p_cop_attribute24              No   varchar2  Descriptive Flexfield
--   p_cop_attribute25              No   varchar2  Descriptive Flexfield
--   p_cop_attribute26              No   varchar2  Descriptive Flexfield
--   p_cop_attribute27              No   varchar2  Descriptive Flexfield
--   p_cop_attribute28              No   varchar2  Descriptive Flexfield
--   p_cop_attribute29              No   varchar2  Descriptive Flexfield
--   p_cop_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_oipl_id                      Yes  number    PK of record
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
procedure create_Option_in_Plan
(  p_validate                       in boolean    default false
  ,p_oipl_id                        out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_ivr_ident                      in  varchar2  default null
  ,p_url_ref_name                   in  varchar2  default null
  ,p_opt_id                         in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_ordr_num                       in  number    default null
  ,p_rqd_perd_enrt_nenrt_val                       in  number    default null
  ,p_dflt_flag                      in  varchar2  default 'N'
  ,p_actl_prem_id                   in  number    default null
  ,p_mndtry_flag                    in  varchar2  default 'N'
  ,p_oipl_stat_cd                   in  varchar2  default null
  ,p_pcp_dsgn_cd                    in  varchar2  default null
  ,p_pcp_dpnt_dsgn_cd               in  varchar2  default null
  ,p_rqd_perd_enrt_nenrt_uom                   in  varchar2  default null
  ,p_elig_apls_flag                 in  varchar2  default 'N'
  ,p_dflt_enrt_det_rl               in  number    default null
  ,p_trk_inelig_per_flag            in  varchar2  default 'N'
  ,p_drvbl_fctr_prtn_elig_flag      in  varchar2  default 'N'
  ,p_mndtry_rl                      in  number    default null
  ,p_rqd_perd_enrt_nenrt_rl                      in  number    default null
  ,p_dflt_enrt_cd                   in  varchar2  default null
  ,p_prtn_elig_ovrid_alwd_flag      in  varchar2  default 'N'
  ,p_drvbl_fctr_apls_rts_flag       in  varchar2  default 'N'
  ,p_per_cvrd_cd                    in  varchar2  default null
  ,p_postelcn_edit_rl               in  number    default null
  ,p_vrfy_fmly_mmbr_cd              in  varchar2  default null
  ,p_vrfy_fmly_mmbr_rl              in  number    default null
  ,p_enrt_cd                        in  varchar2  default null
  ,p_enrt_rl                        in  number    default null
  ,p_auto_enrt_flag                 in  varchar2  default null
  ,p_auto_enrt_mthd_rl              in  number    default null
  ,p_short_name			    in  varchar2  default null		/*FHR*/
  ,p_short_code			    in  varchar2  default null		/*FHR*/
    ,p_legislation_code			    in  varchar2  default null		/*FHR*/
    ,p_legislation_subgroup			    in  varchar2  default null		/*FHR*/
  ,p_hidden_flag		    in  varchar2  default 'N'
  ,p_susp_if_ctfn_not_prvd_flag      in  varchar2   default 'Y'
  ,p_ctfn_determine_cd          in  varchar2   default null
  ,p_cop_attribute_category         in  varchar2  default null
  ,p_cop_attribute1                 in  varchar2  default null
  ,p_cop_attribute2                 in  varchar2  default null
  ,p_cop_attribute3                 in  varchar2  default null
  ,p_cop_attribute4                 in  varchar2  default null
  ,p_cop_attribute5                 in  varchar2  default null
  ,p_cop_attribute6                 in  varchar2  default null
  ,p_cop_attribute7                 in  varchar2  default null
  ,p_cop_attribute8                 in  varchar2  default null
  ,p_cop_attribute9                 in  varchar2  default null
  ,p_cop_attribute10                in  varchar2  default null
  ,p_cop_attribute11                in  varchar2  default null
  ,p_cop_attribute12                in  varchar2  default null
  ,p_cop_attribute13                in  varchar2  default null
  ,p_cop_attribute14                in  varchar2  default null
  ,p_cop_attribute15                in  varchar2  default null
  ,p_cop_attribute16                in  varchar2  default null
  ,p_cop_attribute17                in  varchar2  default null
  ,p_cop_attribute18                in  varchar2  default null
  ,p_cop_attribute19                in  varchar2  default null
  ,p_cop_attribute20                in  varchar2  default null
  ,p_cop_attribute21                in  varchar2  default null
  ,p_cop_attribute22                in  varchar2  default null
  ,p_cop_attribute23                in  varchar2  default null
  ,p_cop_attribute24                in  varchar2  default null
  ,p_cop_attribute25                in  varchar2  default null
  ,p_cop_attribute26                in  varchar2  default null
  ,p_cop_attribute27                in  varchar2  default null
  ,p_cop_attribute28                in  varchar2  default null
  ,p_cop_attribute29                in  varchar2  default null
  ,p_cop_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date);
-- ----------------------------------------------------------------------------
-- |------------------------< update_Option_in_Plan >-------------------------|
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
--   p_oipl_id                      Yes  number    PK of record
--   p_ivr_ident                    No   varchar2
--   p_url_ref_name                 No   varchar2
--   p_opt_id                       Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_pl_id                        Yes  number
--   p_ordr_num                     No   number
--   p_rqd_perd_enrt_nenrt_val                     No   number
--   p_dflt_flag                    Yes  varchar2
--   p_actl_prem_id                 No   number
--   p_mndtry_flag                  Yes  varchar2
--   p_oipl_stat_cd                 Yes  varchar2
--   p_pcp_dsgn_cd                  Yes  varchar2
--   p_pcp_dpnt_dsgn_cd             Yes  varchar2
--   p_rqd_perd_enrt_nenrt_uom                 Yes  varchar2
--   p_elig_apls_flag               Yes  varchar2
--   p_dflt_enrt_det_rl             No   number
--   p_trk_inelig_per_flag          Yes  varchar2
--   p_drvbl_fctr_prtn_elig_flag    Yes  varchar2
--   p_mndtry_rl                    No   number
--   p_rqd_perd_enrt_nenrt_rl                    No   number
--   p_dflt_enrt_cd                 No   varchar2
--   p_prtn_elig_ovrid_alwd_flag    Yes  varchar2
--   p_drvbl_fctr_apls_rts_flag     Yes  varchar2
--   p_per_cvrd_cd                  No   varchar2
--   p_postelcn_edit_rl             No   number
--   p_vrfy_fmly_mmbr_cd            No   varchar2
--   p_vrfy_fmly_mmbr_rl            No   number
--   p_enrt_cd                      No   varchar2
--   p_enrt_rl                      No   number
--   p_auto_enrt_flag               No   varchar2
--   p_auto_enrt_mthd_rl            No   number
--   p_short_name		    No   varchar2			 FHR
--   p_short_code      	   	    No   varchar2 			 FHR
--   p_legislation_code      	   	    No   varchar2 			 FHR
--   p_legislation_subgroup      	   	    No   varchar2 			 FHR
--   p_hidden_flag      	    Yes  varchar2
--   p_cop_attribute_category       No   varchar2  Descriptive Flexfield
--   p_cop_attribute1               No   varchar2  Descriptive Flexfield
--   p_cop_attribute2               No   varchar2  Descriptive Flexfield
--   p_cop_attribute3               No   varchar2  Descriptive Flexfield
--   p_cop_attribute4               No   varchar2  Descriptive Flexfield
--   p_cop_attribute5               No   varchar2  Descriptive Flexfield
--   p_cop_attribute6               No   varchar2  Descriptive Flexfield
--   p_cop_attribute7               No   varchar2  Descriptive Flexfield
--   p_cop_attribute8               No   varchar2  Descriptive Flexfield
--   p_cop_attribute9               No   varchar2  Descriptive Flexfield
--   p_cop_attribute10              No   varchar2  Descriptive Flexfield
--   p_cop_attribute11              No   varchar2  Descriptive Flexfield
--   p_cop_attribute12              No   varchar2  Descriptive Flexfield
--   p_cop_attribute13              No   varchar2  Descriptive Flexfield
--   p_cop_attribute14              No   varchar2  Descriptive Flexfield
--   p_cop_attribute15              No   varchar2  Descriptive Flexfield
--   p_cop_attribute16              No   varchar2  Descriptive Flexfield
--   p_cop_attribute17              No   varchar2  Descriptive Flexfield
--   p_cop_attribute18              No   varchar2  Descriptive Flexfield
--   p_cop_attribute19              No   varchar2  Descriptive Flexfield
--   p_cop_attribute20              No   varchar2  Descriptive Flexfield
--   p_cop_attribute21              No   varchar2  Descriptive Flexfield
--   p_cop_attribute22              No   varchar2  Descriptive Flexfield
--   p_cop_attribute23              No   varchar2  Descriptive Flexfield
--   p_cop_attribute24              No   varchar2  Descriptive Flexfield
--   p_cop_attribute25              No   varchar2  Descriptive Flexfield
--   p_cop_attribute26              No   varchar2  Descriptive Flexfield
--   p_cop_attribute27              No   varchar2  Descriptive Flexfield
--   p_cop_attribute28              No   varchar2  Descriptive Flexfield
--   p_cop_attribute29              No   varchar2  Descriptive Flexfield
--   p_cop_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_Option_in_Plan
  (p_validate                       in boolean    default false
  ,p_oipl_id                        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_ivr_ident                      in  varchar2  default hr_api.g_varchar2
  ,p_url_ref_name                   in  varchar2  default hr_api.g_varchar2
  ,p_opt_id                         in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_rqd_perd_enrt_nenrt_val                       in  number    default hr_api.g_number
  ,p_dflt_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_actl_prem_id                   in  number    default hr_api.g_number
  ,p_mndtry_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_oipl_stat_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_pcp_dsgn_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_pcp_dpnt_dsgn_cd               in  varchar2  default hr_api.g_varchar2
  ,p_rqd_perd_enrt_nenrt_uom                   in  varchar2  default hr_api.g_varchar2
  ,p_elig_apls_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_dflt_enrt_det_rl               in  number    default hr_api.g_number
  ,p_trk_inelig_per_flag            in  varchar2  default hr_api.g_varchar2
  ,p_drvbl_fctr_prtn_elig_flag      in  varchar2  default hr_api.g_varchar2
  ,p_mndtry_rl                      in  number    default hr_api.g_number
  ,p_rqd_perd_enrt_nenrt_rl                      in  number    default hr_api.g_number
  ,p_dflt_enrt_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_prtn_elig_ovrid_alwd_flag      in  varchar2  default hr_api.g_varchar2
  ,p_drvbl_fctr_apls_rts_flag       in  varchar2  default hr_api.g_varchar2
  ,p_per_cvrd_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_postelcn_edit_rl               in  number    default hr_api.g_number
  ,p_vrfy_fmly_mmbr_cd              in  varchar2  default hr_api.g_varchar2
  ,p_vrfy_fmly_mmbr_rl              in  number    default hr_api.g_number
  ,p_enrt_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_enrt_rl                        in  number    default hr_api.g_number
  ,p_auto_enrt_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_auto_enrt_mthd_rl              in  number    default hr_api.g_number
  ,p_short_name			    in  varchar2  default hr_api.g_varchar2 	/*FHR*/
  ,p_short_code			    in  varchar2  default hr_api.g_varchar2 	/*FHR*/
    ,p_legislation_code			    in  varchar2  default hr_api.g_varchar2 	/*FHR*/
    ,p_legislation_subgroup			    in  varchar2  default hr_api.g_varchar2 	/*FHR*/
  ,p_hidden_flag		    in  varchar2  default hr_api.g_varchar2
  ,p_susp_if_ctfn_not_prvd_flag      in  varchar2   default hr_api.g_varchar2
  ,p_ctfn_determine_cd          in  varchar2   default hr_api.g_varchar2
  ,p_cop_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2);
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Option_in_Plan >-------------------------|
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
--   p_oipl_id                      Yes  number    PK of record
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
procedure delete_Option_in_Plan
  (p_validate                       in boolean        default false
  ,p_oipl_id                        in  number
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
--   p_oipl_id                 Yes  number   PK of record
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
  (p_oipl_id                 in number
  ,p_object_version_number   in number
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   out nocopy date
  ,p_validation_end_date     out nocopy date);
--
end ben_Option_in_Plan_api;

 

/
