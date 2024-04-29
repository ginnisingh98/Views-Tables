--------------------------------------------------------
--  DDL for Package BEN_PRTT_ENRT_CTFN_PRVDD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRTT_ENRT_CTFN_PRVDD_API" AUTHID CURRENT_USER as
/* $Header: bepcsapi.pkh 120.0.12000000.1 2007/01/19 20:39:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_PRTT_ENRT_CTFN_PRVDD >------------------------|
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
--   p_enrt_ctfn_rqd_flag           Yes  varchar2
--   p_enrt_ctfn_typ_cd             No   varchar2
--   p_enrt_ctfn_recd_dt            No   date      received date
--   p_enrt_ctfn_dnd_dt             No   date      denied date
--   p_enrt_r_bnft_ctfn_cd          No   varchar2  enrollment or benefit related
--   p_prtt_enrt_rslt_id            Yes  number
--   p_prtt_enrt_actn_id            Yes  number
--   p_business_group_id            No   number    Business Group of Record
--   p_pcs_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pcs_attribute1               No   varchar2  Descriptive Flexfield
--   p_pcs_attribute2               No   varchar2  Descriptive Flexfield
--   p_pcs_attribute3               No   varchar2  Descriptive Flexfield
--   p_pcs_attribute4               No   varchar2  Descriptive Flexfield
--   p_pcs_attribute5               No   varchar2  Descriptive Flexfield
--   p_pcs_attribute6               No   varchar2  Descriptive Flexfield
--   p_pcs_attribute7               No   varchar2  Descriptive Flexfield
--   p_pcs_attribute8               No   varchar2  Descriptive Flexfield
--   p_pcs_attribute9               No   varchar2  Descriptive Flexfield
--   p_pcs_attribute10              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute11              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute12              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute13              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute14              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute15              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute16              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute17              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute18              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute19              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute20              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute21              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute22              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute23              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute24              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute25              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute26              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute27              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute28              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute29              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_prtt_enrt_ctfn_prvdd_id      Yes  number    PK of record
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
procedure create_PRTT_ENRT_CTFN_PRVDD
(
   p_validate                       in boolean    default false
  ,p_prtt_enrt_ctfn_prvdd_id        out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_enrt_ctfn_rqd_flag             in  varchar2  default 'N'
  ,p_enrt_ctfn_typ_cd               in  varchar2  default null
  ,p_enrt_ctfn_recd_dt              in  date      default null
  ,p_enrt_ctfn_dnd_dt               in  date      default null
  ,p_enrt_r_bnft_ctfn_cd            in  varchar2  default null
  ,p_prtt_enrt_rslt_id              in  number    default null
  ,p_prtt_enrt_actn_id              in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_pcs_attribute_category         in  varchar2  default null
  ,p_pcs_attribute1                 in  varchar2  default null
  ,p_pcs_attribute2                 in  varchar2  default null
  ,p_pcs_attribute3                 in  varchar2  default null
  ,p_pcs_attribute4                 in  varchar2  default null
  ,p_pcs_attribute5                 in  varchar2  default null
  ,p_pcs_attribute6                 in  varchar2  default null
  ,p_pcs_attribute7                 in  varchar2  default null
  ,p_pcs_attribute8                 in  varchar2  default null
  ,p_pcs_attribute9                 in  varchar2  default null
  ,p_pcs_attribute10                in  varchar2  default null
  ,p_pcs_attribute11                in  varchar2  default null
  ,p_pcs_attribute12                in  varchar2  default null
  ,p_pcs_attribute13                in  varchar2  default null
  ,p_pcs_attribute14                in  varchar2  default null
  ,p_pcs_attribute15                in  varchar2  default null
  ,p_pcs_attribute16                in  varchar2  default null
  ,p_pcs_attribute17                in  varchar2  default null
  ,p_pcs_attribute18                in  varchar2  default null
  ,p_pcs_attribute19                in  varchar2  default null
  ,p_pcs_attribute20                in  varchar2  default null
  ,p_pcs_attribute21                in  varchar2  default null
  ,p_pcs_attribute22                in  varchar2  default null
  ,p_pcs_attribute23                in  varchar2  default null
  ,p_pcs_attribute24                in  varchar2  default null
  ,p_pcs_attribute25                in  varchar2  default null
  ,p_pcs_attribute26                in  varchar2  default null
  ,p_pcs_attribute27                in  varchar2  default null
  ,p_pcs_attribute28                in  varchar2  default null
  ,p_pcs_attribute29                in  varchar2  default null
  ,p_pcs_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_PRTT_ENRT_CTFN_PRVDD >------------------------|
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
--   p_prtt_enrt_ctfn_prvdd_id      Yes  number    PK of record
--   p_enrt_ctfn_rqd_flag           Yes  varchar2
--   p_enrt_ctfn_typ_cd             No   varchar2
--   p_enrt_ctfn_recd_dt            No   date
--   p_enrt_ctfn_dnd_dt             No   date      denied date
--   p_enrt_r_bnft_ctfn_cd          No   varchar2  enrollment or benefit related
--   p_prtt_enrt_rslt_id            Yes  number
--   p_prtt_enrt_actn_id            Yes  number
--   p_business_group_id            No   number    Business Group of Record
--   p_pcs_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pcs_attribute1               No   varchar2  Descriptive Flexfield
--   p_pcs_attribute2               No   varchar2  Descriptive Flexfield
--   p_pcs_attribute3               No   varchar2  Descriptive Flexfield
--   p_pcs_attribute4               No   varchar2  Descriptive Flexfield
--   p_pcs_attribute5               No   varchar2  Descriptive Flexfield
--   p_pcs_attribute6               No   varchar2  Descriptive Flexfield
--   p_pcs_attribute7               No   varchar2  Descriptive Flexfield
--   p_pcs_attribute8               No   varchar2  Descriptive Flexfield
--   p_pcs_attribute9               No   varchar2  Descriptive Flexfield
--   p_pcs_attribute10              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute11              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute12              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute13              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute14              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute15              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute16              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute17              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute18              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute19              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute20              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute21              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute22              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute23              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute24              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute25              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute26              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute27              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute28              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute29              No   varchar2  Descriptive Flexfield
--   p_pcs_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_PRTT_ENRT_CTFN_PRVDD
  (
   p_validate                       in boolean    default false
  ,p_prtt_enrt_ctfn_prvdd_id        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_enrt_ctfn_rqd_flag             in  varchar2  default hr_api.g_varchar2
  ,p_enrt_ctfn_typ_cd               in  varchar2  default hr_api.g_varchar2
  ,p_enrt_ctfn_recd_dt              in  date      default hr_api.g_date
  ,p_enrt_ctfn_dnd_dt               in  date      default hr_api.g_date
  ,p_enrt_r_bnft_ctfn_cd            in  varchar2  default hr_api.g_varchar2
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_prtt_enrt_actn_id              in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pcs_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_PRTT_ENRT_CTFN_PRVDD >------------------------|
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
--   p_prtt_enrt_ctfn_prvdd_id      Yes  number    PK of record
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
procedure delete_PRTT_ENRT_CTFN_PRVDD
  (
   p_validate                       in boolean        default false
  ,p_prtt_enrt_ctfn_prvdd_id        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  ,p_check_actions                  in varchar2 default 'Y'
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
--   p_prtt_enrt_ctfn_prvdd_id                 Yes  number   PK of record
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
    p_prtt_enrt_ctfn_prvdd_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end ben_PRTT_ENRT_CTFN_PRVDD_api;

 

/
