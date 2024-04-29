--------------------------------------------------------
--  DDL for Package BEN_DPNT_ELIG_CRIT_VAL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DPNT_ELIG_CRIT_VAL_API" AUTHID CURRENT_USER AS
/* $Header: beedvapi.pkh 120.0.12010000.4 2010/04/19 07:30:10 pvelvano noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_dpnt_eligy_crit_val >------------------------|
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
--   p_dpnt_cvg_eligy_prfl_id                Yes  Number
--   p_eligy_criteria_dpnt_id            Yes  Number
--   p_ordr_num                     No   Number
--   p_number_value1                No   Number
--   p_number_value2                No   Number
--   p_char_value1                  No   Varchar2
--   p_char_value2                  No   Varchar2
--   p_date_value1                  No   Date
--   p_date_value2                  No   Date
--   p_excld_flag                   Yes  Varchar2
--   p_business_group_id            Yes  Number   Business Group of Record
--   p_edc_attribute_category       No   Varchar2 Descriptive Flexfield
--   p_edc_attribute1               No   Varchar2 Descriptive Flexfield
--   p_edc_attribute2               No   Varchar2 Descriptive Flexfield
--   p_edc_attribute3               No   Varchar2 Descriptive Flexfield
--   p_edc_attribute4               No   Varchar2 Descriptive Flexfield
--   p_edc_attribute5               No   Varchar2 Descriptive Flexfield
--   p_edc_attribute6               No   Varchar2 Descriptive Flexfield
--   p_edc_attribute7               No   Varchar2 Descriptive Flexfield
--   p_edc_attribute8               No   Varchar2 Descriptive Flexfield
--   p_edc_attribute9               No   Varchar2 Descriptive Flexfield
--   p_edc_attribute10              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute11              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute12              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute13              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute14              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute15              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute16              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute17              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute18              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute19              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute20              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute21              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute22              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute23              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute24              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute25              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute26              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute27              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute28              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute29              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute30              No   Varchar2 Descriptive Flexfield
--   p_effective_date               Yes  date     Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--  p_dpnt_eligy_crit_values_id          Yes  Number   PK of record
--  p_effective_start_date          Yes  Date     Effective start Date of Record
--  p_effective_end_date            Yes  Date     Effective End Date of Record
--  p_object_version_number         No   Number   OVN of Record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_dpnt_eligy_crit_val
(
   p_validate                     In  Boolean      default false
  ,p_dpnt_eligy_crit_values_id         Out nocopy Number
  ,p_dpnt_cvg_eligy_prfl_id                In  Number       default NULL
  ,p_eligy_criteria_dpnt_id            In  Number       default NULL
  ,p_effective_start_date         Out nocopy Date
  ,p_effective_end_date           Out nocopy Date
  ,p_ordr_num                     In  Number       default NULL
  ,p_number_value1                In  Number       default NULL
  ,p_number_value2                In  Number       default NULL
  ,p_char_value1                  In  Varchar2     default NULL
  ,p_char_value2                  In  Varchar2     default NULL
  ,p_date_value1                  In  Date         default NULL
  ,p_date_value2                  In  Date         default NULL
  ,p_excld_flag                   In  Varchar2     default 'N'
  ,p_business_group_id            In  Number       default NULL
  ,p_edc_attribute_category       In  Varchar2     default NULL
  ,p_edc_attribute1               In  Varchar2     default NULL
  ,p_edc_attribute2               In  Varchar2     default NULL
  ,p_edc_attribute3               In  Varchar2     default NULL
  ,p_edc_attribute4               In  Varchar2     default NULL
  ,p_edc_attribute5               In  Varchar2     default NULL
  ,p_edc_attribute6               In  Varchar2     default NULL
  ,p_edc_attribute7               In  Varchar2     default NULL
  ,p_edc_attribute8               In  Varchar2     default NULL
  ,p_edc_attribute9               In  Varchar2     default NULL
  ,p_edc_attribute10              In  Varchar2     default NULL
  ,p_edc_attribute11              In  Varchar2     default NULL
  ,p_edc_attribute12              In  Varchar2     default NULL
  ,p_edc_attribute13              In  Varchar2     default NULL
  ,p_edc_attribute14              In  Varchar2     default NULL
  ,p_edc_attribute15              In  Varchar2     default NULL
  ,p_edc_attribute16              In  Varchar2     default NULL
  ,p_edc_attribute17              In  Varchar2     default NULL
  ,p_edc_attribute18              In  Varchar2     default NULL
  ,p_edc_attribute19              In  Varchar2     default NULL
  ,p_edc_attribute20              In  Varchar2     default NULL
  ,p_edc_attribute21              In  Varchar2     default NULL
  ,p_edc_attribute22              In  Varchar2     default NULL
  ,p_edc_attribute23              In  Varchar2     default NULL
  ,p_edc_attribute24              In  Varchar2     default NULL
  ,p_edc_attribute25              In  Varchar2     default NULL
  ,p_edc_attribute26              In  Varchar2     default NULL
  ,p_edc_attribute27              In  Varchar2     default NULL
  ,p_edc_attribute28              In  Varchar2     default NULL
  ,p_edc_attribute29              In  Varchar2     default NULL
  ,p_edc_attribute30              In  Varchar2     default NULL
  ,p_object_version_number        Out nocopy Number
  ,p_effective_date               In  Date
  ,p_char_value3                  In  Varchar2     default NULL
  ,p_char_value4                  In  Varchar2     default NULL
  ,p_number_value3                In  Number       default NULL
  ,p_number_value4                In  Number       default NULL
  ,p_date_value3                  In  Date         default NULL
  ,p_date_value4                  In  Date         default NULL
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_dpnt_eligy_crit_val >------------------------|
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
--   p_dpnt_eligy_crit_values_id         yes  Number   PK of record
--   p_dpnt_cvg_eligy_prfl_id                Yes  Number
--   p_eligy_criteria_dpnt_id            Yes  Number
--   p_ordr_num                     No   Number
--   p_number_value1                No   Number
--   p_number_value2                No   Number
--   p_char_value1                  No   Varchar2
--   p_char_value2                  No   Varchar2
--   p_date_value1                  No   Date
--   p_date_value2                  No   Date
--   p_excld_flag                   Yes  Varchar2
--   p_business_group_id            Yes  Number   Business Group of Record
--   p_edc_attribute_category       No   Varchar2 Descriptive Flexfield
--   p_edc_attribute1               No   Varchar2 Descriptive Flexfield
--   p_edc_attribute2               No   Varchar2 Descriptive Flexfield
--   p_edc_attribute3               No   Varchar2 Descriptive Flexfield
--   p_edc_attribute4               No   Varchar2 Descriptive Flexfield
--   p_edc_attribute5               No   Varchar2 Descriptive Flexfield
--   p_edc_attribute6               No   Varchar2 Descriptive Flexfield
--   p_edc_attribute7               No   Varchar2 Descriptive Flexfield
--   p_edc_attribute8               No   Varchar2 Descriptive Flexfield
--   p_edc_attribute9               No   Varchar2 Descriptive Flexfield
--   p_edc_attribute10              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute11              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute12              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute13              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute14              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute15              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute16              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute17              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute18              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute19              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute20              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute21              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute22              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute23              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute24              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute25              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute26              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute27              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute28              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute29              No   Varchar2 Descriptive Flexfield
--   p_edc_attribute30              No   Varchar2 Descriptive Flexfield
--   p_effective_date               Yes  date     Session Date.
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
procedure update_dpnt_eligy_crit_val
  (
   p_validate                     In  Boolean      default false
  ,p_dpnt_eligy_crit_values_id         In  Number
  ,p_dpnt_cvg_eligy_prfl_id                In  Number       default hr_api.g_number
  ,p_eligy_criteria_dpnt_id            In  Number       default hr_api.g_number
  ,p_effective_start_date         Out nocopy Date
  ,p_effective_end_date           Out nocopy Date
  ,p_ordr_num                     In  Number       default hr_api.g_number
  ,p_number_value1                In  Number       default hr_api.g_number
  ,p_number_value2                In  Number       default hr_api.g_number
  ,p_char_value1                  In  Varchar2     default hr_api.g_varchar2
  ,p_char_value2                  In  Varchar2     default hr_api.g_varchar2
  ,p_date_value1                  In  Date         default hr_api.g_date
  ,p_date_value2                  In  Date         default hr_api.g_date
  ,p_excld_flag                   In  Varchar2     default hr_api.g_varchar2
  ,p_business_group_id            In  Number       default hr_api.g_number
  ,p_edc_attribute_category       In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute1               In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute2               In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute3               In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute4               In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute5               In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute6               In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute7               In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute8               In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute9               In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute10              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute11              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute12              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute13              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute14              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute15              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute16              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute17              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute18              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute19              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute20              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute21              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute22              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute23              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute24              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute25              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute26              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute27              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute28              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute29              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute30              In  Varchar2     default hr_api.g_varchar2
  ,p_object_version_number        In Out nocopy Number
  ,p_effective_date               In  Date
  ,p_datetrack_mode               In  varchar2
  ,p_char_value3                  In  Varchar2     default hr_api.g_varchar2
  ,p_char_value4                  In  Varchar2     default hr_api.g_varchar2
  ,p_number_value3                In  Number       default hr_api.g_number
  ,p_number_value4                In  Number       default hr_api.g_number
  ,p_date_value3                  In  Date         default hr_api.g_date
  ,p_date_value4                  In  Date         default hr_api.g_date
  );
  --
-- ----------------------------------------------------------------------------
-- |------------------------< delete_dpnt_eligy_crit_val >------------------------|
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
--   p_dpnt_eligy_crit_values_id         Yes  number   PK of record
--   p_effective_date               Yes  Date     Session Date
--   p_datetrack_mode               Yes  Varchar2 Datetrack mode.
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
procedure delete_dpnt_eligy_crit_val
(
   p_validate                       In Boolean        default false
  ,p_dpnt_eligy_crit_values_id           In Number
  ,p_effective_start_date           Out nocopy date
  ,p_effective_end_date             Out nocopy date
  ,p_object_version_number          In Out nocopy number
  ,p_effective_date                 In Date
  ,p_datetrack_mode                 In Varchar2
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
--   p_dpnt_eligy_crit_values_id         Yes  number   PK of record
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
    p_dpnt_eligy_crit_values_id         In Number
   ,p_object_version_number        In Number
   ,p_effective_date               In Date
   ,p_datetrack_mode               In Varchar2
   ,p_validation_start_date        Out nocopy Date
   ,p_validation_end_date          Out nocopy Date
  );
--
end ben_dpnt_elig_crit_val_api;

/
