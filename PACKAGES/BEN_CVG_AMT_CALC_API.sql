--------------------------------------------------------
--  DDL for Package BEN_CVG_AMT_CALC_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CVG_AMT_CALC_API" AUTHID CURRENT_USER as
/* $Header: beccmapi.pkh 120.0 2005/05/28 00:57:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_Cvg_Amt_Calc >------------------------|
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
-- --p_cvg_det_cd                   No   varchar2
--   p_incrmt_val                   No   number
--   p_mx_val                       No   number
--   p_mn_val                       No   number
--   p_no_mx_val_dfnd_flag          Yes  varchar2
--   p_no_mn_val_dfnd_flag          Yes  varchar2
--   p_rndg_cd                      No   varchar2
--   p_rndg_rl                      No   number
--   p_lwr_lmt_val                  No   number
--   p_lwr_lmt_calc_rl              No   number
--   p_upr_lmt_val                  No   number
--   p_upr_lmt_calc_rl              No   number
--   p_val                          No   number
--   p_val_ovrid_alwd_flag          Yes  varchar2
--   p_val_calc_rl                  No   number
--   p_uom                          No   varchar2
--   p_nnmntry_uom                  No   varchar2
--   p_bndry_perd_cd                No   varchar2
--   p_bnft_typ_cd                  No   varchar2
--   p_cvg_mlt_cd                   No   varchar2
--   p_rt_typ_cd                    No   varchar2
--   p_dflt_val                     No   number
--   p_entr_val_at_enrt_flag        Yes  varchar2
--   p_dflt_flag                    Yes  varchar2
--   p_comp_lvl_fctr_id             No   number
--   p_oipl_id                      No   number
--   p_pl_id                        No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_ccm_attribute_category       No   varchar2  Descriptive Flexfield
--   p_ccm_attribute1               No   varchar2  Descriptive Flexfield
--   p_ccm_attribute2               No   varchar2  Descriptive Flexfield
--   p_ccm_attribute3               No   varchar2  Descriptive Flexfield
--   p_ccm_attribute4               No   varchar2  Descriptive Flexfield
--   p_ccm_attribute5               No   varchar2  Descriptive Flexfield
--   p_ccm_attribute6               No   varchar2  Descriptive Flexfield
--   p_ccm_attribute7               No   varchar2  Descriptive Flexfield
--   p_ccm_attribute8               No   varchar2  Descriptive Flexfield
--   p_ccm_attribute9               No   varchar2  Descriptive Flexfield
--   p_ccm_attribute10              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute11              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute12              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute13              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute14              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute15              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute16              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute17              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute18              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute19              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute20              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute21              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute22              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute23              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute24              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute25              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute26              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute27              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute28              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute29              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_cvg_amt_calc_mthd_id         Yes  number    PK of record
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
procedure create_Cvg_Amt_Calc
  (p_validate                       in boolean    default false
  ,p_cvg_amt_calc_mthd_id           out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default null
  ,p_incrmt_val                     in  number    default null
  ,p_mx_val                         in  number    default null
  ,p_mn_val                         in  number    default null
  ,p_no_mx_val_dfnd_flag            in  varchar2  default null
  ,p_no_mn_val_dfnd_flag            in  varchar2  default null
  ,p_rndg_cd                        in  varchar2  default null
  ,p_rndg_rl                        in  number    default null
  ,p_lwr_lmt_val                    in  number    default null
  ,p_lwr_lmt_calc_rl                in  number    default null
  ,p_upr_lmt_val                    in  number    default null
  ,p_upr_lmt_calc_rl                in  number    default null
  ,p_val                            in  number    default null
  ,p_val_ovrid_alwd_flag            in  varchar2  default null
  ,p_val_calc_rl                    in  number    default null
  ,p_uom                            in  varchar2  default null
  ,p_nnmntry_uom                    in  varchar2  default null
  ,p_bndry_perd_cd                  in  varchar2  default null
  ,p_bnft_typ_cd                    in  varchar2  default null
  ,p_cvg_mlt_cd                     in  varchar2  default null
  ,p_rt_typ_cd                      in  varchar2  default null
  ,p_dflt_val                       in  number    default null
  ,p_entr_val_at_enrt_flag          in  varchar2  default null
  ,p_dflt_flag                      in  varchar2  default null
  ,p_comp_lvl_fctr_id               in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_plip_id                        in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_ccm_attribute_category         in  varchar2  default null
  ,p_ccm_attribute1                 in  varchar2  default null
  ,p_ccm_attribute2                 in  varchar2  default null
  ,p_ccm_attribute3                 in  varchar2  default null
  ,p_ccm_attribute4                 in  varchar2  default null
  ,p_ccm_attribute5                 in  varchar2  default null
  ,p_ccm_attribute6                 in  varchar2  default null
  ,p_ccm_attribute7                 in  varchar2  default null
  ,p_ccm_attribute8                 in  varchar2  default null
  ,p_ccm_attribute9                 in  varchar2  default null
  ,p_ccm_attribute10                in  varchar2  default null
  ,p_ccm_attribute11                in  varchar2  default null
  ,p_ccm_attribute12                in  varchar2  default null
  ,p_ccm_attribute13                in  varchar2  default null
  ,p_ccm_attribute14                in  varchar2  default null
  ,p_ccm_attribute15                in  varchar2  default null
  ,p_ccm_attribute16                in  varchar2  default null
  ,p_ccm_attribute17                in  varchar2  default null
  ,p_ccm_attribute18                in  varchar2  default null
  ,p_ccm_attribute19                in  varchar2  default null
  ,p_ccm_attribute20                in  varchar2  default null
  ,p_ccm_attribute21                in  varchar2  default null
  ,p_ccm_attribute22                in  varchar2  default null
  ,p_ccm_attribute23                in  varchar2  default null
  ,p_ccm_attribute24                in  varchar2  default null
  ,p_ccm_attribute25                in  varchar2  default null
  ,p_ccm_attribute26                in  varchar2  default null
  ,p_ccm_attribute27                in  varchar2  default null
  ,p_ccm_attribute28                in  varchar2  default null
  ,p_ccm_attribute29                in  varchar2  default null
  ,p_ccm_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date);
-- ----------------------------------------------------------------------------
-- |------------------------< update_Cvg_Amt_Calc >---------------------------|
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
--   p_cvg_amt_calc_mthd_id         Yes  number    PK of record
--   p_name                         Yes  varchar2
-- --p_cvg_det_cd                   No   varchar2
--   p_incrmt_val                   No   number
--   p_mx_val                       No   number
--   p_mn_val                       No   number
--   p_no_mx_val_dfnd_flag          Yes  varchar2
--   p_no_mn_val_dfnd_flag          Yes  varchar2
--   p_rndg_cd                      No   varchar2
--   p_rndg_rl                      No   number
--   p_lwr_lmt_val                  No   number
--   p_lwr_lmt_calc_rl              No   number
--   p_upr_lmt_val                  No   number
--   p_upr_lmt_calc_rl              No   number
--   p_val                          No   number
--   p_val_ovrid_alwd_flag          Yes  varchar2
--   p_val_calc_rl                  No   number
--   p_uom                          No   varchar2
--   p_nnmntry_uom                  No   varchar2
--   p_bndry_perd_cd                No   varchar2
--   p_bnft_typ_cd                  No   varchar2
--   p_cvg_mlt_cd                   No   varchar2
--   p_rt_typ_cd                    No   varchar2
--   p_dflt_val                     No   number
--   p_entr_val_at_enrt_flag        No   varchar2
--   p_dflt_flag                    No   varchar2
--   p_comp_lvl_fctr_id             No   number
--   p_oipl_id                      No   number
--   p_pl_id                        No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_ccm_attribute_category       No   varchar2  Descriptive Flexfield
--   p_ccm_attribute1               No   varchar2  Descriptive Flexfield
--   p_ccm_attribute2               No   varchar2  Descriptive Flexfield
--   p_ccm_attribute3               No   varchar2  Descriptive Flexfield
--   p_ccm_attribute4               No   varchar2  Descriptive Flexfield
--   p_ccm_attribute5               No   varchar2  Descriptive Flexfield
--   p_ccm_attribute6               No   varchar2  Descriptive Flexfield
--   p_ccm_attribute7               No   varchar2  Descriptive Flexfield
--   p_ccm_attribute8               No   varchar2  Descriptive Flexfield
--   p_ccm_attribute9               No   varchar2  Descriptive Flexfield
--   p_ccm_attribute10              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute11              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute12              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute13              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute14              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute15              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute16              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute17              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute18              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute19              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute20              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute21              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute22              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute23              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute24              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute25              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute26              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute27              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute28              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute29              No   varchar2  Descriptive Flexfield
--   p_ccm_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_Cvg_Amt_Calc
  (p_validate                       in boolean    default false
  ,p_cvg_amt_calc_mthd_id           in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_incrmt_val                     in  number    default hr_api.g_number
  ,p_mx_val                         in  number    default hr_api.g_number
  ,p_mn_val                         in  number    default hr_api.g_number
  ,p_no_mx_val_dfnd_flag            in  varchar2  default hr_api.g_varchar2
  ,p_no_mn_val_dfnd_flag            in  varchar2  default hr_api.g_varchar2
  ,p_rndg_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_rndg_rl                        in  number    default hr_api.g_number
  ,p_lwr_lmt_val                    in  number    default hr_api.g_number
  ,p_lwr_lmt_calc_rl                in  number    default hr_api.g_number
  ,p_upr_lmt_val                    in  number    default hr_api.g_number
  ,p_upr_lmt_calc_rl                in  number    default hr_api.g_number
  ,p_val                            in  number    default hr_api.g_number
  ,p_val_ovrid_alwd_flag            in  varchar2  default hr_api.g_varchar2
  ,p_val_calc_rl                    in  number    default hr_api.g_number
  ,p_uom                            in  varchar2  default hr_api.g_varchar2
  ,p_nnmntry_uom                    in  varchar2  default hr_api.g_varchar2
  ,p_bndry_perd_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_bnft_typ_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_cvg_mlt_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_rt_typ_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_dflt_val                       in  number    default hr_api.g_number
  ,p_entr_val_at_enrt_flag          in  varchar2  default hr_api.g_varchar2
  ,p_dflt_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_comp_lvl_fctr_id               in  number    default hr_api.g_number
  ,p_oipl_id                        in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_plip_id                        in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_ccm_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2);
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Cvg_Amt_Calc >---------------------------|
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
--   p_cvg_amt_calc_mthd_id         Yes  number    PK of record
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
procedure delete_Cvg_Amt_Calc
  (p_validate                       in boolean        default false
  ,p_cvg_amt_calc_mthd_id           in  number
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
--   p_cvg_amt_calc_mthd_id                 Yes  number   PK of record
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
   (p_cvg_amt_calc_mthd_id        in  number
   ,p_object_version_number       in  number
   ,p_effective_date              in  date
   ,p_datetrack_mode              in  varchar2
   ,p_validation_start_date       out nocopy date
   ,p_validation_end_date         out nocopy date);
--
end ben_Cvg_Amt_Calc_api;

 

/
