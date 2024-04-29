--------------------------------------------------------
--  DDL for Package BEN_CRT_ORDERS_CVRD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CRT_ORDERS_CVRD_API" AUTHID CURRENT_USER as
/* $Header: becrdapi.pkh 120.0 2005/05/28 01:21:00 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_crt_orders_cvrd >------------------------|
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
--   p_crt_ordr_id                  No   number
--   p_person_id                    No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_crd_attribute_category       No   varchar2  Descriptive Flexfield
--   p_crd_attribute1               No   varchar2  Descriptive Flexfield
--   p_crd_attribute2               No   varchar2  Descriptive Flexfield
--   p_crd_attribute3               No   varchar2  Descriptive Flexfield
--   p_crd_attribute4               No   varchar2  Descriptive Flexfield
--   p_crd_attribute5               No   varchar2  Descriptive Flexfield
--   p_crd_attribute6               No   varchar2  Descriptive Flexfield
--   p_crd_attribute7               No   varchar2  Descriptive Flexfield
--   p_crd_attribute8               No   varchar2  Descriptive Flexfield
--   p_crd_attribute9               No   varchar2  Descriptive Flexfield
--   p_crd_attribute10              No   varchar2  Descriptive Flexfield
--   p_crd_attribute11              No   varchar2  Descriptive Flexfield
--   p_crd_attribute12              No   varchar2  Descriptive Flexfield
--   p_crd_attribute13              No   varchar2  Descriptive Flexfield
--   p_crd_attribute14              No   varchar2  Descriptive Flexfield
--   p_crd_attribute15              No   varchar2  Descriptive Flexfield
--   p_crd_attribute16              No   varchar2  Descriptive Flexfield
--   p_crd_attribute17              No   varchar2  Descriptive Flexfield
--   p_crd_attribute18              No   varchar2  Descriptive Flexfield
--   p_crd_attribute19              No   varchar2  Descriptive Flexfield
--   p_crd_attribute20              No   varchar2  Descriptive Flexfield
--   p_crd_attribute21              No   varchar2  Descriptive Flexfield
--   p_crd_attribute22              No   varchar2  Descriptive Flexfield
--   p_crd_attribute23              No   varchar2  Descriptive Flexfield
--   p_crd_attribute24              No   varchar2  Descriptive Flexfield
--   p_crd_attribute25              No   varchar2  Descriptive Flexfield
--   p_crd_attribute26              No   varchar2  Descriptive Flexfield
--   p_crd_attribute27              No   varchar2  Descriptive Flexfield
--   p_crd_attribute28              No   varchar2  Descriptive Flexfield
--   p_crd_attribute29              No   varchar2  Descriptive Flexfield
--   p_crd_attribute30              No   varchar2  Descriptive Flexfield
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_crt_ordr_cvrd_per_id         Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_crt_orders_cvrd
(
   p_validate                       in boolean    default false
  ,p_crt_ordr_cvrd_per_id           out nocopy number
  ,p_crt_ordr_id                    in  number    default null
  ,p_person_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_crd_attribute_category         in  varchar2  default null
  ,p_crd_attribute1                 in  varchar2  default null
  ,p_crd_attribute2                 in  varchar2  default null
  ,p_crd_attribute3                 in  varchar2  default null
  ,p_crd_attribute4                 in  varchar2  default null
  ,p_crd_attribute5                 in  varchar2  default null
  ,p_crd_attribute6                 in  varchar2  default null
  ,p_crd_attribute7                 in  varchar2  default null
  ,p_crd_attribute8                 in  varchar2  default null
  ,p_crd_attribute9                 in  varchar2  default null
  ,p_crd_attribute10                in  varchar2  default null
  ,p_crd_attribute11                in  varchar2  default null
  ,p_crd_attribute12                in  varchar2  default null
  ,p_crd_attribute13                in  varchar2  default null
  ,p_crd_attribute14                in  varchar2  default null
  ,p_crd_attribute15                in  varchar2  default null
  ,p_crd_attribute16                in  varchar2  default null
  ,p_crd_attribute17                in  varchar2  default null
  ,p_crd_attribute18                in  varchar2  default null
  ,p_crd_attribute19                in  varchar2  default null
  ,p_crd_attribute20                in  varchar2  default null
  ,p_crd_attribute21                in  varchar2  default null
  ,p_crd_attribute22                in  varchar2  default null
  ,p_crd_attribute23                in  varchar2  default null
  ,p_crd_attribute24                in  varchar2  default null
  ,p_crd_attribute25                in  varchar2  default null
  ,p_crd_attribute26                in  varchar2  default null
  ,p_crd_attribute27                in  varchar2  default null
  ,p_crd_attribute28                in  varchar2  default null
  ,p_crd_attribute29                in  varchar2  default null
  ,p_crd_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_crt_orders_cvrd >------------------------|
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
--   p_crt_ordr_cvrd_per_id         Yes  number    PK of record
--   p_crt_ordr_id                  No   number
--   p_person_id                    No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_crd_attribute_category       No   varchar2  Descriptive Flexfield
--   p_crd_attribute1               No   varchar2  Descriptive Flexfield
--   p_crd_attribute2               No   varchar2  Descriptive Flexfield
--   p_crd_attribute3               No   varchar2  Descriptive Flexfield
--   p_crd_attribute4               No   varchar2  Descriptive Flexfield
--   p_crd_attribute5               No   varchar2  Descriptive Flexfield
--   p_crd_attribute6               No   varchar2  Descriptive Flexfield
--   p_crd_attribute7               No   varchar2  Descriptive Flexfield
--   p_crd_attribute8               No   varchar2  Descriptive Flexfield
--   p_crd_attribute9               No   varchar2  Descriptive Flexfield
--   p_crd_attribute10              No   varchar2  Descriptive Flexfield
--   p_crd_attribute11              No   varchar2  Descriptive Flexfield
--   p_crd_attribute12              No   varchar2  Descriptive Flexfield
--   p_crd_attribute13              No   varchar2  Descriptive Flexfield
--   p_crd_attribute14              No   varchar2  Descriptive Flexfield
--   p_crd_attribute15              No   varchar2  Descriptive Flexfield
--   p_crd_attribute16              No   varchar2  Descriptive Flexfield
--   p_crd_attribute17              No   varchar2  Descriptive Flexfield
--   p_crd_attribute18              No   varchar2  Descriptive Flexfield
--   p_crd_attribute19              No   varchar2  Descriptive Flexfield
--   p_crd_attribute20              No   varchar2  Descriptive Flexfield
--   p_crd_attribute21              No   varchar2  Descriptive Flexfield
--   p_crd_attribute22              No   varchar2  Descriptive Flexfield
--   p_crd_attribute23              No   varchar2  Descriptive Flexfield
--   p_crd_attribute24              No   varchar2  Descriptive Flexfield
--   p_crd_attribute25              No   varchar2  Descriptive Flexfield
--   p_crd_attribute26              No   varchar2  Descriptive Flexfield
--   p_crd_attribute27              No   varchar2  Descriptive Flexfield
--   p_crd_attribute28              No   varchar2  Descriptive Flexfield
--   p_crd_attribute29              No   varchar2  Descriptive Flexfield
--   p_crd_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_crt_orders_cvrd
  (
   p_validate                       in boolean    default false
  ,p_crt_ordr_cvrd_per_id           in  number
  ,p_crt_ordr_id                    in  number    default hr_api.g_number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_crd_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_crt_orders_cvrd >------------------------|
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
--   p_crt_ordr_cvrd_per_id         Yes  number    PK of record
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
procedure delete_crt_orders_cvrd
  (
   p_validate                       in boolean        default false
  ,p_crt_ordr_cvrd_per_id           in  number
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
--   p_crt_ordr_cvrd_per_id                 Yes  number   PK of record
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
    p_crt_ordr_cvrd_per_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_crt_orders_cvrd_api;

 

/
