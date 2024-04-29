--------------------------------------------------------
--  DDL for Package BEN_BENEFITS_GROUP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BENEFITS_GROUP_API" AUTHID CURRENT_USER as
/* $Header: bebngapi.pkh 120.0 2005/05/28 00:45:10 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Benefits_Group >------------------------|
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
--   p_name                         Yes  varchar2
--   p_bng_desc                     No   varchar2
--   p_bng_attribute_category       No   varchar2  Descriptive Flexfield
--   p_bng_attribute1               No   varchar2  Descriptive Flexfield
--   p_bng_attribute2               No   varchar2  Descriptive Flexfield
--   p_bng_attribute3               No   varchar2  Descriptive Flexfield
--   p_bng_attribute4               No   varchar2  Descriptive Flexfield
--   p_bng_attribute5               No   varchar2  Descriptive Flexfield
--   p_bng_attribute6               No   varchar2  Descriptive Flexfield
--   p_bng_attribute7               No   varchar2  Descriptive Flexfield
--   p_bng_attribute8               No   varchar2  Descriptive Flexfield
--   p_bng_attribute9               No   varchar2  Descriptive Flexfield
--   p_bng_attribute10              No   varchar2  Descriptive Flexfield
--   p_bng_attribute11              No   varchar2  Descriptive Flexfield
--   p_bng_attribute12              No   varchar2  Descriptive Flexfield
--   p_bng_attribute13              No   varchar2  Descriptive Flexfield
--   p_bng_attribute14              No   varchar2  Descriptive Flexfield
--   p_bng_attribute15              No   varchar2  Descriptive Flexfield
--   p_bng_attribute16              No   varchar2  Descriptive Flexfield
--   p_bng_attribute17              No   varchar2  Descriptive Flexfield
--   p_bng_attribute18              No   varchar2  Descriptive Flexfield
--   p_bng_attribute19              No   varchar2  Descriptive Flexfield
--   p_bng_attribute20              No   varchar2  Descriptive Flexfield
--   p_bng_attribute21              No   varchar2  Descriptive Flexfield
--   p_bng_attribute22              No   varchar2  Descriptive Flexfield
--   p_bng_attribute23              No   varchar2  Descriptive Flexfield
--   p_bng_attribute24              No   varchar2  Descriptive Flexfield
--   p_bng_attribute25              No   varchar2  Descriptive Flexfield
--   p_bng_attribute26              No   varchar2  Descriptive Flexfield
--   p_bng_attribute27              No   varchar2  Descriptive Flexfield
--   p_bng_attribute28              No   varchar2  Descriptive Flexfield
--   p_bng_attribute29              No   varchar2  Descriptive Flexfield
--   p_bng_attribute30              No   varchar2  Descriptive Flexfield
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_benfts_grp_id                Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_Benefits_Group
(
   p_validate                       in boolean    default false
  ,p_benfts_grp_id                  out nocopy number
  ,p_business_group_id              in  number    default null
  ,p_name                           in  varchar2  default null
  ,p_bng_desc                       in  varchar2  default null
  ,p_bng_attribute_category         in  varchar2  default null
  ,p_bng_attribute1                 in  varchar2  default null
  ,p_bng_attribute2                 in  varchar2  default null
  ,p_bng_attribute3                 in  varchar2  default null
  ,p_bng_attribute4                 in  varchar2  default null
  ,p_bng_attribute5                 in  varchar2  default null
  ,p_bng_attribute6                 in  varchar2  default null
  ,p_bng_attribute7                 in  varchar2  default null
  ,p_bng_attribute8                 in  varchar2  default null
  ,p_bng_attribute9                 in  varchar2  default null
  ,p_bng_attribute10                in  varchar2  default null
  ,p_bng_attribute11                in  varchar2  default null
  ,p_bng_attribute12                in  varchar2  default null
  ,p_bng_attribute13                in  varchar2  default null
  ,p_bng_attribute14                in  varchar2  default null
  ,p_bng_attribute15                in  varchar2  default null
  ,p_bng_attribute16                in  varchar2  default null
  ,p_bng_attribute17                in  varchar2  default null
  ,p_bng_attribute18                in  varchar2  default null
  ,p_bng_attribute19                in  varchar2  default null
  ,p_bng_attribute20                in  varchar2  default null
  ,p_bng_attribute21                in  varchar2  default null
  ,p_bng_attribute22                in  varchar2  default null
  ,p_bng_attribute23                in  varchar2  default null
  ,p_bng_attribute24                in  varchar2  default null
  ,p_bng_attribute25                in  varchar2  default null
  ,p_bng_attribute26                in  varchar2  default null
  ,p_bng_attribute27                in  varchar2  default null
  ,p_bng_attribute28                in  varchar2  default null
  ,p_bng_attribute29                in  varchar2  default null
  ,p_bng_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_Benefits_Group >------------------------|
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
--   p_benfts_grp_id                Yes  number    PK of record
--   p_business_group_id            Yes  number    Business Group of Record
--   p_name                         Yes  varchar2
--   p_bng_desc                     No   varchar2
--   p_bng_attribute_category       No   varchar2  Descriptive Flexfield
--   p_bng_attribute1               No   varchar2  Descriptive Flexfield
--   p_bng_attribute2               No   varchar2  Descriptive Flexfield
--   p_bng_attribute3               No   varchar2  Descriptive Flexfield
--   p_bng_attribute4               No   varchar2  Descriptive Flexfield
--   p_bng_attribute5               No   varchar2  Descriptive Flexfield
--   p_bng_attribute6               No   varchar2  Descriptive Flexfield
--   p_bng_attribute7               No   varchar2  Descriptive Flexfield
--   p_bng_attribute8               No   varchar2  Descriptive Flexfield
--   p_bng_attribute9               No   varchar2  Descriptive Flexfield
--   p_bng_attribute10              No   varchar2  Descriptive Flexfield
--   p_bng_attribute11              No   varchar2  Descriptive Flexfield
--   p_bng_attribute12              No   varchar2  Descriptive Flexfield
--   p_bng_attribute13              No   varchar2  Descriptive Flexfield
--   p_bng_attribute14              No   varchar2  Descriptive Flexfield
--   p_bng_attribute15              No   varchar2  Descriptive Flexfield
--   p_bng_attribute16              No   varchar2  Descriptive Flexfield
--   p_bng_attribute17              No   varchar2  Descriptive Flexfield
--   p_bng_attribute18              No   varchar2  Descriptive Flexfield
--   p_bng_attribute19              No   varchar2  Descriptive Flexfield
--   p_bng_attribute20              No   varchar2  Descriptive Flexfield
--   p_bng_attribute21              No   varchar2  Descriptive Flexfield
--   p_bng_attribute22              No   varchar2  Descriptive Flexfield
--   p_bng_attribute23              No   varchar2  Descriptive Flexfield
--   p_bng_attribute24              No   varchar2  Descriptive Flexfield
--   p_bng_attribute25              No   varchar2  Descriptive Flexfield
--   p_bng_attribute26              No   varchar2  Descriptive Flexfield
--   p_bng_attribute27              No   varchar2  Descriptive Flexfield
--   p_bng_attribute28              No   varchar2  Descriptive Flexfield
--   p_bng_attribute29              No   varchar2  Descriptive Flexfield
--   p_bng_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_Benefits_Group
  (
   p_validate                       in boolean    default false
  ,p_benfts_grp_id                  in  number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_bng_desc                       in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Benefits_Group >------------------------|
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
--   p_benfts_grp_id                Yes  number    PK of record
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
procedure delete_Benefits_Group
  (
   p_validate                       in boolean        default false
  ,p_benfts_grp_id                  in  number
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
--   p_benfts_grp_id                 Yes  number   PK of record
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
    p_benfts_grp_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_Benefits_Group_api;

 

/
