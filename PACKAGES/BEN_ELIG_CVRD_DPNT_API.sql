--------------------------------------------------------
--  DDL for Package BEN_ELIG_CVRD_DPNT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_CVRD_DPNT_API" AUTHID CURRENT_USER as
/* $Header: bepdpapi.pkh 120.0.12000000.1 2007/01/19 20:54:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ELIG_CVRD_DPNT >------------------------|
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
--   p_business_group_id            Yes  number    Business Group of Record
--   p_prtt_enrt_rslt_id            No   number
--   p_dpnt_person_id               Yes  number
--   p_cvg_strt_dt                  No   date
--   p_cvg_thru_dt                  No   date
--   p_cvg_pndg_flag                Yes  varchar2
--   p_pdp_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pdp_attribute1               No   varchar2  Descriptive Flexfield
--   p_pdp_attribute2               No   varchar2  Descriptive Flexfield
--   p_pdp_attribute3               No   varchar2  Descriptive Flexfield
--   p_pdp_attribute4               No   varchar2  Descriptive Flexfield
--   p_pdp_attribute5               No   varchar2  Descriptive Flexfield
--   p_pdp_attribute6               No   varchar2  Descriptive Flexfield
--   p_pdp_attribute7               No   varchar2  Descriptive Flexfield
--   p_pdp_attribute8               No   varchar2  Descriptive Flexfield
--   p_pdp_attribute9               No   varchar2  Descriptive Flexfield
--   p_pdp_attribute10              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute11              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute12              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute13              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute14              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute15              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute16              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute17              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute18              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute19              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute20              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute21              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute22              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute23              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute24              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute25              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute26              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute27              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute28              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute29              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute30              No   varchar2  Descriptive Flexfield
--   p_ovrdn_flag                   Yes  varchar2
--   p_per_in_ler_id                No   number
--   p_ovrdn_thru_dt                No   date
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_elig_cvrd_dpnt_id            Yes  number    PK of record
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
procedure create_ELIG_CVRD_DPNT
(
   p_validate                       in boolean    default false
  ,p_elig_cvrd_dpnt_id              out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_prtt_enrt_rslt_id              in  number    default null
  ,p_dpnt_person_id                 in  number    default null
  ,p_cvg_strt_dt                    in  date      default null
  ,p_cvg_thru_dt                    in  date      default null
  ,p_cvg_pndg_flag                  in  varchar2  default 'N'
  ,p_pdp_attribute_category         in  varchar2  default null
  ,p_pdp_attribute1                 in  varchar2  default null
  ,p_pdp_attribute2                 in  varchar2  default null
  ,p_pdp_attribute3                 in  varchar2  default null
  ,p_pdp_attribute4                 in  varchar2  default null
  ,p_pdp_attribute5                 in  varchar2  default null
  ,p_pdp_attribute6                 in  varchar2  default null
  ,p_pdp_attribute7                 in  varchar2  default null
  ,p_pdp_attribute8                 in  varchar2  default null
  ,p_pdp_attribute9                 in  varchar2  default null
  ,p_pdp_attribute10                in  varchar2  default null
  ,p_pdp_attribute11                in  varchar2  default null
  ,p_pdp_attribute12                in  varchar2  default null
  ,p_pdp_attribute13                in  varchar2  default null
  ,p_pdp_attribute14                in  varchar2  default null
  ,p_pdp_attribute15                in  varchar2  default null
  ,p_pdp_attribute16                in  varchar2  default null
  ,p_pdp_attribute17                in  varchar2  default null
  ,p_pdp_attribute18                in  varchar2  default null
  ,p_pdp_attribute19                in  varchar2  default null
  ,p_pdp_attribute20                in  varchar2  default null
  ,p_pdp_attribute21                in  varchar2  default null
  ,p_pdp_attribute22                in  varchar2  default null
  ,p_pdp_attribute23                in  varchar2  default null
  ,p_pdp_attribute24                in  varchar2  default null
  ,p_pdp_attribute25                in  varchar2  default null
  ,p_pdp_attribute26                in  varchar2  default null
  ,p_pdp_attribute27                in  varchar2  default null
  ,p_pdp_attribute28                in  varchar2  default null
  ,p_pdp_attribute29                in  varchar2  default null
  ,p_pdp_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_ovrdn_flag                     in  varchar2  default 'N'
  ,p_per_in_ler_id                  in  number    default null
  ,p_ovrdn_thru_dt                  in  date      default null
  ,p_effective_date                 in  date
  ,p_multi_row_actn                 in  boolean   default TRUE
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_ELIG_CVRD_DPNT >------------------------|
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
--   p_elig_cvrd_dpnt_id            Yes  number    PK of record
--   p_business_group_id            Yes  number    Business Group of Record
--   p_prtt_enrt_rslt_id            No   number
--   p_dpnt_person_id               Yes  number
--   p_cvg_strt_dt                  No   date
--   p_cvg_thru_dt                  No   date
--   p_cvg_pndg_flag                Yes  varchar2
--   p_pdp_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pdp_attribute1               No   varchar2  Descriptive Flexfield
--   p_pdp_attribute2               No   varchar2  Descriptive Flexfield
--   p_pdp_attribute3               No   varchar2  Descriptive Flexfield
--   p_pdp_attribute4               No   varchar2  Descriptive Flexfield
--   p_pdp_attribute5               No   varchar2  Descriptive Flexfield
--   p_pdp_attribute6               No   varchar2  Descriptive Flexfield
--   p_pdp_attribute7               No   varchar2  Descriptive Flexfield
--   p_pdp_attribute8               No   varchar2  Descriptive Flexfield
--   p_pdp_attribute9               No   varchar2  Descriptive Flexfield
--   p_pdp_attribute10              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute11              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute12              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute13              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute14              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute15              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute16              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute17              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute18              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute19              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute20              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute21              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute22              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute23              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute24              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute25              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute26              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute27              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute28              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute29              No   varchar2  Descriptive Flexfield
--   p_pdp_attribute30              No   varchar2  Descriptive Flexfield
--   p_ovrdn_flag                   Yes  varchar2
--   p_per_in_ler_id                No   number
--   p_ovrdn_thru_dt                No   date
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
procedure update_ELIG_CVRD_DPNT
  (
   p_validate                       in boolean    default false
  ,p_elig_cvrd_dpnt_id              in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_dpnt_person_id                 in  number    default hr_api.g_number
  ,p_cvg_strt_dt                    in  date      default hr_api.g_date
  ,p_cvg_thru_dt                    in  date      default hr_api.g_date
  ,p_cvg_pndg_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_ovrdn_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_ovrdn_thru_dt                  in  date      default hr_api.g_date
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_multi_row_actn                 in  boolean   default TRUE
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ELIG_CVRD_DPNT >------------------------|
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
--   p_elig_cvrd_dpnt_id            Yes  number    PK of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--   p_business_group_id            Yes  number   Business Group.
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
procedure delete_ELIG_CVRD_DPNT
  (
   p_validate                       in boolean        default false
  ,p_elig_cvrd_dpnt_id              in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_business_group_id              in number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  ,p_multi_row_actn                 in  boolean   default TRUE
  );
--
-- Overloaded Procedure  2386000
--
procedure delete_ELIG_CVRD_DPNT
  (
   p_validate                       in boolean        default false
  ,p_elig_cvrd_dpnt_id              in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_business_group_id              in number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  ,p_multi_row_actn                 in  boolean   default TRUE
  ,p_called_from                    in varchar2
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
--   p_elig_cvrd_dpnt_id                 Yes  number   PK of record
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
    p_elig_cvrd_dpnt_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< dpnt_actn_items >-----------------|
-- ----------------------------------------------------------------------------
procedure dpnt_actn_items
  (
   p_prtt_enrt_rslt_id              in     number
  ,p_elig_cvrd_dpnt_id              in     number
  ,p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_validate                       in     boolean default false
  ,p_datetrack_mode                 in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< add_usage >-----------------|
-- ----------------------------------------------------------------------------
procedure add_usage
  (
   p_validate                       in     boolean  default false
  ,p_elig_cvrd_dpnt_id              in     number
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< remove_usage >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure remove_usage (
   p_validate                       in     boolean  default false
  ,p_elig_cvrd_dpnt_id              in     number
  ,p_cvg_thru_dt                    in     date
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ) ;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< chk_max_num_dpnt_for_pen >--------------|
-- ----------------------------------------------------------------------------
--
--
-- bug : 1418754 : Max number of dependents for a comp object enrollment
-- have to be checked as part of post-forms commit.
-- If user uncovers one dependent and covers other dependent then,
-- this check have to be done after making changes to the rows.
--
Procedure chk_max_num_dpnt_for_pen (p_prtt_enrt_rslt_id      in number,
                            p_effective_date         in date,
                            p_business_group_id      in number) ;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< dpnt_actn_items_w >-----------------|
-- ----------------------------------------------------------------------------
-- Self-service wrapper for calling dpnt_actn_items.
--
procedure dpnt_actn_items_w
  (
   p_prtt_enrt_rslt_id              in     number
  ,p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_datetrack_mode                 in     varchar2
  );
--
end ben_ELIG_CVRD_DPNT_api;

 

/
