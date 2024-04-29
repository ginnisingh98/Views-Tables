--------------------------------------------------------
--  DDL for Package BEN_CBR_PER_IN_LER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CBR_PER_IN_LER_API" AUTHID CURRENT_USER as
/* $Header: becrpapi.pkh 120.0 2005/05/28 01:21:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_CBR_PER_IN_LER >------------------------|
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
--   p_init_evt_flag                Yes  varchar2
--   p_cnt_num                      No   number
--   p_per_in_ler_id                Yes  number
--   p_cbr_quald_bnf_id             Yes  number
--   p_prvs_elig_perd_end_dt        No   date
--   p_business_group_id            Yes  number    Business Group of Record
--   p_crp_attribute_category       No   varchar2  Descriptive Flexfield
--   p_crp_attribute1               No   varchar2  Descriptive Flexfield
--   p_crp_attribute2               No   varchar2  Descriptive Flexfield
--   p_crp_attribute3               No   varchar2  Descriptive Flexfield
--   p_crp_attribute4               No   varchar2  Descriptive Flexfield
--   p_crp_attribute5               No   varchar2  Descriptive Flexfield
--   p_crp_attribute6               No   varchar2  Descriptive Flexfield
--   p_crp_attribute7               No   varchar2  Descriptive Flexfield
--   p_crp_attribute8               No   varchar2  Descriptive Flexfield
--   p_crp_attribute9               No   varchar2  Descriptive Flexfield
--   p_crp_attribute10              No   varchar2  Descriptive Flexfield
--   p_crp_attribute11              No   varchar2  Descriptive Flexfield
--   p_crp_attribute12              No   varchar2  Descriptive Flexfield
--   p_crp_attribute13              No   varchar2  Descriptive Flexfield
--   p_crp_attribute14              No   varchar2  Descriptive Flexfield
--   p_crp_attribute15              No   varchar2  Descriptive Flexfield
--   p_crp_attribute16              No   varchar2  Descriptive Flexfield
--   p_crp_attribute17              No   varchar2  Descriptive Flexfield
--   p_crp_attribute18              No   varchar2  Descriptive Flexfield
--   p_crp_attribute19              No   varchar2  Descriptive Flexfield
--   p_crp_attribute20              No   varchar2  Descriptive Flexfield
--   p_crp_attribute21              No   varchar2  Descriptive Flexfield
--   p_crp_attribute22              No   varchar2  Descriptive Flexfield
--   p_crp_attribute23              No   varchar2  Descriptive Flexfield
--   p_crp_attribute24              No   varchar2  Descriptive Flexfield
--   p_crp_attribute25              No   varchar2  Descriptive Flexfield
--   p_crp_attribute26              No   varchar2  Descriptive Flexfield
--   p_crp_attribute27              No   varchar2  Descriptive Flexfield
--   p_crp_attribute28              No   varchar2  Descriptive Flexfield
--   p_crp_attribute29              No   varchar2  Descriptive Flexfield
--   p_crp_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_cbr_per_in_ler_id            Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_CBR_PER_IN_LER
(
   p_validate                       in boolean    default false
  ,p_cbr_per_in_ler_id              out nocopy number
  ,p_init_evt_flag                  in  varchar2  default 'N'
  ,p_cnt_num                        in  number    default null
  ,p_per_in_ler_id                  in  number    default null
  ,p_cbr_quald_bnf_id               in  number    default null
  ,p_prvs_elig_perd_end_dt          in  date      default null
  ,p_business_group_id              in  number    default null
  ,p_crp_attribute_category         in  varchar2  default null
  ,p_crp_attribute1                 in  varchar2  default null
  ,p_crp_attribute2                 in  varchar2  default null
  ,p_crp_attribute3                 in  varchar2  default null
  ,p_crp_attribute4                 in  varchar2  default null
  ,p_crp_attribute5                 in  varchar2  default null
  ,p_crp_attribute6                 in  varchar2  default null
  ,p_crp_attribute7                 in  varchar2  default null
  ,p_crp_attribute8                 in  varchar2  default null
  ,p_crp_attribute9                 in  varchar2  default null
  ,p_crp_attribute10                in  varchar2  default null
  ,p_crp_attribute11                in  varchar2  default null
  ,p_crp_attribute12                in  varchar2  default null
  ,p_crp_attribute13                in  varchar2  default null
  ,p_crp_attribute14                in  varchar2  default null
  ,p_crp_attribute15                in  varchar2  default null
  ,p_crp_attribute16                in  varchar2  default null
  ,p_crp_attribute17                in  varchar2  default null
  ,p_crp_attribute18                in  varchar2  default null
  ,p_crp_attribute19                in  varchar2  default null
  ,p_crp_attribute20                in  varchar2  default null
  ,p_crp_attribute21                in  varchar2  default null
  ,p_crp_attribute22                in  varchar2  default null
  ,p_crp_attribute23                in  varchar2  default null
  ,p_crp_attribute24                in  varchar2  default null
  ,p_crp_attribute25                in  varchar2  default null
  ,p_crp_attribute26                in  varchar2  default null
  ,p_crp_attribute27                in  varchar2  default null
  ,p_crp_attribute28                in  varchar2  default null
  ,p_crp_attribute29                in  varchar2  default null
  ,p_crp_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_CBR_PER_IN_LER >------------------------|
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
--   p_cbr_per_in_ler_id            Yes  number    PK of record
--   p_init_evt_flag                Yes  varchar2
--   p_cnt_num                      No   number
--   p_per_in_ler_id                Yes  number
--   p_cbr_quald_bnf_id             Yes  number
--   p_prvs_elig_perd_end_dt        No   date
--   p_business_group_id            Yes  number    Business Group of Record
--   p_crp_attribute_category       No   varchar2  Descriptive Flexfield
--   p_crp_attribute1               No   varchar2  Descriptive Flexfield
--   p_crp_attribute2               No   varchar2  Descriptive Flexfield
--   p_crp_attribute3               No   varchar2  Descriptive Flexfield
--   p_crp_attribute4               No   varchar2  Descriptive Flexfield
--   p_crp_attribute5               No   varchar2  Descriptive Flexfield
--   p_crp_attribute6               No   varchar2  Descriptive Flexfield
--   p_crp_attribute7               No   varchar2  Descriptive Flexfield
--   p_crp_attribute8               No   varchar2  Descriptive Flexfield
--   p_crp_attribute9               No   varchar2  Descriptive Flexfield
--   p_crp_attribute10              No   varchar2  Descriptive Flexfield
--   p_crp_attribute11              No   varchar2  Descriptive Flexfield
--   p_crp_attribute12              No   varchar2  Descriptive Flexfield
--   p_crp_attribute13              No   varchar2  Descriptive Flexfield
--   p_crp_attribute14              No   varchar2  Descriptive Flexfield
--   p_crp_attribute15              No   varchar2  Descriptive Flexfield
--   p_crp_attribute16              No   varchar2  Descriptive Flexfield
--   p_crp_attribute17              No   varchar2  Descriptive Flexfield
--   p_crp_attribute18              No   varchar2  Descriptive Flexfield
--   p_crp_attribute19              No   varchar2  Descriptive Flexfield
--   p_crp_attribute20              No   varchar2  Descriptive Flexfield
--   p_crp_attribute21              No   varchar2  Descriptive Flexfield
--   p_crp_attribute22              No   varchar2  Descriptive Flexfield
--   p_crp_attribute23              No   varchar2  Descriptive Flexfield
--   p_crp_attribute24              No   varchar2  Descriptive Flexfield
--   p_crp_attribute25              No   varchar2  Descriptive Flexfield
--   p_crp_attribute26              No   varchar2  Descriptive Flexfield
--   p_crp_attribute27              No   varchar2  Descriptive Flexfield
--   p_crp_attribute28              No   varchar2  Descriptive Flexfield
--   p_crp_attribute29              No   varchar2  Descriptive Flexfield
--   p_crp_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_CBR_PER_IN_LER
  (
   p_validate                       in boolean    default false
  ,p_cbr_per_in_ler_id              in  number
  ,p_init_evt_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_cnt_num                        in  number    default hr_api.g_number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_cbr_quald_bnf_id               in  number    default hr_api.g_number
  ,p_prvs_elig_perd_end_dt          in  date      default hr_api.g_date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_crp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_CBR_PER_IN_LER >------------------------|
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
--   p_cbr_per_in_ler_id            Yes  number    PK of record
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
procedure delete_CBR_PER_IN_LER
  (
   p_validate                       in boolean        default false
  ,p_cbr_per_in_ler_id              in  number
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
--   p_cbr_per_in_ler_id                 Yes  number   PK of record
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
    p_cbr_per_in_ler_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_CBR_PER_IN_LER_api;

 

/
