--------------------------------------------------------
--  DDL for Package BEN_VRBL_RATE_RULE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_VRBL_RATE_RULE_API" AUTHID CURRENT_USER as
/* $Header: bevrrapi.pkh 120.0 2005/05/28 12:13:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Vrbl_Rate_Rule >------------------------|
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
--   p_drvbl_fctr_apls_flag         Yes  varchar2
--   p_rt_trtmt_cd                  No   varchar2
--   p_ordr_to_aply_num             No   number
--   p_formula_id                   Yes  number
--   p_acty_base_rt_id              No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_vrr_attribute_category       No   varchar2  Descriptive Flexfield
--   p_vrr_attribute1               No   varchar2  Descriptive Flexfield
--   p_vrr_attribute2               No   varchar2  Descriptive Flexfield
--   p_vrr_attribute3               No   varchar2  Descriptive Flexfield
--   p_vrr_attribute4               No   varchar2  Descriptive Flexfield
--   p_vrr_attribute5               No   varchar2  Descriptive Flexfield
--   p_vrr_attribute6               No   varchar2  Descriptive Flexfield
--   p_vrr_attribute7               No   varchar2  Descriptive Flexfield
--   p_vrr_attribute8               No   varchar2  Descriptive Flexfield
--   p_vrr_attribute9               No   varchar2  Descriptive Flexfield
--   p_vrr_attribute10              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute11              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute12              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute13              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute14              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute15              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute16              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute17              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute18              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute19              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute20              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute21              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute22              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute23              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute24              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute25              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute26              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute27              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute28              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute29              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_vrbl_rt_rl_id                Yes  number    PK of record
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
procedure create_Vrbl_Rate_Rule
(
   p_validate                       in boolean    default false
  ,p_vrbl_rt_rl_id                  out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_drvbl_fctr_apls_flag           in  varchar2  default null
  ,p_rt_trtmt_cd                    in  varchar2  default null
  ,p_ordr_to_aply_num               in  number    default null
  ,p_formula_id                     in  number    default null
  ,p_acty_base_rt_id                in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_vrr_attribute_category         in  varchar2  default null
  ,p_vrr_attribute1                 in  varchar2  default null
  ,p_vrr_attribute2                 in  varchar2  default null
  ,p_vrr_attribute3                 in  varchar2  default null
  ,p_vrr_attribute4                 in  varchar2  default null
  ,p_vrr_attribute5                 in  varchar2  default null
  ,p_vrr_attribute6                 in  varchar2  default null
  ,p_vrr_attribute7                 in  varchar2  default null
  ,p_vrr_attribute8                 in  varchar2  default null
  ,p_vrr_attribute9                 in  varchar2  default null
  ,p_vrr_attribute10                in  varchar2  default null
  ,p_vrr_attribute11                in  varchar2  default null
  ,p_vrr_attribute12                in  varchar2  default null
  ,p_vrr_attribute13                in  varchar2  default null
  ,p_vrr_attribute14                in  varchar2  default null
  ,p_vrr_attribute15                in  varchar2  default null
  ,p_vrr_attribute16                in  varchar2  default null
  ,p_vrr_attribute17                in  varchar2  default null
  ,p_vrr_attribute18                in  varchar2  default null
  ,p_vrr_attribute19                in  varchar2  default null
  ,p_vrr_attribute20                in  varchar2  default null
  ,p_vrr_attribute21                in  varchar2  default null
  ,p_vrr_attribute22                in  varchar2  default null
  ,p_vrr_attribute23                in  varchar2  default null
  ,p_vrr_attribute24                in  varchar2  default null
  ,p_vrr_attribute25                in  varchar2  default null
  ,p_vrr_attribute26                in  varchar2  default null
  ,p_vrr_attribute27                in  varchar2  default null
  ,p_vrr_attribute28                in  varchar2  default null
  ,p_vrr_attribute29                in  varchar2  default null
  ,p_vrr_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_Vrbl_Rate_Rule >------------------------|
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
--   p_vrbl_rt_rl_id                Yes  number    PK of record
--   p_drvbl_fctr_apls_flag         Yes  varchar2
--   p_rt_trtmt_cd                  No   varchar2
--   p_ordr_to_aply_num             No   number
--   p_formula_id                   Yes  number
--   p_acty_base_rt_id              No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_vrr_attribute_category       No   varchar2  Descriptive Flexfield
--   p_vrr_attribute1               No   varchar2  Descriptive Flexfield
--   p_vrr_attribute2               No   varchar2  Descriptive Flexfield
--   p_vrr_attribute3               No   varchar2  Descriptive Flexfield
--   p_vrr_attribute4               No   varchar2  Descriptive Flexfield
--   p_vrr_attribute5               No   varchar2  Descriptive Flexfield
--   p_vrr_attribute6               No   varchar2  Descriptive Flexfield
--   p_vrr_attribute7               No   varchar2  Descriptive Flexfield
--   p_vrr_attribute8               No   varchar2  Descriptive Flexfield
--   p_vrr_attribute9               No   varchar2  Descriptive Flexfield
--   p_vrr_attribute10              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute11              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute12              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute13              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute14              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute15              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute16              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute17              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute18              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute19              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute20              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute21              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute22              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute23              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute24              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute25              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute26              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute27              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute28              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute29              No   varchar2  Descriptive Flexfield
--   p_vrr_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_Vrbl_Rate_Rule
  (
   p_validate                       in boolean    default false
  ,p_vrbl_rt_rl_id                  in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_drvbl_fctr_apls_flag           in  varchar2  default hr_api.g_varchar2
  ,p_rt_trtmt_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_ordr_to_aply_num               in  number    default hr_api.g_number
  ,p_formula_id                     in  number    default hr_api.g_number
  ,p_acty_base_rt_id                in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_vrr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Vrbl_Rate_Rule >------------------------|
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
--   p_vrbl_rt_rl_id                Yes  number    PK of record
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
procedure delete_Vrbl_Rate_Rule
  (
   p_validate                       in boolean        default false
  ,p_vrbl_rt_rl_id                  in  number
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
--   p_vrbl_rt_rl_id                 Yes  number   PK of record
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
    p_vrbl_rt_rl_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end ben_Vrbl_Rate_Rule_api;

 

/
