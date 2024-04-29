--------------------------------------------------------
--  DDL for Package BEN_LOS_FACTORS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LOS_FACTORS_API" AUTHID CURRENT_USER as
/* $Header: belsfapi.pkh 120.0 2005/05/28 03:37:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_LOS_FACTORS >------------------------|
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
--   p_business_group_id            Yes  number    Business Group of Record
--   p_los_det_cd                   No   varchar2
--   p_los_det_rl                   No   number
--   p_mn_los_num                   No   number
--   p_mx_los_num                   No   number
--   p_no_mx_los_num_apls_flag      Yes  varchar2
--   p_no_mn_los_num_apls_flag      Yes  varchar2
--   p_rndg_cd                      No   varchar2
--   p_rndg_rl                      No   number
--   p_los_dt_to_use_cd             No   varchar2
--   p_los_dt_to_use_rl             No   number
--   p_los_uom                      No   varchar2
--   p_los_calc_rl                  No   number
--   p_los_alt_val_to_use_cd        No   varchar2
--   p_lsf_attribute_category       No   varchar2  Descriptive Flexfield
--   p_lsf_attribute1               No   varchar2  Descriptive Flexfield
--   p_lsf_attribute2               No   varchar2  Descriptive Flexfield
--   p_lsf_attribute3               No   varchar2  Descriptive Flexfield
--   p_lsf_attribute4               No   varchar2  Descriptive Flexfield
--   p_lsf_attribute5               No   varchar2  Descriptive Flexfield
--   p_lsf_attribute6               No   varchar2  Descriptive Flexfield
--   p_lsf_attribute7               No   varchar2  Descriptive Flexfield
--   p_lsf_attribute8               No   varchar2  Descriptive Flexfield
--   p_lsf_attribute9               No   varchar2  Descriptive Flexfield
--   p_lsf_attribute10              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute11              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute12              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute13              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute14              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute15              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute16              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute17              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute18              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute19              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute20              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute21              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute22              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute23              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute24              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute25              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute26              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute27              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute28              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute29              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute30              No   varchar2  Descriptive Flexfield
--   p_use_overid_svc_dt_flag       Yes  varchar2
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_los_fctr_id                  Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_LOS_FACTORS
(
   p_validate                       in boolean    default false
  ,p_los_fctr_id                    out nocopy number
  ,p_name                           in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_los_det_cd                     in  varchar2  default null
  ,p_los_det_rl                     in  number    default null
  ,p_mn_los_num                     in  number    default null
  ,p_mx_los_num                     in  number    default null
  ,p_no_mx_los_num_apls_flag        in  varchar2  default null
  ,p_no_mn_los_num_apls_flag        in  varchar2  default null
  ,p_rndg_cd                        in  varchar2  default null
  ,p_rndg_rl                        in  number    default null
  ,p_los_dt_to_use_cd               in  varchar2  default null
  ,p_los_dt_to_use_rl               in  number    default null
  ,p_los_uom                        in  varchar2  default null
  ,p_los_calc_rl                    in  number    default null
  ,p_los_alt_val_to_use_cd          in  varchar2  default null
  ,p_lsf_attribute_category         in  varchar2  default null
  ,p_lsf_attribute1                 in  varchar2  default null
  ,p_lsf_attribute2                 in  varchar2  default null
  ,p_lsf_attribute3                 in  varchar2  default null
  ,p_lsf_attribute4                 in  varchar2  default null
  ,p_lsf_attribute5                 in  varchar2  default null
  ,p_lsf_attribute6                 in  varchar2  default null
  ,p_lsf_attribute7                 in  varchar2  default null
  ,p_lsf_attribute8                 in  varchar2  default null
  ,p_lsf_attribute9                 in  varchar2  default null
  ,p_lsf_attribute10                in  varchar2  default null
  ,p_lsf_attribute11                in  varchar2  default null
  ,p_lsf_attribute12                in  varchar2  default null
  ,p_lsf_attribute13                in  varchar2  default null
  ,p_lsf_attribute14                in  varchar2  default null
  ,p_lsf_attribute15                in  varchar2  default null
  ,p_lsf_attribute16                in  varchar2  default null
  ,p_lsf_attribute17                in  varchar2  default null
  ,p_lsf_attribute18                in  varchar2  default null
  ,p_lsf_attribute19                in  varchar2  default null
  ,p_lsf_attribute20                in  varchar2  default null
  ,p_lsf_attribute21                in  varchar2  default null
  ,p_lsf_attribute22                in  varchar2  default null
  ,p_lsf_attribute23                in  varchar2  default null
  ,p_lsf_attribute24                in  varchar2  default null
  ,p_lsf_attribute25                in  varchar2  default null
  ,p_lsf_attribute26                in  varchar2  default null
  ,p_lsf_attribute27                in  varchar2  default null
  ,p_lsf_attribute28                in  varchar2  default null
  ,p_lsf_attribute29                in  varchar2  default null
  ,p_lsf_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_use_overid_svc_dt_flag         in  varchar2  default null
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_LOS_FACTORS >------------------------|
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
--   p_los_fctr_id                  Yes  number    PK of record
--   p_name                         Yes  varchar2
--   p_business_group_id            Yes  number    Business Group of Record
--   p_los_det_cd                   No   varchar2
--   p_los_det_rl                   No   number
--   p_mn_los_num                   No   number
--   p_mx_los_num                   No   number
--   p_no_mx_los_num_apls_flag      Yes  varchar2
--   p_no_mn_los_num_apls_flag      Yes  varchar2
--   p_rndg_cd                      No   varchar2
--   p_rndg_rl                      No   number
--   p_los_dt_to_use_cd             No   varchar2
--   p_los_dt_to_use_rl             No   number
--   p_los_uom                      No   varchar2
--   p_los_calc_rl                  No   number
--   p_los_alt_val_to_use_cd        No   varchar2
--   p_lsf_attribute_category       No   varchar2  Descriptive Flexfield
--   p_lsf_attribute1               No   varchar2  Descriptive Flexfield
--   p_lsf_attribute2               No   varchar2  Descriptive Flexfield
--   p_lsf_attribute3               No   varchar2  Descriptive Flexfield
--   p_lsf_attribute4               No   varchar2  Descriptive Flexfield
--   p_lsf_attribute5               No   varchar2  Descriptive Flexfield
--   p_lsf_attribute6               No   varchar2  Descriptive Flexfield
--   p_lsf_attribute7               No   varchar2  Descriptive Flexfield
--   p_lsf_attribute8               No   varchar2  Descriptive Flexfield
--   p_lsf_attribute9               No   varchar2  Descriptive Flexfield
--   p_lsf_attribute10              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute11              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute12              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute13              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute14              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute15              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute16              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute17              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute18              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute19              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute20              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute21              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute22              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute23              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute24              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute25              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute26              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute27              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute28              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute29              No   varchar2  Descriptive Flexfield
--   p_lsf_attribute30              No   varchar2  Descriptive Flexfield
--   p_use_overid_svc_dt_flag       Yes  varchar2
--   p_effective_date          Yes  date       Session Date.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_LOS_FACTORS
  (
   p_validate                       in boolean    default false
  ,p_los_fctr_id                    in  number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_los_det_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_los_det_rl                     in  number    default hr_api.g_number
  ,p_mn_los_num                     in  number    default hr_api.g_number
  ,p_mx_los_num                     in  number    default hr_api.g_number
  ,p_no_mx_los_num_apls_flag        in  varchar2  default hr_api.g_varchar2
  ,p_no_mn_los_num_apls_flag        in  varchar2  default hr_api.g_varchar2
  ,p_rndg_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_rndg_rl                        in  number    default hr_api.g_number
  ,p_los_dt_to_use_cd               in  varchar2  default hr_api.g_varchar2
  ,p_los_dt_to_use_rl               in  number    default hr_api.g_number
  ,p_los_uom                        in  varchar2  default hr_api.g_varchar2
  ,p_los_calc_rl                    in  number    default hr_api.g_number
  ,p_los_alt_val_to_use_cd          in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_use_overid_svc_dt_flag         in  varchar2  default hr_api.g_varchar2
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_LOS_FACTORS >------------------------|
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
--   p_los_fctr_id                  Yes  number    PK of record
--   p_effective_date          Yes  date     Session Date.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_LOS_FACTORS
  (
   p_validate                       in boolean        default false
  ,p_los_fctr_id                    in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in date
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
--   p_los_fctr_id                 Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--
-- Post Success:
--
--   Name                           Type     Description
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
    p_los_fctr_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_LOS_FACTORS_api;

 

/
