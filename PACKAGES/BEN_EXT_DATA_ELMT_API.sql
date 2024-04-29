--------------------------------------------------------
--  DDL for Package BEN_EXT_DATA_ELMT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_DATA_ELMT_API" AUTHID CURRENT_USER as
/* $Header: bexelapi.pkh 120.1 2005/06/08 13:17:09 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_EXT_DATA_ELMT >------------------------|
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
--   p_name                         No   varchar2
--   p_data_elmt_typ_cd             No   varchar2
--   p_data_elmt_rl                 No   number
--   p_frmt_mask_cd                 No   varchar2
--   p_string_val                   No   varchar2
--   p_dflt_val                     No   varchar2
--   p_max_length_num               No   number
--   p_just_cd                     No   varchar2
--   p_ttl_fnctn_cd                     No   varchar2
--   p_ttl_cond_oper_cd                     No   varchar2
--   p_ttl_cond_val                     No   varchar2
--   p_ttl_sum_ext_data_elmt_id                   No   number
--   p_ttl_cond_ext_data_elmt_id                   No   number
--   p_ext_fld_id                   No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_legislation_code             No   varchar2
--   p_xel_attribute_category       No   varchar2  Descriptive Flexfield
--   p_xel_attribute1               No   varchar2  Descriptive Flexfield
--   p_xel_attribute2               No   varchar2  Descriptive Flexfield
--   p_xel_attribute3               No   varchar2  Descriptive Flexfield
--   p_xel_attribute4               No   varchar2  Descriptive Flexfield
--   p_xel_attribute5               No   varchar2  Descriptive Flexfield
--   p_xel_attribute6               No   varchar2  Descriptive Flexfield
--   p_xel_attribute7               No   varchar2  Descriptive Flexfield
--   p_xel_attribute8               No   varchar2  Descriptive Flexfield
--   p_xel_attribute9               No   varchar2  Descriptive Flexfield
--   p_xel_attribute10              No   varchar2  Descriptive Flexfield
--   p_xel_attribute11              No   varchar2  Descriptive Flexfield
--   p_xel_attribute12              No   varchar2  Descriptive Flexfield
--   p_xel_attribute13              No   varchar2  Descriptive Flexfield
--   p_xel_attribute14              No   varchar2  Descriptive Flexfield
--   p_xel_attribute15              No   varchar2  Descriptive Flexfield
--   p_xel_attribute16              No   varchar2  Descriptive Flexfield
--   p_xel_attribute17              No   varchar2  Descriptive Flexfield
--   p_xel_attribute18              No   varchar2  Descriptive Flexfield
--   p_xel_attribute19              No   varchar2  Descriptive Flexfield
--   p_xel_attribute20              No   varchar2  Descriptive Flexfield
--   p_xel_attribute21              No   varchar2  Descriptive Flexfield
--   p_xel_attribute22              No   varchar2  Descriptive Flexfield
--   p_xel_attribute23              No   varchar2  Descriptive Flexfield
--   p_xel_attribute24              No   varchar2  Descriptive Flexfield
--   p_xel_attribute25              No   varchar2  Descriptive Flexfield
--   p_xel_attribute26              No   varchar2  Descriptive Flexfield
--   p_xel_attribute27              No   varchar2  Descriptive Flexfield
--   p_xel_attribute28              No   varchar2  Descriptive Flexfield
--   p_xel_attribute29              No   varchar2  Descriptive Flexfield
--   p_xel_attribute30              No   varchar2  Descriptive Flexfield
--   p_defined_balance_id            No   number
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_ext_data_elmt_id             Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_EXT_DATA_ELMT
(
   p_validate                       in boolean    default false
  ,p_ext_data_elmt_id               out nocopy number
  ,p_name                           in  varchar2  default null
  ,p_xml_tag_name                   in  varchar2  default null
  ,p_data_elmt_typ_cd               in  varchar2  default null
  ,p_data_elmt_rl                   in  number    default null
  ,p_frmt_mask_cd                   in  varchar2  default null
  ,p_string_val                     in  varchar2  default null
  ,p_dflt_val                       in  varchar2  default null
  ,p_max_length_num                 in  number    default null
  ,p_just_cd                       in  varchar2  default null
  ,p_ttl_fnctn_cd                       in  varchar2  default null
  ,p_ttl_cond_oper_cd                       in  varchar2  default null
  ,p_ttl_cond_val                       in  varchar2  default null
  ,p_ttl_sum_ext_data_elmt_id                     in  number    default null
  ,p_ttl_cond_ext_data_elmt_id                     in  number    default null
  ,p_ext_fld_id                     in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_legislation_code               in  varchar2  default null
  ,p_xel_attribute_category         in  varchar2  default null
  ,p_xel_attribute1                 in  varchar2  default null
  ,p_xel_attribute2                 in  varchar2  default null
  ,p_xel_attribute3                 in  varchar2  default null
  ,p_xel_attribute4                 in  varchar2  default null
  ,p_xel_attribute5                 in  varchar2  default null
  ,p_xel_attribute6                 in  varchar2  default null
  ,p_xel_attribute7                 in  varchar2  default null
  ,p_xel_attribute8                 in  varchar2  default null
  ,p_xel_attribute9                 in  varchar2  default null
  ,p_xel_attribute10                in  varchar2  default null
  ,p_xel_attribute11                in  varchar2  default null
  ,p_xel_attribute12                in  varchar2  default null
  ,p_xel_attribute13                in  varchar2  default null
  ,p_xel_attribute14                in  varchar2  default null
  ,p_xel_attribute15                in  varchar2  default null
  ,p_xel_attribute16                in  varchar2  default null
  ,p_xel_attribute17                in  varchar2  default null
  ,p_xel_attribute18                in  varchar2  default null
  ,p_xel_attribute19                in  varchar2  default null
  ,p_xel_attribute20                in  varchar2  default null
  ,p_xel_attribute21                in  varchar2  default null
  ,p_xel_attribute22                in  varchar2  default null
  ,p_xel_attribute23                in  varchar2  default null
  ,p_xel_attribute24                in  varchar2  default null
  ,p_xel_attribute25                in  varchar2  default null
  ,p_xel_attribute26                in  varchar2  default null
  ,p_xel_attribute27                in  varchar2  default null
  ,p_xel_attribute28                in  varchar2  default null
  ,p_xel_attribute29                in  varchar2  default null
  ,p_xel_attribute30                in  varchar2  default null
  ,p_defined_balance_id             in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_EXT_DATA_ELMT >------------------------|
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
--   p_ext_data_elmt_id             Yes  number    PK of record
--   p_name                         No   varchar2
--   p_data_elmt_typ_cd             No   varchar2
--   p_data_elmt_rl                 No   number
--   p_frmt_mask_cd                 No   varchar2
--   p_string_val                   No   varchar2
--   p_dflt_val                     No   varchar2
--   p_max_length_num               No   number
--   p_just_cd                     No   varchar2
--   p_ext_fld_id                   No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_legislation_code             No   varchar2
--   p_xel_attribute_category       No   varchar2  Descriptive Flexfield
--   p_xel_attribute1               No   varchar2  Descriptive Flexfield
--   p_xel_attribute2               No   varchar2  Descriptive Flexfield
--   p_xel_attribute3               No   varchar2  Descriptive Flexfield
--   p_xel_attribute4               No   varchar2  Descriptive Flexfield
--   p_xel_attribute5               No   varchar2  Descriptive Flexfield
--   p_xel_attribute6               No   varchar2  Descriptive Flexfield
--   p_xel_attribute7               No   varchar2  Descriptive Flexfield
--   p_xel_attribute8               No   varchar2  Descriptive Flexfield
--   p_xel_attribute9               No   varchar2  Descriptive Flexfield
--   p_xel_attribute10              No   varchar2  Descriptive Flexfield
--   p_xel_attribute11              No   varchar2  Descriptive Flexfield
--   p_xel_attribute12              No   varchar2  Descriptive Flexfield
--   p_xel_attribute13              No   varchar2  Descriptive Flexfield
--   p_xel_attribute14              No   varchar2  Descriptive Flexfield
--   p_xel_attribute15              No   varchar2  Descriptive Flexfield
--   p_xel_attribute16              No   varchar2  Descriptive Flexfield
--   p_xel_attribute17              No   varchar2  Descriptive Flexfield
--   p_xel_attribute18              No   varchar2  Descriptive Flexfield
--   p_xel_attribute19              No   varchar2  Descriptive Flexfield
--   p_xel_attribute20              No   varchar2  Descriptive Flexfield
--   p_xel_attribute21              No   varchar2  Descriptive Flexfield
--   p_xel_attribute22              No   varchar2  Descriptive Flexfield
--   p_xel_attribute23              No   varchar2  Descriptive Flexfield
--   p_xel_attribute24              No   varchar2  Descriptive Flexfield
--   p_xel_attribute25              No   varchar2  Descriptive Flexfield
--   p_xel_attribute26              No   varchar2  Descriptive Flexfield
--   p_xel_attribute27              No   varchar2  Descriptive Flexfield
--   p_xel_attribute28              No   varchar2  Descriptive Flexfield
--   p_xel_attribute29              No   varchar2  Descriptive Flexfield
--   p_xel_attribute30              No   varchar2  Descriptive Flexfield
--   p_defined_balance_id           No   number    Descriptive Flexfield
--   p_effective_date          Yes  date       Session Date.
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
procedure update_EXT_DATA_ELMT
  (
   p_validate                       in boolean    default false
  ,p_ext_data_elmt_id               in  number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_xml_tag_name                   in  varchar2  default hr_api.g_varchar2
  ,p_data_elmt_typ_cd               in  varchar2  default hr_api.g_varchar2
  ,p_data_elmt_rl                   in  number    default hr_api.g_number
  ,p_frmt_mask_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_string_val                     in  varchar2  default hr_api.g_varchar2
  ,p_dflt_val                       in  varchar2  default hr_api.g_varchar2
  ,p_max_length_num                 in  number    default hr_api.g_number
  ,p_just_cd                       in  varchar2  default hr_api.g_varchar2
  ,p_ttl_fnctn_cd                       in  varchar2  default hr_api.g_varchar2
  ,p_ttl_cond_oper_cd                       in  varchar2  default hr_api.g_varchar2
  ,p_ttl_cond_val                       in  varchar2  default hr_api.g_varchar2
  ,p_ttl_sum_ext_data_elmt_id                     in  number    default hr_api.g_number
  ,p_ttl_cond_ext_data_elmt_id                     in  number    default hr_api.g_number
  ,p_ext_fld_id                     in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_defined_balance_id             in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_EXT_DATA_ELMT >------------------------|
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
--   p_legislation_code             No   varchar2
--   p_ext_data_elmt_id             Yes  number    PK of record
--   p_effective_date          Yes  date     Session Date.
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
procedure delete_EXT_DATA_ELMT
  (
   p_validate                       in boolean        default false
  ,p_ext_data_elmt_id               in  number
  ,p_legislation_code               in  varchar2  default null
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in date
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
--   p_ext_data_elmt_id                 Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--
-- Post Success:
--
--   Name                           Type     Description
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
    p_ext_data_elmt_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_EXT_DATA_ELMT_api;

 

/
