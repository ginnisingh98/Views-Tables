--------------------------------------------------------
--  DDL for Package BEN_EXTRA_INPUT_VALUE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXTRA_INPUT_VALUE_API" AUTHID CURRENT_USER as
/* $Header: beeivapi.pkh 120.0 2005/05/28 02:16:22 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_extra_input_value >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type      Description
--   p_validate                     Yes  boolean   Commit or Rollback.
--   p_acty_base_rt_id              Yes  number    Rate Identifier
--   p_input_value_id               Yes  number    Input value Identifier
--   p_input_text                   Yes  varchar2  Not used
--   p_upd_when_ele_ended_cd        Yes  varchar2  Update indicator
--   p_return_var_name              Yes  varchar2  Formula Return variable Name
--   p_business_group_id            Yes  number    Business Group of Record
--   p_eiv_attribute_category       No   varchar2  Descriptive Flexfield
--   p_eiv_attribute1               No   varchar2  Descriptive Flexfield
--   p_eiv_attribute2               No   varchar2  Descriptive Flexfield
--   p_eiv_attribute3               No   varchar2  Descriptive Flexfield
--   p_eiv_attribute4               No   varchar2  Descriptive Flexfield
--   p_eiv_attribute5               No   varchar2  Descriptive Flexfield
--   p_eiv_attribute6               No   varchar2  Descriptive Flexfield
--   p_eiv_attribute7               No   varchar2  Descriptive Flexfield
--   p_eiv_attribute8               No   varchar2  Descriptive Flexfield
--   p_eiv_attribute9               No   varchar2  Descriptive Flexfield
--   p_eiv_attribute10              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute11              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute12              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute13              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute14              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute15              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute16              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute17              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute18              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute19              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute20              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute21              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute22              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute23              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute24              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute25              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute26              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute27              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute28              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute29              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute30              No   varchar2  Descriptive Flexfield
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_extra_input_value_id         Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_extra_input_value
(
   p_validate                       in boolean    default false
  ,p_extra_input_value_id           out nocopy number
  ,p_acty_base_rt_id                in  number
  ,p_input_value_id                 in  number
  ,p_input_text                     in  varchar2  default null
  ,p_upd_when_ele_ended_cd          in  varchar2  default 'C'
  ,p_return_var_name                in  varchar2
  ,p_business_group_id              in  number
  ,p_eiv_attribute_category         in  varchar2  default null
  ,p_eiv_attribute1                 in  varchar2  default null
  ,p_eiv_attribute2                 in  varchar2  default null
  ,p_eiv_attribute3                 in  varchar2  default null
  ,p_eiv_attribute4                 in  varchar2  default null
  ,p_eiv_attribute5                 in  varchar2  default null
  ,p_eiv_attribute6                 in  varchar2  default null
  ,p_eiv_attribute7                 in  varchar2  default null
  ,p_eiv_attribute8                 in  varchar2  default null
  ,p_eiv_attribute9                 in  varchar2  default null
  ,p_eiv_attribute10                in  varchar2  default null
  ,p_eiv_attribute11                in  varchar2  default null
  ,p_eiv_attribute12                in  varchar2  default null
  ,p_eiv_attribute13                in  varchar2  default null
  ,p_eiv_attribute14                in  varchar2  default null
  ,p_eiv_attribute15                in  varchar2  default null
  ,p_eiv_attribute16                in  varchar2  default null
  ,p_eiv_attribute17                in  varchar2  default null
  ,p_eiv_attribute18                in  varchar2  default null
  ,p_eiv_attribute19                in  varchar2  default null
  ,p_eiv_attribute20                in  varchar2  default null
  ,p_eiv_attribute21                in  varchar2  default null
  ,p_eiv_attribute22                in  varchar2  default null
  ,p_eiv_attribute23                in  varchar2  default null
  ,p_eiv_attribute24                in  varchar2  default null
  ,p_eiv_attribute25                in  varchar2  default null
  ,p_eiv_attribute26                in  varchar2  default null
  ,p_eiv_attribute27                in  varchar2  default null
  ,p_eiv_attribute28                in  varchar2  default null
  ,p_eiv_attribute29                in  varchar2  default null
  ,p_eiv_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_extra_input_value >------------------------|
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
--   p_extra_input_value_id         No   number
--   p_acty_base_rt_id              Yes  number    Rate Identifier
--   p_input_value_id               Yes  number    Input value Identifier
--   p_input_text                   Yes  varchar2  Not used
--   p_upd_when_ele_ended_cd        Yes  varchar2  Update indicator
--   p_return_var_name              Yes  varchar2  Formula Return variable Name
--   p_business_group_id            Yes  number    Business Group of Record
--   p_eiv_attribute_category       No   varchar2  Descriptive Flexfield
--   p_eiv_attribute1               No   varchar2  Descriptive Flexfield
--   p_eiv_attribute2               No   varchar2  Descriptive Flexfield
--   p_eiv_attribute3               No   varchar2  Descriptive Flexfield
--   p_eiv_attribute4               No   varchar2  Descriptive Flexfield
--   p_eiv_attribute5               No   varchar2  Descriptive Flexfield
--   p_eiv_attribute6               No   varchar2  Descriptive Flexfield
--   p_eiv_attribute7               No   varchar2  Descriptive Flexfield
--   p_eiv_attribute8               No   varchar2  Descriptive Flexfield
--   p_eiv_attribute9               No   varchar2  Descriptive Flexfield
--   p_eiv_attribute10              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute11              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute12              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute13              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute14              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute15              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute16              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute17              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute18              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute19              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute20              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute21              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute22              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute23              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute24              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute25              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute26              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute27              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute28              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute29              No   varchar2  Descriptive Flexfield
--   p_eiv_attribute30              No   varchar2  Descriptive Flexfield
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_extra_input_value
  (
   p_validate                       in boolean    default false
  ,p_extra_input_value_id           in  number
  ,p_acty_base_rt_id                in  number    default hr_api.g_number
  ,p_input_value_id                 in  number    default hr_api.g_number
  ,p_input_text                     in  varchar2  default hr_api.g_varchar2
  ,p_upd_when_ele_ended_cd          in  varchar2  default hr_api.g_varchar2
  ,p_return_var_name                in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_eiv_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_extra_input_value >------------------------|
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
--   p_acty_base_rt_id              Yes  number    PK of record
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
procedure delete_extra_input_value
  (
   p_validate                       in boolean        default false
  ,p_extra_input_value_id           in number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
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
--   p_acty_base_rt_id                 Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
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
    p_extra_input_value_id        in number
   ,p_object_version_number       in number
  );
--
end ben_extra_input_value_api;

 

/
