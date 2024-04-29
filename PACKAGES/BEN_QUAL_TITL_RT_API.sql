--------------------------------------------------------
--  DDL for Package BEN_QUAL_TITL_RT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_QUAL_TITL_RT_API" AUTHID CURRENT_USER as
/* $Header: beqtrapi.pkh 120.0 2005/05/28 11:32:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_qual_titl_rt >------------------------|
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
--   p_vrbl_rt_prfl_id              Yes  number
--   p_ordr_num                     No   number
--   p_excld_flag                   Yes  varchar2
--   p_qualification_type_id        No   number
--   p_title                        No   varchar2
--   p_qtr_attribute_category       No   varchar2  Descriptive Flexfield
--   p_qtr_attribute1               No   varchar2  Descriptive Flexfield
--   p_qtr_attribute2               No   varchar2  Descriptive Flexfield
--   p_qtr_attribute3               No   varchar2  Descriptive Flexfield
--   p_qtr_attribute4               No   varchar2  Descriptive Flexfield
--   p_qtr_attribute5               No   varchar2  Descriptive Flexfield
--   p_qtr_attribute6               No   varchar2  Descriptive Flexfield
--   p_qtr_attribute7               No   varchar2  Descriptive Flexfield
--   p_qtr_attribute8               No   varchar2  Descriptive Flexfield
--   p_qtr_attribute9               No   varchar2  Descriptive Flexfield
--   p_qtr_attribute10              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute11              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute12              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute13              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute14              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute15              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute16              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute17              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute18              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute19              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute20              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute21              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute22              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute23              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute24              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute25              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute26              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute27              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute28              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute29              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date               Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_qual_titl_rt_id         Yes  number    PK of record
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
procedure create_qual_titl_rt
(
   p_validate                       in boolean    default false
  ,p_qual_titl_rt_id           out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_vrbl_rt_prfl_id                  in  number    default null
  ,p_ordr_num                       in  number    default null
  ,p_excld_flag                     in  varchar2  default 'N'
  ,p_qualification_type_id          in  number    default null
  ,p_title                          in  varchar2  default null
  ,p_qtr_attribute_category         in  varchar2  default null
  ,p_qtr_attribute1                 in  varchar2  default null
  ,p_qtr_attribute2                 in  varchar2  default null
  ,p_qtr_attribute3                 in  varchar2  default null
  ,p_qtr_attribute4                 in  varchar2  default null
  ,p_qtr_attribute5                 in  varchar2  default null
  ,p_qtr_attribute6                 in  varchar2  default null
  ,p_qtr_attribute7                 in  varchar2  default null
  ,p_qtr_attribute8                 in  varchar2  default null
  ,p_qtr_attribute9                 in  varchar2  default null
  ,p_qtr_attribute10                in  varchar2  default null
  ,p_qtr_attribute11                in  varchar2  default null
  ,p_qtr_attribute12                in  varchar2  default null
  ,p_qtr_attribute13                in  varchar2  default null
  ,p_qtr_attribute14                in  varchar2  default null
  ,p_qtr_attribute15                in  varchar2  default null
  ,p_qtr_attribute16                in  varchar2  default null
  ,p_qtr_attribute17                in  varchar2  default null
  ,p_qtr_attribute18                in  varchar2  default null
  ,p_qtr_attribute19                in  varchar2  default null
  ,p_qtr_attribute20                in  varchar2  default null
  ,p_qtr_attribute21                in  varchar2  default null
  ,p_qtr_attribute22                in  varchar2  default null
  ,p_qtr_attribute23                in  varchar2  default null
  ,p_qtr_attribute24                in  varchar2  default null
  ,p_qtr_attribute25                in  varchar2  default null
  ,p_qtr_attribute26                in  varchar2  default null
  ,p_qtr_attribute27                in  varchar2  default null
  ,p_qtr_attribute28                in  varchar2  default null
  ,p_qtr_attribute29                in  varchar2  default null
  ,p_qtr_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_qual_titl_rt >------------------------|
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
--   p_qual_titl_rt_id         Yes  number    PK of record
--   p_business_group_id            Yes  number    Business Group of Record
--   p_vrbl_rt_prfl_id                Yes  number
--   p_ordr_num                     No   number
--   p_excld_flag                   Yes  varchar2
--   p_qualification_type_id        No   number
--   p_title                        No   varchar2
--   p_qtr_attribute_category       No   varchar2  Descriptive Flexfield
--   p_qtr_attribute1               No   varchar2  Descriptive Flexfield
--   p_qtr_attribute2               No   varchar2  Descriptive Flexfield
--   p_qtr_attribute3               No   varchar2  Descriptive Flexfield
--   p_qtr_attribute4               No   varchar2  Descriptive Flexfield
--   p_qtr_attribute5               No   varchar2  Descriptive Flexfield
--   p_qtr_attribute6               No   varchar2  Descriptive Flexfield
--   p_qtr_attribute7               No   varchar2  Descriptive Flexfield
--   p_qtr_attribute8               No   varchar2  Descriptive Flexfield
--   p_qtr_attribute9               No   varchar2  Descriptive Flexfield
--   p_qtr_attribute10              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute11              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute12              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute13              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute14              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute15              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute16              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute17              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute18              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute19              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute20              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute21              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute22              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute23              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute24              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute25              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute26              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute27              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute28              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute29              No   varchar2  Descriptive Flexfield
--   p_qtr_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_qual_titl_rt
  (
   p_validate                       in boolean    default false
  ,p_qual_titl_rt_id                in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_vrbl_rt_prfl_id                in  number    default hr_api.g_number
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_excld_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_qualification_type_id          in  number    default hr_api.g_number
  ,p_title                          in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_qtr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_qual_titl_rt >------------------------|
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
--   p_qual_titl_rt_id              Yes  number    PK of record
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
procedure delete_qual_titl_rt
  (
   p_validate                       in boolean        default false
  ,p_qual_titl_rt_id                in  number
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
--   p_qual_titl_rt_id              Yes  number   PK of record
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
    p_qual_titl_rt_id              in number
   ,p_object_version_number        in number
   ,p_effective_date               in date
   ,p_datetrack_mode               in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end ben_qual_titl_rt_api;

 

/
