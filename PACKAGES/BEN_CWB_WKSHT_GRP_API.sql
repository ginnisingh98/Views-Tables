--------------------------------------------------------
--  DDL for Package BEN_CWB_WKSHT_GRP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_WKSHT_GRP_API" AUTHID CURRENT_USER as
/* $Header: becwgapi.pkh 120.0 2005/05/28 01:29:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_cwb_wksht_grp >------------------------|
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
--   p_cwb_wksht_grp_id		    Yes  number   PK
--   p_pl_id   			    Yes  number   FK to ben_pl_f
--   p_label   			    Yes  varchar2 SS Label
--   p_ordr_num			    Yes  number   Sequence number
--   p_effective_date                Yes  date    Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_cwb_wksht_grp_id             Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_cwb_wksht_grp
(
   p_validate                       in boolean     default false
  ,p_business_group_id              in number
  ,p_pl_id                          in number
  ,p_ordr_num                       in number
  ,p_wksht_grp_cd                   in varchar2
  ,p_label                          in varchar2
  ,p_cwg_attribute_category         in varchar2     default null
  ,p_cwg_attribute1                 in varchar2     default null
  ,p_cwg_attribute2                 in varchar2     default null
  ,p_cwg_attribute3                 in varchar2     default null
  ,p_cwg_attribute4                 in varchar2     default null
  ,p_cwg_attribute5                 in varchar2     default null
  ,p_cwg_attribute6                 in varchar2     default null
  ,p_cwg_attribute7                 in varchar2     default null
  ,p_cwg_attribute8                 in varchar2     default null
  ,p_cwg_attribute9                 in varchar2     default null
  ,p_cwg_attribute10                in varchar2     default null
  ,p_cwg_attribute11                in varchar2     default null
  ,p_cwg_attribute12                in varchar2     default null
  ,p_cwg_attribute13                in varchar2     default null
  ,p_cwg_attribute14                in varchar2     default null
  ,p_cwg_attribute15                in varchar2     default null
  ,p_cwg_attribute16                in varchar2     default null
  ,p_cwg_attribute17                in varchar2     default null
  ,p_cwg_attribute18                in varchar2     default null
  ,p_cwg_attribute19                in varchar2     default null
  ,p_cwg_attribute20                in varchar2     default null
  ,p_cwg_attribute21                in varchar2     default null
  ,p_cwg_attribute22                in varchar2     default null
  ,p_cwg_attribute23                in varchar2     default null
  ,p_cwg_attribute24                in varchar2     default null
  ,p_cwg_attribute25                in varchar2     default null
  ,p_cwg_attribute26                in varchar2     default null
  ,p_cwg_attribute27                in varchar2     default null
  ,p_cwg_attribute28                in varchar2     default null
  ,p_cwg_attribute29                in varchar2     default null
  ,p_cwg_attribute30                in varchar2     default null
  ,p_status_cd                      in varchar2     default null
  ,p_hidden_cd                    in varchar2     default null
  ,p_effective_date                 in  date
  ,p_cwb_wksht_grp_id               out nocopy number
  ,p_object_version_number          out nocopy number
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_cwb_wksht_grp >------------------------|
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
--   p_cwb_wksht_grp_id		    Yes  number   PK
--   p_pl_id   			    Yes  number   FK to ben_pl_f
--   p_label   			    Yes  varchar2 SS Label
--   p_ordr_num			    Yes  number   Sequence number
--   p_effective_date                Yes  date    Session Date.
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
procedure update_cwb_wksht_grp
  (
   p_validate                       in boolean      default false
  ,p_business_group_id              in number
  ,p_cwb_wksht_grp_id               in number
  ,p_pl_id                          in number       default hr_api.g_number
  ,p_ordr_num                       in number       default hr_api.g_number
  ,p_wksht_grp_cd                   in varchar2     default hr_api.g_varchar2
  ,p_label                          in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute_category         in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute1                 in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute2                 in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute3                 in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute4                 in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute5                 in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute6                 in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute7                 in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute8                 in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute9                 in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute10                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute11                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute12                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute13                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute14                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute15                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute16                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute17                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute18                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute19                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute20                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute21                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute22                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute23                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute24                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute25                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute26                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute27                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute28                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute29                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute30                in varchar2     default hr_api.g_varchar2
  ,p_status_cd                      in varchar2     default hr_api.g_varchar2
  ,p_hidden_cd                     in varchar2     default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_cwb_wksht_grp >------------------------|
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
--   p_cwb_wksht_grp_id             Yes  number    PK of record
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
procedure delete_cwb_wksht_grp
  (
   p_validate                       in boolean        default false
  ,p_cwb_wksht_grp_id               in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date
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
--   p_cwb_wksht_grp_id             Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--   p_effective_date               Yes  date     Session Date.
--
-- Post Success:
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
    p_cwb_wksht_grp_id            in number
   ,p_object_version_number       in number
  );
--
end ben_cwb_wksht_grp_api;

 

/
