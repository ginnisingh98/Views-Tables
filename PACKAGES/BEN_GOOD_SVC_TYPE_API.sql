--------------------------------------------------------
--  DDL for Package BEN_GOOD_SVC_TYPE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_GOOD_SVC_TYPE_API" AUTHID CURRENT_USER as
/* $Header: begosapi.pkh 120.0 2005/05/28 03:08:10 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_GOOD_SVC_TYPE >------------------------|
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
--   p_typ_cd                       No   varchar2
--   p_description                  No   varchar2
--   p_gos_attribute_category       No   varchar2  Descriptive Flexfield
--   p_gos_attribute1               No   varchar2  Descriptive Flexfield
--   p_gos_attribute2               No   varchar2  Descriptive Flexfield
--   p_gos_attribute3               No   varchar2  Descriptive Flexfield
--   p_gos_attribute4               No   varchar2  Descriptive Flexfield
--   p_gos_attribute5               No   varchar2  Descriptive Flexfield
--   p_gos_attribute6               No   varchar2  Descriptive Flexfield
--   p_gos_attribute7               No   varchar2  Descriptive Flexfield
--   p_gos_attribute8               No   varchar2  Descriptive Flexfield
--   p_gos_attribute9               No   varchar2  Descriptive Flexfield
--   p_gos_attribute10              No   varchar2  Descriptive Flexfield
--   p_gos_attribute11              No   varchar2  Descriptive Flexfield
--   p_gos_attribute12              No   varchar2  Descriptive Flexfield
--   p_gos_attribute13              No   varchar2  Descriptive Flexfield
--   p_gos_attribute14              No   varchar2  Descriptive Flexfield
--   p_gos_attribute15              No   varchar2  Descriptive Flexfield
--   p_gos_attribute16              No   varchar2  Descriptive Flexfield
--   p_gos_attribute17              No   varchar2  Descriptive Flexfield
--   p_gos_attribute18              No   varchar2  Descriptive Flexfield
--   p_gos_attribute19              No   varchar2  Descriptive Flexfield
--   p_gos_attribute20              No   varchar2  Descriptive Flexfield
--   p_gos_attribute21              No   varchar2  Descriptive Flexfield
--   p_gos_attribute22              No   varchar2  Descriptive Flexfield
--   p_gos_attribute23              No   varchar2  Descriptive Flexfield
--   p_gos_attribute24              No   varchar2  Descriptive Flexfield
--   p_gos_attribute25              No   varchar2  Descriptive Flexfield
--   p_gos_attribute26              No   varchar2  Descriptive Flexfield
--   p_gos_attribute27              No   varchar2  Descriptive Flexfield
--   p_gos_attribute28              No   varchar2  Descriptive Flexfield
--   p_gos_attribute29              No   varchar2  Descriptive Flexfield
--   p_gos_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_gd_or_svc_typ_id             Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_GOOD_SVC_TYPE
(
   p_validate                       in boolean    default false
  ,p_gd_or_svc_typ_id               out nocopy number
  ,p_business_group_id              in  number    default null
  ,p_name                           in  varchar2  default null
  ,p_typ_cd                         in  varchar2  default null
  ,p_description                    in  varchar2  default null
  ,p_gos_attribute_category         in  varchar2  default null
  ,p_gos_attribute1                 in  varchar2  default null
  ,p_gos_attribute2                 in  varchar2  default null
  ,p_gos_attribute3                 in  varchar2  default null
  ,p_gos_attribute4                 in  varchar2  default null
  ,p_gos_attribute5                 in  varchar2  default null
  ,p_gos_attribute6                 in  varchar2  default null
  ,p_gos_attribute7                 in  varchar2  default null
  ,p_gos_attribute8                 in  varchar2  default null
  ,p_gos_attribute9                 in  varchar2  default null
  ,p_gos_attribute10                in  varchar2  default null
  ,p_gos_attribute11                in  varchar2  default null
  ,p_gos_attribute12                in  varchar2  default null
  ,p_gos_attribute13                in  varchar2  default null
  ,p_gos_attribute14                in  varchar2  default null
  ,p_gos_attribute15                in  varchar2  default null
  ,p_gos_attribute16                in  varchar2  default null
  ,p_gos_attribute17                in  varchar2  default null
  ,p_gos_attribute18                in  varchar2  default null
  ,p_gos_attribute19                in  varchar2  default null
  ,p_gos_attribute20                in  varchar2  default null
  ,p_gos_attribute21                in  varchar2  default null
  ,p_gos_attribute22                in  varchar2  default null
  ,p_gos_attribute23                in  varchar2  default null
  ,p_gos_attribute24                in  varchar2  default null
  ,p_gos_attribute25                in  varchar2  default null
  ,p_gos_attribute26                in  varchar2  default null
  ,p_gos_attribute27                in  varchar2  default null
  ,p_gos_attribute28                in  varchar2  default null
  ,p_gos_attribute29                in  varchar2  default null
  ,p_gos_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_GOOD_SVC_TYPE >------------------------|
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
--   p_gd_or_svc_typ_id             Yes  number    PK of record
--   p_business_group_id            Yes  number    Business Group of Record
--   p_name                         Yes  varchar2
--   p_typ_cd                       No   varchar2
--   p_description                  No   varchar2
--   p_gos_attribute_category       No   varchar2  Descriptive Flexfield
--   p_gos_attribute1               No   varchar2  Descriptive Flexfield
--   p_gos_attribute2               No   varchar2  Descriptive Flexfield
--   p_gos_attribute3               No   varchar2  Descriptive Flexfield
--   p_gos_attribute4               No   varchar2  Descriptive Flexfield
--   p_gos_attribute5               No   varchar2  Descriptive Flexfield
--   p_gos_attribute6               No   varchar2  Descriptive Flexfield
--   p_gos_attribute7               No   varchar2  Descriptive Flexfield
--   p_gos_attribute8               No   varchar2  Descriptive Flexfield
--   p_gos_attribute9               No   varchar2  Descriptive Flexfield
--   p_gos_attribute10              No   varchar2  Descriptive Flexfield
--   p_gos_attribute11              No   varchar2  Descriptive Flexfield
--   p_gos_attribute12              No   varchar2  Descriptive Flexfield
--   p_gos_attribute13              No   varchar2  Descriptive Flexfield
--   p_gos_attribute14              No   varchar2  Descriptive Flexfield
--   p_gos_attribute15              No   varchar2  Descriptive Flexfield
--   p_gos_attribute16              No   varchar2  Descriptive Flexfield
--   p_gos_attribute17              No   varchar2  Descriptive Flexfield
--   p_gos_attribute18              No   varchar2  Descriptive Flexfield
--   p_gos_attribute19              No   varchar2  Descriptive Flexfield
--   p_gos_attribute20              No   varchar2  Descriptive Flexfield
--   p_gos_attribute21              No   varchar2  Descriptive Flexfield
--   p_gos_attribute22              No   varchar2  Descriptive Flexfield
--   p_gos_attribute23              No   varchar2  Descriptive Flexfield
--   p_gos_attribute24              No   varchar2  Descriptive Flexfield
--   p_gos_attribute25              No   varchar2  Descriptive Flexfield
--   p_gos_attribute26              No   varchar2  Descriptive Flexfield
--   p_gos_attribute27              No   varchar2  Descriptive Flexfield
--   p_gos_attribute28              No   varchar2  Descriptive Flexfield
--   p_gos_attribute29              No   varchar2  Descriptive Flexfield
--   p_gos_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_GOOD_SVC_TYPE
  (
   p_validate                       in boolean    default false
  ,p_gd_or_svc_typ_id               in  number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_typ_cd                         in  varchar2  default hr_api.g_varchar2
  ,p_description                    in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_GOOD_SVC_TYPE >------------------------|
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
--   p_gd_or_svc_typ_id             Yes  number    PK of record
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
procedure delete_GOOD_SVC_TYPE
  (
   p_validate                       in boolean        default false
  ,p_gd_or_svc_typ_id               in  number
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
--   p_gd_or_svc_typ_id                 Yes  number   PK of record
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
    p_gd_or_svc_typ_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_GOOD_SVC_TYPE_api;

 

/
