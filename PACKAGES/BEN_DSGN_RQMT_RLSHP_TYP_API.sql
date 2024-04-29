--------------------------------------------------------
--  DDL for Package BEN_DSGN_RQMT_RLSHP_TYP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DSGN_RQMT_RLSHP_TYP_API" AUTHID CURRENT_USER as
/* $Header: bedrrapi.pkh 120.0 2005/05/28 01:40:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_DSGN_RQMT_RLSHP_TYP >------------------------|
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
--   p_rlshp_typ_cd                 No   varchar2
--   p_dsgn_rqmt_id                 No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_drr_attribute_category       No   varchar2  Descriptive Flexfield
--   p_drr_attribute1               No   varchar2  Descriptive Flexfield
--   p_drr_attribute2               No   varchar2  Descriptive Flexfield
--   p_drr_attribute3               No   varchar2  Descriptive Flexfield
--   p_drr_attribute4               No   varchar2  Descriptive Flexfield
--   p_drr_attribute5               No   varchar2  Descriptive Flexfield
--   p_drr_attribute6               No   varchar2  Descriptive Flexfield
--   p_drr_attribute7               No   varchar2  Descriptive Flexfield
--   p_drr_attribute8               No   varchar2  Descriptive Flexfield
--   p_drr_attribute9               No   varchar2  Descriptive Flexfield
--   p_drr_attribute10              No   varchar2  Descriptive Flexfield
--   p_drr_attribute11              No   varchar2  Descriptive Flexfield
--   p_drr_attribute12              No   varchar2  Descriptive Flexfield
--   p_drr_attribute13              No   varchar2  Descriptive Flexfield
--   p_drr_attribute14              No   varchar2  Descriptive Flexfield
--   p_drr_attribute15              No   varchar2  Descriptive Flexfield
--   p_drr_attribute16              No   varchar2  Descriptive Flexfield
--   p_drr_attribute17              No   varchar2  Descriptive Flexfield
--   p_drr_attribute18              No   varchar2  Descriptive Flexfield
--   p_drr_attribute19              No   varchar2  Descriptive Flexfield
--   p_drr_attribute20              No   varchar2  Descriptive Flexfield
--   p_drr_attribute21              No   varchar2  Descriptive Flexfield
--   p_drr_attribute22              No   varchar2  Descriptive Flexfield
--   p_drr_attribute23              No   varchar2  Descriptive Flexfield
--   p_drr_attribute24              No   varchar2  Descriptive Flexfield
--   p_drr_attribute25              No   varchar2  Descriptive Flexfield
--   p_drr_attribute26              No   varchar2  Descriptive Flexfield
--   p_drr_attribute27              No   varchar2  Descriptive Flexfield
--   p_drr_attribute28              No   varchar2  Descriptive Flexfield
--   p_drr_attribute29              No   varchar2  Descriptive Flexfield
--   p_drr_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_dsgn_rqmt_rlshp_typ_id       Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_DSGN_RQMT_RLSHP_TYP
(
   p_validate                       in boolean    default false
  ,p_dsgn_rqmt_rlshp_typ_id         out nocopy number
  ,p_rlshp_typ_cd                   in  varchar2  default null
  ,p_dsgn_rqmt_id                   in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_drr_attribute_category         in  varchar2  default null
  ,p_drr_attribute1                 in  varchar2  default null
  ,p_drr_attribute2                 in  varchar2  default null
  ,p_drr_attribute3                 in  varchar2  default null
  ,p_drr_attribute4                 in  varchar2  default null
  ,p_drr_attribute5                 in  varchar2  default null
  ,p_drr_attribute6                 in  varchar2  default null
  ,p_drr_attribute7                 in  varchar2  default null
  ,p_drr_attribute8                 in  varchar2  default null
  ,p_drr_attribute9                 in  varchar2  default null
  ,p_drr_attribute10                in  varchar2  default null
  ,p_drr_attribute11                in  varchar2  default null
  ,p_drr_attribute12                in  varchar2  default null
  ,p_drr_attribute13                in  varchar2  default null
  ,p_drr_attribute14                in  varchar2  default null
  ,p_drr_attribute15                in  varchar2  default null
  ,p_drr_attribute16                in  varchar2  default null
  ,p_drr_attribute17                in  varchar2  default null
  ,p_drr_attribute18                in  varchar2  default null
  ,p_drr_attribute19                in  varchar2  default null
  ,p_drr_attribute20                in  varchar2  default null
  ,p_drr_attribute21                in  varchar2  default null
  ,p_drr_attribute22                in  varchar2  default null
  ,p_drr_attribute23                in  varchar2  default null
  ,p_drr_attribute24                in  varchar2  default null
  ,p_drr_attribute25                in  varchar2  default null
  ,p_drr_attribute26                in  varchar2  default null
  ,p_drr_attribute27                in  varchar2  default null
  ,p_drr_attribute28                in  varchar2  default null
  ,p_drr_attribute29                in  varchar2  default null
  ,p_drr_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_DSGN_RQMT_RLSHP_TYP >------------------------|
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
--   p_dsgn_rqmt_rlshp_typ_id       Yes  number    PK of record
--   p_rlshp_typ_cd                 No   varchar2
--   p_dsgn_rqmt_id                 No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_drr_attribute_category       No   varchar2  Descriptive Flexfield
--   p_drr_attribute1               No   varchar2  Descriptive Flexfield
--   p_drr_attribute2               No   varchar2  Descriptive Flexfield
--   p_drr_attribute3               No   varchar2  Descriptive Flexfield
--   p_drr_attribute4               No   varchar2  Descriptive Flexfield
--   p_drr_attribute5               No   varchar2  Descriptive Flexfield
--   p_drr_attribute6               No   varchar2  Descriptive Flexfield
--   p_drr_attribute7               No   varchar2  Descriptive Flexfield
--   p_drr_attribute8               No   varchar2  Descriptive Flexfield
--   p_drr_attribute9               No   varchar2  Descriptive Flexfield
--   p_drr_attribute10              No   varchar2  Descriptive Flexfield
--   p_drr_attribute11              No   varchar2  Descriptive Flexfield
--   p_drr_attribute12              No   varchar2  Descriptive Flexfield
--   p_drr_attribute13              No   varchar2  Descriptive Flexfield
--   p_drr_attribute14              No   varchar2  Descriptive Flexfield
--   p_drr_attribute15              No   varchar2  Descriptive Flexfield
--   p_drr_attribute16              No   varchar2  Descriptive Flexfield
--   p_drr_attribute17              No   varchar2  Descriptive Flexfield
--   p_drr_attribute18              No   varchar2  Descriptive Flexfield
--   p_drr_attribute19              No   varchar2  Descriptive Flexfield
--   p_drr_attribute20              No   varchar2  Descriptive Flexfield
--   p_drr_attribute21              No   varchar2  Descriptive Flexfield
--   p_drr_attribute22              No   varchar2  Descriptive Flexfield
--   p_drr_attribute23              No   varchar2  Descriptive Flexfield
--   p_drr_attribute24              No   varchar2  Descriptive Flexfield
--   p_drr_attribute25              No   varchar2  Descriptive Flexfield
--   p_drr_attribute26              No   varchar2  Descriptive Flexfield
--   p_drr_attribute27              No   varchar2  Descriptive Flexfield
--   p_drr_attribute28              No   varchar2  Descriptive Flexfield
--   p_drr_attribute29              No   varchar2  Descriptive Flexfield
--   p_drr_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_DSGN_RQMT_RLSHP_TYP
  (
   p_validate                       in boolean    default false
  ,p_dsgn_rqmt_rlshp_typ_id         in  number
  ,p_rlshp_typ_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_dsgn_rqmt_id                   in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_drr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_DSGN_RQMT_RLSHP_TYP >------------------------|
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
--   p_dsgn_rqmt_rlshp_typ_id       Yes  number    PK of record
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
procedure delete_DSGN_RQMT_RLSHP_TYP
  (
   p_validate                       in boolean        default false
  ,p_dsgn_rqmt_rlshp_typ_id         in  number
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
--   p_dsgn_rqmt_rlshp_typ_id                 Yes  number   PK of record
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
    p_dsgn_rqmt_rlshp_typ_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_DSGN_RQMT_RLSHP_TYP_api;

 

/
