--------------------------------------------------------
--  DDL for Package BEN_ELIG_TO_PRTE_REASON_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_TO_PRTE_REASON_API" AUTHID CURRENT_USER as
/* $Header: bepeoapi.pkh 120.0 2005/05/28 10:37:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_ELIG_TO_PRTE_REASON >----------------------|
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
--   p_ler_id                       Yes  number
--   p_oipl_id                      No   number
--   p_pgm_id                       No   number
--   p_pl_id                        No   number
--   p_ignr_prtn_ovrid_flag         Yes  varchar2
--   p_elig_inelig_cd               Yes  varchar2
--   p_prtn_eff_strt_dt_cd          No   varchar2
--   p_prtn_eff_strt_dt_rl          No   number
--   p_prtn_eff_end_dt_cd           No   varchar2
--   p_prtn_eff_end_dt_rl           No   number
--   p_wait_perd_dt_to_use_cd       No   varchar2
--   p_wait_perd_dt_to_use_rl       no   number
--   p_wait_perd_val                no   number
--   p_wait_perd_uom                no   varchar2
--   p_wait_perd_rl                 no   number
--   p_mx_poe_det_dt_cd             no   varchar2
--   p_mx_poe_det_dt_rl             no   number
--   p_mx_poe_val                   no   number
--   p_mx_poe_uom                   no   varchar2
--   p_mx_poe_rl                    no   number
--   p_mx_poe_apls_cd               no   varchar2
--   p_prtn_ovridbl_flag            Yes  varchar2
--   p_vrfy_fmly_mmbr_cd            No   varchar2
--   p_vrfy_fmly_mmbr_rl            No   varchar2
--   p_peo_attribute_category       No   varchar2  Descriptive Flexfield
--   p_peo_attribute1               No   varchar2  Descriptive Flexfield
--   p_peo_attribute2               No   varchar2  Descriptive Flexfield
--   p_peo_attribute3               No   varchar2  Descriptive Flexfield
--   p_peo_attribute4               No   varchar2  Descriptive Flexfield
--   p_peo_attribute5               No   varchar2  Descriptive Flexfield
--   p_peo_attribute6               No   varchar2  Descriptive Flexfield
--   p_peo_attribute7               No   varchar2  Descriptive Flexfield
--   p_peo_attribute8               No   varchar2  Descriptive Flexfield
--   p_peo_attribute9               No   varchar2  Descriptive Flexfield
--   p_peo_attribute10              No   varchar2  Descriptive Flexfield
--   p_peo_attribute11              No   varchar2  Descriptive Flexfield
--   p_peo_attribute12              No   varchar2  Descriptive Flexfield
--   p_peo_attribute13              No   varchar2  Descriptive Flexfield
--   p_peo_attribute14              No   varchar2  Descriptive Flexfield
--   p_peo_attribute15              No   varchar2  Descriptive Flexfield
--   p_peo_attribute16              No   varchar2  Descriptive Flexfield
--   p_peo_attribute17              No   varchar2  Descriptive Flexfield
--   p_peo_attribute18              No   varchar2  Descriptive Flexfield
--   p_peo_attribute19              No   varchar2  Descriptive Flexfield
--   p_peo_attribute20              No   varchar2  Descriptive Flexfield
--   p_peo_attribute21              No   varchar2  Descriptive Flexfield
--   p_peo_attribute22              No   varchar2  Descriptive Flexfield
--   p_peo_attribute23              No   varchar2  Descriptive Flexfield
--   p_peo_attribute24              No   varchar2  Descriptive Flexfield
--   p_peo_attribute25              No   varchar2  Descriptive Flexfield
--   p_peo_attribute26              No   varchar2  Descriptive Flexfield
--   p_peo_attribute27              No   varchar2  Descriptive Flexfield
--   p_peo_attribute28              No   varchar2  Descriptive Flexfield
--   p_peo_attribute29              No   varchar2  Descriptive Flexfield
--   p_peo_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_elig_to_prte_rsn_id          Yes  number    PK of record
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
procedure create_ELIG_TO_PRTE_REASON
  (p_validate                       in boolean    default false
  ,p_elig_to_prte_rsn_id            out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_plip_id                        in  number    default null
  ,p_ignr_prtn_ovrid_flag           in  varchar2  default null
  ,p_elig_inelig_cd                 in  varchar2  default null
  ,p_prtn_eff_strt_dt_cd            in  varchar2  default null
  ,p_prtn_eff_strt_dt_rl            in  number    default null
  ,p_prtn_eff_end_dt_cd             in  varchar2  default null
  ,p_prtn_eff_end_dt_rl             in  number    default null
  ,p_wait_perd_dt_to_use_cd         in  varchar2  default null
  ,p_wait_perd_dt_to_use_rl         in  number    default null
  ,p_wait_perd_val                  in  number    default null
  ,p_wait_perd_uom                  in  varchar2  default null
  ,p_wait_perd_rl                   in  number    default null
  ,p_mx_poe_det_dt_cd               in  varchar2  default null
  ,p_mx_poe_det_dt_rl               in  number    default null
  ,p_mx_poe_val                     in  number    default null
  ,p_mx_poe_uom                     in  varchar2  default null
  ,p_mx_poe_rl                      in  number    default null
  ,p_mx_poe_apls_cd                 in  varchar2  default null
  ,p_prtn_ovridbl_flag              in  varchar2  default null
  ,p_vrfy_fmly_mmbr_cd              in  varchar2  default null
  ,p_vrfy_fmly_mmbr_rl              in  number    default null
  ,p_peo_attribute_category         in  varchar2  default null
  ,p_peo_attribute1                 in  varchar2  default null
  ,p_peo_attribute2                 in  varchar2  default null
  ,p_peo_attribute3                 in  varchar2  default null
  ,p_peo_attribute4                 in  varchar2  default null
  ,p_peo_attribute5                 in  varchar2  default null
  ,p_peo_attribute6                 in  varchar2  default null
  ,p_peo_attribute7                 in  varchar2  default null
  ,p_peo_attribute8                 in  varchar2  default null
  ,p_peo_attribute9                 in  varchar2  default null
  ,p_peo_attribute10                in  varchar2  default null
  ,p_peo_attribute11                in  varchar2  default null
  ,p_peo_attribute12                in  varchar2  default null
  ,p_peo_attribute13                in  varchar2  default null
  ,p_peo_attribute14                in  varchar2  default null
  ,p_peo_attribute15                in  varchar2  default null
  ,p_peo_attribute16                in  varchar2  default null
  ,p_peo_attribute17                in  varchar2  default null
  ,p_peo_attribute18                in  varchar2  default null
  ,p_peo_attribute19                in  varchar2  default null
  ,p_peo_attribute20                in  varchar2  default null
  ,p_peo_attribute21                in  varchar2  default null
  ,p_peo_attribute22                in  varchar2  default null
  ,p_peo_attribute23                in  varchar2  default null
  ,p_peo_attribute24                in  varchar2  default null
  ,p_peo_attribute25                in  varchar2  default null
  ,p_peo_attribute26                in  varchar2  default null
  ,p_peo_attribute27                in  varchar2  default null
  ,p_peo_attribute28                in  varchar2  default null
  ,p_peo_attribute29                in  varchar2  default null
  ,p_peo_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date);
-- ----------------------------------------------------------------------------
-- |----------------------< update_ELIG_TO_PRTE_REASON >----------------------|
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
--   p_elig_to_prte_rsn_id          Yes  number    PK of record
--   p_business_group_id            Yes  number    Business Group of Record
--   p_ler_id                       Yes  number
--   p_oipl_id                      No   number
--   p_pgm_id                       No   number
--   p_pl_id                        No   number
--   p_ignr_prtn_ovrid_flag         Yes  varchar2
--   p_elig_inelig_cd               Yes  varchar2
--   p_prtn_eff_strt_dt_cd          No   varchar2
--   p_prtn_eff_strt_dt_rl          No   number
--   p_prtn_eff_end_dt_cd           No   varchar2
--   p_prtn_eff_end_dt_rl           No   number
--   p_wait_perd_dt_to_use_cd       No   varchar2
--   p_wait_perd_dt_to_use_rl       no   number
--   p_wait_perd_val                no   number
--   p_wait_perd_uom                no   varchar2
--   p_wait_perd_rl                 no   number
--   p_mx_poe_det_dt_cd             no   varchar2
--   p_mx_poe_det_dt_rl             no   number
--   p_mx_poe_val                   no   number
--   p_mx_poe_uom                   no   varchar2
--   p_mx_poe_rl                    no   number
--   p_mx_poe_apls_cd               no   varchar2
--   p_prtn_ovridbl_flag            Yes  varchar2
--   p_vrfy_fmly_mmbr_cd            No   varchar2
--   p_vrfy_fmly_mmbr_rl            No   number
--   p_peo_attribute_category       No   varchar2  Descriptive Flexfield
--   p_peo_attribute1               No   varchar2  Descriptive Flexfield
--   p_peo_attribute2               No   varchar2  Descriptive Flexfield
--   p_peo_attribute3               No   varchar2  Descriptive Flexfield
--   p_peo_attribute4               No   varchar2  Descriptive Flexfield
--   p_peo_attribute5               No   varchar2  Descriptive Flexfield
--   p_peo_attribute6               No   varchar2  Descriptive Flexfield
--   p_peo_attribute7               No   varchar2  Descriptive Flexfield
--   p_peo_attribute8               No   varchar2  Descriptive Flexfield
--   p_peo_attribute9               No   varchar2  Descriptive Flexfield
--   p_peo_attribute10              No   varchar2  Descriptive Flexfield
--   p_peo_attribute11              No   varchar2  Descriptive Flexfield
--   p_peo_attribute12              No   varchar2  Descriptive Flexfield
--   p_peo_attribute13              No   varchar2  Descriptive Flexfield
--   p_peo_attribute14              No   varchar2  Descriptive Flexfield
--   p_peo_attribute15              No   varchar2  Descriptive Flexfield
--   p_peo_attribute16              No   varchar2  Descriptive Flexfield
--   p_peo_attribute17              No   varchar2  Descriptive Flexfield
--   p_peo_attribute18              No   varchar2  Descriptive Flexfield
--   p_peo_attribute19              No   varchar2  Descriptive Flexfield
--   p_peo_attribute20              No   varchar2  Descriptive Flexfield
--   p_peo_attribute21              No   varchar2  Descriptive Flexfield
--   p_peo_attribute22              No   varchar2  Descriptive Flexfield
--   p_peo_attribute23              No   varchar2  Descriptive Flexfield
--   p_peo_attribute24              No   varchar2  Descriptive Flexfield
--   p_peo_attribute25              No   varchar2  Descriptive Flexfield
--   p_peo_attribute26              No   varchar2  Descriptive Flexfield
--   p_peo_attribute27              No   varchar2  Descriptive Flexfield
--   p_peo_attribute28              No   varchar2  Descriptive Flexfield
--   p_peo_attribute29              No   varchar2  Descriptive Flexfield
--   p_peo_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_ELIG_TO_PRTE_REASON
  (p_validate                       in boolean    default false
  ,p_elig_to_prte_rsn_id            in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_oipl_id                        in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_ptip_id                        in  number    default hr_api.g_number
  ,p_plip_id                        in  number    default hr_api.g_number
  ,p_ignr_prtn_ovrid_flag           in  varchar2  default hr_api.g_varchar2
  ,p_elig_inelig_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_prtn_eff_strt_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_prtn_eff_strt_dt_rl            in  number    default hr_api.g_number
  ,p_prtn_eff_end_dt_cd             in  varchar2  default hr_api.g_varchar2
  ,p_prtn_eff_end_dt_rl             in  number    default hr_api.g_number
  ,p_wait_perd_dt_to_use_cd         in  varchar2  default hr_api.g_varchar2
  ,p_wait_perd_dt_to_use_rl         in  number    default hr_api.g_number
  ,p_wait_perd_val                  in  number    default hr_api.g_number
  ,p_wait_perd_uom                  in  varchar2  default hr_api.g_varchar2
  ,p_wait_perd_rl                   in  number    default hr_api.g_number
  ,p_mx_poe_det_dt_cd               in  varchar2  default hr_api.g_varchar2
  ,p_mx_poe_det_dt_rl               in  number    default hr_api.g_number
  ,p_mx_poe_val                     in  number    default hr_api.g_number
  ,p_mx_poe_uom                     in  varchar2  default hr_api.g_varchar2
  ,p_mx_poe_rl                      in  number    default hr_api.g_number
  ,p_mx_poe_apls_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_prtn_ovridbl_flag              in  varchar2  default hr_api.g_varchar2
  ,p_vrfy_fmly_mmbr_cd              in  varchar2  default hr_api.g_varchar2
  ,p_vrfy_fmly_mmbr_rl              in  number    default hr_api.g_number
  ,p_peo_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_peo_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_peo_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_peo_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_peo_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_peo_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_peo_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_peo_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_peo_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_peo_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_peo_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_peo_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_peo_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_peo_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_peo_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_peo_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_peo_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_peo_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_peo_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_peo_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_peo_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_peo_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_peo_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_peo_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_peo_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_peo_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_peo_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_peo_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_peo_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_peo_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_peo_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2);
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_ELIG_TO_PRTE_REASON >----------------------|
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
--   p_elig_to_prte_rsn_id          Yes  number    PK of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_effective_start_date    Yes  date      Effective Start Date of Record
--   p_effective_end_date      Yes  date      Effective End Date of Record
--   p_object_version_number   No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_ELIG_TO_PRTE_REASON
  (p_validate                       in boolean        default false
  ,p_elig_to_prte_rsn_id            in  number
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
--   p_elig_to_prte_rsn_id                 Yes  number   PK of record
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
   (p_elig_to_prte_rsn_id          in number
   ,p_object_version_number        in number
   ,p_effective_date               in date
   ,p_datetrack_mode               in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date);
--
end ben_ELIG_TO_PRTE_REASON_api;

 

/
