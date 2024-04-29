--------------------------------------------------------
--  DDL for Package BEN_PLAN_TYPE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_TYPE_API" AUTHID CURRENT_USER as
/* $Header: beptpapi.pkh 120.0 2005/05/28 11:22:10 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_PLAN_TYPE >------------------------|
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
--   p_mx_enrl_alwd_num             No   number
--   p_mn_enrl_rqd_num              No   number
--   p_pl_typ_stat_cd               No   varchar2
--   p_opt_typ_cd                   No   varchar2
--   p_opt_dsply_fmt_cd             No   varchar2
--   p_comp_typ_cd                  No   varchar2
--   p_ivr_ident                    No   varchar2
--   p_no_mx_enrl_num_dfnd_flag     Yes  varchar2
--   p_no_mn_enrl_num_dfnd_flag     Yes  varchar2
--   p_business_group_id            Yes  number    Business Group of Record
--   p_ptp_attribute_category       No   varchar2  Descriptive Flexfield
--   p_ptp_attribute1               No   varchar2  Descriptive Flexfield
--   p_ptp_attribute2               No   varchar2  Descriptive Flexfield
--   p_ptp_attribute3               No   varchar2  Descriptive Flexfield
--   p_ptp_attribute4               No   varchar2  Descriptive Flexfield
--   p_ptp_attribute5               No   varchar2  Descriptive Flexfield
--   p_ptp_attribute6               No   varchar2  Descriptive Flexfield
--   p_ptp_attribute7               No   varchar2  Descriptive Flexfield
--   p_ptp_attribute8               No   varchar2  Descriptive Flexfield
--   p_ptp_attribute9               No   varchar2  Descriptive Flexfield
--   p_ptp_attribute10              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute11              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute12              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute13              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute14              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute15              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute16              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute17              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute18              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute19              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute20              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute21              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute22              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute23              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute24              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute25              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute26              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute27              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute28              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute29              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date               Yes  date      Session Date.
--   p_short_name           No   varchar2               FHR
--   p_short_code                   No   varchar2                   FHR
--   p_legislation_code                   No   varchar2                   FHR
--   p_legislation_subgroup                   No   varchar2                   FHR
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_pl_typ_id                    Yes  number    PK of record
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
procedure create_PLAN_TYPE
(
   p_validate                       in boolean    default false
  ,p_pl_typ_id                      out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default null
  ,p_mx_enrl_alwd_num               in  number    default null
  ,p_mn_enrl_rqd_num                in  number    default null
  ,p_pl_typ_stat_cd                 in  varchar2  default 'A'
  ,p_opt_typ_cd                     in  varchar2  default null
  ,p_opt_dsply_fmt_cd               in  varchar2  default null
  ,p_comp_typ_cd                    in  varchar2  default null
  ,p_ivr_ident                      in  varchar2  default null
  ,p_no_mx_enrl_num_dfnd_flag       in  varchar2  default null
  ,p_no_mn_enrl_num_dfnd_flag       in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_ptp_attribute_category         in  varchar2  default null
  ,p_ptp_attribute1                 in  varchar2  default null
  ,p_ptp_attribute2                 in  varchar2  default null
  ,p_ptp_attribute3                 in  varchar2  default null
  ,p_ptp_attribute4                 in  varchar2  default null
  ,p_ptp_attribute5                 in  varchar2  default null
  ,p_ptp_attribute6                 in  varchar2  default null
  ,p_ptp_attribute7                 in  varchar2  default null
  ,p_ptp_attribute8                 in  varchar2  default null
  ,p_ptp_attribute9                 in  varchar2  default null
  ,p_ptp_attribute10                in  varchar2  default null
  ,p_ptp_attribute11                in  varchar2  default null
  ,p_ptp_attribute12                in  varchar2  default null
  ,p_ptp_attribute13                in  varchar2  default null
  ,p_ptp_attribute14                in  varchar2  default null
  ,p_ptp_attribute15                in  varchar2  default null
  ,p_ptp_attribute16                in  varchar2  default null
  ,p_ptp_attribute17                in  varchar2  default null
  ,p_ptp_attribute18                in  varchar2  default null
  ,p_ptp_attribute19                in  varchar2  default null
  ,p_ptp_attribute20                in  varchar2  default null
  ,p_ptp_attribute21                in  varchar2  default null
  ,p_ptp_attribute22                in  varchar2  default null
  ,p_ptp_attribute23                in  varchar2  default null
  ,p_ptp_attribute24                in  varchar2  default null
  ,p_ptp_attribute25                in  varchar2  default null
  ,p_ptp_attribute26                in  varchar2  default null
  ,p_ptp_attribute27                in  varchar2  default null
  ,p_ptp_attribute28                in  varchar2  default null
  ,p_ptp_attribute29                in  varchar2  default null
  ,p_ptp_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_short_name             in  varchar2  default null
  ,p_short_code             in  varchar2  default null
    ,p_legislation_code             in  varchar2  default null
    ,p_legislation_subgroup             in  varchar2  default null
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_PLAN_TYPE >------------------------|
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
--   p_pl_typ_id                    Yes  number    PK of record
--   p_name                         Yes  varchar2
--   p_mx_enrl_alwd_num             No   number
--   p_mn_enrl_rqd_num              No   number
--   p_pl_typ_stat_cd               No   varchar2
--   p_opt_typ_cd                   No   varchar2
--   p_opt_dsply_fmt_cd             No   varchar2
--   p_comp_typ_cd                  No   varchar2
--   p_ivr_ident                    No   varchar2
--   p_no_mx_enrl_num_dfnd_flag     Yes  varchar2
--   p_no_mn_enrl_num_dfnd_flag     Yes  varchar2
--   p_business_group_id            Yes  number    Business Group of Record
--   p_ptp_attribute_category       No   varchar2  Descriptive Flexfield
--   p_ptp_attribute1               No   varchar2  Descriptive Flexfield
--   p_ptp_attribute2               No   varchar2  Descriptive Flexfield
--   p_ptp_attribute3               No   varchar2  Descriptive Flexfield
--   p_ptp_attribute4               No   varchar2  Descriptive Flexfield
--   p_ptp_attribute5               No   varchar2  Descriptive Flexfield
--   p_ptp_attribute6               No   varchar2  Descriptive Flexfield
--   p_ptp_attribute7               No   varchar2  Descriptive Flexfield
--   p_ptp_attribute8               No   varchar2  Descriptive Flexfield
--   p_ptp_attribute9               No   varchar2  Descriptive Flexfield
--   p_ptp_attribute10              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute11              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute12              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute13              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute14              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute15              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute16              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute17              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute18              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute19              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute20              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute21              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute22              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute23              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute24              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute25              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute26              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute27              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute28              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute29              No   varchar2  Descriptive Flexfield
--   p_ptp_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date               Yes  date       Session Date.
--   p_datetrack_mode               Yes  varchar2   Datetrack mode.
--   p_short_name           No   varchar2               FHR
--   p_short_code                   No   varchar2                   FHR
--   p_legislation_code                   No   varchar2                   FHR
--   p_legislation_subgroup                   No   varchar2                   FHR
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
procedure update_PLAN_TYPE
  (
   p_validate                       in boolean    default false
  ,p_pl_typ_id                      in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_mx_enrl_alwd_num               in  number    default hr_api.g_number
  ,p_mn_enrl_rqd_num                in  number    default hr_api.g_number
  ,p_pl_typ_stat_cd                 in  varchar2  default 'A'
  ,p_opt_typ_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_opt_dsply_fmt_cd               in  varchar2  default hr_api.g_varchar2
  ,p_comp_typ_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_ivr_ident                      in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_enrl_num_dfnd_flag       in  varchar2  default hr_api.g_varchar2
  ,p_no_mn_enrl_num_dfnd_flag       in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_ptp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_short_name             in  varchar2  default hr_api.g_varchar2
  ,p_short_code             in  varchar2  default hr_api.g_varchar2
    ,p_legislation_code             in  varchar2  default hr_api.g_varchar2
    ,p_legislation_subgroup             in  varchar2  default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_PLAN_TYPE >------------------------|
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
--   p_pl_typ_id                    Yes  number    PK of record
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
procedure delete_PLAN_TYPE
  (
   p_validate                       in boolean        default false
  ,p_pl_typ_id                      in  number
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
--   p_pl_typ_id                 Yes  number   PK of record
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
    p_pl_typ_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end ben_PLAN_TYPE_api;

 

/
