--------------------------------------------------------
--  DDL for Package BEN_CBR_QUALD_BNF_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CBR_QUALD_BNF_API" AUTHID CURRENT_USER as
/* $Header: becqbapi.pkh 120.0 2005/05/28 01:19:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_CBR_QUALD_BNF >------------------------|
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
--   p_quald_bnf_flag               Yes  varchar2
--   p_cbr_elig_perd_strt_dt        No   date
--   p_cbr_elig_perd_end_dt         No   date
--   p_quald_bnf_person_id          Yes  number
--   p_pgm_id                       No   number
--   p_ptip_id                      No   number
--   p_pl_typ_id                    No   number
--   p_cvrd_emp_person_id           No   number
--   p_cbr_inelg_rsn_cd             No   varchar2
--   p_business_group_id            Yes  number    Business Group of Record
--   p_cqb_attribute_category       No   varchar2  Descriptive Flexfield
--   p_cqb_attribute1               No   varchar2  Descriptive Flexfield
--   p_cqb_attribute2               No   varchar2  Descriptive Flexfield
--   p_cqb_attribute3               No   varchar2  Descriptive Flexfield
--   p_cqb_attribute4               No   varchar2  Descriptive Flexfield
--   p_cqb_attribute5               No   varchar2  Descriptive Flexfield
--   p_cqb_attribute6               No   varchar2  Descriptive Flexfield
--   p_cqb_attribute7               No   varchar2  Descriptive Flexfield
--   p_cqb_attribute8               No   varchar2  Descriptive Flexfield
--   p_cqb_attribute9               No   varchar2  Descriptive Flexfield
--   p_cqb_attribute10              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute11              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute12              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute13              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute14              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute15              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute16              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute17              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute18              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute19              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute20              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute21              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute22              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute23              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute24              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute25              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute26              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute27              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute28              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute29              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_cbr_quald_bnf_id             Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_CBR_QUALD_BNF
(
   p_validate                       in boolean    default false
  ,p_cbr_quald_bnf_id               out nocopy number
  ,p_quald_bnf_flag                 in  varchar2  default 'N'
  ,p_cbr_elig_perd_strt_dt          in  date      default null
  ,p_cbr_elig_perd_end_dt           in  date      default null
  ,p_quald_bnf_person_id            in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_pl_typ_id                      in  number    default null
  ,p_cvrd_emp_person_id             in  number    default null
  ,p_cbr_inelg_rsn_cd               in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_cqb_attribute_category         in  varchar2  default null
  ,p_cqb_attribute1                 in  varchar2  default null
  ,p_cqb_attribute2                 in  varchar2  default null
  ,p_cqb_attribute3                 in  varchar2  default null
  ,p_cqb_attribute4                 in  varchar2  default null
  ,p_cqb_attribute5                 in  varchar2  default null
  ,p_cqb_attribute6                 in  varchar2  default null
  ,p_cqb_attribute7                 in  varchar2  default null
  ,p_cqb_attribute8                 in  varchar2  default null
  ,p_cqb_attribute9                 in  varchar2  default null
  ,p_cqb_attribute10                in  varchar2  default null
  ,p_cqb_attribute11                in  varchar2  default null
  ,p_cqb_attribute12                in  varchar2  default null
  ,p_cqb_attribute13                in  varchar2  default null
  ,p_cqb_attribute14                in  varchar2  default null
  ,p_cqb_attribute15                in  varchar2  default null
  ,p_cqb_attribute16                in  varchar2  default null
  ,p_cqb_attribute17                in  varchar2  default null
  ,p_cqb_attribute18                in  varchar2  default null
  ,p_cqb_attribute19                in  varchar2  default null
  ,p_cqb_attribute20                in  varchar2  default null
  ,p_cqb_attribute21                in  varchar2  default null
  ,p_cqb_attribute22                in  varchar2  default null
  ,p_cqb_attribute23                in  varchar2  default null
  ,p_cqb_attribute24                in  varchar2  default null
  ,p_cqb_attribute25                in  varchar2  default null
  ,p_cqb_attribute26                in  varchar2  default null
  ,p_cqb_attribute27                in  varchar2  default null
  ,p_cqb_attribute28                in  varchar2  default null
  ,p_cqb_attribute29                in  varchar2  default null
  ,p_cqb_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_CBR_QUALD_BNF >------------------------|
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
--   p_cbr_quald_bnf_id             Yes  number    PK of record
--   p_quald_bnf_flag               Yes  varchar2
--   p_cbr_elig_perd_strt_dt        No   date
--   p_cbr_elig_perd_end_dt         No   date
--   p_quald_bnf_person_id          Yes  number
--   p_pgm_id                       No   number
--   p_ptip_id                      No   number
--   p_pl_typ_id                    No   number
--   p_cvrd_emp_person_id           No   number
--   p_cbr_inelg_rsn_cd             No   varchar2
--   p_business_group_id            Yes  number    Business Group of Record
--   p_cqb_attribute_category       No   varchar2  Descriptive Flexfield
--   p_cqb_attribute1               No   varchar2  Descriptive Flexfield
--   p_cqb_attribute2               No   varchar2  Descriptive Flexfield
--   p_cqb_attribute3               No   varchar2  Descriptive Flexfield
--   p_cqb_attribute4               No   varchar2  Descriptive Flexfield
--   p_cqb_attribute5               No   varchar2  Descriptive Flexfield
--   p_cqb_attribute6               No   varchar2  Descriptive Flexfield
--   p_cqb_attribute7               No   varchar2  Descriptive Flexfield
--   p_cqb_attribute8               No   varchar2  Descriptive Flexfield
--   p_cqb_attribute9               No   varchar2  Descriptive Flexfield
--   p_cqb_attribute10              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute11              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute12              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute13              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute14              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute15              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute16              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute17              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute18              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute19              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute20              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute21              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute22              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute23              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute24              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute25              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute26              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute27              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute28              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute29              No   varchar2  Descriptive Flexfield
--   p_cqb_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_CBR_QUALD_BNF
  (
   p_validate                       in boolean    default false
  ,p_cbr_quald_bnf_id               in  number
  ,p_quald_bnf_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_cbr_elig_perd_strt_dt          in  date      default hr_api.g_date
  ,p_cbr_elig_perd_end_dt           in  date      default hr_api.g_date
  ,p_quald_bnf_person_id            in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_ptip_id                        in  number    default hr_api.g_number
  ,p_pl_typ_id                      in  number    default hr_api.g_number
  ,p_cvrd_emp_person_id             in  number    default hr_api.g_number
  ,p_cbr_inelg_rsn_cd               in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_cqb_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_CBR_QUALD_BNF >------------------------|
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
--   p_cbr_quald_bnf_id             Yes  number    PK of record
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
procedure delete_CBR_QUALD_BNF
  (
   p_validate                       in boolean        default false
  ,p_cbr_quald_bnf_id               in  number
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
--   p_cbr_quald_bnf_id                 Yes  number   PK of record
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
    p_cbr_quald_bnf_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_CBR_QUALD_BNF_api;

 

/
