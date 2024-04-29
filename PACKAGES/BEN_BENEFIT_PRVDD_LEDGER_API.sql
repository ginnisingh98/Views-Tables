--------------------------------------------------------
--  DDL for Package BEN_BENEFIT_PRVDD_LEDGER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BENEFIT_PRVDD_LEDGER_API" AUTHID CURRENT_USER as
/* $Header: bebplapi.pkh 120.0.12000000.1 2007/01/19 01:23:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Benefit_Prvdd_Ledger >------------------------|
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
--   p_prtt_ro_of_unusd_amt_flag    Yes  varchar2
--   p_frftd_val                    No   number
--   p_prvdd_val                    No   number
--   p_used_val                     No   number
--   p_bnft_prvdr_pool_id           No   number
--   p_acty_base_rt_id              Yes  number
--   p_per_in_ler_id                Yes  number
--   p_prtt_enrt_rslt_id            No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_bpl_attribute_category       No   varchar2  Descriptive Flexfield
--   p_bpl_attribute1               No   varchar2  Descriptive Flexfield
--   p_bpl_attribute2               No   varchar2  Descriptive Flexfield
--   p_bpl_attribute3               No   varchar2  Descriptive Flexfield
--   p_bpl_attribute4               No   varchar2  Descriptive Flexfield
--   p_bpl_attribute5               No   varchar2  Descriptive Flexfield
--   p_bpl_attribute6               No   varchar2  Descriptive Flexfield
--   p_bpl_attribute7               No   varchar2  Descriptive Flexfield
--   p_bpl_attribute8               No   varchar2  Descriptive Flexfield
--   p_bpl_attribute9               No   varchar2  Descriptive Flexfield
--   p_bpl_attribute10              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute11              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute12              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute13              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute14              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute15              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute16              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute17              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute18              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute19              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute20              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute21              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute22              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute23              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute24              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute25              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute26              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute27              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute28              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute29              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute30              No   varchar2  Descriptive Flexfield
--   p_cash_recd_val                No   number
--   p_rld_up_val                   No   number
--   p_acty_ref_perd_cd             Yes  varchar2
--   p_cmcd_frftd_val               No   number
--   p_cmcd_prvdd_val               No   number
--   p_cmcd_rld_up_val              No   number
--   p_cmcd_used_val                No   number
--   p_cmcd_cash_recd_val           No   number
--   p_cmcd_ref_perd_cd             Yes  varchar2
--   p_ann_frftd_val                No   number
--   p_ann_prvdd_val                No   number
--   p_ann_rld_up_val               No   number
--   p_ann_used_val                 No   number
--   p_ann_cash_recd_val            No   number
--   p_effective_date               Yes  date      Session Date.
--   p_process_enrt_flag            No   varchar2  Process related enrollments.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_bnft_prvdd_ldgr_id           Yes  number    PK of record
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
procedure create_Benefit_Prvdd_Ledger
(
   p_validate                       in boolean    default false
  ,p_bnft_prvdd_ldgr_id             out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_prtt_ro_of_unusd_amt_flag      in  varchar2  default null
  ,p_frftd_val                      in  number    default null
  ,p_prvdd_val                      in  number    default null
  ,p_used_val                       in  number    default null
  ,p_person_id              in  number    default null
  ,p_enrt_mthd_cd           in  varchar2  default null
  ,p_bnft_prvdr_pool_id             in  number    default null
  ,p_acty_base_rt_id                in  number    default null
  ,p_per_in_ler_id                  in  number    default null
  ,p_prtt_enrt_rslt_id              in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_bpl_attribute_category         in  varchar2  default null
  ,p_bpl_attribute1                 in  varchar2  default null
  ,p_bpl_attribute2                 in  varchar2  default null
  ,p_bpl_attribute3                 in  varchar2  default null
  ,p_bpl_attribute4                 in  varchar2  default null
  ,p_bpl_attribute5                 in  varchar2  default null
  ,p_bpl_attribute6                 in  varchar2  default null
  ,p_bpl_attribute7                 in  varchar2  default null
  ,p_bpl_attribute8                 in  varchar2  default null
  ,p_bpl_attribute9                 in  varchar2  default null
  ,p_bpl_attribute10                in  varchar2  default null
  ,p_bpl_attribute11                in  varchar2  default null
  ,p_bpl_attribute12                in  varchar2  default null
  ,p_bpl_attribute13                in  varchar2  default null
  ,p_bpl_attribute14                in  varchar2  default null
  ,p_bpl_attribute15                in  varchar2  default null
  ,p_bpl_attribute16                in  varchar2  default null
  ,p_bpl_attribute17                in  varchar2  default null
  ,p_bpl_attribute18                in  varchar2  default null
  ,p_bpl_attribute19                in  varchar2  default null
  ,p_bpl_attribute20                in  varchar2  default null
  ,p_bpl_attribute21                in  varchar2  default null
  ,p_bpl_attribute22                in  varchar2  default null
  ,p_bpl_attribute23                in  varchar2  default null
  ,p_bpl_attribute24                in  varchar2  default null
  ,p_bpl_attribute25                in  varchar2  default null
  ,p_bpl_attribute26                in  varchar2  default null
  ,p_bpl_attribute27                in  varchar2  default null
  ,p_bpl_attribute28                in  varchar2  default null
  ,p_bpl_attribute29                in  varchar2  default null
  ,p_bpl_attribute30                in  varchar2  default null
  ,p_cash_recd_val                  in  number    default null
  ,p_rld_up_val                     in  number    default null
  ,p_effective_date                 in  date
  ,p_process_enrt_flag              in  varchar2  default 'Y'
  ,p_from_reinstate_enrt_flag       in  varchar2  default 'N',
  p_acty_ref_perd_cd             in   varchar2         default null,
  p_cmcd_frftd_val               in   number           default null,
  p_cmcd_prvdd_val               in   number           default null,
  p_cmcd_rld_up_val              in   number           default null,
  p_cmcd_used_val                in   number           default null,
  p_cmcd_cash_recd_val           in   number           default null,
  p_cmcd_ref_perd_cd             in   varchar2         default null,
  p_ann_frftd_val                in   number           default null,
  p_ann_prvdd_val                in   number           default null,
  p_ann_rld_up_val               in   number           default null,
  p_ann_used_val                 in   number           default null,
  p_ann_cash_recd_val            in   number           default null,
  p_object_version_number          out nocopy number
 );
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Benefit_Prvdd_Ledger_w >-----------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: Self Service wrapper called from Java code.
--
-- {End Of Comments}
--
procedure create_Benefit_Prvdd_Ledger_w
(
   p_validate                       in  varchar2  default 'FALSE'
  ,p_bnft_prvdd_ldgr_id             out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_prtt_ro_of_unusd_amt_flag      in  varchar2  default null
  ,p_frftd_val                      in  number    default null
  ,p_prvdd_val                      in  number    default null
  ,p_used_val                       in  number    default null
  ,p_person_id                      in  number    default null
  ,p_enrt_mthd_cd                   in  varchar2  default null
  ,p_bnft_prvdr_pool_id             in  number    default null
  ,p_acty_base_rt_id                in  number    default null
  ,p_per_in_ler_id                  in  number    default null
  ,p_prtt_enrt_rslt_id              in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_cash_recd_val                  in  number    default null
  ,p_rld_up_val                     in  number    default null
  ,p_effective_date                 in  date
  ,p_process_enrt_flag              in  varchar2  default 'Y'
  ,p_from_reinstate_enrt_flag       in  varchar2  default 'N',
  p_acty_ref_perd_cd             in   varchar2         default null,
  p_cmcd_frftd_val               in   number           default null,
  p_cmcd_prvdd_val               in   number           default null,
  p_cmcd_rld_up_val              in   number           default null,
  p_cmcd_used_val                in   number           default null,
  p_cmcd_cash_recd_val           in   number           default null,
  p_cmcd_ref_perd_cd             in   varchar2         default null,
  p_ann_frftd_val                in   number           default null,
  p_ann_prvdd_val                in   number           default null,
  p_ann_rld_up_val               in   number           default null,
  p_ann_used_val                 in   number           default null,
  p_ann_cash_recd_val            in   number           default null,
  p_object_version_number          out nocopy number
 );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_Benefit_Prvdd_Ledger >-------------------|
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
--   p_bnft_prvdd_ldgr_id           Yes  number    PK of record
--   p_prtt_ro_of_unusd_amt_flag    Yes  varchar2
--   p_frftd_val                    No   number
--   p_prvdd_val                    No   number
--   p_used_val                     No   number
--   p_bnft_prvdr_pool_id           No   number
--   p_acty_base_rt_id              Yes  number
--   p_per_in_ler_id                Yes  number
--   p_prtt_enrt_rslt_id            No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_bpl_attribute_category       No   varchar2  Descriptive Flexfield
--   p_bpl_attribute1               No   varchar2  Descriptive Flexfield
--   p_bpl_attribute2               No   varchar2  Descriptive Flexfield
--   p_bpl_attribute3               No   varchar2  Descriptive Flexfield
--   p_bpl_attribute4               No   varchar2  Descriptive Flexfield
--   p_bpl_attribute5               No   varchar2  Descriptive Flexfield
--   p_bpl_attribute6               No   varchar2  Descriptive Flexfield
--   p_bpl_attribute7               No   varchar2  Descriptive Flexfield
--   p_bpl_attribute8               No   varchar2  Descriptive Flexfield
--   p_bpl_attribute9               No   varchar2  Descriptive Flexfield
--   p_bpl_attribute10              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute11              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute12              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute13              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute14              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute15              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute16              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute17              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute18              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute19              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute20              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute21              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute22              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute23              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute24              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute25              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute26              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute27              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute28              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute29              No   varchar2  Descriptive Flexfield
--   p_bpl_attribute30              No   varchar2  Descriptive Flexfield
--   p_cash_recd_val                No   number
--   p_rld_up_val                   No   number
--   p_acty_ref_perd_cd             Yes  varchar2
--   p_cmcd_frftd_val               No   number
--   p_cmcd_prvdd_val               No   number
--   p_cmcd_rld_up_val              No   number
--   p_cmcd_used_val                No   number
--   p_cmcd_cash_recd_val           No   number
--   p_cmcd_ref_perd_cd             Yes  varchar2
--   p_ann_frftd_val                No   number
--   p_ann_prvdd_val                No   number
--   p_ann_rld_up_val               No   number
--   p_ann_used_val                 No   number
--   p_ann_cash_recd_val            No   number
--   p_effective_date               Yes  date       Session Date.
--   p_datetrack_mode               Yes  varchar2   Datetrack mode.
--   p_process_enrt_flag            No   varchar2  Process related enrollments.
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
procedure update_Benefit_Prvdd_Ledger
  (
   p_validate                       in boolean    default false
  ,p_bnft_prvdd_ldgr_id             in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_prtt_ro_of_unusd_amt_flag      in  varchar2  default hr_api.g_varchar2
  ,p_frftd_val                      in  number    default hr_api.g_number
  ,p_prvdd_val                      in  number    default hr_api.g_number
  ,p_used_val                       in  number    default hr_api.g_number
  ,p_bnft_prvdr_pool_id             in  number    default hr_api.g_number
  ,p_acty_base_rt_id                in  number    default hr_api.g_number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_bpl_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_cash_recd_val                  in  number    default hr_api.g_number
  ,p_rld_up_val                     in number     default hr_api.g_number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_process_enrt_flag              in  varchar2  default 'Y'
  ,p_from_reinstate_enrt_flag       in  varchar2  default 'N',
  p_acty_ref_perd_cd             in   varchar2         default hr_api.g_varchar2,
  p_cmcd_frftd_val               in   number           default hr_api.g_number,
  p_cmcd_prvdd_val               in   number           default hr_api.g_number,
  p_cmcd_rld_up_val              in   number           default hr_api.g_number,
  p_cmcd_used_val                in   number           default hr_api.g_number,
  p_cmcd_cash_recd_val           in   number           default hr_api.g_number,
  p_cmcd_ref_perd_cd             in   varchar2         default hr_api.g_varchar2,
  p_ann_frftd_val                in   number           default hr_api.g_number,
  p_ann_prvdd_val                in   number           default hr_api.g_number,
  p_ann_rld_up_val               in   number           default hr_api.g_number,
  p_ann_used_val                 in   number           default hr_api.g_number,
  p_ann_cash_recd_val            in   number           default hr_api.g_number,
  p_object_version_number          in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_Benefit_Prvdd_Ledger_w >-----------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: Self Service wrapper called from Java code.
--
--
-- {End Of Comments}
--
procedure update_Benefit_Prvdd_Ledger_w
  (
   p_validate                       in  varchar2  default 'FALSE'
  ,p_bnft_prvdd_ldgr_id             in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_prtt_ro_of_unusd_amt_flag      in  varchar2  default hr_api.g_varchar2
  ,p_frftd_val                      in  number    default hr_api.g_number
  ,p_prvdd_val                      in  number    default hr_api.g_number
  ,p_used_val                       in  number    default hr_api.g_number
  ,p_bnft_prvdr_pool_id             in  number    default hr_api.g_number
  ,p_acty_base_rt_id                in  number    default hr_api.g_number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_cash_recd_val                  in  number    default hr_api.g_number
  ,p_rld_up_val                     in number     default hr_api.g_number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_process_enrt_flag              in  varchar2  default 'Y'
  ,p_from_reinstate_enrt_flag       in  varchar2  default 'N',
  p_acty_ref_perd_cd             in   varchar2         default hr_api.g_varchar2,
  p_cmcd_frftd_val               in   number           default hr_api.g_number,
  p_cmcd_prvdd_val               in   number           default hr_api.g_number,
  p_cmcd_rld_up_val              in   number           default hr_api.g_number,
  p_cmcd_used_val                in   number           default hr_api.g_number,
  p_cmcd_cash_recd_val           in   number           default hr_api.g_number,
  p_cmcd_ref_perd_cd             in   varchar2         default hr_api.g_varchar2,
  p_ann_frftd_val                in   number           default hr_api.g_number,
  p_ann_prvdd_val                in   number           default hr_api.g_number,
  p_ann_rld_up_val               in   number           default hr_api.g_number,
  p_ann_used_val                 in   number           default hr_api.g_number,
  p_ann_cash_recd_val            in   number           default hr_api.g_number,
  p_object_version_number          in  out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Benefit_Prvdd_Ledger >------------------------|
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
--   p_bnft_prvdd_ldgr_id           Yes  number    PK of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--   p_process_enrt_flag            No   varchar2  Process related enrollments.
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
procedure delete_Benefit_Prvdd_Ledger
  (
   p_validate                       in  boolean     default false
  ,p_bnft_prvdd_ldgr_id             in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in  out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_business_group_id              in  number
  ,p_process_enrt_flag              in  varchar2    default 'Y'
  ,p_from_reinstate_enrt_flag       in  varchar2    default 'N'
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Benefit_Prvdd_Ledger_w >-----------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: Self Service wrapper called from Java code.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  varchar2 TRUE or FALSE
--   p_bnft_prvdd_ldgr_id           Yes  number   PK of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--   p_process_enrt_flag            No   varchar2 Process related enrollments.
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
procedure delete_Benefit_Prvdd_Ledger_w
  (
   p_validate                       in  varchar2  default 'FALSE'
  ,p_bnft_prvdd_ldgr_id             in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in  out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_business_group_id              in  number
  ,p_process_enrt_flag              in  varchar2  default 'Y'
  ,p_from_reinstate_enrt_flag       in  varchar2  default 'N'
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
--   p_bnft_prvdd_ldgr_id                 Yes  number   PK of record
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
    p_bnft_prvdd_ldgr_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end ben_Benefit_Prvdd_Ledger_api;

 

/
