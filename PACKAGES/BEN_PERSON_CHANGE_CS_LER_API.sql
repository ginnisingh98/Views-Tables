--------------------------------------------------------
--  DDL for Package BEN_PERSON_CHANGE_CS_LER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PERSON_CHANGE_CS_LER_API" AUTHID CURRENT_USER as
/* $Header: bepslapi.pkh 120.0 2005/05/28 11:18:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Person_Change_Cs_Ler >------------------------|
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
--   p_per_info_chg_cs_ler_rl       No   number
--   p_name                         No   varchar2
--   p_old_val                      No   varchar2
--   p_new_val                      No   varchar2
--   p_whatif_lbl_txt               No   varchar2
--   p_rule_overrides_flag          No   varchar2
--   p_source_column                Yes  varchar2
--   p_source_table                 Yes  varchar2
--   p_business_group_id            Yes  number    Business Group of Record
--   p_psl_attribute_category       No   varchar2  Descriptive Flexfield
--   p_psl_attribute1               No   varchar2  Descriptive Flexfield
--   p_psl_attribute2               No   varchar2  Descriptive Flexfield
--   p_psl_attribute3               No   varchar2  Descriptive Flexfield
--   p_psl_attribute4               No   varchar2  Descriptive Flexfield
--   p_psl_attribute5               No   varchar2  Descriptive Flexfield
--   p_psl_attribute6               No   varchar2  Descriptive Flexfield
--   p_psl_attribute7               No   varchar2  Descriptive Flexfield
--   p_psl_attribute8               No   varchar2  Descriptive Flexfield
--   p_psl_attribute9               No   varchar2  Descriptive Flexfield
--   p_psl_attribute10              No   varchar2  Descriptive Flexfield
--   p_psl_attribute11              No   varchar2  Descriptive Flexfield
--   p_psl_attribute12              No   varchar2  Descriptive Flexfield
--   p_psl_attribute13              No   varchar2  Descriptive Flexfield
--   p_psl_attribute14              No   varchar2  Descriptive Flexfield
--   p_psl_attribute15              No   varchar2  Descriptive Flexfield
--   p_psl_attribute16              No   varchar2  Descriptive Flexfield
--   p_psl_attribute17              No   varchar2  Descriptive Flexfield
--   p_psl_attribute18              No   varchar2  Descriptive Flexfield
--   p_psl_attribute19              No   varchar2  Descriptive Flexfield
--   p_psl_attribute20              No   varchar2  Descriptive Flexfield
--   p_psl_attribute21              No   varchar2  Descriptive Flexfield
--   p_psl_attribute22              No   varchar2  Descriptive Flexfield
--   p_psl_attribute23              No   varchar2  Descriptive Flexfield
--   p_psl_attribute24              No   varchar2  Descriptive Flexfield
--   p_psl_attribute25              No   varchar2  Descriptive Flexfield
--   p_psl_attribute26              No   varchar2  Descriptive Flexfield
--   p_psl_attribute27              No   varchar2  Descriptive Flexfield
--   p_psl_attribute28              No   varchar2  Descriptive Flexfield
--   p_psl_attribute29              No   varchar2  Descriptive Flexfield
--   p_psl_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_per_info_chg_cs_ler_id       Yes  number    PK of record
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
procedure create_Person_Change_Cs_Ler
(
   p_validate                       in boolean    default false
  ,p_per_info_chg_cs_ler_id         out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_per_info_chg_cs_ler_rl         in  number    default null
  ,p_name                           in  varchar2  default null
  ,p_old_val                        in  varchar2  default null
  ,p_new_val                        in  varchar2  default null
  ,p_whatif_lbl_txt                 in  varchar2  default null
  ,p_rule_overrides_flag                 in  varchar2  default 'N'
  ,p_source_column                  in  varchar2  default null
  ,p_source_table                   in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_psl_attribute_category         in  varchar2  default null
  ,p_psl_attribute1                 in  varchar2  default null
  ,p_psl_attribute2                 in  varchar2  default null
  ,p_psl_attribute3                 in  varchar2  default null
  ,p_psl_attribute4                 in  varchar2  default null
  ,p_psl_attribute5                 in  varchar2  default null
  ,p_psl_attribute6                 in  varchar2  default null
  ,p_psl_attribute7                 in  varchar2  default null
  ,p_psl_attribute8                 in  varchar2  default null
  ,p_psl_attribute9                 in  varchar2  default null
  ,p_psl_attribute10                in  varchar2  default null
  ,p_psl_attribute11                in  varchar2  default null
  ,p_psl_attribute12                in  varchar2  default null
  ,p_psl_attribute13                in  varchar2  default null
  ,p_psl_attribute14                in  varchar2  default null
  ,p_psl_attribute15                in  varchar2  default null
  ,p_psl_attribute16                in  varchar2  default null
  ,p_psl_attribute17                in  varchar2  default null
  ,p_psl_attribute18                in  varchar2  default null
  ,p_psl_attribute19                in  varchar2  default null
  ,p_psl_attribute20                in  varchar2  default null
  ,p_psl_attribute21                in  varchar2  default null
  ,p_psl_attribute22                in  varchar2  default null
  ,p_psl_attribute23                in  varchar2  default null
  ,p_psl_attribute24                in  varchar2  default null
  ,p_psl_attribute25                in  varchar2  default null
  ,p_psl_attribute26                in  varchar2  default null
  ,p_psl_attribute27                in  varchar2  default null
  ,p_psl_attribute28                in  varchar2  default null
  ,p_psl_attribute29                in  varchar2  default null
  ,p_psl_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_Person_Change_Cs_Ler >------------------------|
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
--   p_per_info_chg_cs_ler_id       Yes  number    PK of record
--   p_per_info_chg_cs_ler_rl       No   number
--   p_name                         No   varchar2
--   p_old_val                      No   varchar2
--   p_new_val                      No   varchar2
--   p_whatif_lbl_txt               No   varchar2
--   p_rule_overrides_flag          No   varchar2
--   p_source_column                Yes  varchar2
--   p_source_table                 Yes  varchar2
--   p_business_group_id            Yes  number    Business Group of Record
--   p_psl_attribute_category       No   varchar2  Descriptive Flexfield
--   p_psl_attribute1               No   varchar2  Descriptive Flexfield
--   p_psl_attribute2               No   varchar2  Descriptive Flexfield
--   p_psl_attribute3               No   varchar2  Descriptive Flexfield
--   p_psl_attribute4               No   varchar2  Descriptive Flexfield
--   p_psl_attribute5               No   varchar2  Descriptive Flexfield
--   p_psl_attribute6               No   varchar2  Descriptive Flexfield
--   p_psl_attribute7               No   varchar2  Descriptive Flexfield
--   p_psl_attribute8               No   varchar2  Descriptive Flexfield
--   p_psl_attribute9               No   varchar2  Descriptive Flexfield
--   p_psl_attribute10              No   varchar2  Descriptive Flexfield
--   p_psl_attribute11              No   varchar2  Descriptive Flexfield
--   p_psl_attribute12              No   varchar2  Descriptive Flexfield
--   p_psl_attribute13              No   varchar2  Descriptive Flexfield
--   p_psl_attribute14              No   varchar2  Descriptive Flexfield
--   p_psl_attribute15              No   varchar2  Descriptive Flexfield
--   p_psl_attribute16              No   varchar2  Descriptive Flexfield
--   p_psl_attribute17              No   varchar2  Descriptive Flexfield
--   p_psl_attribute18              No   varchar2  Descriptive Flexfield
--   p_psl_attribute19              No   varchar2  Descriptive Flexfield
--   p_psl_attribute20              No   varchar2  Descriptive Flexfield
--   p_psl_attribute21              No   varchar2  Descriptive Flexfield
--   p_psl_attribute22              No   varchar2  Descriptive Flexfield
--   p_psl_attribute23              No   varchar2  Descriptive Flexfield
--   p_psl_attribute24              No   varchar2  Descriptive Flexfield
--   p_psl_attribute25              No   varchar2  Descriptive Flexfield
--   p_psl_attribute26              No   varchar2  Descriptive Flexfield
--   p_psl_attribute27              No   varchar2  Descriptive Flexfield
--   p_psl_attribute28              No   varchar2  Descriptive Flexfield
--   p_psl_attribute29              No   varchar2  Descriptive Flexfield
--   p_psl_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_Person_Change_Cs_Ler
  (
   p_validate                       in boolean    default false
  ,p_per_info_chg_cs_ler_id         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_per_info_chg_cs_ler_rl         in  number    default hr_api.g_number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_old_val                        in  varchar2  default hr_api.g_varchar2
  ,p_new_val                        in  varchar2  default hr_api.g_varchar2
  ,p_whatif_lbl_txt                 in  varchar2  default hr_api.g_varchar2
  ,p_rule_overrides_flag            in  varchar2  default hr_api.g_varchar2
  ,p_source_column                  in  varchar2  default hr_api.g_varchar2
  ,p_source_table                   in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_psl_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_psl_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_psl_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_psl_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_psl_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_psl_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_psl_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_psl_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_psl_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_psl_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_psl_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_psl_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_psl_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_psl_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_psl_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_psl_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_psl_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_psl_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_psl_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_psl_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_psl_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_psl_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_psl_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_psl_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_psl_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_psl_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_psl_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_psl_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_psl_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_psl_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_psl_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Person_Change_Cs_Ler >------------------------|
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
--   p_per_info_chg_cs_ler_id       Yes  number    PK of record
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
procedure delete_Person_Change_Cs_Ler
  (
   p_validate                       in boolean        default false
  ,p_per_info_chg_cs_ler_id         in  number
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
--   p_per_info_chg_cs_ler_id                 Yes  number   PK of record
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
    p_per_info_chg_cs_ler_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end ben_Person_Change_Cs_Ler_api;

 

/
