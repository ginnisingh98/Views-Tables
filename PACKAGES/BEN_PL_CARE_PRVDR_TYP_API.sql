--------------------------------------------------------
--  DDL for Package BEN_PL_CARE_PRVDR_TYP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PL_CARE_PRVDR_TYP_API" AUTHID CURRENT_USER as
/* $Header: beptyapi.pkh 120.0 2005/05/28 11:25:09 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_pl_care_prvdr_typ >------------------------|
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
--   p_pl_pcp_id                    Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_pcp_typ_cd                   No   varchar2
--   p_min_age                      No   number
--   p_max_age                      No   number
--   p_gndr_alwd_cd                 No   varchar2
--   p_pty_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pty_attribute1               No   varchar2  Descriptive Flexfield
--   p_pty_attribute2               No   varchar2  Descriptive Flexfield
--   p_pty_attribute3               No   varchar2  Descriptive Flexfield
--   p_pty_attribute4               No   varchar2  Descriptive Flexfield
--   p_pty_attribute5               No   varchar2  Descriptive Flexfield
--   p_pty_attribute6               No   varchar2  Descriptive Flexfield
--   p_pty_attribute7               No   varchar2  Descriptive Flexfield
--   p_pty_attribute8               No   varchar2  Descriptive Flexfield
--   p_pty_attribute9               No   varchar2  Descriptive Flexfield
--   p_pty_attribute10              No   varchar2  Descriptive Flexfield
--   p_pty_attribute11              No   varchar2  Descriptive Flexfield
--   p_pty_attribute12              No   varchar2  Descriptive Flexfield
--   p_pty_attribute13              No   varchar2  Descriptive Flexfield
--   p_pty_attribute14              No   varchar2  Descriptive Flexfield
--   p_pty_attribute15              No   varchar2  Descriptive Flexfield
--   p_pty_attribute16              No   varchar2  Descriptive Flexfield
--   p_pty_attribute17              No   varchar2  Descriptive Flexfield
--   p_pty_attribute18              No   varchar2  Descriptive Flexfield
--   p_pty_attribute19              No   varchar2  Descriptive Flexfield
--   p_pty_attribute20              No   varchar2  Descriptive Flexfield
--   p_pty_attribute21              No   varchar2  Descriptive Flexfield
--   p_pty_attribute22              No   varchar2  Descriptive Flexfield
--   p_pty_attribute23              No   varchar2  Descriptive Flexfield
--   p_pty_attribute24              No   varchar2  Descriptive Flexfield
--   p_pty_attribute25              No   varchar2  Descriptive Flexfield
--   p_pty_attribute26              No   varchar2  Descriptive Flexfield
--   p_pty_attribute27              No   varchar2  Descriptive Flexfield
--   p_pty_attribute28              No   varchar2  Descriptive Flexfield
--   p_pty_attribute29              No   varchar2  Descriptive Flexfield
--   p_pty_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_pl_pcp_typ_id                Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_pl_care_prvdr_typ
(
   p_validate                       in boolean    default false
  ,p_pl_pcp_typ_id                  out nocopy number
  ,p_pl_pcp_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_pcp_typ_cd                     in  varchar2  default null
  ,p_min_age                        in  number    default null
  ,p_max_age                        in  number    default null
  ,p_gndr_alwd_cd                   in  varchar2  default null
  ,p_pty_attribute_category         in  varchar2  default null
  ,p_pty_attribute1                 in  varchar2  default null
  ,p_pty_attribute2                 in  varchar2  default null
  ,p_pty_attribute3                 in  varchar2  default null
  ,p_pty_attribute4                 in  varchar2  default null
  ,p_pty_attribute5                 in  varchar2  default null
  ,p_pty_attribute6                 in  varchar2  default null
  ,p_pty_attribute7                 in  varchar2  default null
  ,p_pty_attribute8                 in  varchar2  default null
  ,p_pty_attribute9                 in  varchar2  default null
  ,p_pty_attribute10                in  varchar2  default null
  ,p_pty_attribute11                in  varchar2  default null
  ,p_pty_attribute12                in  varchar2  default null
  ,p_pty_attribute13                in  varchar2  default null
  ,p_pty_attribute14                in  varchar2  default null
  ,p_pty_attribute15                in  varchar2  default null
  ,p_pty_attribute16                in  varchar2  default null
  ,p_pty_attribute17                in  varchar2  default null
  ,p_pty_attribute18                in  varchar2  default null
  ,p_pty_attribute19                in  varchar2  default null
  ,p_pty_attribute20                in  varchar2  default null
  ,p_pty_attribute21                in  varchar2  default null
  ,p_pty_attribute22                in  varchar2  default null
  ,p_pty_attribute23                in  varchar2  default null
  ,p_pty_attribute24                in  varchar2  default null
  ,p_pty_attribute25                in  varchar2  default null
  ,p_pty_attribute26                in  varchar2  default null
  ,p_pty_attribute27                in  varchar2  default null
  ,p_pty_attribute28                in  varchar2  default null
  ,p_pty_attribute29                in  varchar2  default null
  ,p_pty_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_pl_care_prvdr_typ >------------------------|
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
--   p_pl_pcp_typ_id                Yes  number    PK of record
--   p_pl_pcp_id                    Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_pcp_typ_cd                   No   varchar2
--   p_min_age                      No   number
--   p_max_age                      No   number
--   p_gndr_alwd_cd                 No   varchar2
--   p_pty_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pty_attribute1               No   varchar2  Descriptive Flexfield
--   p_pty_attribute2               No   varchar2  Descriptive Flexfield
--   p_pty_attribute3               No   varchar2  Descriptive Flexfield
--   p_pty_attribute4               No   varchar2  Descriptive Flexfield
--   p_pty_attribute5               No   varchar2  Descriptive Flexfield
--   p_pty_attribute6               No   varchar2  Descriptive Flexfield
--   p_pty_attribute7               No   varchar2  Descriptive Flexfield
--   p_pty_attribute8               No   varchar2  Descriptive Flexfield
--   p_pty_attribute9               No   varchar2  Descriptive Flexfield
--   p_pty_attribute10              No   varchar2  Descriptive Flexfield
--   p_pty_attribute11              No   varchar2  Descriptive Flexfield
--   p_pty_attribute12              No   varchar2  Descriptive Flexfield
--   p_pty_attribute13              No   varchar2  Descriptive Flexfield
--   p_pty_attribute14              No   varchar2  Descriptive Flexfield
--   p_pty_attribute15              No   varchar2  Descriptive Flexfield
--   p_pty_attribute16              No   varchar2  Descriptive Flexfield
--   p_pty_attribute17              No   varchar2  Descriptive Flexfield
--   p_pty_attribute18              No   varchar2  Descriptive Flexfield
--   p_pty_attribute19              No   varchar2  Descriptive Flexfield
--   p_pty_attribute20              No   varchar2  Descriptive Flexfield
--   p_pty_attribute21              No   varchar2  Descriptive Flexfield
--   p_pty_attribute22              No   varchar2  Descriptive Flexfield
--   p_pty_attribute23              No   varchar2  Descriptive Flexfield
--   p_pty_attribute24              No   varchar2  Descriptive Flexfield
--   p_pty_attribute25              No   varchar2  Descriptive Flexfield
--   p_pty_attribute26              No   varchar2  Descriptive Flexfield
--   p_pty_attribute27              No   varchar2  Descriptive Flexfield
--   p_pty_attribute28              No   varchar2  Descriptive Flexfield
--   p_pty_attribute29              No   varchar2  Descriptive Flexfield
--   p_pty_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_pl_care_prvdr_typ
  (
   p_validate                       in boolean    default false
  ,p_pl_pcp_typ_id                  in  number
  ,p_pl_pcp_id                      in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pcp_typ_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_min_age                        in  number    default hr_api.g_number
  ,p_max_age                        in  number    default hr_api.g_number
  ,p_gndr_alwd_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_pl_care_prvdr_typ >------------------------|
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
--   p_pl_pcp_typ_id                Yes  number    PK of record
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
procedure delete_pl_care_prvdr_typ
  (
   p_validate                       in boolean        default false
  ,p_pl_pcp_typ_id                  in  number
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
--   p_pl_pcp_typ_id                 Yes  number   PK of record
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
    p_pl_pcp_typ_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_pl_care_prvdr_typ_api;

 

/
