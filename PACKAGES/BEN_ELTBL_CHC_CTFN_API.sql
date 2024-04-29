--------------------------------------------------------
--  DDL for Package BEN_ELTBL_CHC_CTFN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELTBL_CHC_CTFN_API" AUTHID CURRENT_USER as
/* $Header: beeccapi.pkh 120.0 2005/05/28 01:48:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ELTBL_CHC_CTFN >------------------------|
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
--   p_elig_per_elctbl_chc_id       No   number
--   p_enrt_bnft_id                 No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_ecc_attribute_category       No   varchar2  Descriptive Flexfield
--   p_ecc_attribute1               No   varchar2  Descriptive Flexfield
--   p_ecc_attribute2               No   varchar2  Descriptive Flexfield
--   p_ecc_attribute3               No   varchar2  Descriptive Flexfield
--   p_ecc_attribute4               No   varchar2  Descriptive Flexfield
--   p_ecc_attribute5               No   varchar2  Descriptive Flexfield
--   p_ecc_attribute6               No   varchar2  Descriptive Flexfield
--   p_ecc_attribute7               No   varchar2  Descriptive Flexfield
--   p_ecc_attribute8               No   varchar2  Descriptive Flexfield
--   p_ecc_attribute9               No   varchar2  Descriptive Flexfield
--   p_ecc_attribute10              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute11              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute12              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute13              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute14              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute15              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute16              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute17              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute18              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute19              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute20              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute21              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute22              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute23              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute24              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute25              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute26              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute27              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute28              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute29              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute30              No   varchar2  Descriptive Flexfield
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
--   p_elctbl_chc_ctfn_id           Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_ELTBL_CHC_CTFN
(
   p_validate                       in boolean    default false
  ,p_elctbl_chc_ctfn_id             out nocopy number
  ,p_enrt_ctfn_typ_cd               in  varchar2  default null
  ,p_rqd_flag                       in  varchar2  default 'N'
  ,p_elig_per_elctbl_chc_id         in  number    default null
  ,p_enrt_bnft_id                   in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_ecc_attribute_category         in  varchar2  default null
  ,p_ecc_attribute1                 in  varchar2  default null
  ,p_ecc_attribute2                 in  varchar2  default null
  ,p_ecc_attribute3                 in  varchar2  default null
  ,p_ecc_attribute4                 in  varchar2  default null
  ,p_ecc_attribute5                 in  varchar2  default null
  ,p_ecc_attribute6                 in  varchar2  default null
  ,p_ecc_attribute7                 in  varchar2  default null
  ,p_ecc_attribute8                 in  varchar2  default null
  ,p_ecc_attribute9                 in  varchar2  default null
  ,p_ecc_attribute10                in  varchar2  default null
  ,p_ecc_attribute11                in  varchar2  default null
  ,p_ecc_attribute12                in  varchar2  default null
  ,p_ecc_attribute13                in  varchar2  default null
  ,p_ecc_attribute14                in  varchar2  default null
  ,p_ecc_attribute15                in  varchar2  default null
  ,p_ecc_attribute16                in  varchar2  default null
  ,p_ecc_attribute17                in  varchar2  default null
  ,p_ecc_attribute18                in  varchar2  default null
  ,p_ecc_attribute19                in  varchar2  default null
  ,p_ecc_attribute20                in  varchar2  default null
  ,p_ecc_attribute21                in  varchar2  default null
  ,p_ecc_attribute22                in  varchar2  default null
  ,p_ecc_attribute23                in  varchar2  default null
  ,p_ecc_attribute24                in  varchar2  default null
  ,p_ecc_attribute25                in  varchar2  default null
  ,p_ecc_attribute26                in  varchar2  default null
  ,p_ecc_attribute27                in  varchar2  default null
  ,p_ecc_attribute28                in  varchar2  default null
  ,p_ecc_attribute29                in  varchar2  default null
  ,p_ecc_attribute30                in  varchar2  default null
  ,p_susp_if_ctfn_not_prvd_flag     in  varchar2  default 'Y'
  ,p_ctfn_determine_cd              in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_ELTBL_CHC_CTFN >------------------------|
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
--   p_elctbl_chc_ctfn_id           Yes  number    PK of record
--   p_enrt_ctfn_typ_cd             Yes  varchar2
--   p_rqd_flag                     Yes  varchar2
--   p_elig_per_elctbl_chc_id       No   number
--   p_enrt_bnft_id                 No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_ecc_attribute_category       No   varchar2  Descriptive Flexfield
--   p_ecc_attribute1               No   varchar2  Descriptive Flexfield
--   p_ecc_attribute2               No   varchar2  Descriptive Flexfield
--   p_ecc_attribute3               No   varchar2  Descriptive Flexfield
--   p_ecc_attribute4               No   varchar2  Descriptive Flexfield
--   p_ecc_attribute5               No   varchar2  Descriptive Flexfield
--   p_ecc_attribute6               No   varchar2  Descriptive Flexfield
--   p_ecc_attribute7               No   varchar2  Descriptive Flexfield
--   p_ecc_attribute8               No   varchar2  Descriptive Flexfield
--   p_ecc_attribute9               No   varchar2  Descriptive Flexfield
--   p_ecc_attribute10              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute11              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute12              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute13              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute14              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute15              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute16              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute17              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute18              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute19              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute20              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute21              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute22              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute23              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute24              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute25              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute26              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute27              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute28              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute29              No   varchar2  Descriptive Flexfield
--   p_ecc_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_ELTBL_CHC_CTFN
  (
   p_validate                       in boolean    default false
  ,p_elctbl_chc_ctfn_id             in  number
  ,p_enrt_ctfn_typ_cd               in  varchar2  default hr_api.g_varchar2
  ,p_rqd_flag                       in  varchar2  default hr_api.g_varchar2
  ,p_elig_per_elctbl_chc_id         in  number    default hr_api.g_number
  ,p_enrt_bnft_id                   in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_ecc_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_susp_if_ctfn_not_prvd_flag     in  varchar2  default hr_api.g_varchar2
  ,p_ctfn_determine_cd              in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ELTBL_CHC_CTFN >------------------------|
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
--   p_elctbl_chc_ctfn_id           Yes  number    PK of record
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
procedure delete_ELTBL_CHC_CTFN
  (
   p_validate                       in boolean        default false
  ,p_elctbl_chc_ctfn_id             in  number
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
--   p_elctbl_chc_ctfn_id                 Yes  number   PK of record
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
    p_elctbl_chc_ctfn_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_ELTBL_CHC_CTFN_api;

 

/
