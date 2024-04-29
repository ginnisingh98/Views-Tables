--------------------------------------------------------
--  DDL for Package BEN_CMBN_AGE_LOS_FCTR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CMBN_AGE_LOS_FCTR_API" AUTHID CURRENT_USER as
/* $Header: beclaapi.pkh 120.0 2005/05/28 01:03:06 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_cmbn_age_los_fctr >------------------------|
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
--   p_los_fctr_id                  Yes  number
--   p_age_fctr_id                  Yes  number
--   p_cmbnd_min_val                No   number
--   p_cmbnd_max_val                No   number
--   p_ordr_num                     No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_cla_attribute_category       No   varchar2  Descriptive Flexfield
--   p_cla_attribute1               No   varchar2  Descriptive Flexfield
--   p_cla_attribute2               No   varchar2  Descriptive Flexfield
--   p_cla_attribute3               No   varchar2  Descriptive Flexfield
--   p_cla_attribute4               No   varchar2  Descriptive Flexfield
--   p_cla_attribute5               No   varchar2  Descriptive Flexfield
--   p_cla_attribute6               No   varchar2  Descriptive Flexfield
--   p_cla_attribute7               No   varchar2  Descriptive Flexfield
--   p_cla_attribute8               No   varchar2  Descriptive Flexfield
--   p_cla_attribute9               No   varchar2  Descriptive Flexfield
--   p_cla_attribute10              No   varchar2  Descriptive Flexfield
--   p_cla_attribute11              No   varchar2  Descriptive Flexfield
--   p_cla_attribute12              No   varchar2  Descriptive Flexfield
--   p_cla_attribute13              No   varchar2  Descriptive Flexfield
--   p_cla_attribute14              No   varchar2  Descriptive Flexfield
--   p_cla_attribute15              No   varchar2  Descriptive Flexfield
--   p_cla_attribute16              No   varchar2  Descriptive Flexfield
--   p_cla_attribute17              No   varchar2  Descriptive Flexfield
--   p_cla_attribute18              No   varchar2  Descriptive Flexfield
--   p_cla_attribute19              No   varchar2  Descriptive Flexfield
--   p_cla_attribute20              No   varchar2  Descriptive Flexfield
--   p_cla_attribute21              No   varchar2  Descriptive Flexfield
--   p_cla_attribute22              No   varchar2  Descriptive Flexfield
--   p_cla_attribute23              No   varchar2  Descriptive Flexfield
--   p_cla_attribute24              No   varchar2  Descriptive Flexfield
--   p_cla_attribute25              No   varchar2  Descriptive Flexfield
--   p_cla_attribute26              No   varchar2  Descriptive Flexfield
--   p_cla_attribute27              No   varchar2  Descriptive Flexfield
--   p_cla_attribute28              No   varchar2  Descriptive Flexfield
--   p_cla_attribute29              No   varchar2  Descriptive Flexfield
--   p_cla_attribute30              No   varchar2  Descriptive Flexfield
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_cmbn_age_los_fctr_id         Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_cmbn_age_los_fctr
(
   p_validate                       in boolean    default false
  ,p_cmbn_age_los_fctr_id           out nocopy number
  ,p_name                           in  varchar2  default null
  ,p_los_fctr_id                    in  number    default null
  ,p_age_fctr_id                    in  number    default null
  ,p_cmbnd_min_val                  in  number    default null
  ,p_cmbnd_max_val                  in  number    default null
  ,p_ordr_num                       in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_cla_attribute_category         in  varchar2  default null
  ,p_cla_attribute1                 in  varchar2  default null
  ,p_cla_attribute2                 in  varchar2  default null
  ,p_cla_attribute3                 in  varchar2  default null
  ,p_cla_attribute4                 in  varchar2  default null
  ,p_cla_attribute5                 in  varchar2  default null
  ,p_cla_attribute6                 in  varchar2  default null
  ,p_cla_attribute7                 in  varchar2  default null
  ,p_cla_attribute8                 in  varchar2  default null
  ,p_cla_attribute9                 in  varchar2  default null
  ,p_cla_attribute10                in  varchar2  default null
  ,p_cla_attribute11                in  varchar2  default null
  ,p_cla_attribute12                in  varchar2  default null
  ,p_cla_attribute13                in  varchar2  default null
  ,p_cla_attribute14                in  varchar2  default null
  ,p_cla_attribute15                in  varchar2  default null
  ,p_cla_attribute16                in  varchar2  default null
  ,p_cla_attribute17                in  varchar2  default null
  ,p_cla_attribute18                in  varchar2  default null
  ,p_cla_attribute19                in  varchar2  default null
  ,p_cla_attribute20                in  varchar2  default null
  ,p_cla_attribute21                in  varchar2  default null
  ,p_cla_attribute22                in  varchar2  default null
  ,p_cla_attribute23                in  varchar2  default null
  ,p_cla_attribute24                in  varchar2  default null
  ,p_cla_attribute25                in  varchar2  default null
  ,p_cla_attribute26                in  varchar2  default null
  ,p_cla_attribute27                in  varchar2  default null
  ,p_cla_attribute28                in  varchar2  default null
  ,p_cla_attribute29                in  varchar2  default null
  ,p_cla_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_cmbn_age_los_fctr >------------------------|
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
--   p_cmbn_age_los_fctr_id         Yes  number    PK of record
--   p_name                         Yes  varchar2
--   p_los_fctr_id                  Yes  number
--   p_age_fctr_id                  Yes  number
--   p_cmbnd_min_val                No   number
--   p_cmbnd_max_val                No   number
--   p_ordr_num                     No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_cla_attribute_category       No   varchar2  Descriptive Flexfield
--   p_cla_attribute1               No   varchar2  Descriptive Flexfield
--   p_cla_attribute2               No   varchar2  Descriptive Flexfield
--   p_cla_attribute3               No   varchar2  Descriptive Flexfield
--   p_cla_attribute4               No   varchar2  Descriptive Flexfield
--   p_cla_attribute5               No   varchar2  Descriptive Flexfield
--   p_cla_attribute6               No   varchar2  Descriptive Flexfield
--   p_cla_attribute7               No   varchar2  Descriptive Flexfield
--   p_cla_attribute8               No   varchar2  Descriptive Flexfield
--   p_cla_attribute9               No   varchar2  Descriptive Flexfield
--   p_cla_attribute10              No   varchar2  Descriptive Flexfield
--   p_cla_attribute11              No   varchar2  Descriptive Flexfield
--   p_cla_attribute12              No   varchar2  Descriptive Flexfield
--   p_cla_attribute13              No   varchar2  Descriptive Flexfield
--   p_cla_attribute14              No   varchar2  Descriptive Flexfield
--   p_cla_attribute15              No   varchar2  Descriptive Flexfield
--   p_cla_attribute16              No   varchar2  Descriptive Flexfield
--   p_cla_attribute17              No   varchar2  Descriptive Flexfield
--   p_cla_attribute18              No   varchar2  Descriptive Flexfield
--   p_cla_attribute19              No   varchar2  Descriptive Flexfield
--   p_cla_attribute20              No   varchar2  Descriptive Flexfield
--   p_cla_attribute21              No   varchar2  Descriptive Flexfield
--   p_cla_attribute22              No   varchar2  Descriptive Flexfield
--   p_cla_attribute23              No   varchar2  Descriptive Flexfield
--   p_cla_attribute24              No   varchar2  Descriptive Flexfield
--   p_cla_attribute25              No   varchar2  Descriptive Flexfield
--   p_cla_attribute26              No   varchar2  Descriptive Flexfield
--   p_cla_attribute27              No   varchar2  Descriptive Flexfield
--   p_cla_attribute28              No   varchar2  Descriptive Flexfield
--   p_cla_attribute29              No   varchar2  Descriptive Flexfield
--   p_cla_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_cmbn_age_los_fctr
  (
   p_validate                       in boolean    default false
  ,p_cmbn_age_los_fctr_id           in  number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_los_fctr_id                    in  number    default hr_api.g_number
  ,p_age_fctr_id                    in  number    default hr_api.g_number
  ,p_cmbnd_min_val                  in  number    default hr_api.g_number
  ,p_cmbnd_max_val                  in  number    default hr_api.g_number
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_cla_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_cmbn_age_los_fctr >------------------------|
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
--   p_cmbn_age_los_fctr_id         Yes  number    PK of record
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
procedure delete_cmbn_age_los_fctr
  (
   p_validate                       in boolean        default false
  ,p_cmbn_age_los_fctr_id           in  number
  ,p_object_version_number          in out nocopy number
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
--   p_cmbn_age_los_fctr_id                 Yes  number   PK of record
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
    p_cmbn_age_los_fctr_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_cmbn_age_los_fctr_api;

 

/
