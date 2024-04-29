--------------------------------------------------------
--  DDL for Package BEN_ACTUAL_PREMIUM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ACTUAL_PREMIUM_API" AUTHID CURRENT_USER as
/* $Header: beaprapi.pkh 120.0 2005/05/28 00:26:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_actual_premium >------------------------|
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
--   p_acty_ref_perd_cd             Yes  varchar2
--   p_uom                          Yes  varchar2
--   p_rt_typ_cd                    No   varchar2
--   p_bnft_rt_typ_cd               No   varchar2
--   p_val                          No   number
--   p_mlt_cd                       No   varchar2
--   p_prdct_cd                     No   varchar2
--   p_rndg_cd                      No   varchar2
--   p_rndg_rl                      No   number
--   p_val_calc_rl                  No   number
--   p_prem_asnmt_cd                No   varchar2
--   p_prem_asnmt_lvl_cd            No   varchar2
--   p_actl_prem_typ_cd             No   varchar2
--   p_prem_pyr_cd                  No   varchar2
--   p_cr_lkbk_val                  No   number
--   p_cr_lkbk_uom                  No   varchar2
--   p_cr_lkbk_crnt_py_only_flag    Yes  varchar2
--   p_prsptv_r_rtsptv_cd           No   varchar2
--   p_upr_lmt_val                  No   number
--   p_upr_lmt_calc_rl              No   number
--   p_lwr_lmt_val                  No   number
--   p_lwr_lmt_calc_rl              No   number
--   p_cost_allocation_keyflex_id   No   number
--   p_organization_id              No   number
--   p_oipl_id                      No   number
--   p_pl_id                        No   number
--   p_comp_lvl_fctr_id             No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_apr_attribute_category       No   varchar2  Descriptive Flexfield
--   p_apr_attribute1               No   varchar2  Descriptive Flexfield
--   p_apr_attribute2               No   varchar2  Descriptive Flexfield
--   p_apr_attribute3               No   varchar2  Descriptive Flexfield
--   p_apr_attribute4               No   varchar2  Descriptive Flexfield
--   p_apr_attribute5               No   varchar2  Descriptive Flexfield
--   p_apr_attribute6               No   varchar2  Descriptive Flexfield
--   p_apr_attribute7               No   varchar2  Descriptive Flexfield
--   p_apr_attribute8               No   varchar2  Descriptive Flexfield
--   p_apr_attribute9               No   varchar2  Descriptive Flexfield
--   p_apr_attribute10              No   varchar2  Descriptive Flexfield
--   p_apr_attribute11              No   varchar2  Descriptive Flexfield
--   p_apr_attribute12              No   varchar2  Descriptive Flexfield
--   p_apr_attribute13              No   varchar2  Descriptive Flexfield
--   p_apr_attribute14              No   varchar2  Descriptive Flexfield
--   p_apr_attribute15              No   varchar2  Descriptive Flexfield
--   p_apr_attribute16              No   varchar2  Descriptive Flexfield
--   p_apr_attribute17              No   varchar2  Descriptive Flexfield
--   p_apr_attribute18              No   varchar2  Descriptive Flexfield
--   p_apr_attribute19              No   varchar2  Descriptive Flexfield
--   p_apr_attribute20              No   varchar2  Descriptive Flexfield
--   p_apr_attribute21              No   varchar2  Descriptive Flexfield
--   p_apr_attribute22              No   varchar2  Descriptive Flexfield
--   p_apr_attribute23              No   varchar2  Descriptive Flexfield
--   p_apr_attribute24              No   varchar2  Descriptive Flexfield
--   p_apr_attribute25              No   varchar2  Descriptive Flexfield
--   p_apr_attribute26              No   varchar2  Descriptive Flexfield
--   p_apr_attribute27              No   varchar2  Descriptive Flexfield
--   p_apr_attribute28              No   varchar2  Descriptive Flexfield
--   p_apr_attribute29              No   varchar2  Descriptive Flexfield
--   p_apr_attribute30              No   varchar2  Descriptive Flexfield
--   p_prtl_mo_det_mthd_cd          No   varchar2
--   p_prtl_mo_det_mthd_rl          No   number
--   p_wsh_rl_dy_mo_num             No   number
--   p_vrbl_rt_add_on_calc_rl       No   number
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_actl_prem_id                 Yes  number    PK of record
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
procedure create_actual_premium
(
   p_validate                       in boolean    default false
  ,p_actl_prem_id                   out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default null
  ,p_acty_ref_perd_cd               in  varchar2  default null
  ,p_uom                            in  varchar2  default null
  ,p_rt_typ_cd                      in  varchar2  default null
  ,p_bnft_rt_typ_cd                 in  varchar2  default null
  ,p_val                            in  number    default null
  ,p_mlt_cd                         in  varchar2  default null
  ,p_prdct_cd                       in  varchar2  default null
  ,p_rndg_cd                        in  varchar2  default null
  ,p_rndg_rl                        in  number    default null
  ,p_val_calc_rl                    in  number    default null
  ,p_prem_asnmt_cd                  in  varchar2  default null
  ,p_prem_asnmt_lvl_cd              in  varchar2  default null
  ,p_actl_prem_typ_cd               in  varchar2  default null
  ,p_prem_pyr_cd                    in  varchar2  default null
  ,p_cr_lkbk_val                    in  number    default null
  ,p_cr_lkbk_uom                    in  varchar2  default null
  ,p_cr_lkbk_crnt_py_only_flag      in  varchar2  default null
  ,p_prsptv_r_rtsptv_cd             in  varchar2  default null
  ,p_upr_lmt_val                    in  number    default null
  ,p_upr_lmt_calc_rl                in  number    default null
  ,p_lwr_lmt_val                    in  number    default null
  ,p_lwr_lmt_calc_rl                in  number    default null
  ,p_cost_allocation_keyflex_id     in  number    default null
  ,p_organization_id                in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_comp_lvl_fctr_id               in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_apr_attribute_category         in  varchar2  default null
  ,p_apr_attribute1                 in  varchar2  default null
  ,p_apr_attribute2                 in  varchar2  default null
  ,p_apr_attribute3                 in  varchar2  default null
  ,p_apr_attribute4                 in  varchar2  default null
  ,p_apr_attribute5                 in  varchar2  default null
  ,p_apr_attribute6                 in  varchar2  default null
  ,p_apr_attribute7                 in  varchar2  default null
  ,p_apr_attribute8                 in  varchar2  default null
  ,p_apr_attribute9                 in  varchar2  default null
  ,p_apr_attribute10                in  varchar2  default null
  ,p_apr_attribute11                in  varchar2  default null
  ,p_apr_attribute12                in  varchar2  default null
  ,p_apr_attribute13                in  varchar2  default null
  ,p_apr_attribute14                in  varchar2  default null
  ,p_apr_attribute15                in  varchar2  default null
  ,p_apr_attribute16                in  varchar2  default null
  ,p_apr_attribute17                in  varchar2  default null
  ,p_apr_attribute18                in  varchar2  default null
  ,p_apr_attribute19                in  varchar2  default null
  ,p_apr_attribute20                in  varchar2  default null
  ,p_apr_attribute21                in  varchar2  default null
  ,p_apr_attribute22                in  varchar2  default null
  ,p_apr_attribute23                in  varchar2  default null
  ,p_apr_attribute24                in  varchar2  default null
  ,p_apr_attribute25                in  varchar2  default null
  ,p_apr_attribute26                in  varchar2  default null
  ,p_apr_attribute27                in  varchar2  default null
  ,p_apr_attribute28                in  varchar2  default null
  ,p_apr_attribute29                in  varchar2  default null
  ,p_apr_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_prtl_mo_det_mthd_cd            in  varchar2  default null
  ,p_prtl_mo_det_mthd_rl            in  number    default null
  ,p_wsh_rl_dy_mo_num               in  number    default null
  ,p_vrbl_rt_add_on_calc_rl         in  number    default null
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_actual_premium >------------------------|
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
--   p_actl_prem_id                 Yes  number    PK of record
--   p_name                         Yes  varchar2
--   p_acty_ref_perd_cd             Yes  varchar2
--   p_uom                          Yes  varchar2
--   p_rt_typ_cd                    No   varchar2
--   p_bnft_rt_typ_cd               No   varchar2
--   p_val                          No   number
--   p_mlt_cd                       No   varchar2
--   p_prdct_cd                     No   varchar2
--   p_rndg_cd                      No   varchar2
--   p_rndg_rl                      No   number
--   p_val_calc_rl                  No   number
--   p_prem_asnmt_cd                No   varchar2
--   p_prem_asnmt_lvl_cd            No   varchar2
--   p_actl_prem_typ_cd             No   varchar2
--   p_prem_pyr_cd                  No   varchar2
--   p_cr_lkbk_val                  No   number
--   p_cr_lkbk_uom                  No   varchar2
--   p_cr_lkbk_crnt_py_only_flag    Yes  varchar2
--   p_prsptv_r_rtsptv_cd           No   varchar2
--   p_upr_lmt_val                  No   number
--   p_upr_lmt_calc_rl              No   number
--   p_lwr_lmt_val                  No   number
--   p_lwr_lmt_calc_rl              No   number
--   p_cost_allocation_keyflex_id   No   number
--   p_organization_id              No   number
--   p_oipl_id                      No   number
--   p_pl_id                        No   number
--   p_comp_lvl_fctr_id             No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_apr_attribute_category       No   varchar2  Descriptive Flexfield
--   p_apr_attribute1               No   varchar2  Descriptive Flexfield
--   p_apr_attribute2               No   varchar2  Descriptive Flexfield
--   p_apr_attribute3               No   varchar2  Descriptive Flexfield
--   p_apr_attribute4               No   varchar2  Descriptive Flexfield
--   p_apr_attribute5               No   varchar2  Descriptive Flexfield
--   p_apr_attribute6               No   varchar2  Descriptive Flexfield
--   p_apr_attribute7               No   varchar2  Descriptive Flexfield
--   p_apr_attribute8               No   varchar2  Descriptive Flexfield
--   p_apr_attribute9               No   varchar2  Descriptive Flexfield
--   p_apr_attribute10              No   varchar2  Descriptive Flexfield
--   p_apr_attribute11              No   varchar2  Descriptive Flexfield
--   p_apr_attribute12              No   varchar2  Descriptive Flexfield
--   p_apr_attribute13              No   varchar2  Descriptive Flexfield
--   p_apr_attribute14              No   varchar2  Descriptive Flexfield
--   p_apr_attribute15              No   varchar2  Descriptive Flexfield
--   p_apr_attribute16              No   varchar2  Descriptive Flexfield
--   p_apr_attribute17              No   varchar2  Descriptive Flexfield
--   p_apr_attribute18              No   varchar2  Descriptive Flexfield
--   p_apr_attribute19              No   varchar2  Descriptive Flexfield
--   p_apr_attribute20              No   varchar2  Descriptive Flexfield
--   p_apr_attribute21              No   varchar2  Descriptive Flexfield
--   p_apr_attribute22              No   varchar2  Descriptive Flexfield
--   p_apr_attribute23              No   varchar2  Descriptive Flexfield
--   p_apr_attribute24              No   varchar2  Descriptive Flexfield
--   p_apr_attribute25              No   varchar2  Descriptive Flexfield
--   p_apr_attribute26              No   varchar2  Descriptive Flexfield
--   p_apr_attribute27              No   varchar2  Descriptive Flexfield
--   p_apr_attribute28              No   varchar2  Descriptive Flexfield
--   p_apr_attribute29              No   varchar2  Descriptive Flexfield
--   p_apr_attribute30              No   varchar2  Descriptive Flexfield
--   p_prtl_mo_det_mthd_cd          No   varchar2
--   p_prtl_mo_det_mthd_rl          No   number
--   p_wsh_rl_dy_mo_num             No   number
--   p_vrbl_rt_add_on_calc_rl       No   number
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
procedure update_actual_premium
  (
   p_validate                       in boolean    default false
  ,p_actl_prem_id                   in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_acty_ref_perd_cd               in  varchar2  default hr_api.g_varchar2
  ,p_uom                            in  varchar2  default hr_api.g_varchar2
  ,p_rt_typ_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_bnft_rt_typ_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_val                            in  number    default hr_api.g_number
  ,p_mlt_cd                         in  varchar2  default hr_api.g_varchar2
  ,p_prdct_cd                       in  varchar2  default hr_api.g_varchar2
  ,p_rndg_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_rndg_rl                        in  number    default hr_api.g_number
  ,p_val_calc_rl                    in  number    default hr_api.g_number
  ,p_prem_asnmt_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_prem_asnmt_lvl_cd              in  varchar2  default hr_api.g_varchar2
  ,p_actl_prem_typ_cd               in  varchar2  default hr_api.g_varchar2
  ,p_prem_pyr_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_cr_lkbk_val                    in  number    default hr_api.g_number
  ,p_cr_lkbk_uom                    in  varchar2  default hr_api.g_varchar2
  ,p_cr_lkbk_crnt_py_only_flag      in  varchar2  default hr_api.g_varchar2
  ,p_prsptv_r_rtsptv_cd             in  varchar2  default hr_api.g_varchar2
  ,p_upr_lmt_val                    in  number    default hr_api.g_number
  ,p_upr_lmt_calc_rl                in  number    default hr_api.g_number
  ,p_lwr_lmt_val                    in  number    default hr_api.g_number
  ,p_lwr_lmt_calc_rl                in  number    default hr_api.g_number
  ,p_cost_allocation_keyflex_id     in  number    default hr_api.g_number
  ,p_organization_id                in  number    default hr_api.g_number
  ,p_oipl_id                        in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_comp_lvl_fctr_id               in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_apr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_prtl_mo_det_mthd_cd            in  varchar2  default hr_api.g_varchar2
  ,p_prtl_mo_det_mthd_rl            in  number    default hr_api.g_number
  ,p_wsh_rl_dy_mo_num               in  number    default hr_api.g_number
  ,p_vrbl_rt_add_on_calc_rl         in  number    default hr_api.g_number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_actual_premium >------------------------|
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
--   p_actl_prem_id                 Yes  number    PK of record
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
procedure delete_actual_premium
  (
   p_validate                       in boolean        default false
  ,p_actl_prem_id                   in  number
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
--   p_actl_prem_id                 Yes  number   PK of record
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
    p_actl_prem_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end ben_actual_premium_api;

 

/
