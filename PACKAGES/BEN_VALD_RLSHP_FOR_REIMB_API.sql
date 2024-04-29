--------------------------------------------------------
--  DDL for Package BEN_VALD_RLSHP_FOR_REIMB_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_VALD_RLSHP_FOR_REIMB_API" AUTHID CURRENT_USER as
/* $Header: bevrpapi.pkh 120.0 2005/05/28 12:12:17 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Vald_Rlshp_For_Reimb >------------------------|
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
--   p_pl_id                        Yes  number
--   p_rlshp_typ_cd                 No   varchar2
--   p_vrp_attribute_category       No   varchar2  Descriptive Flexfield
--   p_vrp_attribute1               No   varchar2  Descriptive Flexfield
--   p_vrp_attribute2               No   varchar2  Descriptive Flexfield
--   p_vrp_attribute3               No   varchar2  Descriptive Flexfield
--   p_vrp_attribute4               No   varchar2  Descriptive Flexfield
--   p_vrp_attribute5               No   varchar2  Descriptive Flexfield
--   p_vrp_attribute6               No   varchar2  Descriptive Flexfield
--   p_vrp_attribute7               No   varchar2  Descriptive Flexfield
--   p_vrp_attribute8               No   varchar2  Descriptive Flexfield
--   p_vrp_attribute9               No   varchar2  Descriptive Flexfield
--   p_vrp_attribute10              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute11              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute12              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute13              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute14              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute15              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute16              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute17              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute18              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute19              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute20              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute21              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute22              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute23              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute24              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute25              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute26              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute27              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute28              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute29              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_vald_rlshp_for_reimb_id      Yes  number    PK of record
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
procedure create_Vald_Rlshp_For_Reimb
(
   p_validate                       in boolean    default false
  ,p_vald_rlshp_for_reimb_id        out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_rlshp_typ_cd                   in  varchar2  default null
  ,p_vrp_attribute_category         in  varchar2  default null
  ,p_vrp_attribute1                 in  varchar2  default null
  ,p_vrp_attribute2                 in  varchar2  default null
  ,p_vrp_attribute3                 in  varchar2  default null
  ,p_vrp_attribute4                 in  varchar2  default null
  ,p_vrp_attribute5                 in  varchar2  default null
  ,p_vrp_attribute6                 in  varchar2  default null
  ,p_vrp_attribute7                 in  varchar2  default null
  ,p_vrp_attribute8                 in  varchar2  default null
  ,p_vrp_attribute9                 in  varchar2  default null
  ,p_vrp_attribute10                in  varchar2  default null
  ,p_vrp_attribute11                in  varchar2  default null
  ,p_vrp_attribute12                in  varchar2  default null
  ,p_vrp_attribute13                in  varchar2  default null
  ,p_vrp_attribute14                in  varchar2  default null
  ,p_vrp_attribute15                in  varchar2  default null
  ,p_vrp_attribute16                in  varchar2  default null
  ,p_vrp_attribute17                in  varchar2  default null
  ,p_vrp_attribute18                in  varchar2  default null
  ,p_vrp_attribute19                in  varchar2  default null
  ,p_vrp_attribute20                in  varchar2  default null
  ,p_vrp_attribute21                in  varchar2  default null
  ,p_vrp_attribute22                in  varchar2  default null
  ,p_vrp_attribute23                in  varchar2  default null
  ,p_vrp_attribute24                in  varchar2  default null
  ,p_vrp_attribute25                in  varchar2  default null
  ,p_vrp_attribute26                in  varchar2  default null
  ,p_vrp_attribute27                in  varchar2  default null
  ,p_vrp_attribute28                in  varchar2  default null
  ,p_vrp_attribute29                in  varchar2  default null
  ,p_vrp_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_Vald_Rlshp_For_Reimb >------------------------|
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
--   p_vald_rlshp_for_reimb_id      Yes  number    PK of record
--   p_business_group_id            Yes  number    Business Group of Record
--   p_pl_id                        Yes  number
--   p_rlshp_typ_cd                 No   varchar2
--   p_vrp_attribute_category       No   varchar2  Descriptive Flexfield
--   p_vrp_attribute1               No   varchar2  Descriptive Flexfield
--   p_vrp_attribute2               No   varchar2  Descriptive Flexfield
--   p_vrp_attribute3               No   varchar2  Descriptive Flexfield
--   p_vrp_attribute4               No   varchar2  Descriptive Flexfield
--   p_vrp_attribute5               No   varchar2  Descriptive Flexfield
--   p_vrp_attribute6               No   varchar2  Descriptive Flexfield
--   p_vrp_attribute7               No   varchar2  Descriptive Flexfield
--   p_vrp_attribute8               No   varchar2  Descriptive Flexfield
--   p_vrp_attribute9               No   varchar2  Descriptive Flexfield
--   p_vrp_attribute10              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute11              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute12              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute13              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute14              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute15              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute16              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute17              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute18              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute19              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute20              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute21              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute22              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute23              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute24              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute25              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute26              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute27              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute28              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute29              No   varchar2  Descriptive Flexfield
--   p_vrp_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_Vald_Rlshp_For_Reimb
  (
   p_validate                       in boolean    default false
  ,p_vald_rlshp_for_reimb_id        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_rlshp_typ_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Vald_Rlshp_For_Reimb >------------------------|
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
--   p_vald_rlshp_for_reimb_id      Yes  number    PK of record
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
procedure delete_Vald_Rlshp_For_Reimb
  (
   p_validate                       in boolean        default false
  ,p_vald_rlshp_for_reimb_id        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
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
--   p_vald_rlshp_for_reimb_id                 Yes  number   PK of record
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
  (
    p_vald_rlshp_for_reimb_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end ben_Vald_Rlshp_For_Reimb_api;

 

/
