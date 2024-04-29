--------------------------------------------------------
--  DDL for Package BEN_OPTION_DEFINITION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_OPTION_DEFINITION_API" AUTHID CURRENT_USER as
/* $Header: beoptapi.pkh 120.0 2005/05/28 09:56:18 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_option_definition >------------------------|
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
--   p_name                         Yes  varchar2
--   p_cmbn_ptip_opt_id             No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_opt_attribute_category       No   varchar2  Descriptive Flexfield
--   p_opt_attribute1               No   varchar2  Descriptive Flexfield
--   p_opt_attribute2               No   varchar2  Descriptive Flexfield
--   p_opt_attribute3               No   varchar2  Descriptive Flexfield
--   p_opt_attribute4               No   varchar2  Descriptive Flexfield
--   p_opt_attribute5               No   varchar2  Descriptive Flexfield
--   p_opt_attribute6               No   varchar2  Descriptive Flexfield
--   p_opt_attribute7               No   varchar2  Descriptive Flexfield
--   p_opt_attribute8               No   varchar2  Descriptive Flexfield
--   p_opt_attribute9               No   varchar2  Descriptive Flexfield
--   p_opt_attribute10              No   varchar2  Descriptive Flexfield
--   p_opt_attribute11              No   varchar2  Descriptive Flexfield
--   p_opt_attribute12              No   varchar2  Descriptive Flexfield
--   p_opt_attribute13              No   varchar2  Descriptive Flexfield
--   p_opt_attribute14              No   varchar2  Descriptive Flexfield
--   p_opt_attribute15              No   varchar2  Descriptive Flexfield
--   p_opt_attribute16              No   varchar2  Descriptive Flexfield
--   p_opt_attribute17              No   varchar2  Descriptive Flexfield
--   p_opt_attribute18              No   varchar2  Descriptive Flexfield
--   p_opt_attribute19              No   varchar2  Descriptive Flexfield
--   p_opt_attribute20              No   varchar2  Descriptive Flexfield
--   p_opt_attribute21              No   varchar2  Descriptive Flexfield
--   p_opt_attribute22              No   varchar2  Descriptive Flexfield
--   p_opt_attribute23              No   varchar2  Descriptive Flexfield
--   p_opt_attribute24              No   varchar2  Descriptive Flexfield
--   p_opt_attribute25              No   varchar2  Descriptive Flexfield
--   p_opt_attribute26              No   varchar2  Descriptive Flexfield
--   p_opt_attribute27              No   varchar2  Descriptive Flexfield
--   p_opt_attribute28              No   varchar2  Descriptive Flexfield
--   p_opt_attribute29              No   varchar2  Descriptive Flexfield
--   p_opt_attribute30              No   varchar2  Descriptive Flexfield
--   p_rqd_perd_enrt_nenrt_uom      No   varchar2
--   p_rqd_perd_enrt_nenrt_val      No   number
--   p_rqd_perd_enrt_nenrt_rl       No   number
--   p_invk_wv_opt_flag             No   varchar2
--   p_short_name	            No   varchar2
--   p_short_code 	            No   varchar2
--   p_legislation_code 	            No   varchar2
--   p_legislation_subgroup 	            No   varchar2
--   p_group_opt_id                 No   number
--   p_component_reason		    No   varchar2
--   p_mapping_table_name           No   varchar2
--   p_mapping_table_pk_id          No   number
--   p_effective_date               Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_opt_id                       Yes  number    PK of record
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
procedure create_option_definition
(
   p_validate                       in boolean    default false
  ,p_opt_id                         out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default null
  ,p_cmbn_ptip_opt_id               in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_opt_attribute_category         in  varchar2  default null
  ,p_opt_attribute1                 in  varchar2  default null
  ,p_opt_attribute2                 in  varchar2  default null
  ,p_opt_attribute3                 in  varchar2  default null
  ,p_opt_attribute4                 in  varchar2  default null
  ,p_opt_attribute5                 in  varchar2  default null
  ,p_opt_attribute6                 in  varchar2  default null
  ,p_opt_attribute7                 in  varchar2  default null
  ,p_opt_attribute8                 in  varchar2  default null
  ,p_opt_attribute9                 in  varchar2  default null
  ,p_opt_attribute10                in  varchar2  default null
  ,p_opt_attribute11                in  varchar2  default null
  ,p_opt_attribute12                in  varchar2  default null
  ,p_opt_attribute13                in  varchar2  default null
  ,p_opt_attribute14                in  varchar2  default null
  ,p_opt_attribute15                in  varchar2  default null
  ,p_opt_attribute16                in  varchar2  default null
  ,p_opt_attribute17                in  varchar2  default null
  ,p_opt_attribute18                in  varchar2  default null
  ,p_opt_attribute19                in  varchar2  default null
  ,p_opt_attribute20                in  varchar2  default null
  ,p_opt_attribute21                in  varchar2  default null
  ,p_opt_attribute22                in  varchar2  default null
  ,p_opt_attribute23                in  varchar2  default null
  ,p_opt_attribute24                in  varchar2  default null
  ,p_opt_attribute25                in  varchar2  default null
  ,p_opt_attribute26                in  varchar2  default null
  ,p_opt_attribute27                in  varchar2  default null
  ,p_opt_attribute28                in  varchar2  default null
  ,p_opt_attribute29                in  varchar2  default null
  ,p_opt_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_rqd_perd_enrt_nenrt_uom        in  varchar2  default null
  ,p_rqd_perd_enrt_nenrt_val        in  number    default null
  ,p_rqd_perd_enrt_nenrt_rl         in  number    default null
  ,p_invk_wv_opt_flag               in  varchar2  default 'N'
  ,p_short_name			    in  varchar2  default null
  ,p_short_code			    in  varchar2  default null
  ,p_legislation_code		    in  varchar2  default null
  ,p_legislation_subgroup	    in  varchar2  default null
  ,p_group_opt_id	            in  number    default null
  ,p_component_reason               in  varchar2  default null
  ,p_mapping_table_name             in  varchar2  default null
  ,p_mapping_table_pk_id            in  number    default null
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_option_definition >------------------------|
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
--   p_opt_id                       Yes  number    PK of record
--   p_name                         Yes  varchar2
--   p_cmbn_ptip_opt_id             No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_opt_attribute_category       No   varchar2  Descriptive Flexfield
--   p_opt_attribute1               No   varchar2  Descriptive Flexfield
--   p_opt_attribute2               No   varchar2  Descriptive Flexfield
--   p_opt_attribute3               No   varchar2  Descriptive Flexfield
--   p_opt_attribute4               No   varchar2  Descriptive Flexfield
--   p_opt_attribute5               No   varchar2  Descriptive Flexfield
--   p_opt_attribute6               No   varchar2  Descriptive Flexfield
--   p_opt_attribute7               No   varchar2  Descriptive Flexfield
--   p_opt_attribute8               No   varchar2  Descriptive Flexfield
--   p_opt_attribute9               No   varchar2  Descriptive Flexfield
--   p_opt_attribute10              No   varchar2  Descriptive Flexfield
--   p_opt_attribute11              No   varchar2  Descriptive Flexfield
--   p_opt_attribute12              No   varchar2  Descriptive Flexfield
--   p_opt_attribute13              No   varchar2  Descriptive Flexfield
--   p_opt_attribute14              No   varchar2  Descriptive Flexfield
--   p_opt_attribute15              No   varchar2  Descriptive Flexfield
--   p_opt_attribute16              No   varchar2  Descriptive Flexfield
--   p_opt_attribute17              No   varchar2  Descriptive Flexfield
--   p_opt_attribute18              No   varchar2  Descriptive Flexfield
--   p_opt_attribute19              No   varchar2  Descriptive Flexfield
--   p_opt_attribute20              No   varchar2  Descriptive Flexfield
--   p_opt_attribute21              No   varchar2  Descriptive Flexfield
--   p_opt_attribute22              No   varchar2  Descriptive Flexfield
--   p_opt_attribute23              No   varchar2  Descriptive Flexfield
--   p_opt_attribute24              No   varchar2  Descriptive Flexfield
--   p_opt_attribute25              No   varchar2  Descriptive Flexfield
--   p_opt_attribute26              No   varchar2  Descriptive Flexfield
--   p_opt_attribute27              No   varchar2  Descriptive Flexfield
--   p_opt_attribute28              No   varchar2  Descriptive Flexfield
--   p_opt_attribute29              No   varchar2  Descriptive Flexfield
--   p_opt_attribute30              No   varchar2  Descriptive Flexfield
--   p_rqd_perd_enrt_nenrt_uom      No   varchar2
--   p_rqd_perd_enrt_nenrt_val      No   number
--   p_rqd_perd_enrt_nenrt_rl       No   number
--   p_invk_wv_opt_flag             No   varchar2
--   p_short_name                   No   varchar2
--   p_short_code                   No   varchar2
--   p_legislation_code                   No   varchar2
--   p_legislation_subgroup                   No   varchar2
--   p_group_opt_id                 No   number
--   p_component_reason             No   varchar2
--   p_mapping_table_name           No   varchar2
--   p_mapping_table_pk_id          No   number
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
procedure update_option_definition
  (
   p_validate                       in boolean    default false
  ,p_opt_id                         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_cmbn_ptip_opt_id               in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_opt_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_rqd_perd_enrt_nenrt_uom        in  varchar2  default hr_api.g_varchar2
  ,p_rqd_perd_enrt_nenrt_val        in  number    default hr_api.g_number
  ,p_rqd_perd_enrt_nenrt_rl         in  number    default hr_api.g_number
  ,p_invk_wv_opt_flag               in  varchar2  default hr_api.g_varchar2
  ,p_short_name                     in  varchar2  default hr_api.g_varchar2
  ,p_short_code                     in  varchar2  default hr_api.g_varchar2
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_legislation_subgroup           in  varchar2  default hr_api.g_varchar2
  ,p_group_opt_id                   in  number    default hr_api.g_number
  ,p_component_reason               in  varchar2  default hr_api.g_varchar2
  ,p_mapping_table_name             in  varchar2  default hr_api.g_varchar2
  ,p_mapping_table_pk_id            in  number    default hr_api.g_number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_option_definition >------------------------|
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
--   p_opt_id                       Yes  number    PK of record
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
procedure delete_option_definition
  (
   p_validate                       in boolean        default false
  ,p_opt_id                         in  number
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
--   p_opt_id                 Yes  number   PK of record
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
    p_opt_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end ben_option_definition_api;

 

/
