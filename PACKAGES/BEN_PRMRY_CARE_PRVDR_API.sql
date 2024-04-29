--------------------------------------------------------
--  DDL for Package BEN_PRMRY_CARE_PRVDR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRMRY_CARE_PRVDR_API" AUTHID CURRENT_USER as
/* $Header: bepprapi.pkh 120.1.12000000.1 2007/01/19 21:49:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------< determine_datetrack_mode >---------------------------|
-- ----------------------------------------------------------------------------
procedure determine_datetrack_mode
                  (p_effective_date         in     date
                  ,p_base_key_value         in     number
                  ,p_desired_datetrack_mode in     varchar2
                  ,p_mini_mode              in     varchar2
                  ,p_datetrack_allow        in out nocopy varchar2
                  );

-- ----------------------------------------------------------------------------
-- |------------------------< create_PRMRY_CARE_PRVDR >------------------------|
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
--   p_prmry_care_prvdr_typ_cd      Yes  varchar2
--   p_name                         Yes  varchar2
--   p_ext_ident                    No   varchar2
--   p_prtt_enrt_rslt_id            No   number
--   p_elig_cvrd_dpnt_id            No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_ppr_attribute_category       No   varchar2  Descriptive Flexfield
--   p_ppr_attribute1               No   varchar2  Descriptive Flexfield
--   p_ppr_attribute2               No   varchar2  Descriptive Flexfield
--   p_ppr_attribute3               No   varchar2  Descriptive Flexfield
--   p_ppr_attribute4               No   varchar2  Descriptive Flexfield
--   p_ppr_attribute5               No   varchar2  Descriptive Flexfield
--   p_ppr_attribute6               No   varchar2  Descriptive Flexfield
--   p_ppr_attribute7               No   varchar2  Descriptive Flexfield
--   p_ppr_attribute8               No   varchar2  Descriptive Flexfield
--   p_ppr_attribute9               No   varchar2  Descriptive Flexfield
--   p_ppr_attribute10              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute11              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute12              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute13              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute14              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute15              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute16              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute17              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute18              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute19              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute20              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute21              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute22              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute23              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute24              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute25              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute26              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute27              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute28              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute29              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute30              No   varchar2  Descriptive Flexfield
--   p_request_id                   No   number
--   p_program_application_id       No   number
--   p_program_id                   No   number
--   p_program_update_date          No   date
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_prmry_care_prvdr_id          Yes  number    PK of record
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_PRMRY_CARE_PRVDR
(
   p_validate                       in boolean    default false
  ,p_prmry_care_prvdr_id            out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_prmry_care_prvdr_typ_cd        in  varchar2  default null
  ,p_name                           in  varchar2  default null
  ,p_ext_ident                      in  varchar2  default null
  ,p_prtt_enrt_rslt_id              in  number    default null
  ,p_elig_cvrd_dpnt_id              in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_ppr_attribute_category         in  varchar2  default null
  ,p_ppr_attribute1                 in  varchar2  default null
  ,p_ppr_attribute2                 in  varchar2  default null
  ,p_ppr_attribute3                 in  varchar2  default null
  ,p_ppr_attribute4                 in  varchar2  default null
  ,p_ppr_attribute5                 in  varchar2  default null
  ,p_ppr_attribute6                 in  varchar2  default null
  ,p_ppr_attribute7                 in  varchar2  default null
  ,p_ppr_attribute8                 in  varchar2  default null
  ,p_ppr_attribute9                 in  varchar2  default null
  ,p_ppr_attribute10                in  varchar2  default null
  ,p_ppr_attribute11                in  varchar2  default null
  ,p_ppr_attribute12                in  varchar2  default null
  ,p_ppr_attribute13                in  varchar2  default null
  ,p_ppr_attribute14                in  varchar2  default null
  ,p_ppr_attribute15                in  varchar2  default null
  ,p_ppr_attribute16                in  varchar2  default null
  ,p_ppr_attribute17                in  varchar2  default null
  ,p_ppr_attribute18                in  varchar2  default null
  ,p_ppr_attribute19                in  varchar2  default null
  ,p_ppr_attribute20                in  varchar2  default null
  ,p_ppr_attribute21                in  varchar2  default null
  ,p_ppr_attribute22                in  varchar2  default null
  ,p_ppr_attribute23                in  varchar2  default null
  ,p_ppr_attribute24                in  varchar2  default null
  ,p_ppr_attribute25                in  varchar2  default null
  ,p_ppr_attribute26                in  varchar2  default null
  ,p_ppr_attribute27                in  varchar2  default null
  ,p_ppr_attribute28                in  varchar2  default null
  ,p_ppr_attribute29                in  varchar2  default null
  ,p_ppr_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 );
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_prmry_care_prvdr_w >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: Wrapper for self service development
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_prmry_care_prvdr_typ_cd      Yes  varchar2
--   p_name                         Yes  varchar2
--   p_ext_ident                    No   varchar2
--   p_prtt_enrt_rslt_id            No   number
--   p_elig_cvrd_dpnt_id            No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_prmry_care_prvdr_id          Yes  number    PK of record
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_prmry_care_prvdr_w
(
   p_prmry_care_prvdr_id            out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_prmry_care_prvdr_typ_cd        in  varchar2  default null
  ,p_name                           in  varchar2  default null
  ,p_ext_ident                      in  varchar2  default null
  ,p_prtt_enrt_rslt_id              in  number    default null
  ,p_elig_cvrd_dpnt_id              in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_return_status                  out nocopy    varchar2
 );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_PRMRY_CARE_PRVDR >-----------------------|
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
--   p_prmry_care_prvdr_id          Yes  number    PK of record
--   p_prmry_care_prvdr_typ_cd      Yes  varchar2
--   p_name                         Yes  varchar2
--   p_ext_ident                    No   varchar2
--   p_prtt_enrt_rslt_id            No   number
--   p_elig_cvrd_dpnt_id            No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_ppr_attribute_category       No   varchar2  Descriptive Flexfield
--   p_ppr_attribute1               No   varchar2  Descriptive Flexfield
--   p_ppr_attribute2               No   varchar2  Descriptive Flexfield
--   p_ppr_attribute3               No   varchar2  Descriptive Flexfield
--   p_ppr_attribute4               No   varchar2  Descriptive Flexfield
--   p_ppr_attribute5               No   varchar2  Descriptive Flexfield
--   p_ppr_attribute6               No   varchar2  Descriptive Flexfield
--   p_ppr_attribute7               No   varchar2  Descriptive Flexfield
--   p_ppr_attribute8               No   varchar2  Descriptive Flexfield
--   p_ppr_attribute9               No   varchar2  Descriptive Flexfield
--   p_ppr_attribute10              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute11              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute12              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute13              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute14              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute15              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute16              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute17              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute18              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute19              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute20              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute21              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute22              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute23              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute24              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute25              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute26              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute27              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute28              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute29              No   varchar2  Descriptive Flexfield
--   p_ppr_attribute30              No   varchar2  Descriptive Flexfield
--   p_request_id                   No   number
--   p_program_application_id       No   number
--   p_program_id                   No   number
--   p_program_update_date          No   date
--   p_effective_date               Yes  date       Session Date.
--   p_datetrack_mode               Yes  varchar2   Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_PRMRY_CARE_PRVDR
  (
   p_validate                       in boolean    default false
  ,p_prmry_care_prvdr_id            in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_prmry_care_prvdr_typ_cd        in  varchar2  default hr_api.g_varchar2
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_ext_ident                      in  varchar2  default hr_api.g_varchar2
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_elig_cvrd_dpnt_id              in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_ppr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_prmry_care_prvdr_w >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: Wrapper for self service development
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_prmry_care_prvdr_id          Yes  number    PK of record
--   p_prmry_care_prvdr_typ_cd      Yes  varchar2
--   p_name                         Yes  varchar2
--   p_ext_ident                    No   varchar2
--   p_prtt_enrt_rslt_id            No   number
--   p_elig_cvrd_dpnt_id            No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_effective_date               Yes  date       Session Date.
--   p_datetrack_mode               Yes  varchar2   Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_prmry_care_prvdr_w
   (
    p_prmry_care_prvdr_id            in  number
   ,p_effective_start_date           out nocopy date
   ,p_effective_end_date             out nocopy date
   ,p_prmry_care_prvdr_typ_cd        in  varchar2  default hr_api.g_varchar2
   ,p_name                           in  varchar2  default hr_api.g_varchar2
   ,p_ext_ident                      in  varchar2  default hr_api.g_varchar2
   ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
   ,p_elig_cvrd_dpnt_id              in  number    default hr_api.g_number
   ,p_business_group_id              in  number    default hr_api.g_number
   ,p_object_version_number          in out nocopy number
   ,p_effective_date                 in  date
   ,p_datetrack_mode                 in  varchar2
   ,p_return_status                  out nocopy    varchar2
   );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_PRMRY_CARE_PRVDR >-----------------------|
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
--   p_prmry_care_prvdr_id          Yes  number    PK of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_PRMRY_CARE_PRVDR
  (
   p_validate                       in boolean        default false
  ,p_prmry_care_prvdr_id            in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  ,p_called_from                    in varchar2 default null
  );
--
  -- ----------------------------------------------------------------------------
  -- |-----------------------< delete_prmry_care_prvdr_w >----------------------|
  -- ----------------------------------------------------------------------------
  -- {Start Of Comments}
  --
  -- Description: Wrapper for self service development
  --
  -- Prerequisites:
  --
  --
  -- In Parameters:
  --   Name                           Reqd Type     Description
  --   p_validate                     Yes  boolean  Commit or Rollback.
  --   p_prmry_care_prvdr_id          Yes  number    PK of record
  --   p_effective_date               Yes  date     Session Date.
  --   p_datetrack_mode               Yes  varchar2 Datetrack mode.
  --
  -- Post Success:
  --
  --   Name                           Type     Description
  --   p_effective_start_date         Yes  date      Effective Start Date of Record
  --   p_effective_end_date           Yes  date      Effective End Date of Record
  --   p_object_version_number        No   number    OVN of record
  --
  -- Post Failure:
  --
  -- Access Status:
  --   Public.
  --
  -- {End Of Comments}
  --
  procedure delete_prmry_care_prvdr_w
    (
     p_prmry_care_prvdr_id            in  number
    ,p_effective_start_date           out nocopy date
    ,p_effective_end_date             out nocopy date
    ,p_object_version_number          in out nocopy number
    ,p_effective_date                 in date
    ,p_datetrack_mode                 in varchar2
    ,p_return_status                  out nocopy    varchar2
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
--   p_prmry_care_prvdr_id                 Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_validation_start_date        Yes      Derived Effective Start Date.
--   p_validation_end_date          Yes      Derived Effective End Date.
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
    p_prmry_care_prvdr_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< pcp_actn_items >-----------------|
-- ----------------------------------------------------------------------------
procedure pcp_actn_items
  (
   p_prtt_enrt_rslt_id              in     number
  ,p_elig_cvrd_dpnt_id              in     number
  ,p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_validate                       in     boolean default false
  ,p_datetrack_mode                 in     varchar2
  );
--
end ben_PRMRY_CARE_PRVDR_api;

 

/
