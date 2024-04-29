--------------------------------------------------------
--  DDL for Package BEN_PRTT_PREM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRTT_PREM_API" AUTHID CURRENT_USER as
/* $Header: beppeapi.pkh 120.0.12000000.1 2007/01/19 21:44:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< recalc_PRTT_PREM >------------------------|
-- ----------------------------------------------------------------------------
procedure recalc_PRTT_PREM
  (p_prtt_prem_id                   in  number default null
  ,p_std_prem_uom                   in  varchar2  default null
  ,p_std_prem_val                   in out nocopy number
  ,p_actl_prem_id                   in  number    default null
  ,p_prtt_enrt_rslt_id              in  number    default null
  ,p_per_in_ler_id                  in  number
  ,p_ler_id                         in  number
  ,p_lf_evt_ocrd_dt                 in  date
  ,p_elig_per_elctbl_chc_id         in  number
  ,p_enrt_bnft_id                   in  number
  ,p_business_group_id              in  number    default null
  -- bof FONM
  ,p_enrt_cvg_strt_dt               in  date      default null
  ,p_rt_strt_dt                     in  date      default null
  -- eof FONM
  ,p_effective_date                 in  date);

-- ----------------------------------------------------------------------------
-- |------------------------< create_PRTT_PREM >------------------------|
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
--   p_std_prem_uom                 No   varchar2
--   p_std_prem_val                 No   number
--   p_actl_prem_id                 Yes  number
--   p_prtt_enrt_rslt_id            Yes  number
--   p_per_in_ler_id            Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_ppe_attribute_category       No   varchar2  Descriptive Flexfield
--   p_ppe_attribute1               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute2               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute3               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute4               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute5               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute6               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute7               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute8               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute9               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute10              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute11              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute12              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute13              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute14              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute15              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute16              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute17              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute18              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute19              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute20              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute21              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute22              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute23              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute24              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute25              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute26              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute27              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute28              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute29              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute30              No   varchar2  Descriptive Flexfield
--   p_request_id                   No   number
--   p_program_application_id       No   number
--   p_program_id                   No   number
--   p_program_update_date          No   date
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_prtt_prem_id                 Yes  number    PK of record
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
procedure create_PRTT_PREM
(
   p_validate                       in boolean    default false
  ,p_prtt_prem_id                   out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_std_prem_uom                   in  varchar2  default null
  ,p_std_prem_val                   in  number    default null
  ,p_actl_prem_id                   in  number    default null
  ,p_prtt_enrt_rslt_id              in  number    default null
  ,p_per_in_ler_id              in  number
  ,p_business_group_id              in  number    default null
  ,p_ppe_attribute_category         in  varchar2  default null
  ,p_ppe_attribute1                 in  varchar2  default null
  ,p_ppe_attribute2                 in  varchar2  default null
  ,p_ppe_attribute3                 in  varchar2  default null
  ,p_ppe_attribute4                 in  varchar2  default null
  ,p_ppe_attribute5                 in  varchar2  default null
  ,p_ppe_attribute6                 in  varchar2  default null
  ,p_ppe_attribute7                 in  varchar2  default null
  ,p_ppe_attribute8                 in  varchar2  default null
  ,p_ppe_attribute9                 in  varchar2  default null
  ,p_ppe_attribute10                in  varchar2  default null
  ,p_ppe_attribute11                in  varchar2  default null
  ,p_ppe_attribute12                in  varchar2  default null
  ,p_ppe_attribute13                in  varchar2  default null
  ,p_ppe_attribute14                in  varchar2  default null
  ,p_ppe_attribute15                in  varchar2  default null
  ,p_ppe_attribute16                in  varchar2  default null
  ,p_ppe_attribute17                in  varchar2  default null
  ,p_ppe_attribute18                in  varchar2  default null
  ,p_ppe_attribute19                in  varchar2  default null
  ,p_ppe_attribute20                in  varchar2  default null
  ,p_ppe_attribute21                in  varchar2  default null
  ,p_ppe_attribute22                in  varchar2  default null
  ,p_ppe_attribute23                in  varchar2  default null
  ,p_ppe_attribute24                in  varchar2  default null
  ,p_ppe_attribute25                in  varchar2  default null
  ,p_ppe_attribute26                in  varchar2  default null
  ,p_ppe_attribute27                in  varchar2  default null
  ,p_ppe_attribute28                in  varchar2  default null
  ,p_ppe_attribute29                in  varchar2  default null
  ,p_ppe_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_effective_date                 in  date
 );
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_PRTT_PREM >------------------------|
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
--   p_std_prem_uom                 No   varchar2
--   p_std_prem_val                 No   number
--   p_actl_prem_id                 Yes  number
--   p_prtt_enrt_rslt_id            Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_ppe_attribute_category       No   varchar2  Descriptive Flexfield
--   p_ppe_attribute1               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute2               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute3               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute4               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute5               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute6               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute7               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute8               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute9               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute10              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute11              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute12              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute13              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute14              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute15              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute16              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute17              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute18              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute19              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute20              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute21              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute22              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute23              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute24              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute25              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute26              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute27              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute28              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute29              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute30              No   varchar2  Descriptive Flexfield
--   p_request_id                   No   number
--   p_program_application_id       No   number
--   p_program_id                   No   number
--   p_program_update_date          No   date
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_prtt_prem_id                 Yes  number    PK of record
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
procedure create_PRTT_PREM
(
   p_validate                       in boolean    default false
  ,p_prtt_prem_id                   out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_std_prem_uom                   in  varchar2  default null
  ,p_std_prem_val                   in  number    default null
  ,p_actl_prem_id                   in  number    default null
  ,p_prtt_enrt_rslt_id              in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_ppe_attribute_category         in  varchar2  default null
  ,p_ppe_attribute1                 in  varchar2  default null
  ,p_ppe_attribute2                 in  varchar2  default null
  ,p_ppe_attribute3                 in  varchar2  default null
  ,p_ppe_attribute4                 in  varchar2  default null
  ,p_ppe_attribute5                 in  varchar2  default null
  ,p_ppe_attribute6                 in  varchar2  default null
  ,p_ppe_attribute7                 in  varchar2  default null
  ,p_ppe_attribute8                 in  varchar2  default null
  ,p_ppe_attribute9                 in  varchar2  default null
  ,p_ppe_attribute10                in  varchar2  default null
  ,p_ppe_attribute11                in  varchar2  default null
  ,p_ppe_attribute12                in  varchar2  default null
  ,p_ppe_attribute13                in  varchar2  default null
  ,p_ppe_attribute14                in  varchar2  default null
  ,p_ppe_attribute15                in  varchar2  default null
  ,p_ppe_attribute16                in  varchar2  default null
  ,p_ppe_attribute17                in  varchar2  default null
  ,p_ppe_attribute18                in  varchar2  default null
  ,p_ppe_attribute19                in  varchar2  default null
  ,p_ppe_attribute20                in  varchar2  default null
  ,p_ppe_attribute21                in  varchar2  default null
  ,p_ppe_attribute22                in  varchar2  default null
  ,p_ppe_attribute23                in  varchar2  default null
  ,p_ppe_attribute24                in  varchar2  default null
  ,p_ppe_attribute25                in  varchar2  default null
  ,p_ppe_attribute26                in  varchar2  default null
  ,p_ppe_attribute27                in  varchar2  default null
  ,p_ppe_attribute28                in  varchar2  default null
  ,p_ppe_attribute29                in  varchar2  default null
  ,p_ppe_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_PRTT_PREM >------------------------|
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
--   p_prtt_prem_id                 Yes  number    PK of record
--   p_std_prem_uom                 No   varchar2
--   p_std_prem_val                 No   number
--   p_actl_prem_id                 Yes  number
--   p_prtt_enrt_rslt_id            Yes  number
--   p_per_in_ler_id            Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_ppe_attribute_category       No   varchar2  Descriptive Flexfield
--   p_ppe_attribute1               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute2               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute3               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute4               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute5               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute6               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute7               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute8               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute9               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute10              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute11              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute12              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute13              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute14              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute15              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute16              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute17              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute18              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute19              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute20              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute21              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute22              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute23              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute24              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute25              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute26              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute27              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute28              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute29              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute30              No   varchar2  Descriptive Flexfield
--   p_request_id                   No   number
--   p_program_application_id       No   number
--   p_program_id                   No   number
--   p_program_update_date          No   date
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
procedure update_PRTT_PREM
  (
   p_validate                       in boolean    default false
  ,p_prtt_prem_id                   in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_std_prem_uom                   in  varchar2  default hr_api.g_varchar2
  ,p_std_prem_val                   in  number    default hr_api.g_number
  ,p_actl_prem_id                   in  number    default hr_api.g_number
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_per_in_ler_id              in  number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_ppe_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_PRTT_PREM >------------------------|
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
--   p_prtt_prem_id                 Yes  number    PK of record
--   p_std_prem_uom                 No   varchar2
--   p_std_prem_val                 No   number
--   p_actl_prem_id                 Yes  number
--   p_prtt_enrt_rslt_id            Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_ppe_attribute_category       No   varchar2  Descriptive Flexfield
--   p_ppe_attribute1               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute2               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute3               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute4               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute5               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute6               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute7               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute8               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute9               No   varchar2  Descriptive Flexfield
--   p_ppe_attribute10              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute11              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute12              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute13              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute14              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute15              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute16              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute17              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute18              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute19              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute20              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute21              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute22              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute23              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute24              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute25              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute26              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute27              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute28              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute29              No   varchar2  Descriptive Flexfield
--   p_ppe_attribute30              No   varchar2  Descriptive Flexfield
--   p_request_id                   No   number
--   p_program_application_id       No   number
--   p_program_id                   No   number
--   p_program_update_date          No   date
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
procedure update_PRTT_PREM
  (
   p_validate                       in boolean    default false
  ,p_prtt_prem_id                   in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_std_prem_uom                   in  varchar2  default hr_api.g_varchar2
  ,p_std_prem_val                   in  number    default hr_api.g_number
  ,p_actl_prem_id                   in  number    default hr_api.g_number
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_ppe_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_PRTT_PREM >------------------------|
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
--   p_prtt_prem_id                 Yes  number    PK of record
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
procedure delete_PRTT_PREM
  (
   p_validate                       in boolean        default false
  ,p_prtt_prem_id                   in  number
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
--   p_prtt_prem_id                 Yes  number   PK of record
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
    p_prtt_prem_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end ben_PRTT_PREM_api;

 

/
