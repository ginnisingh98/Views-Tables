--------------------------------------------------------
--  DDL for Package BEN_VRBL_MATCHING_RATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_VRBL_MATCHING_RATE_API" AUTHID CURRENT_USER as
/* $Header: bevmrapi.pkh 120.0 2005/05/28 12:05:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_VRBL_MATCHING_RATE >------------------------|
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
--   p_no_mx_pct_of_py_num_flag     Yes  varchar2
--   p_to_pct_val                   No   number
--   p_no_mx_amt_of_py_num_flag     Yes  varchar2
--   p_mx_pct_of_py_num             No   number
--   p_no_mx_mtch_amt_flag          Yes  varchar2
--   p_ordr_num                     Yes  number
--   p_pct_val                      No   number
--   p_mx_mtch_amt                  No   number
--   p_mx_amt_of_py_num             No   number
--   p_mn_mtch_amt                  No   number
--   p_mtchg_rt_calc_rl             No   number
--   p_cntnu_mtch_aftr_max_rl_flag  Yes  varchar2
--   p_from_pct_val                 No   number
--   p_vrbl_rt_prfl_id              No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_vmr_attribute_category       No   varchar2  Descriptive Flexfield
--   p_vmr_attribute1               No   varchar2  Descriptive Flexfield
--   p_vmr_attribute2               No   varchar2  Descriptive Flexfield
--   p_vmr_attribute3               No   varchar2  Descriptive Flexfield
--   p_vmr_attribute4               No   varchar2  Descriptive Flexfield
--   p_vmr_attribute5               No   varchar2  Descriptive Flexfield
--   p_vmr_attribute6               No   varchar2  Descriptive Flexfield
--   p_vmr_attribute7               No   varchar2  Descriptive Flexfield
--   p_vmr_attribute8               No   varchar2  Descriptive Flexfield
--   p_vmr_attribute9               No   varchar2  Descriptive Flexfield
--   p_vmr_attribute10              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute11              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute12              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute13              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute14              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute15              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute16              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute17              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute18              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute19              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute20              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute21              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute22              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute23              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute24              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute25              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute26              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute27              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute28              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute29              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_vrbl_mtchg_rt_id             Yes  number    PK of record
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_VRBL_MATCHING_RATE
(
   p_validate                       in boolean    default false
  ,p_vrbl_mtchg_rt_id               out nocopy number
  ,p_effective_end_date             out nocopy date
  ,p_effective_start_date           out nocopy date
  ,p_no_mx_pct_of_py_num_flag       in  varchar2  default null
  ,p_to_pct_val                     in  number    default null
  ,p_no_mx_amt_of_py_num_flag       in  varchar2  default null
  ,p_mx_pct_of_py_num               in  number    default null
  ,p_no_mx_mtch_amt_flag            in  varchar2  default null
  ,p_ordr_num                       in  number    default null
  ,p_pct_val                        in  number    default null
  ,p_mx_mtch_amt                    in  number    default null
  ,p_mx_amt_of_py_num               in  number    default null
  ,p_mn_mtch_amt                    in  number    default null
  ,p_mtchg_rt_calc_rl               in  number    default null
  ,p_cntnu_mtch_aftr_max_rl_flag    in  varchar2  default null
  ,p_from_pct_val                   in  number    default null
  ,p_vrbl_rt_prfl_id                in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_vmr_attribute_category         in  varchar2  default null
  ,p_vmr_attribute1                 in  varchar2  default null
  ,p_vmr_attribute2                 in  varchar2  default null
  ,p_vmr_attribute3                 in  varchar2  default null
  ,p_vmr_attribute4                 in  varchar2  default null
  ,p_vmr_attribute5                 in  varchar2  default null
  ,p_vmr_attribute6                 in  varchar2  default null
  ,p_vmr_attribute7                 in  varchar2  default null
  ,p_vmr_attribute8                 in  varchar2  default null
  ,p_vmr_attribute9                 in  varchar2  default null
  ,p_vmr_attribute10                in  varchar2  default null
  ,p_vmr_attribute11                in  varchar2  default null
  ,p_vmr_attribute12                in  varchar2  default null
  ,p_vmr_attribute13                in  varchar2  default null
  ,p_vmr_attribute14                in  varchar2  default null
  ,p_vmr_attribute15                in  varchar2  default null
  ,p_vmr_attribute16                in  varchar2  default null
  ,p_vmr_attribute17                in  varchar2  default null
  ,p_vmr_attribute18                in  varchar2  default null
  ,p_vmr_attribute19                in  varchar2  default null
  ,p_vmr_attribute20                in  varchar2  default null
  ,p_vmr_attribute21                in  varchar2  default null
  ,p_vmr_attribute22                in  varchar2  default null
  ,p_vmr_attribute23                in  varchar2  default null
  ,p_vmr_attribute24                in  varchar2  default null
  ,p_vmr_attribute25                in  varchar2  default null
  ,p_vmr_attribute26                in  varchar2  default null
  ,p_vmr_attribute27                in  varchar2  default null
  ,p_vmr_attribute28                in  varchar2  default null
  ,p_vmr_attribute29                in  varchar2  default null
  ,p_vmr_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_VRBL_MATCHING_RATE >------------------------|
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
--   p_vrbl_mtchg_rt_id             Yes  number    PK of record
--   p_no_mx_pct_of_py_num_flag     Yes  varchar2
--   p_to_pct_val                   No   number
--   p_no_mx_amt_of_py_num_flag     Yes  varchar2
--   p_mx_pct_of_py_num             No   number
--   p_no_mx_mtch_amt_flag          Yes  varchar2
--   p_ordr_num                     Yes  number
--   p_pct_val                      No   number
--   p_mx_mtch_amt                  No   number
--   p_mx_amt_of_py_num             No   number
--   p_mn_mtch_amt                  No   number
--   p_mtchg_rt_calc_rl             No   number
--   p_cntnu_mtch_aftr_max_rl_flag  Yes  varchar2
--   p_from_pct_val                 No   number
--   p_vrbl_rt_prfl_id              No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_vmr_attribute_category       No   varchar2  Descriptive Flexfield
--   p_vmr_attribute1               No   varchar2  Descriptive Flexfield
--   p_vmr_attribute2               No   varchar2  Descriptive Flexfield
--   p_vmr_attribute3               No   varchar2  Descriptive Flexfield
--   p_vmr_attribute4               No   varchar2  Descriptive Flexfield
--   p_vmr_attribute5               No   varchar2  Descriptive Flexfield
--   p_vmr_attribute6               No   varchar2  Descriptive Flexfield
--   p_vmr_attribute7               No   varchar2  Descriptive Flexfield
--   p_vmr_attribute8               No   varchar2  Descriptive Flexfield
--   p_vmr_attribute9               No   varchar2  Descriptive Flexfield
--   p_vmr_attribute10              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute11              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute12              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute13              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute14              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute15              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute16              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute17              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute18              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute19              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute20              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute21              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute22              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute23              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute24              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute25              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute26              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute27              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute28              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute29              No   varchar2  Descriptive Flexfield
--   p_vmr_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date               Yes  date       Session Date.
--   p_datetrack_mode               Yes  varchar2   Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_VRBL_MATCHING_RATE
  (
   p_validate                       in boolean    default false
  ,p_vrbl_mtchg_rt_id               in  number
  ,p_effective_end_date             out nocopy date
  ,p_effective_start_date           out nocopy date
  ,p_no_mx_pct_of_py_num_flag       in  varchar2  default hr_api.g_varchar2
  ,p_to_pct_val                     in  number    default hr_api.g_number
  ,p_no_mx_amt_of_py_num_flag       in  varchar2  default hr_api.g_varchar2
  ,p_mx_pct_of_py_num               in  number    default hr_api.g_number
  ,p_no_mx_mtch_amt_flag            in  varchar2  default hr_api.g_varchar2
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_pct_val                        in  number    default hr_api.g_number
  ,p_mx_mtch_amt                    in  number    default hr_api.g_number
  ,p_mx_amt_of_py_num               in  number    default hr_api.g_number
  ,p_mn_mtch_amt                    in  number    default hr_api.g_number
  ,p_mtchg_rt_calc_rl               in  number    default hr_api.g_number
  ,p_cntnu_mtch_aftr_max_rl_flag    in  varchar2  default hr_api.g_varchar2
  ,p_from_pct_val                   in  number    default hr_api.g_number
  ,p_vrbl_rt_prfl_id                in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_vmr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_VRBL_MATCHING_RATE >------------------------|
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
--   p_vrbl_mtchg_rt_id             Yes  number    PK of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_VRBL_MATCHING_RATE
  (
   p_validate                       in boolean        default false
  ,p_vrbl_mtchg_rt_id               in  number
  ,p_effective_end_date             out nocopy date
  ,p_effective_start_date           out nocopy date
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
--   p_vrbl_mtchg_rt_id                 Yes  number   PK of record
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
    p_vrbl_mtchg_rt_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end ben_VRBL_MATCHING_RATE_api;

 

/
