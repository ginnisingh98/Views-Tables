--------------------------------------------------------
--  DDL for Package BEN_PRTL_MO_RT_PRTN_VAL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRTL_MO_RT_PRTN_VAL_API" AUTHID CURRENT_USER as
/* $Header: beppvapi.pkh 120.0 2005/05/28 11:01:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Prtl_Mo_Rt_Prtn_Val >------------------------|
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
--   p_acty_base_rt_id              No   number
--   p_rndg_rl                      No   number
--   p_rndg_cd                      No   varchar2
--   p_to_dy_mo_num                 No   number
--   p_from_dy_mo_num               No   number
--   p_pct_val                      No   number
--   p_business_group_id            No   number    Business Group of Record
--   p_pmrpv_attribute_category     No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute1             No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute2             No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute3             No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute4             No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute5             No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute6             No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute7             No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute8             No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute9             No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute10            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute11            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute12            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute13            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute14            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute15            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute16            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute17            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute18            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute19            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute20            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute21            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute22            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute23            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute24            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute25            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute26            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute27            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute28            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute29            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute30            No   varchar2  Descriptive Flexfield
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_prtl_mo_rt_prtn_val_id       Yes  number    PK of record
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
procedure create_Prtl_Mo_Rt_Prtn_Val
(
   p_validate                       in boolean    default false
  ,p_prtl_mo_rt_prtn_val_id         out nocopy number
  ,p_effective_end_date             out nocopy date
  ,p_effective_start_date           out nocopy date
  ,p_acty_base_rt_id                in  number    default null
  ,p_rndg_rl                        in  number    default null
  ,p_rndg_cd                        in  varchar2  default null
  ,p_to_dy_mo_num                   in  number    default null
  ,p_from_dy_mo_num                 in  number    default null
  ,p_pct_val                        in  number    default null
  ,p_strt_r_stp_cvg_cd              in  varchar2  default null
  ,p_prtl_mo_prortn_rl              in  number    default null
  ,p_actl_prem_id                   in  number    default null
  ,p_cvg_amt_calc_mthd_id           in  number    default null
  ,p_num_days_month                 in  number    default null
  ,p_prorate_by_day_to_mon_flag     in  varchar2  default 'N'
  ,p_business_group_id              in  number    default null
  ,p_pmrpv_attribute_category       in  varchar2  default null
  ,p_pmrpv_attribute1               in  varchar2  default null
  ,p_pmrpv_attribute2               in  varchar2  default null
  ,p_pmrpv_attribute3               in  varchar2  default null
  ,p_pmrpv_attribute4               in  varchar2  default null
  ,p_pmrpv_attribute5               in  varchar2  default null
  ,p_pmrpv_attribute6               in  varchar2  default null
  ,p_pmrpv_attribute7               in  varchar2  default null
  ,p_pmrpv_attribute8               in  varchar2  default null
  ,p_pmrpv_attribute9               in  varchar2  default null
  ,p_pmrpv_attribute10              in  varchar2  default null
  ,p_pmrpv_attribute11              in  varchar2  default null
  ,p_pmrpv_attribute12              in  varchar2  default null
  ,p_pmrpv_attribute13              in  varchar2  default null
  ,p_pmrpv_attribute14              in  varchar2  default null
  ,p_pmrpv_attribute15              in  varchar2  default null
  ,p_pmrpv_attribute16              in  varchar2  default null
  ,p_pmrpv_attribute17              in  varchar2  default null
  ,p_pmrpv_attribute18              in  varchar2  default null
  ,p_pmrpv_attribute19              in  varchar2  default null
  ,p_pmrpv_attribute20              in  varchar2  default null
  ,p_pmrpv_attribute21              in  varchar2  default null
  ,p_pmrpv_attribute22              in  varchar2  default null
  ,p_pmrpv_attribute23              in  varchar2  default null
  ,p_pmrpv_attribute24              in  varchar2  default null
  ,p_pmrpv_attribute25              in  varchar2  default null
  ,p_pmrpv_attribute26              in  varchar2  default null
  ,p_pmrpv_attribute27              in  varchar2  default null
  ,p_pmrpv_attribute28              in  varchar2  default null
  ,p_pmrpv_attribute29              in  varchar2  default null
  ,p_pmrpv_attribute30              in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_Prtl_Mo_Rt_Prtn_Val >------------------------|
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
--   p_prtl_mo_rt_prtn_val_id       Yes  number    PK of record
--   p_acty_base_rt_id              No   number
--   p_rndg_rl                      No   number
--   p_rndg_cd                      No   varchar2
--   p_to_dy_mo_num                 No   number
--   p_from_dy_mo_num               No   number
--   p_pct_val                      No   number
--   p_business_group_id            No   number    Business Group of Record
--   p_pmrpv_attribute_category     No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute1             No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute2             No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute3             No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute4             No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute5             No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute6             No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute7             No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute8             No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute9             No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute10            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute11            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute12            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute13            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute14            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute15            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute16            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute17            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute18            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute19            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute20            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute21            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute22            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute23            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute24            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute25            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute26            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute27            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute28            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute29            No   varchar2  Descriptive Flexfield
--   p_pmrpv_attribute30            No   varchar2  Descriptive Flexfield
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
procedure update_Prtl_Mo_Rt_Prtn_Val
  (
   p_validate                       in boolean    default false
  ,p_prtl_mo_rt_prtn_val_id         in  number
  ,p_effective_end_date             out nocopy date
  ,p_effective_start_date           out nocopy date
  ,p_acty_base_rt_id                in  number    default hr_api.g_number
  ,p_rndg_rl                        in  number    default hr_api.g_number
  ,p_rndg_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_to_dy_mo_num                   in  number    default hr_api.g_number
  ,p_from_dy_mo_num                 in  number    default hr_api.g_number
  ,p_pct_val                        in  number    default hr_api.g_number
  ,p_strt_r_stp_cvg_cd              in  varchar2  default hr_api.g_varchar2
  ,p_prtl_mo_prortn_rl              in  number    default hr_api.g_number
  ,p_actl_prem_id                   in  number    default hr_api.g_number
  ,p_cvg_amt_calc_mthd_id           in  number    default hr_api.g_number
  ,p_num_days_month                 in  number    default hr_api.g_number
  ,p_prorate_by_day_to_mon_flag     in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pmrpv_attribute_category       in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute1               in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute2               in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute3               in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute4               in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute5               in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute6               in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute7               in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute8               in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute9               in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute10              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute11              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute12              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute13              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute14              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute15              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute16              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute17              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute18              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute19              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute20              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute21              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute22              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute23              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute24              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute25              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute26              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute27              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute28              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute29              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute30              in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Prtl_Mo_Rt_Prtn_Val >------------------------|
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
--   p_prtl_mo_rt_prtn_val_id       Yes  number    PK of record
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
procedure delete_Prtl_Mo_Rt_Prtn_Val
  (
   p_validate                       in boolean        default false
  ,p_prtl_mo_rt_prtn_val_id         in  number
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
--   p_prtl_mo_rt_prtn_val_id                 Yes  number   PK of record
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
    p_prtl_mo_rt_prtn_val_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
procedure update_old_rows
  (p_acty_base_rt_id     in number default null
  ,p_actl_prem_id        in number default null
  ,p_effective_date      in date
  ,p_business_group_id   in number
 );
--
end ben_Prtl_Mo_Rt_Prtn_Val_api;

 

/
