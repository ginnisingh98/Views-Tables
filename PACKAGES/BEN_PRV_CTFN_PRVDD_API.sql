--------------------------------------------------------
--  DDL for Package BEN_PRV_CTFN_PRVDD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRV_CTFN_PRVDD_API" AUTHID CURRENT_USER as
/* $Header: bervcapi.pkh 120.0 2005/05/28 11:44:42 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_PRV_CTFN_PRVDD >------------------------|
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
--   p_prtt_rt_val_id            Yes  number
--   p_business_group_id            No   number    Business Group of Record
--   p_rvc_attribute_category       No   varchar2  Descriptive Flexfield
--   p_rvc_attribute1               No   varchar2  Descriptive Flexfield
--   p_rvc_attribute2               No   varchar2  Descriptive Flexfield
--   p_rvc_attribute3               No   varchar2  Descriptive Flexfield
--   p_rvc_attribute4               No   varchar2  Descriptive Flexfield
--   p_rvc_attribute5               No   varchar2  Descriptive Flexfield
--   p_rvc_attribute6               No   varchar2  Descriptive Flexfield
--   p_rvc_attribute7               No   varchar2  Descriptive Flexfield
--   p_rvc_attribute8               No   varchar2  Descriptive Flexfield
--   p_rvc_attribute9               No   varchar2  Descriptive Flexfield
--   p_rvc_attribute10              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute11              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute12              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute13              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute14              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute15              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute16              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute17              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute18              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute19              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute20              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute21              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute22              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute23              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute24              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute25              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute26              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute27              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute28              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute29              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_prtt_rt_val_ctfn_prvdd_id      Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_PRV_CTFN_PRVDD
(
   p_validate                       in boolean    default false
  ,p_prtt_rt_val_ctfn_prvdd_id        out nocopy number
  ,p_enrt_ctfn_rqd_flag             in  varchar2  default 'N'
  ,p_enrt_ctfn_typ_cd               in  varchar2  default null
  ,p_enrt_ctfn_recd_dt              in  date      default null
  ,p_enrt_ctfn_dnd_dt               in  date      default null
  ,p_prtt_rt_val_id              in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_rvc_attribute_category         in  varchar2  default null
  ,p_rvc_attribute1                 in  varchar2  default null
  ,p_rvc_attribute2                 in  varchar2  default null
  ,p_rvc_attribute3                 in  varchar2  default null
  ,p_rvc_attribute4                 in  varchar2  default null
  ,p_rvc_attribute5                 in  varchar2  default null
  ,p_rvc_attribute6                 in  varchar2  default null
  ,p_rvc_attribute7                 in  varchar2  default null
  ,p_rvc_attribute8                 in  varchar2  default null
  ,p_rvc_attribute9                 in  varchar2  default null
  ,p_rvc_attribute10                in  varchar2  default null
  ,p_rvc_attribute11                in  varchar2  default null
  ,p_rvc_attribute12                in  varchar2  default null
  ,p_rvc_attribute13                in  varchar2  default null
  ,p_rvc_attribute14                in  varchar2  default null
  ,p_rvc_attribute15                in  varchar2  default null
  ,p_rvc_attribute16                in  varchar2  default null
  ,p_rvc_attribute17                in  varchar2  default null
  ,p_rvc_attribute18                in  varchar2  default null
  ,p_rvc_attribute19                in  varchar2  default null
  ,p_rvc_attribute20                in  varchar2  default null
  ,p_rvc_attribute21                in  varchar2  default null
  ,p_rvc_attribute22                in  varchar2  default null
  ,p_rvc_attribute23                in  varchar2  default null
  ,p_rvc_attribute24                in  varchar2  default null
  ,p_rvc_attribute25                in  varchar2  default null
  ,p_rvc_attribute26                in  varchar2  default null
  ,p_rvc_attribute27                in  varchar2  default null
  ,p_rvc_attribute28                in  varchar2  default null
  ,p_rvc_attribute29                in  varchar2  default null
  ,p_rvc_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_PRV_CTFN_PRVDD >------------------------|
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
--   p_prtt_rt_val_ctfn_prvdd_id      Yes  number    PK of record
--   p_enrt_ctfn_rqd_flag           Yes  varchar2
--   p_enrt_ctfn_typ_cd             No   varchar2
--   p_enrt_ctfn_recd_dt            No   date
--   p_enrt_ctfn_dnd_dt             No   date      denied date
--   p_prtt_rt_val_id            Yes  number
--   p_business_group_id            No   number    Business Group of Record
--   p_rvc_attribute_category       No   varchar2  Descriptive Flexfield
--   p_rvc_attribute1               No   varchar2  Descriptive Flexfield
--   p_rvc_attribute2               No   varchar2  Descriptive Flexfield
--   p_rvc_attribute3               No   varchar2  Descriptive Flexfield
--   p_rvc_attribute4               No   varchar2  Descriptive Flexfield
--   p_rvc_attribute5               No   varchar2  Descriptive Flexfield
--   p_rvc_attribute6               No   varchar2  Descriptive Flexfield
--   p_rvc_attribute7               No   varchar2  Descriptive Flexfield
--   p_rvc_attribute8               No   varchar2  Descriptive Flexfield
--   p_rvc_attribute9               No   varchar2  Descriptive Flexfield
--   p_rvc_attribute10              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute11              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute12              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute13              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute14              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute15              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute16              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute17              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute18              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute19              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute20              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute21              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute22              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute23              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute24              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute25              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute26              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute27              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute28              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute29              No   varchar2  Descriptive Flexfield
--   p_rvc_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date               Yes  date       Session Date.
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
procedure update_PRV_CTFN_PRVDD
  (
   p_validate                       in boolean    default false
  ,p_prtt_rt_val_ctfn_prvdd_id        in  number
  ,p_enrt_ctfn_rqd_flag             in  varchar2  default hr_api.g_varchar2
  ,p_enrt_ctfn_typ_cd               in  varchar2  default hr_api.g_varchar2
  ,p_enrt_ctfn_recd_dt              in  date      default hr_api.g_date
  ,p_enrt_ctfn_dnd_dt               in  date      default hr_api.g_date
  ,p_prtt_rt_val_id              in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_rvc_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_PRV_CTFN_PRVDD >------------------------|
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
--   p_prtt_rt_val_ctfn_prvdd_id      Yes  number    PK of record
--   p_effective_date               Yes  date     Session Date.
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
procedure delete_PRV_CTFN_PRVDD
  (
   p_validate                       in boolean        default false
  ,p_prtt_rt_val_ctfn_prvdd_id        in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date
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
--   p_prtt_rt_val_ctfn_prvdd_id                 Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--   p_effective_date               Yes  date     Session Date.
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
    p_prtt_rt_val_ctfn_prvdd_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_PRV_CTFN_PRVDD_api;

 

/
