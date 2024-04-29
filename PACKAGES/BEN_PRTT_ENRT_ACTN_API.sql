--------------------------------------------------------
--  DDL for Package BEN_PRTT_ENRT_ACTN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRTT_ENRT_ACTN_API" AUTHID CURRENT_USER as
/* $Header: bepeaapi.pkh 120.0.12000000.1 2007/01/19 20:59:48 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_PRTT_ENRT_ACTN >-------------------------|
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
--   p_post_rslt_flag               No   varchar2 Flag passed to suspend_enrollment
--   p_cmpltd_dt                    No   date
--   p_due_dt                       No   date
--   p_prtt_enrt_rslt_id            Yes  number
--   p_per_in_ler_id            Yes  number
--   p_actn_typ_id                  Yes  number
--   p_Business_group_id            No   number    Business Group of Record
--   p_elig_cvrd_dpnt_id            no   number
--   p_pl_bnf_id                    no   number
--   p_rqd_flag                     no   varchar2
--   p_pea_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pea_attribute1               No   varchar2  Descriptive Flexfield
--   p_pea_attribute2               No   varchar2  Descriptive Flexfield
--   p_pea_attribute3               No   varchar2  Descriptive Flexfield
--   p_pea_attribute4               No   varchar2  Descriptive Flexfield
--   p_pea_attribute5               No   varchar2  Descriptive Flexfield
--   p_pea_attribute6               No   varchar2  Descriptive Flexfield
--   p_pea_attribute7               No   varchar2  Descriptive Flexfield
--   p_pea_attribute8               No   varchar2  Descriptive Flexfield
--   p_pea_attribute9               No   varchar2  Descriptive Flexfield
--   p_pea_attribute10              No   varchar2  Descriptive Flexfield
--   p_pea_attribute11              No   varchar2  Descriptive Flexfield
--   p_pea_attribute12              No   varchar2  Descriptive Flexfield
--   p_pea_attribute13              No   varchar2  Descriptive Flexfield
--   p_pea_attribute14              No   varchar2  Descriptive Flexfield
--   p_pea_attribute15              No   varchar2  Descriptive Flexfield
--   p_pea_attribute16              No   varchar2  Descriptive Flexfield
--   p_pea_attribute17              No   varchar2  Descriptive Flexfield
--   p_pea_attribute18              No   varchar2  Descriptive Flexfield
--   p_pea_attribute19              No   varchar2  Descriptive Flexfield
--   p_pea_attribute20              No   varchar2  Descriptive Flexfield
--   p_pea_attribute21              No   varchar2  Descriptive Flexfield
--   p_pea_attribute22              No   varchar2  Descriptive Flexfield
--   p_pea_attribute23              No   varchar2  Descriptive Flexfield
--   p_pea_attribute24              No   varchar2  Descriptive Flexfield
--   p_pea_attribute25              No   varchar2  Descriptive Flexfield
--   p_pea_attribute26              No   varchar2  Descriptive Flexfield
--   p_pea_attribute27              No   varchar2  Descriptive Flexfield
--   p_pea_attribute28              No   varchar2  Descriptive Flexfield
--   p_pea_attribute29              No   varchar2  Descriptive Flexfield
--   p_pea_attribute30              No   varchar2  Descriptive Flexfield
--   p_gnrt_cm                      No   varchar2  Generate communication.
--   p_effective_date               Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_prtt_enrt_actn_id            Yes  number    PK of record
--   p_effective_start_date         Yes  date      Effective Start Date of
--                                                 Record
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_object_version_number        No   number    OVN of record
--   p_rslt_object_version_number   No   number    OVN of result record.
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--

-- THERE ARE TWO UPDATE AND TWO CREATE PROCS.
-- CHANGE ONE, CHANGE THE OTHER.
--
procedure create_PRTT_ENRT_ACTN
  (p_validate                       in     boolean   default false
  ,p_effective_date                 in     date
  ,p_post_rslt_flag                 in     varchar2  default 'N'
  ,p_cmpltd_dt                      in     date      default null
  ,p_due_dt                         in     date      default null
  ,p_rqd_flag                       in     varchar2  default 'Y'
  ,p_prtt_enrt_rslt_id              in     number    default null
  ,p_per_in_ler_id              in     number
  ,p_rslt_object_version_number     in out nocopy number
  ,p_actn_typ_id                    in     number    default null
  ,p_elig_cvrd_dpnt_id              in     number    default null
  ,p_pl_bnf_id                      in     number    default null
  ,p_business_group_id              in     number    default null
  ,p_pea_attribute_category         in     varchar2  default null
  ,p_pea_attribute1                 in     varchar2  default null
  ,p_pea_attribute2                 in     varchar2  default null
  ,p_pea_attribute3                 in     varchar2  default null
  ,p_pea_attribute4                 in     varchar2  default null
  ,p_pea_attribute5                 in     varchar2  default null
  ,p_pea_attribute6                 in     varchar2  default null
  ,p_pea_attribute7                 in     varchar2  default null
  ,p_pea_attribute8                 in     varchar2  default null
  ,p_pea_attribute9                 in     varchar2  default null
  ,p_pea_attribute10                in     varchar2  default null
  ,p_pea_attribute11                in     varchar2  default null
  ,p_pea_attribute12                in     varchar2  default null
  ,p_pea_attribute13                in     varchar2  default null
  ,p_pea_attribute14                in     varchar2  default null
  ,p_pea_attribute15                in     varchar2  default null
  ,p_pea_attribute16                in     varchar2  default null
  ,p_pea_attribute17                in     varchar2  default null
  ,p_pea_attribute18                in     varchar2  default null
  ,p_pea_attribute19                in     varchar2  default null
  ,p_pea_attribute20                in     varchar2  default null
  ,p_pea_attribute21                in     varchar2  default null
  ,p_pea_attribute22                in     varchar2  default null
  ,p_pea_attribute23                in     varchar2  default null
  ,p_pea_attribute24                in     varchar2  default null
  ,p_pea_attribute25                in     varchar2  default null
  ,p_pea_attribute26                in     varchar2  default null
  ,p_pea_attribute27                in     varchar2  default null
  ,p_pea_attribute28                in     varchar2  default null
  ,p_pea_attribute29                in     varchar2  default null
  ,p_pea_attribute30                in     varchar2  default null
  ,p_gnrt_cm                        in     boolean   default true
  ,p_object_version_number             out nocopy number
  ,p_prtt_enrt_actn_id                 out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_PRTT_ENRT_ACTN >-------------------------|
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
--   p_post_rslt_flag               No   varchar2 Flag passed to suspend_enrollment
--   p_cmpltd_dt                    No   date
--   p_due_dt                       No   date
--   p_prtt_enrt_rslt_id            Yes  number
--   p_actn_typ_id                  Yes  number
--   p_Business_group_id            No   number    Business Group of Record
--   p_elig_cvrd_dpnt_id            no   number
--   p_pl_bnf_id                    no   number
--   p_rqd_flag                     no   varchar2
--   p_pea_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pea_attribute1               No   varchar2  Descriptive Flexfield
--   p_pea_attribute2               No   varchar2  Descriptive Flexfield
--   p_pea_attribute3               No   varchar2  Descriptive Flexfield
--   p_pea_attribute4               No   varchar2  Descriptive Flexfield
--   p_pea_attribute5               No   varchar2  Descriptive Flexfield
--   p_pea_attribute6               No   varchar2  Descriptive Flexfield
--   p_pea_attribute7               No   varchar2  Descriptive Flexfield
--   p_pea_attribute8               No   varchar2  Descriptive Flexfield
--   p_pea_attribute9               No   varchar2  Descriptive Flexfield
--   p_pea_attribute10              No   varchar2  Descriptive Flexfield
--   p_pea_attribute11              No   varchar2  Descriptive Flexfield
--   p_pea_attribute12              No   varchar2  Descriptive Flexfield
--   p_pea_attribute13              No   varchar2  Descriptive Flexfield
--   p_pea_attribute14              No   varchar2  Descriptive Flexfield
--   p_pea_attribute15              No   varchar2  Descriptive Flexfield
--   p_pea_attribute16              No   varchar2  Descriptive Flexfield
--   p_pea_attribute17              No   varchar2  Descriptive Flexfield
--   p_pea_attribute18              No   varchar2  Descriptive Flexfield
--   p_pea_attribute19              No   varchar2  Descriptive Flexfield
--   p_pea_attribute20              No   varchar2  Descriptive Flexfield
--   p_pea_attribute21              No   varchar2  Descriptive Flexfield
--   p_pea_attribute22              No   varchar2  Descriptive Flexfield
--   p_pea_attribute23              No   varchar2  Descriptive Flexfield
--   p_pea_attribute24              No   varchar2  Descriptive Flexfield
--   p_pea_attribute25              No   varchar2  Descriptive Flexfield
--   p_pea_attribute26              No   varchar2  Descriptive Flexfield
--   p_pea_attribute27              No   varchar2  Descriptive Flexfield
--   p_pea_attribute28              No   varchar2  Descriptive Flexfield
--   p_pea_attribute29              No   varchar2  Descriptive Flexfield
--   p_pea_attribute30              No   varchar2  Descriptive Flexfield
--   p_gnrt_cm                      No   varchar2  Generate communication.
--   p_effective_date               Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_prtt_enrt_actn_id            Yes  number    PK of record
--   p_effective_start_date         Yes  date      Effective Start Date of
--                                                 Record
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_object_version_number        No   number    OVN of record
--   p_rslt_object_version_number   No   number    OVN of result record.
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--

-- THERE ARE TWO UPDATE AND TWO CREATE PROCS.
-- CHANGE ONE, CHANGE THE OTHER.
--

procedure create_PRTT_ENRT_ACTN
  (p_validate                       in     boolean   default false
  ,p_effective_date                 in     date
  ,p_post_rslt_flag                 in     varchar2  default 'N'
  ,p_cmpltd_dt                      in     date      default null
  ,p_due_dt                         in     date      default null
  ,p_rqd_flag                       in     varchar2  default 'Y'
  ,p_prtt_enrt_rslt_id              in     number    default null
  ,p_rslt_object_version_number     in out nocopy number
  ,p_actn_typ_id                    in     number    default null
  ,p_elig_cvrd_dpnt_id              in     number    default null
  ,p_pl_bnf_id                      in     number    default null
  ,p_business_group_id              in     number    default null
  ,p_pea_attribute_category         in     varchar2  default null
  ,p_pea_attribute1                 in     varchar2  default null
  ,p_pea_attribute2                 in     varchar2  default null
  ,p_pea_attribute3                 in     varchar2  default null
  ,p_pea_attribute4                 in     varchar2  default null
  ,p_pea_attribute5                 in     varchar2  default null
  ,p_pea_attribute6                 in     varchar2  default null
  ,p_pea_attribute7                 in     varchar2  default null
  ,p_pea_attribute8                 in     varchar2  default null
  ,p_pea_attribute9                 in     varchar2  default null
  ,p_pea_attribute10                in     varchar2  default null
  ,p_pea_attribute11                in     varchar2  default null
  ,p_pea_attribute12                in     varchar2  default null
  ,p_pea_attribute13                in     varchar2  default null
  ,p_pea_attribute14                in     varchar2  default null
  ,p_pea_attribute15                in     varchar2  default null
  ,p_pea_attribute16                in     varchar2  default null
  ,p_pea_attribute17                in     varchar2  default null
  ,p_pea_attribute18                in     varchar2  default null
  ,p_pea_attribute19                in     varchar2  default null
  ,p_pea_attribute20                in     varchar2  default null
  ,p_pea_attribute21                in     varchar2  default null
  ,p_pea_attribute22                in     varchar2  default null
  ,p_pea_attribute23                in     varchar2  default null
  ,p_pea_attribute24                in     varchar2  default null
  ,p_pea_attribute25                in     varchar2  default null
  ,p_pea_attribute26                in     varchar2  default null
  ,p_pea_attribute27                in     varchar2  default null
  ,p_pea_attribute28                in     varchar2  default null
  ,p_pea_attribute29                in     varchar2  default null
  ,p_pea_attribute30                in     varchar2  default null
  ,p_gnrt_cm                        in     boolean   default true
  ,p_object_version_number             out nocopy number
  ,p_prtt_enrt_actn_id                 out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  );
--

-- ----------------------------------------------------------------------------
-- |------------------------< update_PRTT_ENRT_ACTN >------------------------|
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
--   p_post_rslt_flag               No   varchar2 pass to suspend enrollment
--   p_prtt_enrt_actn_id            Yes  number    PK of record
--   p_cmpltd_dt                    No   date
--   p_due_dt                       No   date
--   p_prtt_enrt_rslt_id            Yes  number
--   p_per_in_ler_id            Yes  number
--   p_actn_typ_id                  Yes  number
--   p_business_group_id            No   number    Business Group of Record
--   p_elig_cvrd_dpnt_id            No   number
--   p_pl_bnf_id                    No   number
--   p_rqd_flag                     No   varchar2
--   p_pea_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pea_attribute1               No   varchar2  Descriptive Flexfield
--   p_pea_attribute2               No   varchar2  Descriptive Flexfield
--   p_pea_attribute3               No   varchar2  Descriptive Flexfield
--   p_pea_attribute4               No   varchar2  Descriptive Flexfield
--   p_pea_attribute5               No   varchar2  Descriptive Flexfield
--   p_pea_attribute6               No   varchar2  Descriptive Flexfield
--   p_pea_attribute7               No   varchar2  Descriptive Flexfield
--   p_pea_attribute8               No   varchar2  Descriptive Flexfield
--   p_pea_attribute9               No   varchar2  Descriptive Flexfield
--   p_pea_attribute10              No   varchar2  Descriptive Flexfield
--   p_pea_attribute11              No   varchar2  Descriptive Flexfield
--   p_pea_attribute12              No   varchar2  Descriptive Flexfield
--   p_pea_attribute13              No   varchar2  Descriptive Flexfield
--   p_pea_attribute14              No   varchar2  Descriptive Flexfield
--   p_pea_attribute15              No   varchar2  Descriptive Flexfield
--   p_pea_attribute16              No   varchar2  Descriptive Flexfield
--   p_pea_attribute17              No   varchar2  Descriptive Flexfield
--   p_pea_attribute18              No   varchar2  Descriptive Flexfield
--   p_pea_attribute19              No   varchar2  Descriptive Flexfield
--   p_pea_attribute20              No   varchar2  Descriptive Flexfield
--   p_pea_attribute21              No   varchar2  Descriptive Flexfield
--   p_pea_attribute22              No   varchar2  Descriptive Flexfield
--   p_pea_attribute23              No   varchar2  Descriptive Flexfield
--   p_pea_attribute24              No   varchar2  Descriptive Flexfield
--   p_pea_attribute25              No   varchar2  Descriptive Flexfield
--   p_pea_attribute26              No   varchar2  Descriptive Flexfield
--   p_pea_attribute27              No   varchar2  Descriptive Flexfield
--   p_pea_attribute28              No   varchar2  Descriptive Flexfield
--   p_pea_attribute29              No   varchar2  Descriptive Flexfield
--   p_pea_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date               Yes  date       Session Date.
--   p_datetrack_mode               Yes  varchar2   Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_object_version_number        No   number    OVN of record
--   p_rslt_object_version_number   No   number    OVN of result record.
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--

-- THERE ARE TWO UPDATE AND TWO CREATE PROCS.
-- CHANGE ONE, CHANGE THE OTHER.
--
procedure update_PRTT_ENRT_ACTN
  (
   p_validate                       in boolean    default false
  ,p_post_rslt_flag                 in varchar2   default 'N'
  ,p_prtt_enrt_actn_id              in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_cmpltd_dt                      in  date      default hr_api.g_date
  ,p_due_dt                         in  date      default hr_api.g_date
  ,p_rqd_flag                       in  varchar2  default hr_api.g_varchar2
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_per_in_ler_id              in  number
  ,p_rslt_object_version_number     in out nocopy number
  ,p_actn_typ_id                    in  number    default hr_api.g_number
  ,p_elig_cvrd_dpnt_id              in  number    default hr_api.g_number
  ,p_pl_bnf_id                      in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pea_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_gnrt_cm                        in  boolean   default true
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_PRTT_ENRT_ACTN >------------------------|
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
--   p_post_rslt_flag               No   varchar2 pass to suspend enrollment
--   p_prtt_enrt_actn_id            Yes  number    PK of record
--   p_cmpltd_dt                    No   date
--   p_due_dt                       No   date
--   p_prtt_enrt_rslt_id            Yes  number
--   p_actn_typ_id                  Yes  number
--   p_business_group_id            No   number    Business Group of Record
--   p_elig_cvrd_dpnt_id            No   number
--   p_pl_bnf_id                    No   number
--   p_rqd_flag                     No   varchar2
--   p_pea_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pea_attribute1               No   varchar2  Descriptive Flexfield
--   p_pea_attribute2               No   varchar2  Descriptive Flexfield
--   p_pea_attribute3               No   varchar2  Descriptive Flexfield
--   p_pea_attribute4               No   varchar2  Descriptive Flexfield
--   p_pea_attribute5               No   varchar2  Descriptive Flexfield
--   p_pea_attribute6               No   varchar2  Descriptive Flexfield
--   p_pea_attribute7               No   varchar2  Descriptive Flexfield
--   p_pea_attribute8               No   varchar2  Descriptive Flexfield
--   p_pea_attribute9               No   varchar2  Descriptive Flexfield
--   p_pea_attribute10              No   varchar2  Descriptive Flexfield
--   p_pea_attribute11              No   varchar2  Descriptive Flexfield
--   p_pea_attribute12              No   varchar2  Descriptive Flexfield
--   p_pea_attribute13              No   varchar2  Descriptive Flexfield
--   p_pea_attribute14              No   varchar2  Descriptive Flexfield
--   p_pea_attribute15              No   varchar2  Descriptive Flexfield
--   p_pea_attribute16              No   varchar2  Descriptive Flexfield
--   p_pea_attribute17              No   varchar2  Descriptive Flexfield
--   p_pea_attribute18              No   varchar2  Descriptive Flexfield
--   p_pea_attribute19              No   varchar2  Descriptive Flexfield
--   p_pea_attribute20              No   varchar2  Descriptive Flexfield
--   p_pea_attribute21              No   varchar2  Descriptive Flexfield
--   p_pea_attribute22              No   varchar2  Descriptive Flexfield
--   p_pea_attribute23              No   varchar2  Descriptive Flexfield
--   p_pea_attribute24              No   varchar2  Descriptive Flexfield
--   p_pea_attribute25              No   varchar2  Descriptive Flexfield
--   p_pea_attribute26              No   varchar2  Descriptive Flexfield
--   p_pea_attribute27              No   varchar2  Descriptive Flexfield
--   p_pea_attribute28              No   varchar2  Descriptive Flexfield
--   p_pea_attribute29              No   varchar2  Descriptive Flexfield
--   p_pea_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date               Yes  date       Session Date.
--   p_datetrack_mode               Yes  varchar2   Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_object_version_number        No   number    OVN of record
--   p_rslt_object_version_number   No   number    OVN of result record.
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--

-- THERE ARE TWO UPDATE AND TWO CREATE PROCS.
-- CHANGE ONE, CHANGE THE OTHER.
--
procedure update_PRTT_ENRT_ACTN
  (
   p_validate                       in boolean    default false
  ,p_post_rslt_flag                 in varchar2   default 'N'
  ,p_prtt_enrt_actn_id              in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_cmpltd_dt                      in  date      default hr_api.g_date
  ,p_due_dt                         in  date      default hr_api.g_date
  ,p_rqd_flag                       in  varchar2  default hr_api.g_varchar2
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_rslt_object_version_number     in out nocopy number
  ,p_actn_typ_id                    in  number    default hr_api.g_number
  ,p_elig_cvrd_dpnt_id              in  number    default hr_api.g_number
  ,p_pl_bnf_id                      in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pea_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_gnrt_cm                        in  boolean   default true
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_PRTT_ENRT_ACTN >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_prtt_enrt_actn_id            Yes  number    PK of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--   p_rslt_object_version_number   Yes  number   OVN of enrt rslt for the actn
--   p_post_rslt_flag               No   varchar2
--   p_unsuspend_enrt_flag          No   varchar2 If set to 'N', doesn't modify
--                                                enrt rslt.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_effective_start_date         date      Effective Start Date of Record
--   p_effective_end_date           date      Effective End Date of Record
--   p_object_version_number        number    OVN of record
--   p_rslt_object_version_number   number    OVN of enrt rslt
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_PRTT_ENRT_ACTN
  (p_validate                   in     boolean  default false
  ,p_prtt_enrt_actn_id          in     number
  ,p_business_group_id          in     number
  ,p_effective_date             in     date
  ,p_datetrack_mode             in     varchar2
  ,p_object_version_number      in out nocopy number
  ,p_prtt_enrt_rslt_id          in     number
  ,p_rslt_object_version_number in out nocopy number
  ,p_post_rslt_flag             in     varchar2 default 'N'
  ,p_unsuspend_enrt_flag        in     varchar2 default 'Y'
  ,p_gnrt_cm                    in     boolean  default true
  ,p_effective_start_date          out nocopy date
  ,p_effective_end_date            out nocopy date);
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
--   p_prtt_enrt_actn_id                 Yes  number   PK of record
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
  (p_prtt_enrt_actn_id     in     number
  ,p_object_version_number in     number
  ,p_effective_date        in     date
  ,p_datetrack_mode        in     varchar2
  ,p_validation_start_date    out nocopy date
  ,p_validation_end_date      out nocopy date);
--
end ben_PRTT_ENRT_ACTN_api;

 

/
