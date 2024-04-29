--------------------------------------------------------
--  DDL for Package BEN_PERCENT_FT_FACTORS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PERCENT_FT_FACTORS_API" AUTHID CURRENT_USER as
/* $Header: bepffapi.pkh 120.0 2005/05/28 10:42:03 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_percent_ft_factors >------------------------|
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
--   p_business_group_id            Yes  number    Business Group of Record
--   p_mx_pct_val                   No   number
--   p_mn_pct_val                   No   number
--   p_no_mn_pct_val_flag           Yes  varchar2
--   p_no_mx_pct_val_flag           Yes  varchar2
--   p_use_prmry_asnt_only_flag     Yes  varchar2
--   p_use_sum_of_all_asnts_flag    Yes  varchar2
--   p_rndg_cd                      No   varchar2
--   p_rndg_rl                      No   number
--   p_pff_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pff_attribute1               No   varchar2  Descriptive Flexfield
--   p_pff_attribute2               No   varchar2  Descriptive Flexfield
--   p_pff_attribute3               No   varchar2  Descriptive Flexfield
--   p_pff_attribute4               No   varchar2  Descriptive Flexfield
--   p_pff_attribute5               No   varchar2  Descriptive Flexfield
--   p_pff_attribute6               No   varchar2  Descriptive Flexfield
--   p_pff_attribute7               No   varchar2  Descriptive Flexfield
--   p_pff_attribute8               No   varchar2  Descriptive Flexfield
--   p_pff_attribute9               No   varchar2  Descriptive Flexfield
--   p_pff_attribute10              No   varchar2  Descriptive Flexfield
--   p_pff_attribute11              No   varchar2  Descriptive Flexfield
--   p_pff_attribute12              No   varchar2  Descriptive Flexfield
--   p_pff_attribute13              No   varchar2  Descriptive Flexfield
--   p_pff_attribute14              No   varchar2  Descriptive Flexfield
--   p_pff_attribute15              No   varchar2  Descriptive Flexfield
--   p_pff_attribute16              No   varchar2  Descriptive Flexfield
--   p_pff_attribute17              No   varchar2  Descriptive Flexfield
--   p_pff_attribute18              No   varchar2  Descriptive Flexfield
--   p_pff_attribute19              No   varchar2  Descriptive Flexfield
--   p_pff_attribute20              No   varchar2  Descriptive Flexfield
--   p_pff_attribute21              No   varchar2  Descriptive Flexfield
--   p_pff_attribute22              No   varchar2  Descriptive Flexfield
--   p_pff_attribute23              No   varchar2  Descriptive Flexfield
--   p_pff_attribute24              No   varchar2  Descriptive Flexfield
--   p_pff_attribute25              No   varchar2  Descriptive Flexfield
--   p_pff_attribute26              No   varchar2  Descriptive Flexfield
--   p_pff_attribute27              No   varchar2  Descriptive Flexfield
--   p_pff_attribute28              No   varchar2  Descriptive Flexfield
--   p_pff_attribute29              No   varchar2  Descriptive Flexfield
--   p_pff_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_pct_fl_tm_fctr_id            Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_percent_ft_factors
(
   p_validate                       in boolean    default false
  ,p_pct_fl_tm_fctr_id              out nocopy number
  ,p_name                           in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_mx_pct_val                     in  number    default null
  ,p_mn_pct_val                     in  number    default null
  ,p_no_mn_pct_val_flag             in  varchar2  default null
  ,p_no_mx_pct_val_flag             in  varchar2  default null
  ,p_use_prmry_asnt_only_flag       in  varchar2  default null
  ,p_use_sum_of_all_asnts_flag      in  varchar2  default null
  ,p_rndg_cd                        in  varchar2  default null
  ,p_rndg_rl                        in  number    default null
  ,p_pff_attribute_category         in  varchar2  default null
  ,p_pff_attribute1                 in  varchar2  default null
  ,p_pff_attribute2                 in  varchar2  default null
  ,p_pff_attribute3                 in  varchar2  default null
  ,p_pff_attribute4                 in  varchar2  default null
  ,p_pff_attribute5                 in  varchar2  default null
  ,p_pff_attribute6                 in  varchar2  default null
  ,p_pff_attribute7                 in  varchar2  default null
  ,p_pff_attribute8                 in  varchar2  default null
  ,p_pff_attribute9                 in  varchar2  default null
  ,p_pff_attribute10                in  varchar2  default null
  ,p_pff_attribute11                in  varchar2  default null
  ,p_pff_attribute12                in  varchar2  default null
  ,p_pff_attribute13                in  varchar2  default null
  ,p_pff_attribute14                in  varchar2  default null
  ,p_pff_attribute15                in  varchar2  default null
  ,p_pff_attribute16                in  varchar2  default null
  ,p_pff_attribute17                in  varchar2  default null
  ,p_pff_attribute18                in  varchar2  default null
  ,p_pff_attribute19                in  varchar2  default null
  ,p_pff_attribute20                in  varchar2  default null
  ,p_pff_attribute21                in  varchar2  default null
  ,p_pff_attribute22                in  varchar2  default null
  ,p_pff_attribute23                in  varchar2  default null
  ,p_pff_attribute24                in  varchar2  default null
  ,p_pff_attribute25                in  varchar2  default null
  ,p_pff_attribute26                in  varchar2  default null
  ,p_pff_attribute27                in  varchar2  default null
  ,p_pff_attribute28                in  varchar2  default null
  ,p_pff_attribute29                in  varchar2  default null
  ,p_pff_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_percent_ft_factors >------------------------|
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
--   p_pct_fl_tm_fctr_id            Yes  number    PK of record
--   p_name                         Yes  varchar2
--   p_business_group_id            Yes  number    Business Group of Record
--   p_mx_pct_val                   No   number
--   p_mn_pct_val                   No   number
--   p_no_mn_pct_val_flag           Yes  varchar2
--   p_no_mx_pct_val_flag           Yes  varchar2
--   p_use_prmry_asnt_only_flag     Yes  varchar2
--   p_use_sum_of_all_asnts_flag    Yes  varchar2
--   p_rndg_cd                      No   varchar2
--   p_rndg_rl                      No   number
--   p_pff_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pff_attribute1               No   varchar2  Descriptive Flexfield
--   p_pff_attribute2               No   varchar2  Descriptive Flexfield
--   p_pff_attribute3               No   varchar2  Descriptive Flexfield
--   p_pff_attribute4               No   varchar2  Descriptive Flexfield
--   p_pff_attribute5               No   varchar2  Descriptive Flexfield
--   p_pff_attribute6               No   varchar2  Descriptive Flexfield
--   p_pff_attribute7               No   varchar2  Descriptive Flexfield
--   p_pff_attribute8               No   varchar2  Descriptive Flexfield
--   p_pff_attribute9               No   varchar2  Descriptive Flexfield
--   p_pff_attribute10              No   varchar2  Descriptive Flexfield
--   p_pff_attribute11              No   varchar2  Descriptive Flexfield
--   p_pff_attribute12              No   varchar2  Descriptive Flexfield
--   p_pff_attribute13              No   varchar2  Descriptive Flexfield
--   p_pff_attribute14              No   varchar2  Descriptive Flexfield
--   p_pff_attribute15              No   varchar2  Descriptive Flexfield
--   p_pff_attribute16              No   varchar2  Descriptive Flexfield
--   p_pff_attribute17              No   varchar2  Descriptive Flexfield
--   p_pff_attribute18              No   varchar2  Descriptive Flexfield
--   p_pff_attribute19              No   varchar2  Descriptive Flexfield
--   p_pff_attribute20              No   varchar2  Descriptive Flexfield
--   p_pff_attribute21              No   varchar2  Descriptive Flexfield
--   p_pff_attribute22              No   varchar2  Descriptive Flexfield
--   p_pff_attribute23              No   varchar2  Descriptive Flexfield
--   p_pff_attribute24              No   varchar2  Descriptive Flexfield
--   p_pff_attribute25              No   varchar2  Descriptive Flexfield
--   p_pff_attribute26              No   varchar2  Descriptive Flexfield
--   p_pff_attribute27              No   varchar2  Descriptive Flexfield
--   p_pff_attribute28              No   varchar2  Descriptive Flexfield
--   p_pff_attribute29              No   varchar2  Descriptive Flexfield
--   p_pff_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_percent_ft_factors
  (
   p_validate                       in boolean    default false
  ,p_pct_fl_tm_fctr_id              in  number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_mx_pct_val                     in  number    default hr_api.g_number
  ,p_mn_pct_val                     in  number    default hr_api.g_number
  ,p_no_mn_pct_val_flag             in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_pct_val_flag             in  varchar2  default hr_api.g_varchar2
  ,p_use_prmry_asnt_only_flag       in  varchar2  default hr_api.g_varchar2
  ,p_use_sum_of_all_asnts_flag      in  varchar2  default hr_api.g_varchar2
  ,p_rndg_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_rndg_rl                        in  number    default hr_api.g_number
  ,p_pff_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_percent_ft_factors >------------------------|
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
--   p_pct_fl_tm_fctr_id            Yes  number    PK of record
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
procedure delete_percent_ft_factors
  (
   p_validate                       in boolean        default false
  ,p_pct_fl_tm_fctr_id              in  number
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
--   p_pct_fl_tm_fctr_id                 Yes  number   PK of record
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
    p_pct_fl_tm_fctr_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_percent_ft_factors_api;

 

/
