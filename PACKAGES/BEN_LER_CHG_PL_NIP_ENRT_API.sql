--------------------------------------------------------
--  DDL for Package BEN_LER_CHG_PL_NIP_ENRT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LER_CHG_PL_NIP_ENRT_API" AUTHID CURRENT_USER as
/* $Header: belpeapi.pkh 120.0 2005/05/28 03:29:57 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Ler_Chg_Pl_Nip_Enrt >------------------------|
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
--   p_ler_id                       Yes  number
--   p_tco_chg_enrt_cd              Yes  varchar2
--   p_crnt_enrt_prclds_chg_flag    Yes  varchar2
--   p_dflt_enrt_cd                 No   varchar2
--   p_dflt_enrt_rl                 No   number
--   p_dflt_flag                    Yes  varchar2
--   p_enrt_rl                      No   number
--   p_enrt_cd                      No   varchar2
--   p_stl_elig_cant_chg_flag       Yes  varchar2
--   p_enrt_mthd_cd                 No   varchar2
--   p_auto_enrt_mthd_rl            No   number
--   p_lpe_attribute_category       No   varchar2  Descriptive Flexfield
--   p_lpe_attribute1               No   varchar2  Descriptive Flexfield
--   p_lpe_attribute2               No   varchar2  Descriptive Flexfield
--   p_lpe_attribute3               No   varchar2  Descriptive Flexfield
--   p_lpe_attribute4               No   varchar2  Descriptive Flexfield
--   p_lpe_attribute5               No   varchar2  Descriptive Flexfield
--   p_lpe_attribute6               No   varchar2  Descriptive Flexfield
--   p_lpe_attribute7               No   varchar2  Descriptive Flexfield
--   p_lpe_attribute8               No   varchar2  Descriptive Flexfield
--   p_lpe_attribute9               No   varchar2  Descriptive Flexfield
--   p_lpe_attribute10              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute11              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute12              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute13              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute14              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute15              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute16              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute17              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute18              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute19              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute20              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute21              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute22              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute23              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute24              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute25              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute26              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute27              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute28              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute29              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_ler_chg_pl_nip_enrt_id       Yes  number    PK of record
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
procedure create_Ler_Chg_Pl_Nip_Enrt
(
   p_validate                       in boolean    default false
  ,p_ler_chg_pl_nip_enrt_id         out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_tco_chg_enrt_cd                in  varchar2  default null
  ,p_crnt_enrt_prclds_chg_flag      in  varchar2  default null
  ,p_dflt_enrt_cd                   in  varchar2  default null
  ,p_dflt_enrt_rl                   in  number    default null
  ,p_dflt_flag                      in  varchar2  default null
  ,p_enrt_rl                        in  number    default null
  ,p_enrt_cd                        in  varchar2  default null
  ,p_stl_elig_cant_chg_flag         in  varchar2  default null
  ,p_enrt_mthd_cd                   in  varchar2  default null
  ,p_auto_enrt_mthd_rl              in  number    default null
  ,p_lpe_attribute_category         in  varchar2  default null
  ,p_lpe_attribute1                 in  varchar2  default null
  ,p_lpe_attribute2                 in  varchar2  default null
  ,p_lpe_attribute3                 in  varchar2  default null
  ,p_lpe_attribute4                 in  varchar2  default null
  ,p_lpe_attribute5                 in  varchar2  default null
  ,p_lpe_attribute6                 in  varchar2  default null
  ,p_lpe_attribute7                 in  varchar2  default null
  ,p_lpe_attribute8                 in  varchar2  default null
  ,p_lpe_attribute9                 in  varchar2  default null
  ,p_lpe_attribute10                in  varchar2  default null
  ,p_lpe_attribute11                in  varchar2  default null
  ,p_lpe_attribute12                in  varchar2  default null
  ,p_lpe_attribute13                in  varchar2  default null
  ,p_lpe_attribute14                in  varchar2  default null
  ,p_lpe_attribute15                in  varchar2  default null
  ,p_lpe_attribute16                in  varchar2  default null
  ,p_lpe_attribute17                in  varchar2  default null
  ,p_lpe_attribute18                in  varchar2  default null
  ,p_lpe_attribute19                in  varchar2  default null
  ,p_lpe_attribute20                in  varchar2  default null
  ,p_lpe_attribute21                in  varchar2  default null
  ,p_lpe_attribute22                in  varchar2  default null
  ,p_lpe_attribute23                in  varchar2  default null
  ,p_lpe_attribute24                in  varchar2  default null
  ,p_lpe_attribute25                in  varchar2  default null
  ,p_lpe_attribute26                in  varchar2  default null
  ,p_lpe_attribute27                in  varchar2  default null
  ,p_lpe_attribute28                in  varchar2  default null
  ,p_lpe_attribute29                in  varchar2  default null
  ,p_lpe_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_Ler_Chg_Pl_Nip_Enrt >------------------------|
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
--   p_ler_chg_pl_nip_enrt_id       Yes  number    PK of record
--   p_business_group_id            Yes  number    Business Group of Record
--   p_pl_id                        Yes  number
--   p_ler_id                       Yes  number
--   p_tco_chg_enrt_cd              Yes  varchar2
--   p_crnt_enrt_prclds_chg_flag    Yes  varchar2
--   p_dflt_enrt_cd                 No   varchar2
--   p_dflt_enrt_rl                 No   number
--   p_dflt_flag                    Yes  varchar2
--   p_enrt_rl                      No   number
--   p_enrt_cd                      No   varchar2
--   p_stl_elig_cant_chg_flag       Yes  varchar2
--   p_enrt_mthd_cd                 No   varchar2
--   p_auto_enrt_mthd_rl            No   number
--   p_lpe_attribute_category       No   varchar2  Descriptive Flexfield
--   p_lpe_attribute1               No   varchar2  Descriptive Flexfield
--   p_lpe_attribute2               No   varchar2  Descriptive Flexfield
--   p_lpe_attribute3               No   varchar2  Descriptive Flexfield
--   p_lpe_attribute4               No   varchar2  Descriptive Flexfield
--   p_lpe_attribute5               No   varchar2  Descriptive Flexfield
--   p_lpe_attribute6               No   varchar2  Descriptive Flexfield
--   p_lpe_attribute7               No   varchar2  Descriptive Flexfield
--   p_lpe_attribute8               No   varchar2  Descriptive Flexfield
--   p_lpe_attribute9               No   varchar2  Descriptive Flexfield
--   p_lpe_attribute10              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute11              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute12              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute13              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute14              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute15              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute16              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute17              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute18              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute19              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute20              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute21              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute22              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute23              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute24              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute25              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute26              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute27              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute28              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute29              No   varchar2  Descriptive Flexfield
--   p_lpe_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_Ler_Chg_Pl_Nip_Enrt
  (
   p_validate                       in boolean    default false
  ,p_ler_chg_pl_nip_enrt_id         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_tco_chg_enrt_cd                in  varchar2  default hr_api.g_varchar2
  ,p_crnt_enrt_prclds_chg_flag      in  varchar2  default hr_api.g_varchar2
  ,p_dflt_enrt_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_dflt_enrt_rl                   in  number    default hr_api.g_number
  ,p_dflt_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_enrt_rl                        in  number    default hr_api.g_number
  ,p_enrt_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_stl_elig_cant_chg_flag         in  varchar2  default hr_api.g_varchar2
  ,p_enrt_mthd_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_auto_enrt_mthd_rl              in  number    default hr_api.g_number
  ,p_lpe_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Ler_Chg_Pl_Nip_Enrt >------------------------|
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
--   p_ler_chg_pl_nip_enrt_id       Yes  number    PK of record
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
procedure delete_Ler_Chg_Pl_Nip_Enrt
  (
   p_validate                       in boolean        default false
  ,p_ler_chg_pl_nip_enrt_id         in  number
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
--   p_ler_chg_pl_nip_enrt_id                 Yes  number   PK of record
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
    p_ler_chg_pl_nip_enrt_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end ben_Ler_Chg_Pl_Nip_Enrt_api;

 

/
