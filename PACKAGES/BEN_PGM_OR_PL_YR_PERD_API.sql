--------------------------------------------------------
--  DDL for Package BEN_PGM_OR_PL_YR_PERD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PGM_OR_PL_YR_PERD_API" AUTHID CURRENT_USER as
/* $Header: beyrpapi.pkh 120.0 2005/05/28 12:44:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_pgm_or_pl_yr_perd >------------------------|
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
--   p_perds_in_yr_num              No   number
--   p_perd_tm_uom_cd               No   varchar2
--   p_perd_typ_cd                  No   varchar2
--   p_end_date                     Yes  date
--   p_start_date                   Yes  date
--   p_lmtn_yr_strt_dt              No   date
--   p_lmtn_yr_end_dt               No   date
--   p_business_group_id            Yes  number    Business Group of Record
--   p_yrp_attribute_category       No   varchar2  Descriptive Flexfield
--   p_yrp_attribute1               No   varchar2  Descriptive Flexfield
--   p_yrp_attribute2               No   varchar2  Descriptive Flexfield
--   p_yrp_attribute3               No   varchar2  Descriptive Flexfield
--   p_yrp_attribute4               No   varchar2  Descriptive Flexfield
--   p_yrp_attribute5               No   varchar2  Descriptive Flexfield
--   p_yrp_attribute6               No   varchar2  Descriptive Flexfield
--   p_yrp_attribute7               No   varchar2  Descriptive Flexfield
--   p_yrp_attribute8               No   varchar2  Descriptive Flexfield
--   p_yrp_attribute9               No   varchar2  Descriptive Flexfield
--   p_yrp_attribute10              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute11              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute12              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute13              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute14              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute15              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute16              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute17              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute18              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute19              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute20              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute21              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute22              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute23              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute24              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute25              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute26              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute27              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute28              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute29              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_yr_perd_id                   Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_pgm_or_pl_yr_perd
(
   p_validate                       in boolean    default false
  ,p_yr_perd_id                     out nocopy number
  ,p_perds_in_yr_num                in  number    default null
  ,p_perd_tm_uom_cd                 in  varchar2  default null
  ,p_perd_typ_cd                    in  varchar2  default null
  ,p_end_date                       in  date      default null
  ,p_start_date                     in  date      default null
  ,p_lmtn_yr_strt_dt                in  date      default null
  ,p_lmtn_yr_end_dt                 in  date      default null
  ,p_business_group_id              in  number    default null
  ,p_yrp_attribute_category         in  varchar2  default null
  ,p_yrp_attribute1                 in  varchar2  default null
  ,p_yrp_attribute2                 in  varchar2  default null
  ,p_yrp_attribute3                 in  varchar2  default null
  ,p_yrp_attribute4                 in  varchar2  default null
  ,p_yrp_attribute5                 in  varchar2  default null
  ,p_yrp_attribute6                 in  varchar2  default null
  ,p_yrp_attribute7                 in  varchar2  default null
  ,p_yrp_attribute8                 in  varchar2  default null
  ,p_yrp_attribute9                 in  varchar2  default null
  ,p_yrp_attribute10                in  varchar2  default null
  ,p_yrp_attribute11                in  varchar2  default null
  ,p_yrp_attribute12                in  varchar2  default null
  ,p_yrp_attribute13                in  varchar2  default null
  ,p_yrp_attribute14                in  varchar2  default null
  ,p_yrp_attribute15                in  varchar2  default null
  ,p_yrp_attribute16                in  varchar2  default null
  ,p_yrp_attribute17                in  varchar2  default null
  ,p_yrp_attribute18                in  varchar2  default null
  ,p_yrp_attribute19                in  varchar2  default null
  ,p_yrp_attribute20                in  varchar2  default null
  ,p_yrp_attribute21                in  varchar2  default null
  ,p_yrp_attribute22                in  varchar2  default null
  ,p_yrp_attribute23                in  varchar2  default null
  ,p_yrp_attribute24                in  varchar2  default null
  ,p_yrp_attribute25                in  varchar2  default null
  ,p_yrp_attribute26                in  varchar2  default null
  ,p_yrp_attribute27                in  varchar2  default null
  ,p_yrp_attribute28                in  varchar2  default null
  ,p_yrp_attribute29                in  varchar2  default null
  ,p_yrp_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_pgm_or_pl_yr_perd >------------------------|
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
--   p_yr_perd_id                   Yes  number    PK of record
--   p_perds_in_yr_num              No   number
--   p_perd_tm_uom_cd               No   varchar2
--   p_perd_typ_cd                  No   varchar2
--   p_end_date                     Yes  date
--   p_start_date                   Yes  date
--   p_lmtn_yr_strt_dt              No   date
--   p_lmtn_yr_end_dt               No   date
--   p_business_group_id            Yes  number    Business Group of Record
--   p_yrp_attribute_category       No   varchar2  Descriptive Flexfield
--   p_yrp_attribute1               No   varchar2  Descriptive Flexfield
--   p_yrp_attribute2               No   varchar2  Descriptive Flexfield
--   p_yrp_attribute3               No   varchar2  Descriptive Flexfield
--   p_yrp_attribute4               No   varchar2  Descriptive Flexfield
--   p_yrp_attribute5               No   varchar2  Descriptive Flexfield
--   p_yrp_attribute6               No   varchar2  Descriptive Flexfield
--   p_yrp_attribute7               No   varchar2  Descriptive Flexfield
--   p_yrp_attribute8               No   varchar2  Descriptive Flexfield
--   p_yrp_attribute9               No   varchar2  Descriptive Flexfield
--   p_yrp_attribute10              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute11              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute12              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute13              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute14              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute15              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute16              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute17              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute18              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute19              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute20              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute21              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute22              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute23              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute24              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute25              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute26              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute27              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute28              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute29              No   varchar2  Descriptive Flexfield
--   p_yrp_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_pgm_or_pl_yr_perd
  (
   p_validate                       in boolean    default false
  ,p_yr_perd_id                     in  number
  ,p_perds_in_yr_num                in  number    default hr_api.g_number
  ,p_perd_tm_uom_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_perd_typ_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_end_date                       in  date      default hr_api.g_date
  ,p_start_date                     in  date      default hr_api.g_date
  ,p_lmtn_yr_strt_dt                in  date      default hr_api.g_date
  ,p_lmtn_yr_end_dt                 in  date      default hr_api.g_date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_yrp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_pgm_or_pl_yr_perd >------------------------|
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
--   p_yr_perd_id                   Yes  number    PK of record
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
procedure delete_pgm_or_pl_yr_perd
  (
   p_validate                       in boolean        default false
  ,p_yr_perd_id                     in  number
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
--   p_yr_perd_id                 Yes  number   PK of record
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
    p_yr_perd_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_pgm_or_pl_yr_perd_api;

 

/
