--------------------------------------------------------
--  DDL for Package BEN_PARTICIPATION_ELIG_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PARTICIPATION_ELIG_API" AUTHID CURRENT_USER as
/* $Header: beepaapi.pkh 120.0 2005/05/28 02:35:03 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_Participation_Elig >------------------------|
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
--   p_pgm_id                       No   number
--   p_pl_id                        No   number
--   p_oipl_id                      No   number
--   p_prtn_eff_strt_dt_cd          No   varchar2
--   p_prtn_eff_end_dt_cd           No   varchar2
--   p_prtn_eff_strt_dt_rl          No   number
--   p_prtn_eff_end_dt_rl           No   number
--   p_wait_perd_dt_to_use_cd       No   varchar2
--   p_wait_perd_dt_to_use_rl       No   number
--   p_wait_perd_val                No   number
--   p_wait_perd_uom                No   varchar2
--   p_wait_perd_rl                 No   number
--   p_mx_poe_det_dt_cd             No   varchar2
--   p_mx_poe_det_dt_rl             No   number
--   p_mx_poe_val                   No   number
--   p_mx_poe_uom                   No   varchar2
--   p_mx_poe_rl                    No   number
--   p_mx_poe_apls_cd               No   varchar2
--   p_epa_attribute_category       No   varchar2  Descriptive Flexfield
--   p_epa_attribute1               No   varchar2  Descriptive Flexfield
--   p_epa_attribute2               No   varchar2  Descriptive Flexfield
--   p_epa_attribute3               No   varchar2  Descriptive Flexfield
--   p_epa_attribute4               No   varchar2  Descriptive Flexfield
--   p_epa_attribute5               No   varchar2  Descriptive Flexfield
--   p_epa_attribute6               No   varchar2  Descriptive Flexfield
--   p_epa_attribute7               No   varchar2  Descriptive Flexfield
--   p_epa_attribute8               No   varchar2  Descriptive Flexfield
--   p_epa_attribute9               No   varchar2  Descriptive Flexfield
--   p_epa_attribute10              No   varchar2  Descriptive Flexfield
--   p_epa_attribute11              No   varchar2  Descriptive Flexfield
--   p_epa_attribute12              No   varchar2  Descriptive Flexfield
--   p_epa_attribute13              No   varchar2  Descriptive Flexfield
--   p_epa_attribute14              No   varchar2  Descriptive Flexfield
--   p_epa_attribute15              No   varchar2  Descriptive Flexfield
--   p_epa_attribute16              No   varchar2  Descriptive Flexfield
--   p_epa_attribute17              No   varchar2  Descriptive Flexfield
--   p_epa_attribute18              No   varchar2  Descriptive Flexfield
--   p_epa_attribute19              No   varchar2  Descriptive Flexfield
--   p_epa_attribute20              No   varchar2  Descriptive Flexfield
--   p_epa_attribute21              No   varchar2  Descriptive Flexfield
--   p_epa_attribute22              No   varchar2  Descriptive Flexfield
--   p_epa_attribute23              No   varchar2  Descriptive Flexfield
--   p_epa_attribute24              No   varchar2  Descriptive Flexfield
--   p_epa_attribute25              No   varchar2  Descriptive Flexfield
--   p_epa_attribute26              No   varchar2  Descriptive Flexfield
--   p_epa_attribute27              No   varchar2  Descriptive Flexfield
--   p_epa_attribute28              No   varchar2  Descriptive Flexfield
--   p_epa_attribute29              No   varchar2  Descriptive Flexfield
--   p_epa_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_prtn_elig_id                 Yes  number    PK of record
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
procedure create_Participation_Elig
  (p_validate                       in boolean    default false
  ,p_prtn_elig_id                   out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_plip_id                        in  number    default null
  ,p_trk_scr_for_inelg_flag         in  varchar2  default null
  ,p_prtn_eff_strt_dt_cd            in  varchar2  default null
  ,p_prtn_eff_end_dt_cd             in  varchar2  default null
  ,p_prtn_eff_strt_dt_rl            in  number    default null
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
  ,p_epa_attribute_category         in  varchar2  default null
  ,p_epa_attribute1                 in  varchar2  default null
  ,p_epa_attribute2                 in  varchar2  default null
  ,p_epa_attribute3                 in  varchar2  default null
  ,p_epa_attribute4                 in  varchar2  default null
  ,p_epa_attribute5                 in  varchar2  default null
  ,p_epa_attribute6                 in  varchar2  default null
  ,p_epa_attribute7                 in  varchar2  default null
  ,p_epa_attribute8                 in  varchar2  default null
  ,p_epa_attribute9                 in  varchar2  default null
  ,p_epa_attribute10                in  varchar2  default null
  ,p_epa_attribute11                in  varchar2  default null
  ,p_epa_attribute12                in  varchar2  default null
  ,p_epa_attribute13                in  varchar2  default null
  ,p_epa_attribute14                in  varchar2  default null
  ,p_epa_attribute15                in  varchar2  default null
  ,p_epa_attribute16                in  varchar2  default null
  ,p_epa_attribute17                in  varchar2  default null
  ,p_epa_attribute18                in  varchar2  default null
  ,p_epa_attribute19                in  varchar2  default null
  ,p_epa_attribute20                in  varchar2  default null
  ,p_epa_attribute21                in  varchar2  default null
  ,p_epa_attribute22                in  varchar2  default null
  ,p_epa_attribute23                in  varchar2  default null
  ,p_epa_attribute24                in  varchar2  default null
  ,p_epa_attribute25                in  varchar2  default null
  ,p_epa_attribute26                in  varchar2  default null
  ,p_epa_attribute27                in  varchar2  default null
  ,p_epa_attribute28                in  varchar2  default null
  ,p_epa_attribute29                in  varchar2  default null
  ,p_epa_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date);
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_Participation_Elig >---------------------|
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
--   p_prtn_elig_id                 Yes  number    PK of record
--   p_business_group_id            Yes  number    Business Group of Record
--   p_pgm_id                       No   number
--   p_pl_id                        No   number
--   p_oipl_id                      No   number
--   p_prtn_eff_strt_dt_cd          No   varchar2
--   p_prtn_eff_end_dt_cd           No   varchar2
--   p_prtn_eff_strt_dt_rl          No   number
--   p_prtn_eff_end_dt_rl           No   number
--   p_wait_perd_dt_to_use_cd       No   varchar2
--   p_wait_perd_dt_to_use_rl       No   number
--   p_wait_perd_val                No   number
--   p_wait_perd_uom                No   varchar2
--   p_wait_perd_rl                 No   number
--   p_mx_poe_det_dt_cd             No   varchar2
--   p_mx_poe_det_dt_rl             No   number
--   p_mx_poe_val                   No   number
--   p_mx_poe_uom                   No   varchar2
--   p_mx_poe_rl                    No   number
--   p_mx_poe_apls_cd               No   varchar2
--   p_epa_attribute_category       No   varchar2  Descriptive Flexfield
--   p_epa_attribute1               No   varchar2  Descriptive Flexfield
--   p_epa_attribute2               No   varchar2  Descriptive Flexfield
--   p_epa_attribute3               No   varchar2  Descriptive Flexfield
--   p_epa_attribute4               No   varchar2  Descriptive Flexfield
--   p_epa_attribute5               No   varchar2  Descriptive Flexfield
--   p_epa_attribute6               No   varchar2  Descriptive Flexfield
--   p_epa_attribute7               No   varchar2  Descriptive Flexfield
--   p_epa_attribute8               No   varchar2  Descriptive Flexfield
--   p_epa_attribute9               No   varchar2  Descriptive Flexfield
--   p_epa_attribute10              No   varchar2  Descriptive Flexfield
--   p_epa_attribute11              No   varchar2  Descriptive Flexfield
--   p_epa_attribute12              No   varchar2  Descriptive Flexfield
--   p_epa_attribute13              No   varchar2  Descriptive Flexfield
--   p_epa_attribute14              No   varchar2  Descriptive Flexfield
--   p_epa_attribute15              No   varchar2  Descriptive Flexfield
--   p_epa_attribute16              No   varchar2  Descriptive Flexfield
--   p_epa_attribute17              No   varchar2  Descriptive Flexfield
--   p_epa_attribute18              No   varchar2  Descriptive Flexfield
--   p_epa_attribute19              No   varchar2  Descriptive Flexfield
--   p_epa_attribute20              No   varchar2  Descriptive Flexfield
--   p_epa_attribute21              No   varchar2  Descriptive Flexfield
--   p_epa_attribute22              No   varchar2  Descriptive Flexfield
--   p_epa_attribute23              No   varchar2  Descriptive Flexfield
--   p_epa_attribute24              No   varchar2  Descriptive Flexfield
--   p_epa_attribute25              No   varchar2  Descriptive Flexfield
--   p_epa_attribute26              No   varchar2  Descriptive Flexfield
--   p_epa_attribute27              No   varchar2  Descriptive Flexfield
--   p_epa_attribute28              No   varchar2  Descriptive Flexfield
--   p_epa_attribute29              No   varchar2  Descriptive Flexfield
--   p_epa_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_Participation_Elig
  (p_validate                       in boolean    default false
  ,p_prtn_elig_id                   in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_oipl_id                        in  number    default hr_api.g_number
  ,p_ptip_id                        in  number    default hr_api.g_number
  ,p_plip_id                        in  number    default hr_api.g_number
  ,p_trk_scr_for_inelg_flag         in  varchar2  default hr_api.g_varchar2
  ,p_prtn_eff_strt_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_prtn_eff_end_dt_cd             in  varchar2  default hr_api.g_varchar2
  ,p_prtn_eff_strt_dt_rl            in  number    default hr_api.g_number
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
  ,p_epa_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2);
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_Participation_Elig >------------------------|
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
--   p_prtn_elig_id                 Yes  number    PK of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--
-- Post Success:
--
--   Name                          Type     Description
--   p_effective_start_date   Yes  date      Effective Start Date of Record
--   p_effective_end_date     Yes  date      Effective End Date of Record
--   p_object_version_number  No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_Participation_Elig
  (p_validate                       in boolean        default false
  ,p_prtn_elig_id                   in  number
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
--   p_prtn_elig_id                 Yes  number   PK of record
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
   (p_prtn_elig_id                in number
   ,p_object_version_number       in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date       out nocopy date
   ,p_validation_end_date         out nocopy date);
--
end ben_Participation_Elig_api;

 

/
