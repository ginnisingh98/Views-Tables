--------------------------------------------------------
--  DDL for Package BEN_WITHIN_YEAR_PERD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_WITHIN_YEAR_PERD_API" AUTHID CURRENT_USER as
/* $Header: bewypapi.pkh 120.0 2005/05/28 12:21:12 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_WITHIN_YEAR_PERD >------------------------|
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
--   p_strt_day                     No   number
--   p_end_day                      No   number
--   p_strt_mo                      No   number
--   p_end_mo                       No   number
--   p_tm_uom                       No   varchar2
--   p_yr_perd_id                   No   number
--   p_business_group_id            No   number    Business Group of Record
--   p_wyp_attribute_category       No   varchar2  Descriptive Flexfield
--   p_wyp_attribute1               No   varchar2  Descriptive Flexfield
--   p_wyp_attribute2               No   varchar2  Descriptive Flexfield
--   p_wyp_attribute3               No   varchar2  Descriptive Flexfield
--   p_wyp_attribute4               No   varchar2  Descriptive Flexfield
--   p_wyp_attribute5               No   varchar2  Descriptive Flexfield
--   p_wyp_attribute6               No   varchar2  Descriptive Flexfield
--   p_wyp_attribute7               No   varchar2  Descriptive Flexfield
--   p_wyp_attribute8               No   varchar2  Descriptive Flexfield
--   p_wyp_attribute9               No   varchar2  Descriptive Flexfield
--   p_wyp_attribute10              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute11              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute12              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute13              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute14              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute15              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute16              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute17              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute18              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute19              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute20              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute21              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute22              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute23              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute24              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute25              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute26              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute27              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute28              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute29              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date               Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_wthn_yr_perd_id              Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_WITHIN_YEAR_PERD
(
   p_validate                       in boolean    default false
  ,p_wthn_yr_perd_id                out nocopy number
  ,p_strt_day                       in  number    default null
  ,p_end_day                        in  number    default null
  ,p_strt_mo                        in  number    default null
  ,p_end_mo                         in  number    default null
  ,p_tm_uom                         in  varchar2  default null
  ,p_yr_perd_id                     in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_wyp_attribute_category         in  varchar2  default null
  ,p_wyp_attribute1                 in  varchar2  default null
  ,p_wyp_attribute2                 in  varchar2  default null
  ,p_wyp_attribute3                 in  varchar2  default null
  ,p_wyp_attribute4                 in  varchar2  default null
  ,p_wyp_attribute5                 in  varchar2  default null
  ,p_wyp_attribute6                 in  varchar2  default null
  ,p_wyp_attribute7                 in  varchar2  default null
  ,p_wyp_attribute8                 in  varchar2  default null
  ,p_wyp_attribute9                 in  varchar2  default null
  ,p_wyp_attribute10                in  varchar2  default null
  ,p_wyp_attribute11                in  varchar2  default null
  ,p_wyp_attribute12                in  varchar2  default null
  ,p_wyp_attribute13                in  varchar2  default null
  ,p_wyp_attribute14                in  varchar2  default null
  ,p_wyp_attribute15                in  varchar2  default null
  ,p_wyp_attribute16                in  varchar2  default null
  ,p_wyp_attribute17                in  varchar2  default null
  ,p_wyp_attribute18                in  varchar2  default null
  ,p_wyp_attribute19                in  varchar2  default null
  ,p_wyp_attribute20                in  varchar2  default null
  ,p_wyp_attribute21                in  varchar2  default null
  ,p_wyp_attribute22                in  varchar2  default null
  ,p_wyp_attribute23                in  varchar2  default null
  ,p_wyp_attribute24                in  varchar2  default null
  ,p_wyp_attribute25                in  varchar2  default null
  ,p_wyp_attribute26                in  varchar2  default null
  ,p_wyp_attribute27                in  varchar2  default null
  ,p_wyp_attribute28                in  varchar2  default null
  ,p_wyp_attribute29                in  varchar2  default null
  ,p_wyp_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_WITHIN_YEAR_PERD >------------------------|
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
--   p_wthn_yr_perd_id              Yes  number    PK of record
--   p_strt_day                     No   number
--   p_end_day                      No   number
--   p_strt_mo                      No   number
--   p_end_mo                       No   number
--   p_tm_uom                       No   varchar2
--   p_yr_perd_id                   No   number
--   p_business_group_id            No   number    Business Group of Record
--   p_wyp_attribute_category       No   varchar2  Descriptive Flexfield
--   p_wyp_attribute1               No   varchar2  Descriptive Flexfield
--   p_wyp_attribute2               No   varchar2  Descriptive Flexfield
--   p_wyp_attribute3               No   varchar2  Descriptive Flexfield
--   p_wyp_attribute4               No   varchar2  Descriptive Flexfield
--   p_wyp_attribute5               No   varchar2  Descriptive Flexfield
--   p_wyp_attribute6               No   varchar2  Descriptive Flexfield
--   p_wyp_attribute7               No   varchar2  Descriptive Flexfield
--   p_wyp_attribute8               No   varchar2  Descriptive Flexfield
--   p_wyp_attribute9               No   varchar2  Descriptive Flexfield
--   p_wyp_attribute10              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute11              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute12              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute13              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute14              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute15              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute16              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute17              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute18              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute19              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute20              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute21              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute22              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute23              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute24              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute25              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute26              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute27              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute28              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute29              No   varchar2  Descriptive Flexfield
--   p_wyp_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date               Yes  date      Session Date.
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
procedure update_WITHIN_YEAR_PERD
  (
   p_validate                       in boolean    default false
  ,p_wthn_yr_perd_id                in  number
  ,p_strt_day                       in  number    default hr_api.g_number
  ,p_end_day                        in  number    default hr_api.g_number
  ,p_strt_mo                        in  number    default hr_api.g_number
  ,p_end_mo                         in  number    default hr_api.g_number
  ,p_tm_uom                         in  varchar2  default hr_api.g_varchar2
  ,p_yr_perd_id                     in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_wyp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_effective_date                 in  date
  ,p_object_version_number          in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_WITHIN_YEAR_PERD >------------------------|
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
--   p_wthn_yr_perd_id              Yes  number    PK of record
--   p_effective_date               Yes  date     Session Date.
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
procedure delete_WITHIN_YEAR_PERD
  (
   p_validate                       in boolean        default false
  ,p_wthn_yr_perd_id                in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date
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
--   p_wthn_yr_perd_id                 Yes  number   PK of record
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
    p_wthn_yr_perd_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_WITHIN_YEAR_PERD_api;

 

/
