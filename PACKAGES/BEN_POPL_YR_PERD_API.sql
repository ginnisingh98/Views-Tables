--------------------------------------------------------
--  DDL for Package BEN_POPL_YR_PERD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_POPL_YR_PERD_API" AUTHID CURRENT_USER as
/* $Header: becpyapi.pkh 120.0 2005/05/28 01:18:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_POPL_YR_PERD >------------------------|
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
--   p_yr_perd_id                   Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_pl_id                        No   number
--   p_pgm_id                       No   number
--   p_ordr_num                     No   number
--   p_acpt_clm_rqsts_thru_dt       No   date
--   p_py_clms_thru_dt              No   date
--   p_cpy_attribute_category       No   varchar2  Descriptive Flexfield
--   p_cpy_attribute1               No   varchar2  Descriptive Flexfield
--   p_cpy_attribute2               No   varchar2  Descriptive Flexfield
--   p_cpy_attribute3               No   varchar2  Descriptive Flexfield
--   p_cpy_attribute4               No   varchar2  Descriptive Flexfield
--   p_cpy_attribute5               No   varchar2  Descriptive Flexfield
--   p_cpy_attribute6               No   varchar2  Descriptive Flexfield
--   p_cpy_attribute7               No   varchar2  Descriptive Flexfield
--   p_cpy_attribute8               No   varchar2  Descriptive Flexfield
--   p_cpy_attribute9               No   varchar2  Descriptive Flexfield
--   p_cpy_attribute10              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute11              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute12              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute13              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute14              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute15              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute16              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute17              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute18              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute19              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute20              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute21              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute22              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute23              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute24              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute25              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute26              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute27              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute28              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute29              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute30              No   varchar2  Descriptive Flexfield
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_popl_yr_perd_id              Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_POPL_YR_PERD
(
   p_validate                       in boolean    default false
  ,p_popl_yr_perd_id                out nocopy number
  ,p_yr_perd_id                     in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_ordr_num                       in  number    default null
  ,p_acpt_clm_rqsts_thru_dt         in  date      default null
  ,p_py_clms_thru_dt                in  date      default null
  ,p_cpy_attribute_category         in  varchar2  default null
  ,p_cpy_attribute1                 in  varchar2  default null
  ,p_cpy_attribute2                 in  varchar2  default null
  ,p_cpy_attribute3                 in  varchar2  default null
  ,p_cpy_attribute4                 in  varchar2  default null
  ,p_cpy_attribute5                 in  varchar2  default null
  ,p_cpy_attribute6                 in  varchar2  default null
  ,p_cpy_attribute7                 in  varchar2  default null
  ,p_cpy_attribute8                 in  varchar2  default null
  ,p_cpy_attribute9                 in  varchar2  default null
  ,p_cpy_attribute10                in  varchar2  default null
  ,p_cpy_attribute11                in  varchar2  default null
  ,p_cpy_attribute12                in  varchar2  default null
  ,p_cpy_attribute13                in  varchar2  default null
  ,p_cpy_attribute14                in  varchar2  default null
  ,p_cpy_attribute15                in  varchar2  default null
  ,p_cpy_attribute16                in  varchar2  default null
  ,p_cpy_attribute17                in  varchar2  default null
  ,p_cpy_attribute18                in  varchar2  default null
  ,p_cpy_attribute19                in  varchar2  default null
  ,p_cpy_attribute20                in  varchar2  default null
  ,p_cpy_attribute21                in  varchar2  default null
  ,p_cpy_attribute22                in  varchar2  default null
  ,p_cpy_attribute23                in  varchar2  default null
  ,p_cpy_attribute24                in  varchar2  default null
  ,p_cpy_attribute25                in  varchar2  default null
  ,p_cpy_attribute26                in  varchar2  default null
  ,p_cpy_attribute27                in  varchar2  default null
  ,p_cpy_attribute28                in  varchar2  default null
  ,p_cpy_attribute29                in  varchar2  default null
  ,p_cpy_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_POPL_YR_PERD >------------------------|
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
--   p_popl_yr_perd_id              Yes  number    PK of record
--   p_yr_perd_id                   Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_pl_id                        No   number
--   p_pgm_id                       No   number
--   p_ordr_num                     No   number
--   p_acpt_clm_rqsts_thru_dt       No   date
--   p_py_clms_thru_dt              No   date
--   p_cpy_attribute_category       No   varchar2  Descriptive Flexfield
--   p_cpy_attribute1               No   varchar2  Descriptive Flexfield
--   p_cpy_attribute2               No   varchar2  Descriptive Flexfield
--   p_cpy_attribute3               No   varchar2  Descriptive Flexfield
--   p_cpy_attribute4               No   varchar2  Descriptive Flexfield
--   p_cpy_attribute5               No   varchar2  Descriptive Flexfield
--   p_cpy_attribute6               No   varchar2  Descriptive Flexfield
--   p_cpy_attribute7               No   varchar2  Descriptive Flexfield
--   p_cpy_attribute8               No   varchar2  Descriptive Flexfield
--   p_cpy_attribute9               No   varchar2  Descriptive Flexfield
--   p_cpy_attribute10              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute11              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute12              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute13              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute14              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute15              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute16              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute17              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute18              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute19              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute20              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute21              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute22              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute23              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute24              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute25              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute26              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute27              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute28              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute29              No   varchar2  Descriptive Flexfield
--   p_cpy_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_POPL_YR_PERD
  (
   p_validate                       in boolean    default false
  ,p_popl_yr_perd_id                in  number
  ,p_yr_perd_id                     in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_acpt_clm_rqsts_thru_dt         in  date      default hr_api.g_date
  ,p_py_clms_thru_dt                in  date      default hr_api.g_date
  ,p_cpy_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_POPL_YR_PERD >------------------------|
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
--   p_popl_yr_perd_id              Yes  number    PK of record
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
procedure delete_POPL_YR_PERD
  (
   p_validate                       in boolean        default false
  ,p_popl_yr_perd_id                in  number
  ,p_object_version_number          in out nocopy number
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
--   p_popl_yr_perd_id                 Yes  number   PK of record
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
    p_popl_yr_perd_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_POPL_YR_PERD_api;

 

/
