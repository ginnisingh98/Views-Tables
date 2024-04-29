--------------------------------------------------------
--  DDL for Package BEN_SCHEDD_HRS_RATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_SCHEDD_HRS_RATE_API" AUTHID CURRENT_USER as
/* $Header: beshrapi.pkh 120.0 2005/05/28 11:51:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_SCHEDD_HRS_RATE >------------------------|
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
--   p_vrbl_rt_prfl_id              No   number
--   p_excld_flag                   Yes  varchar2
--   p_ordr_num                     No   number
--   p_freq_cd                      No   varchar2
--   p_hrs_num                      No   number
-- p_max_hrs_num             	  No number
-- p_schedd_hrs_rl           	  No number
-- p_determination_cd        	  No varchar2
-- p_determination_rl        	  No number
-- p_rounding_cd             	  No varchar2
-- p_rounding_rl             	  No number
--   p_business_group_id            No   number    Business Group of Record
--   p_shr_attribute_category       No   varchar2  Descriptive Flexfield
--   p_shr_attribute1               No   varchar2  Descriptive Flexfield
--   p_shr_attribute2               No   varchar2  Descriptive Flexfield
--   p_shr_attribute3               No   varchar2  Descriptive Flexfield
--   p_shr_attribute4               No   varchar2  Descriptive Flexfield
--   p_shr_attribute5               No   varchar2  Descriptive Flexfield
--   p_shr_attribute6               No   varchar2  Descriptive Flexfield
--   p_shr_attribute7               No   varchar2  Descriptive Flexfield
--   p_shr_attribute8               No   varchar2  Descriptive Flexfield
--   p_shr_attribute9               No   varchar2  Descriptive Flexfield
--   p_shr_attribute10              No   varchar2  Descriptive Flexfield
--   p_shr_attribute11              No   varchar2  Descriptive Flexfield
--   p_shr_attribute12              No   varchar2  Descriptive Flexfield
--   p_shr_attribute13              No   varchar2  Descriptive Flexfield
--   p_shr_attribute14              No   varchar2  Descriptive Flexfield
--   p_shr_attribute15              No   varchar2  Descriptive Flexfield
--   p_shr_attribute16              No   varchar2  Descriptive Flexfield
--   p_shr_attribute17              No   varchar2  Descriptive Flexfield
--   p_shr_attribute18              No   varchar2  Descriptive Flexfield
--   p_shr_attribute19              No   varchar2  Descriptive Flexfield
--   p_shr_attribute20              No   varchar2  Descriptive Flexfield
--   p_shr_attribute21              No   varchar2  Descriptive Flexfield
--   p_shr_attribute22              No   varchar2  Descriptive Flexfield
--   p_shr_attribute23              No   varchar2  Descriptive Flexfield
--   p_shr_attribute24              No   varchar2  Descriptive Flexfield
--   p_shr_attribute25              No   varchar2  Descriptive Flexfield
--   p_shr_attribute26              No   varchar2  Descriptive Flexfield
--   p_shr_attribute27              No   varchar2  Descriptive Flexfield
--   p_shr_attribute28              No   varchar2  Descriptive Flexfield
--   p_shr_attribute29              No   varchar2  Descriptive Flexfield
--   p_shr_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_schedd_hrs_rt_id             Yes  number    PK of record
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
procedure create_SCHEDD_HRS_RATE
(
   p_validate                       in boolean    default false
  ,p_schedd_hrs_rt_id               out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_vrbl_rt_prfl_id                in  number    default null
  ,p_excld_flag                     in  varchar2  default null
  ,p_ordr_num                       in  number    default null
  ,p_freq_cd                        in  varchar2  default null
  ,p_hrs_num                        in  number    default null
  ,p_max_hrs_num             	  in number			 default null
  ,p_schedd_hrs_rl           	  in number			 default null
  ,p_determination_cd        	  in varchar2		 default null
  ,p_determination_rl        	  in number			 default null
  ,p_rounding_cd             	  in varchar2		 default null
  ,p_rounding_rl             	  in number  		 default null
  ,p_business_group_id              in  number    default null
  ,p_shr_attribute_category         in  varchar2  default null
  ,p_shr_attribute1                 in  varchar2  default null
  ,p_shr_attribute2                 in  varchar2  default null
  ,p_shr_attribute3                 in  varchar2  default null
  ,p_shr_attribute4                 in  varchar2  default null
  ,p_shr_attribute5                 in  varchar2  default null
  ,p_shr_attribute6                 in  varchar2  default null
  ,p_shr_attribute7                 in  varchar2  default null
  ,p_shr_attribute8                 in  varchar2  default null
  ,p_shr_attribute9                 in  varchar2  default null
  ,p_shr_attribute10                in  varchar2  default null
  ,p_shr_attribute11                in  varchar2  default null
  ,p_shr_attribute12                in  varchar2  default null
  ,p_shr_attribute13                in  varchar2  default null
  ,p_shr_attribute14                in  varchar2  default null
  ,p_shr_attribute15                in  varchar2  default null
  ,p_shr_attribute16                in  varchar2  default null
  ,p_shr_attribute17                in  varchar2  default null
  ,p_shr_attribute18                in  varchar2  default null
  ,p_shr_attribute19                in  varchar2  default null
  ,p_shr_attribute20                in  varchar2  default null
  ,p_shr_attribute21                in  varchar2  default null
  ,p_shr_attribute22                in  varchar2  default null
  ,p_shr_attribute23                in  varchar2  default null
  ,p_shr_attribute24                in  varchar2  default null
  ,p_shr_attribute25                in  varchar2  default null
  ,p_shr_attribute26                in  varchar2  default null
  ,p_shr_attribute27                in  varchar2  default null
  ,p_shr_attribute28                in  varchar2  default null
  ,p_shr_attribute29                in  varchar2  default null
  ,p_shr_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_SCHEDD_HRS_RATE >------------------------|
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
--   p_schedd_hrs_rt_id             Yes  number    PK of record
--   p_vrbl_rt_prfl_id              No   number
--   p_excld_flag                   Yes  varchar2
--   p_ordr_num                     No   number
--   p_freq_cd                      No   varchar2
--   p_hrs_num                      No   number

--   p_business_group_id            No   number    Business Group of Record
--   p_shr_attribute_category       No   varchar2  Descriptive Flexfield
--   p_shr_attribute1               No   varchar2  Descriptive Flexfield
--   p_shr_attribute2               No   varchar2  Descriptive Flexfield
--   p_shr_attribute3               No   varchar2  Descriptive Flexfield
--   p_shr_attribute4               No   varchar2  Descriptive Flexfield
--   p_shr_attribute5               No   varchar2  Descriptive Flexfield
--   p_shr_attribute6               No   varchar2  Descriptive Flexfield
--   p_shr_attribute7               No   varchar2  Descriptive Flexfield
--   p_shr_attribute8               No   varchar2  Descriptive Flexfield
--   p_shr_attribute9               No   varchar2  Descriptive Flexfield
--   p_shr_attribute10              No   varchar2  Descriptive Flexfield
--   p_shr_attribute11              No   varchar2  Descriptive Flexfield
--   p_shr_attribute12              No   varchar2  Descriptive Flexfield
--   p_shr_attribute13              No   varchar2  Descriptive Flexfield
--   p_shr_attribute14              No   varchar2  Descriptive Flexfield
--   p_shr_attribute15              No   varchar2  Descriptive Flexfield
--   p_shr_attribute16              No   varchar2  Descriptive Flexfield
--   p_shr_attribute17              No   varchar2  Descriptive Flexfield
--   p_shr_attribute18              No   varchar2  Descriptive Flexfield
--   p_shr_attribute19              No   varchar2  Descriptive Flexfield
--   p_shr_attribute20              No   varchar2  Descriptive Flexfield
--   p_shr_attribute21              No   varchar2  Descriptive Flexfield
--   p_shr_attribute22              No   varchar2  Descriptive Flexfield
--   p_shr_attribute23              No   varchar2  Descriptive Flexfield
--   p_shr_attribute24              No   varchar2  Descriptive Flexfield
--   p_shr_attribute25              No   varchar2  Descriptive Flexfield
--   p_shr_attribute26              No   varchar2  Descriptive Flexfield
--   p_shr_attribute27              No   varchar2  Descriptive Flexfield
--   p_shr_attribute28              No   varchar2  Descriptive Flexfield
--   p_shr_attribute29              No   varchar2  Descriptive Flexfield
--   p_shr_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_SCHEDD_HRS_RATE
  (
   p_validate                       in boolean    default false
  ,p_schedd_hrs_rt_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_vrbl_rt_prfl_id                in  number    default hr_api.g_number
  ,p_excld_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_freq_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_hrs_num                        in  number    default hr_api.g_number
  ,p_max_hrs_num                  in number			 default hr_api.g_number
  ,p_schedd_hrs_rl                in number			 default hr_api.g_number
  ,p_determination_cd             in varchar2		 default hr_api.g_varchar2
  ,p_determination_rl             in number			 default hr_api.g_number
  ,p_rounding_cd                  in varchar2		 default hr_api.g_varchar2
  ,p_rounding_rl                  in number  		 default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_shr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_shr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_shr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_shr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_shr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_shr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_shr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_shr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_shr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_shr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_shr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_shr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_shr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_shr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_shr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_shr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_shr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_shr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_shr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_shr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_shr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_shr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_shr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_shr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_shr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_shr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_shr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_shr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_shr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_shr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_shr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_SCHEDD_HRS_RATE >------------------------|
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
--   p_schedd_hrs_rt_id             Yes  number    PK of record
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
procedure delete_SCHEDD_HRS_RATE
  (
   p_validate                       in boolean        default false
  ,p_schedd_hrs_rt_id               in  number
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
--   p_schedd_hrs_rt_id                 Yes  number   PK of record
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
    p_schedd_hrs_rt_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end ben_SCHEDD_HRS_RATE_api;

 

/
