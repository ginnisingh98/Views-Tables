--------------------------------------------------------
--  DDL for Package BEN_ENRT_RT_CTFN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENRT_RT_CTFN_API" AUTHID CURRENT_USER as
/* $Header: beercapi.pkh 120.0 2005/05/28 02:50:32 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_enrt_rt_ctfn >------------------------|
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
--   p_enrt_ctfn_typ_cd             Yes  varchar2
--   p_rqd_flag                     Yes  varchar2
--   p_enrt_rt_id                   No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_erc_attribute_category       No   varchar2  Descriptive Flexfield
--   p_erc_attribute1               No   varchar2  Descriptive Flexfield
--   p_erc_attribute2               No   varchar2  Descriptive Flexfield
--   p_erc_attribute3               No   varchar2  Descriptive Flexfield
--   p_erc_attribute4               No   varchar2  Descriptive Flexfield
--   p_erc_attribute5               No   varchar2  Descriptive Flexfield
--   p_erc_attribute6               No   varchar2  Descriptive Flexfield
--   p_erc_attribute7               No   varchar2  Descriptive Flexfield
--   p_erc_attribute8               No   varchar2  Descriptive Flexfield
--   p_erc_attribute9               No   varchar2  Descriptive Flexfield
--   p_erc_attribute10              No   varchar2  Descriptive Flexfield
--   p_erc_attribute11              No   varchar2  Descriptive Flexfield
--   p_erc_attribute12              No   varchar2  Descriptive Flexfield
--   p_erc_attribute13              No   varchar2  Descriptive Flexfield
--   p_erc_attribute14              No   varchar2  Descriptive Flexfield
--   p_erc_attribute15              No   varchar2  Descriptive Flexfield
--   p_erc_attribute16              No   varchar2  Descriptive Flexfield
--   p_erc_attribute17              No   varchar2  Descriptive Flexfield
--   p_erc_attribute18              No   varchar2  Descriptive Flexfield
--   p_erc_attribute19              No   varchar2  Descriptive Flexfield
--   p_erc_attribute20              No   varchar2  Descriptive Flexfield
--   p_erc_attribute21              No   varchar2  Descriptive Flexfield
--   p_erc_attribute22              No   varchar2  Descriptive Flexfield
--   p_erc_attribute23              No   varchar2  Descriptive Flexfield
--   p_erc_attribute24              No   varchar2  Descriptive Flexfield
--   p_erc_attribute25              No   varchar2  Descriptive Flexfield
--   p_erc_attribute26              No   varchar2  Descriptive Flexfield
--   p_erc_attribute27              No   varchar2  Descriptive Flexfield
--   p_erc_attribute28              No   varchar2  Descriptive Flexfield
--   p_erc_attribute29              No   varchar2  Descriptive Flexfield
--   p_erc_attribute30              No   varchar2  Descriptive Flexfield
--   p_request_id                   No   number
--   p_program_application_id       No   number
--   p_program_id                   No   number
--   p_program_update_date          No   date
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_enrt_rt_ctfn_id           Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_enrt_rt_ctfn
(
   p_validate                       in  boolean    default false
  ,p_enrt_rt_ctfn_id                out nocopy number
  ,p_enrt_ctfn_typ_cd               in  varchar2  default null
  ,p_rqd_flag                       in  varchar2  default 'N'
  ,p_enrt_rt_id                     in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_erc_attribute_category         in  varchar2  default null
  ,p_erc_attribute1                 in  varchar2  default null
  ,p_erc_attribute2                 in  varchar2  default null
  ,p_erc_attribute3                 in  varchar2  default null
  ,p_erc_attribute4                 in  varchar2  default null
  ,p_erc_attribute5                 in  varchar2  default null
  ,p_erc_attribute6                 in  varchar2  default null
  ,p_erc_attribute7                 in  varchar2  default null
  ,p_erc_attribute8                 in  varchar2  default null
  ,p_erc_attribute9                 in  varchar2  default null
  ,p_erc_attribute10                in  varchar2  default null
  ,p_erc_attribute11                in  varchar2  default null
  ,p_erc_attribute12                in  varchar2  default null
  ,p_erc_attribute13                in  varchar2  default null
  ,p_erc_attribute14                in  varchar2  default null
  ,p_erc_attribute15                in  varchar2  default null
  ,p_erc_attribute16                in  varchar2  default null
  ,p_erc_attribute17                in  varchar2  default null
  ,p_erc_attribute18                in  varchar2  default null
  ,p_erc_attribute19                in  varchar2  default null
  ,p_erc_attribute20                in  varchar2  default null
  ,p_erc_attribute21                in  varchar2  default null
  ,p_erc_attribute22                in  varchar2  default null
  ,p_erc_attribute23                in  varchar2  default null
  ,p_erc_attribute24                in  varchar2  default null
  ,p_erc_attribute25                in  varchar2  default null
  ,p_erc_attribute26                in  varchar2  default null
  ,p_erc_attribute27                in  varchar2  default null
  ,p_erc_attribute28                in  varchar2  default null
  ,p_erc_attribute29                in  varchar2  default null
  ,p_erc_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_enrt_rt_ctfn >------------------------|
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
--   p_enrt_rt_ctfn_id           Yes  number    PK of record
--   p_enrt_ctfn_typ_cd             Yes  varchar2
--   p_rqd_flag                     Yes  varchar2
--   p_enrt_rt_id       No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_erc_attribute_category       No   varchar2  Descriptive Flexfield
--   p_erc_attribute1               No   varchar2  Descriptive Flexfield
--   p_erc_attribute2               No   varchar2  Descriptive Flexfield
--   p_erc_attribute3               No   varchar2  Descriptive Flexfield
--   p_erc_attribute4               No   varchar2  Descriptive Flexfield
--   p_erc_attribute5               No   varchar2  Descriptive Flexfield
--   p_erc_attribute6               No   varchar2  Descriptive Flexfield
--   p_erc_attribute7               No   varchar2  Descriptive Flexfield
--   p_erc_attribute8               No   varchar2  Descriptive Flexfield
--   p_erc_attribute9               No   varchar2  Descriptive Flexfield
--   p_erc_attribute10              No   varchar2  Descriptive Flexfield
--   p_erc_attribute11              No   varchar2  Descriptive Flexfield
--   p_erc_attribute12              No   varchar2  Descriptive Flexfield
--   p_erc_attribute13              No   varchar2  Descriptive Flexfield
--   p_erc_attribute14              No   varchar2  Descriptive Flexfield
--   p_erc_attribute15              No   varchar2  Descriptive Flexfield
--   p_erc_attribute16              No   varchar2  Descriptive Flexfield
--   p_erc_attribute17              No   varchar2  Descriptive Flexfield
--   p_erc_attribute18              No   varchar2  Descriptive Flexfield
--   p_erc_attribute19              No   varchar2  Descriptive Flexfield
--   p_erc_attribute20              No   varchar2  Descriptive Flexfield
--   p_erc_attribute21              No   varchar2  Descriptive Flexfield
--   p_erc_attribute22              No   varchar2  Descriptive Flexfield
--   p_erc_attribute23              No   varchar2  Descriptive Flexfield
--   p_erc_attribute24              No   varchar2  Descriptive Flexfield
--   p_erc_attribute25              No   varchar2  Descriptive Flexfield
--   p_erc_attribute26              No   varchar2  Descriptive Flexfield
--   p_erc_attribute27              No   varchar2  Descriptive Flexfield
--   p_erc_attribute28              No   varchar2  Descriptive Flexfield
--   p_erc_attribute29              No   varchar2  Descriptive Flexfield
--   p_erc_attribute30              No   varchar2  Descriptive Flexfield
--   p_request_id                   No   number
--   p_program_application_id       No   number
--   p_program_id                   No   number
--   p_program_update_date          No   date
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
procedure update_enrt_rt_ctfn
  (
   p_validate                       in boolean    default false
  ,p_enrt_rt_ctfn_id             in  number
  ,p_enrt_ctfn_typ_cd               in  varchar2  default hr_api.g_varchar2
  ,p_rqd_flag                       in  varchar2  default hr_api.g_varchar2
  ,p_enrt_rt_id         in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_erc_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_enrt_rt_ctfn >------------------------|
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
--   p_enrt_rt_ctfn_id           Yes  number    PK of record
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
procedure delete_enrt_rt_ctfn
  (
   p_validate                       in boolean        default false
  ,p_enrt_rt_ctfn_id             in  number
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
--   p_enrt_rt_ctfn_id                 Yes  number   PK of record
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
    p_enrt_rt_ctfn_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_enrt_rt_ctfn_api;

 

/
