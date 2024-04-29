--------------------------------------------------------
--  DDL for Package BEN_CNTNG_PRTN_ELIG_PRFL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CNTNG_PRTN_ELIG_PRFL_API" AUTHID CURRENT_USER as
/* $Header: becgpapi.pkh 120.0 2005/05/28 01:01:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_CNTNG_PRTN_ELIG_PRFL >------------------------|
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
--   p_eligy_prfl_id                Yes  number
--   p_name                         No   varchar2
--   p_pymt_must_be_rcvd_uom        No   varchar2
--   p_pymt_must_be_rcvd_num        No   number
--   p_pymt_must_be_rcvd_rl         No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_cgp_attribute_category       No   varchar2  Descriptive Flexfield
--   p_cgp_attribute1               No   varchar2  Descriptive Flexfield
--   p_cgp_attribute2               No   varchar2  Descriptive Flexfield
--   p_cgp_attribute3               No   varchar2  Descriptive Flexfield
--   p_cgp_attribute4               No   varchar2  Descriptive Flexfield
--   p_cgp_attribute5               No   varchar2  Descriptive Flexfield
--   p_cgp_attribute6               No   varchar2  Descriptive Flexfield
--   p_cgp_attribute7               No   varchar2  Descriptive Flexfield
--   p_cgp_attribute8               No   varchar2  Descriptive Flexfield
--   p_cgp_attribute9               No   varchar2  Descriptive Flexfield
--   p_cgp_attribute10              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute11              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute12              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute13              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute14              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute15              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute16              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute17              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute18              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute19              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute20              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute21              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute22              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute23              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute24              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute25              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute26              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute27              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute28              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute29              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_cntng_prtn_elig_prfl_id      Yes  number    PK of record
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
procedure create_CNTNG_PRTN_ELIG_PRFL
(
   p_validate                       in boolean    default false
  ,p_cntng_prtn_elig_prfl_id        out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_eligy_prfl_id                  in  number    default null
  ,p_name                           in  varchar2  default null
  ,p_pymt_must_be_rcvd_uom          in  varchar2  default null
  ,p_pymt_must_be_rcvd_num          in  number    default null
  ,p_pymt_must_be_rcvd_rl           in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_cgp_attribute_category         in  varchar2  default null
  ,p_cgp_attribute1                 in  varchar2  default null
  ,p_cgp_attribute2                 in  varchar2  default null
  ,p_cgp_attribute3                 in  varchar2  default null
  ,p_cgp_attribute4                 in  varchar2  default null
  ,p_cgp_attribute5                 in  varchar2  default null
  ,p_cgp_attribute6                 in  varchar2  default null
  ,p_cgp_attribute7                 in  varchar2  default null
  ,p_cgp_attribute8                 in  varchar2  default null
  ,p_cgp_attribute9                 in  varchar2  default null
  ,p_cgp_attribute10                in  varchar2  default null
  ,p_cgp_attribute11                in  varchar2  default null
  ,p_cgp_attribute12                in  varchar2  default null
  ,p_cgp_attribute13                in  varchar2  default null
  ,p_cgp_attribute14                in  varchar2  default null
  ,p_cgp_attribute15                in  varchar2  default null
  ,p_cgp_attribute16                in  varchar2  default null
  ,p_cgp_attribute17                in  varchar2  default null
  ,p_cgp_attribute18                in  varchar2  default null
  ,p_cgp_attribute19                in  varchar2  default null
  ,p_cgp_attribute20                in  varchar2  default null
  ,p_cgp_attribute21                in  varchar2  default null
  ,p_cgp_attribute22                in  varchar2  default null
  ,p_cgp_attribute23                in  varchar2  default null
  ,p_cgp_attribute24                in  varchar2  default null
  ,p_cgp_attribute25                in  varchar2  default null
  ,p_cgp_attribute26                in  varchar2  default null
  ,p_cgp_attribute27                in  varchar2  default null
  ,p_cgp_attribute28                in  varchar2  default null
  ,p_cgp_attribute29                in  varchar2  default null
  ,p_cgp_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_CNTNG_PRTN_ELIG_PRFL >------------------------|
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
--   p_cntng_prtn_elig_prfl_id      Yes  number    PK of record
--   p_eligy_prfl_id                Yes  number
--   p_name                         No   varchar2
--   p_pymt_must_be_rcvd_uom        No   varchar2
--   p_pymt_must_be_rcvd_num        No   number
--   p_pymt_must_be_rcvd_rl         No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_cgp_attribute_category       No   varchar2  Descriptive Flexfield
--   p_cgp_attribute1               No   varchar2  Descriptive Flexfield
--   p_cgp_attribute2               No   varchar2  Descriptive Flexfield
--   p_cgp_attribute3               No   varchar2  Descriptive Flexfield
--   p_cgp_attribute4               No   varchar2  Descriptive Flexfield
--   p_cgp_attribute5               No   varchar2  Descriptive Flexfield
--   p_cgp_attribute6               No   varchar2  Descriptive Flexfield
--   p_cgp_attribute7               No   varchar2  Descriptive Flexfield
--   p_cgp_attribute8               No   varchar2  Descriptive Flexfield
--   p_cgp_attribute9               No   varchar2  Descriptive Flexfield
--   p_cgp_attribute10              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute11              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute12              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute13              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute14              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute15              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute16              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute17              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute18              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute19              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute20              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute21              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute22              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute23              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute24              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute25              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute26              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute27              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute28              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute29              No   varchar2  Descriptive Flexfield
--   p_cgp_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_CNTNG_PRTN_ELIG_PRFL
  (
   p_validate                       in boolean    default false
  ,p_cntng_prtn_elig_prfl_id        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_eligy_prfl_id                  in  number    default hr_api.g_number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_pymt_must_be_rcvd_uom          in  varchar2  default hr_api.g_varchar2
  ,p_pymt_must_be_rcvd_num          in  number    default hr_api.g_number
  ,p_pymt_must_be_rcvd_rl           in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_cgp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_CNTNG_PRTN_ELIG_PRFL >------------------------|
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
--   p_cntng_prtn_elig_prfl_id      Yes  number    PK of record
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
procedure delete_CNTNG_PRTN_ELIG_PRFL
  (
   p_validate                       in boolean        default false
  ,p_cntng_prtn_elig_prfl_id        in  number
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
--   p_cntng_prtn_elig_prfl_id                 Yes  number   PK of record
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
    p_cntng_prtn_elig_prfl_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end ben_CNTNG_PRTN_ELIG_PRFL_api;

 

/
