--------------------------------------------------------
--  DDL for Package BEN_DPNT_CVG_ELIG_PRFL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DPNT_CVG_ELIG_PRFL_API" AUTHID CURRENT_USER as
/* $Header: bedceapi.pkh 120.0.12010000.2 2010/04/07 06:40:30 pvelvano ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_DPNT_CVG_ELIG_PRFL >------------------------|
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
--   p_regn_id                      No   number
--   p_name                         Yes  varchar2
--   p_dpnt_cvg_eligy_prfl_stat_cd  No   varchar2
--   p_dce_desc                     No   varchar2
--   p_dpnt_cvg_elig_det_rl         No   number
--   p_dce_attribute_category       No   varchar2  Descriptive Flexfield
--   p_dce_attribute1               No   varchar2  Descriptive Flexfield
--   p_dce_attribute2               No   varchar2  Descriptive Flexfield
--   p_dce_attribute3               No   varchar2  Descriptive Flexfield
--   p_dce_attribute4               No   varchar2  Descriptive Flexfield
--   p_dce_attribute5               No   varchar2  Descriptive Flexfield
--   p_dce_attribute6               No   varchar2  Descriptive Flexfield
--   p_dce_attribute7               No   varchar2  Descriptive Flexfield
--   p_dce_attribute8               No   varchar2  Descriptive Flexfield
--   p_dce_attribute9               No   varchar2  Descriptive Flexfield
--   p_dce_attribute10              No   varchar2  Descriptive Flexfield
--   p_dce_attribute11              No   varchar2  Descriptive Flexfield
--   p_dce_attribute12              No   varchar2  Descriptive Flexfield
--   p_dce_attribute13              No   varchar2  Descriptive Flexfield
--   p_dce_attribute14              No   varchar2  Descriptive Flexfield
--   p_dce_attribute15              No   varchar2  Descriptive Flexfield
--   p_dce_attribute16              No   varchar2  Descriptive Flexfield
--   p_dce_attribute17              No   varchar2  Descriptive Flexfield
--   p_dce_attribute18              No   varchar2  Descriptive Flexfield
--   p_dce_attribute19              No   varchar2  Descriptive Flexfield
--   p_dce_attribute20              No   varchar2  Descriptive Flexfield
--   p_dce_attribute21              No   varchar2  Descriptive Flexfield
--   p_dce_attribute22              No   varchar2  Descriptive Flexfield
--   p_dce_attribute23              No   varchar2  Descriptive Flexfield
--   p_dce_attribute24              No   varchar2  Descriptive Flexfield
--   p_dce_attribute25              No   varchar2  Descriptive Flexfield
--   p_dce_attribute26              No   varchar2  Descriptive Flexfield
--   p_dce_attribute27              No   varchar2  Descriptive Flexfield
--   p_dce_attribute28              No   varchar2  Descriptive Flexfield
--   p_dce_attribute29              No   varchar2  Descriptive Flexfield
--   p_dce_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_dpnt_cvg_eligy_prfl_id       Yes  number    PK of record
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_DPNT_CVG_ELIG_PRFL
(
   p_validate                       in boolean    default false
  ,p_dpnt_cvg_eligy_prfl_id         out nocopy number
  ,p_effective_end_date             out nocopy date
  ,p_effective_start_date           out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_regn_id                        in  number    default null
  ,p_name                           in  varchar2  default null
  ,p_dpnt_cvg_eligy_prfl_stat_cd    in  varchar2  default null
  ,p_dce_desc                       in  varchar2  default null
  ,p_dpnt_cvg_elig_det_rl           in  number    default null
  ,p_dce_attribute_category         in  varchar2  default null
  ,p_dce_attribute1                 in  varchar2  default null
  ,p_dce_attribute2                 in  varchar2  default null
  ,p_dce_attribute3                 in  varchar2  default null
  ,p_dce_attribute4                 in  varchar2  default null
  ,p_dce_attribute5                 in  varchar2  default null
  ,p_dce_attribute6                 in  varchar2  default null
  ,p_dce_attribute7                 in  varchar2  default null
  ,p_dce_attribute8                 in  varchar2  default null
  ,p_dce_attribute9                 in  varchar2  default null
  ,p_dce_attribute10                in  varchar2  default null
  ,p_dce_attribute11                in  varchar2  default null
  ,p_dce_attribute12                in  varchar2  default null
  ,p_dce_attribute13                in  varchar2  default null
  ,p_dce_attribute14                in  varchar2  default null
  ,p_dce_attribute15                in  varchar2  default null
  ,p_dce_attribute16                in  varchar2  default null
  ,p_dce_attribute17                in  varchar2  default null
  ,p_dce_attribute18                in  varchar2  default null
  ,p_dce_attribute19                in  varchar2  default null
  ,p_dce_attribute20                in  varchar2  default null
  ,p_dce_attribute21                in  varchar2  default null
  ,p_dce_attribute22                in  varchar2  default null
  ,p_dce_attribute23                in  varchar2  default null
  ,p_dce_attribute24                in  varchar2  default null
  ,p_dce_attribute25                in  varchar2  default null
  ,p_dce_attribute26                in  varchar2  default null
  ,p_dce_attribute27                in  varchar2  default null
  ,p_dce_attribute28                in  varchar2  default null
  ,p_dce_attribute29                in  varchar2  default null
  ,p_dce_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_dpnt_rlshp_flag	            in  varchar2  default 'N'
  ,p_dpnt_age_flag                  in  varchar2  default 'N'
  ,p_dpnt_stud_flag                 in  varchar2  default 'N'
  ,p_dpnt_dsbld_flag                in  varchar2  default 'N'
  ,p_dpnt_mrtl_flag                 in  varchar2  default 'N'
  ,p_dpnt_mltry_flag                in  varchar2  default 'N'
  ,p_dpnt_pstl_flag                 in  varchar2  default 'N'
  ,p_dpnt_cvrd_in_anthr_pl_flag     in  varchar2  default 'N'
  ,p_dpnt_dsgnt_crntly_enrld_flag   in  varchar2  default 'N'
  ,p_dpnt_crit_flag                 in  varchar2  default 'N'
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_DPNT_CVG_ELIG_PRFL >------------------------|
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
--   p_dpnt_cvg_eligy_prfl_id       Yes  number    PK of record
--   p_business_group_id            Yes  number    Business Group of Record
--   p_regn_id                      No   number
--   p_name                         Yes  varchar2
--   p_dpnt_cvg_eligy_prfl_stat_cd  No   varchar2
--   p_dce_desc                     No   varchar2
--   p_dpnt_cvg_elig_det_rl         No   number
--   p_dce_attribute_category       No   varchar2  Descriptive Flexfield
--   p_dce_attribute1               No   varchar2  Descriptive Flexfield
--   p_dce_attribute2               No   varchar2  Descriptive Flexfield
--   p_dce_attribute3               No   varchar2  Descriptive Flexfield
--   p_dce_attribute4               No   varchar2  Descriptive Flexfield
--   p_dce_attribute5               No   varchar2  Descriptive Flexfield
--   p_dce_attribute6               No   varchar2  Descriptive Flexfield
--   p_dce_attribute7               No   varchar2  Descriptive Flexfield
--   p_dce_attribute8               No   varchar2  Descriptive Flexfield
--   p_dce_attribute9               No   varchar2  Descriptive Flexfield
--   p_dce_attribute10              No   varchar2  Descriptive Flexfield
--   p_dce_attribute11              No   varchar2  Descriptive Flexfield
--   p_dce_attribute12              No   varchar2  Descriptive Flexfield
--   p_dce_attribute13              No   varchar2  Descriptive Flexfield
--   p_dce_attribute14              No   varchar2  Descriptive Flexfield
--   p_dce_attribute15              No   varchar2  Descriptive Flexfield
--   p_dce_attribute16              No   varchar2  Descriptive Flexfield
--   p_dce_attribute17              No   varchar2  Descriptive Flexfield
--   p_dce_attribute18              No   varchar2  Descriptive Flexfield
--   p_dce_attribute19              No   varchar2  Descriptive Flexfield
--   p_dce_attribute20              No   varchar2  Descriptive Flexfield
--   p_dce_attribute21              No   varchar2  Descriptive Flexfield
--   p_dce_attribute22              No   varchar2  Descriptive Flexfield
--   p_dce_attribute23              No   varchar2  Descriptive Flexfield
--   p_dce_attribute24              No   varchar2  Descriptive Flexfield
--   p_dce_attribute25              No   varchar2  Descriptive Flexfield
--   p_dce_attribute26              No   varchar2  Descriptive Flexfield
--   p_dce_attribute27              No   varchar2  Descriptive Flexfield
--   p_dce_attribute28              No   varchar2  Descriptive Flexfield
--   p_dce_attribute29              No   varchar2  Descriptive Flexfield
--   p_dce_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date               Yes  date       Session Date.
--   p_datetrack_mode               Yes  varchar2   Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_DPNT_CVG_ELIG_PRFL
  (
   p_validate                       in boolean    default false
  ,p_dpnt_cvg_eligy_prfl_id         in  number
  ,p_effective_end_date             out nocopy date
  ,p_effective_start_date           out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_regn_id                        in  number    default hr_api.g_number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_cvg_eligy_prfl_stat_cd    in  varchar2  default hr_api.g_varchar2
  ,p_dce_desc                       in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_cvg_elig_det_rl           in  number    default hr_api.g_number
  ,p_dce_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_dpnt_rlshp_flag	            in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_age_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_stud_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_dsbld_flag                in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_mrtl_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_mltry_flag                in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_pstl_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_cvrd_in_anthr_pl_flag     in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_dsgnt_crntly_enrld_flag   in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_crit_flag                 in  varchar2  default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_DPNT_CVG_ELIG_PRFL >------------------------|
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
--   p_dpnt_cvg_eligy_prfl_id       Yes  number    PK of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_DPNT_CVG_ELIG_PRFL
  (
   p_validate                       in boolean        default false
  ,p_dpnt_cvg_eligy_prfl_id         in  number
  ,p_effective_end_date             out nocopy date
  ,p_effective_start_date           out nocopy date
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
--   p_dpnt_cvg_eligy_prfl_id                 Yes  number   PK of record
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
    p_dpnt_cvg_eligy_prfl_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end ben_DPNT_CVG_ELIG_PRFL_api;

/
