--------------------------------------------------------
--  DDL for Package BEN_DPNT_CVRD_OTHR_PL_RT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DPNT_CVRD_OTHR_PL_RT_API" AUTHID CURRENT_USER as
/* $Header: bedclapi.pkh 120.0 2005/05/28 01:32:21 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_DPNT_CVRD_OTHR_PL_RT >------------------------|
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
--   p_ordr_num                     No   number
--   p_excld_flag                   Yes  varchar2
--   p_cvg_det_dt_cd                No   varchar2
--   p_business_group_id            Yes  number    Business Group of Record
--   p_vrbl_rt_prfl_id                Yes  number
--   p_pl_id                        Yes  number
--   p_dcl_attribute_category       No   varchar2  Descriptive Flexfield
--   p_dcl_attribute1               No   varchar2  Descriptive Flexfield
--   p_dcl_attribute2               No   varchar2  Descriptive Flexfield
--   p_dcl_attribute3               No   varchar2  Descriptive Flexfield
--   p_dcl_attribute4               No   varchar2  Descriptive Flexfield
--   p_dcl_attribute5               No   varchar2  Descriptive Flexfield
--   p_dcl_attribute6               No   varchar2  Descriptive Flexfield
--   p_dcl_attribute7               No   varchar2  Descriptive Flexfield
--   p_dcl_attribute8               No   varchar2  Descriptive Flexfield
--   p_dcl_attribute9               No   varchar2  Descriptive Flexfield
--   p_dcl_attribute10              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute11              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute12              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute13              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute14              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute15              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute16              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute17              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute18              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute19              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute20              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute21              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute22              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute23              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute24              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute25              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute26              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute27              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute28              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute29              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_dpnt_cvrd_othr_pl_rt_id    Yes  number    PK of record
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
procedure create_DPNT_CVRD_OTHR_PL_RT
(
   p_validate                       in boolean    default false
  ,p_dpnt_cvrd_othr_pl_rt_id      out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_ordr_num                       in  number    default null
  ,p_excld_flag                     in  varchar2  default 'N'
  ,p_cvg_det_dt_cd                  in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_vrbl_rt_prfl_id                  in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_dcl_attribute_category         in  varchar2  default null
  ,p_dcl_attribute1                 in  varchar2  default null
  ,p_dcl_attribute2                 in  varchar2  default null
  ,p_dcl_attribute3                 in  varchar2  default null
  ,p_dcl_attribute4                 in  varchar2  default null
  ,p_dcl_attribute5                 in  varchar2  default null
  ,p_dcl_attribute6                 in  varchar2  default null
  ,p_dcl_attribute7                 in  varchar2  default null
  ,p_dcl_attribute8                 in  varchar2  default null
  ,p_dcl_attribute9                 in  varchar2  default null
  ,p_dcl_attribute10                in  varchar2  default null
  ,p_dcl_attribute11                in  varchar2  default null
  ,p_dcl_attribute12                in  varchar2  default null
  ,p_dcl_attribute13                in  varchar2  default null
  ,p_dcl_attribute14                in  varchar2  default null
  ,p_dcl_attribute15                in  varchar2  default null
  ,p_dcl_attribute16                in  varchar2  default null
  ,p_dcl_attribute17                in  varchar2  default null
  ,p_dcl_attribute18                in  varchar2  default null
  ,p_dcl_attribute19                in  varchar2  default null
  ,p_dcl_attribute20                in  varchar2  default null
  ,p_dcl_attribute21                in  varchar2  default null
  ,p_dcl_attribute22                in  varchar2  default null
  ,p_dcl_attribute23                in  varchar2  default null
  ,p_dcl_attribute24                in  varchar2  default null
  ,p_dcl_attribute25                in  varchar2  default null
  ,p_dcl_attribute26                in  varchar2  default null
  ,p_dcl_attribute27                in  varchar2  default null
  ,p_dcl_attribute28                in  varchar2  default null
  ,p_dcl_attribute29                in  varchar2  default null
  ,p_dcl_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_DPNT_CVRD_OTHR_PL_RT >------------------------|
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
--   p_dpnt_cvrd_othr_pl_rt_id    Yes  number    PK of record
--   p_ordr_num                     No   number
--   p_excld_flag                   Yes  varchar2
--   p_cvg_det_dt_cd                No   varchar2
--   p_business_group_id            Yes  number    Business Group of Record
--   p_vrbl_rt_prfl_id                Yes  number
--   p_pl_id                        Yes  number
--   p_dcl_attribute_category       No   varchar2  Descriptive Flexfield
--   p_dcl_attribute1               No   varchar2  Descriptive Flexfield
--   p_dcl_attribute2               No   varchar2  Descriptive Flexfield
--   p_dcl_attribute3               No   varchar2  Descriptive Flexfield
--   p_dcl_attribute4               No   varchar2  Descriptive Flexfield
--   p_dcl_attribute5               No   varchar2  Descriptive Flexfield
--   p_dcl_attribute6               No   varchar2  Descriptive Flexfield
--   p_dcl_attribute7               No   varchar2  Descriptive Flexfield
--   p_dcl_attribute8               No   varchar2  Descriptive Flexfield
--   p_dcl_attribute9               No   varchar2  Descriptive Flexfield
--   p_dcl_attribute10              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute11              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute12              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute13              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute14              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute15              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute16              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute17              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute18              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute19              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute20              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute21              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute22              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute23              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute24              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute25              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute26              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute27              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute28              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute29              No   varchar2  Descriptive Flexfield
--   p_dcl_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_DPNT_CVRD_OTHR_PL_RT
  (
   p_validate                       in boolean    default false
  ,p_dpnt_cvrd_othr_pl_rt_id      in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_excld_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_cvg_det_dt_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_vrbl_rt_prfl_id                  in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_dcl_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_dcl_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_dcl_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_dcl_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_dcl_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_dcl_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_dcl_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_dcl_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_dcl_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_dcl_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_dcl_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_dcl_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_dcl_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_dcl_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_dcl_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_dcl_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_dcl_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_dcl_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_dcl_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_dcl_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_dcl_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_dcl_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_dcl_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_dcl_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_dcl_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_dcl_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_dcl_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_dcl_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_dcl_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_dcl_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_dcl_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_DPNT_CVRD_OTHR_PL_RT >------------------------|
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
--   p_dpnt_cvrd_othr_pl_rt_id    Yes  number    PK of record
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
procedure delete_DPNT_CVRD_OTHR_PL_RT
  (
   p_validate                       in boolean        default false
  ,p_dpnt_cvrd_othr_pl_rt_id      in  number
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
--   p_dpnt_cvrd_othr_pl_rt_id                 Yes  number   PK of record
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
    p_dpnt_cvrd_othr_pl_rt_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end ben_DPNT_CVRD_OTHR_PL_RT_api;

 

/
