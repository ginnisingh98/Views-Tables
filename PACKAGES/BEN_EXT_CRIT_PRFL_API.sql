--------------------------------------------------------
--  DDL for Package BEN_EXT_CRIT_PRFL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_CRIT_PRFL_API" AUTHID CURRENT_USER as
/* $Header: bexcrapi.pkh 120.0 2005/05/28 12:25:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_EXT_CRIT_PRFL >------------------------|
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
--   p_name                         No   varchar2
--   p_business_group_id            Yes  number    Business Group of Record
--   p_legislation_code             No   varchar2  Legislation Code
--   p_xcr_attribute_category       No   varchar2  Descriptive Flexfield
--   p_xcr_attribute1               No   varchar2  Descriptive Flexfield
--   p_xcr_attribute2               No   varchar2  Descriptive Flexfield
--   p_xcr_attribute3               No   varchar2  Descriptive Flexfield
--   p_xcr_attribute4               No   varchar2  Descriptive Flexfield
--   p_xcr_attribute5               No   varchar2  Descriptive Flexfield
--   p_xcr_attribute6               No   varchar2  Descriptive Flexfield
--   p_xcr_attribute7               No   varchar2  Descriptive Flexfield
--   p_xcr_attribute8               No   varchar2  Descriptive Flexfield
--   p_xcr_attribute9               No   varchar2  Descriptive Flexfield
--   p_xcr_attribute10              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute11              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute12              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute13              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute14              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute15              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute16              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute17              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute18              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute19              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute20              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute21              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute22              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute23              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute24              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute25              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute26              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute27              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute28              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute29              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute30              No   varchar2  Descriptive Flexfield
--   p_ext_global_flag              No   varchar2  Descriptive Flexfield
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_ext_crit_prfl_id             Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_EXT_CRIT_PRFL
(
   p_validate                       in boolean    default false
  ,p_ext_crit_prfl_id               out nocopy number
  ,p_name                           in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_legislation_code               in  varchar2  default null
  ,p_xcr_attribute_category         in  varchar2  default null
  ,p_xcr_attribute1                 in  varchar2  default null
  ,p_xcr_attribute2                 in  varchar2  default null
  ,p_xcr_attribute3                 in  varchar2  default null
  ,p_xcr_attribute4                 in  varchar2  default null
  ,p_xcr_attribute5                 in  varchar2  default null
  ,p_xcr_attribute6                 in  varchar2  default null
  ,p_xcr_attribute7                 in  varchar2  default null
  ,p_xcr_attribute8                 in  varchar2  default null
  ,p_xcr_attribute9                 in  varchar2  default null
  ,p_xcr_attribute10                in  varchar2  default null
  ,p_xcr_attribute11                in  varchar2  default null
  ,p_xcr_attribute12                in  varchar2  default null
  ,p_xcr_attribute13                in  varchar2  default null
  ,p_xcr_attribute14                in  varchar2  default null
  ,p_xcr_attribute15                in  varchar2  default null
  ,p_xcr_attribute16                in  varchar2  default null
  ,p_xcr_attribute17                in  varchar2  default null
  ,p_xcr_attribute18                in  varchar2  default null
  ,p_xcr_attribute19                in  varchar2  default null
  ,p_xcr_attribute20                in  varchar2  default null
  ,p_xcr_attribute21                in  varchar2  default null
  ,p_xcr_attribute22                in  varchar2  default null
  ,p_xcr_attribute23                in  varchar2  default null
  ,p_xcr_attribute24                in  varchar2  default null
  ,p_xcr_attribute25                in  varchar2  default null
  ,p_xcr_attribute26                in  varchar2  default null
  ,p_xcr_attribute27                in  varchar2  default null
  ,p_xcr_attribute28                in  varchar2  default null
  ,p_xcr_attribute29                in  varchar2  default null
  ,p_xcr_attribute30                in  varchar2  default null
  ,p_ext_global_flag                in  varchar2  default 'N'
  ,p_object_version_number          out nocopy number
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_EXT_CRIT_PRFL >------------------------|
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
--   p_ext_crit_prfl_id             Yes  number    PK of record
--   p_name                         No   varchar2
--   p_business_group_id            Yes  number    Business Group of Record
--   p_legislation_code             No   varchar2  Legislation Code
--   p_xcr_attribute_category       No   varchar2  Descriptive Flexfield
--   p_xcr_attribute1               No   varchar2  Descriptive Flexfield
--   p_xcr_attribute2               No   varchar2  Descriptive Flexfield
--   p_xcr_attribute3               No   varchar2  Descriptive Flexfield
--   p_xcr_attribute4               No   varchar2  Descriptive Flexfield
--   p_xcr_attribute5               No   varchar2  Descriptive Flexfield
--   p_xcr_attribute6               No   varchar2  Descriptive Flexfield
--   p_xcr_attribute7               No   varchar2  Descriptive Flexfield
--   p_xcr_attribute8               No   varchar2  Descriptive Flexfield
--   p_xcr_attribute9               No   varchar2  Descriptive Flexfield
--   p_xcr_attribute10              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute11              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute12              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute13              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute14              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute15              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute16              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute17              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute18              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute19              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute20              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute21              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute22              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute23              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute24              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute25              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute26              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute27              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute28              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute29              No   varchar2  Descriptive Flexfield
--   p_xcr_attribute30              No   varchar2  Descriptive Flexfield
--   p_ext_global_flag              No   varchar2  Descriptive Flexfield
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
procedure update_EXT_CRIT_PRFL
  (
   p_validate                       in boolean    default false
  ,p_ext_crit_prfl_id               in  number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_ext_global_flag                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_EXT_CRIT_PRFL >------------------------|
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
--   p_ext_crit_prfl_id             Yes  number    PK of record
--   p_legislation_code             No   varchar2  Legislation Code
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
procedure delete_EXT_CRIT_PRFL
  (
   p_validate                       in boolean        default false
  ,p_ext_crit_prfl_id               in  number
  ,p_legislation_code               in  varchar2      default null
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
--   p_ext_crit_prfl_id                 Yes  number   PK of record
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
    p_ext_crit_prfl_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_EXT_CRIT_PRFL_api;

 

/
