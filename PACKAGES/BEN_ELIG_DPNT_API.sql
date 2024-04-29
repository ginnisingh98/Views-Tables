--------------------------------------------------------
--  DDL for Package BEN_ELIG_DPNT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_DPNT_API" AUTHID CURRENT_USER as
/* $Header: beegdapi.pkh 120.3.12010000.3 2009/04/10 04:29:26 pvelvano ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ELIG_DPNT >------------------------|
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
--   p_create_dt                    Yes  date
--   p_elig_strt_dt                 No   date
--   p_elig_thru_dt                 No   date
--   p_ovrdn_flag                   Yes  varchar2
--   p_ovrdn_thru_dt                No   date
--   p_inelg_rsn_cd                 No   varchar2
--   p_dpnt_inelig_flag             Yes  varchar2
--   p_elig_per_elctbl_chc_id       No   number
--   p_per_in_ler_id                No   number
--   p_elig_per_id                  No   number
--   p_elig_per_opt_id              No   number
--   p_elig_cvrd_dpnt_id            No   number
--   p_dpnt_person_id               Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_egd_attribute_category       No   varchar2  Descriptive Flexfield
--   p_egd_attribute1               No   varchar2  Descriptive Flexfield
--   p_egd_attribute2               No   varchar2  Descriptive Flexfield
--   p_egd_attribute3               No   varchar2  Descriptive Flexfield
--   p_egd_attribute4               No   varchar2  Descriptive Flexfield
--   p_egd_attribute5               No   varchar2  Descriptive Flexfield
--   p_egd_attribute6               No   varchar2  Descriptive Flexfield
--   p_egd_attribute7               No   varchar2  Descriptive Flexfield
--   p_egd_attribute8               No   varchar2  Descriptive Flexfield
--   p_egd_attribute9               No   varchar2  Descriptive Flexfield
--   p_egd_attribute10              No   varchar2  Descriptive Flexfield
--   p_egd_attribute11              No   varchar2  Descriptive Flexfield
--   p_egd_attribute12              No   varchar2  Descriptive Flexfield
--   p_egd_attribute13              No   varchar2  Descriptive Flexfield
--   p_egd_attribute14              No   varchar2  Descriptive Flexfield
--   p_egd_attribute15              No   varchar2  Descriptive Flexfield
--   p_egd_attribute16              No   varchar2  Descriptive Flexfield
--   p_egd_attribute17              No   varchar2  Descriptive Flexfield
--   p_egd_attribute18              No   varchar2  Descriptive Flexfield
--   p_egd_attribute19              No   varchar2  Descriptive Flexfield
--   p_egd_attribute20              No   varchar2  Descriptive Flexfield
--   p_egd_attribute21              No   varchar2  Descriptive Flexfield
--   p_egd_attribute22              No   varchar2  Descriptive Flexfield
--   p_egd_attribute23              No   varchar2  Descriptive Flexfield
--   p_egd_attribute24              No   varchar2  Descriptive Flexfield
--   p_egd_attribute25              No   varchar2  Descriptive Flexfield
--   p_egd_attribute26              No   varchar2  Descriptive Flexfield
--   p_egd_attribute27              No   varchar2  Descriptive Flexfield
--   p_egd_attribute28              No   varchar2  Descriptive Flexfield
--   p_egd_attribute29              No   varchar2  Descriptive Flexfield
--   p_egd_attribute30              No   varchar2  Descriptive Flexfield
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
--   p_elig_dpnt_id                 Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_ELIG_DPNT
(
   p_validate                       in boolean    default false
  ,p_elig_dpnt_id                   out nocopy number
  ,p_create_dt                      in  date      default null
  ,p_elig_strt_dt                   in  date      default null
  ,p_elig_thru_dt                   in  date      default null
  ,p_ovrdn_flag                     in  varchar2  default 'N'
  ,p_ovrdn_thru_dt                  in  date      default null
  ,p_inelg_rsn_cd                   in  varchar2  default null
  ,p_dpnt_inelig_flag               in  varchar2  default 'N'
  ,p_elig_per_elctbl_chc_id         in  number    default null
  ,p_per_in_ler_id                  in  number    default null
  ,p_elig_per_id                    in  number    default null
  ,p_elig_per_opt_id                in  number    default null
  ,p_elig_cvrd_dpnt_id              in  number    default null
  ,p_dpnt_person_id                 in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_egd_attribute_category         in  varchar2  default null
  ,p_egd_attribute1                 in  varchar2  default null
  ,p_egd_attribute2                 in  varchar2  default null
  ,p_egd_attribute3                 in  varchar2  default null
  ,p_egd_attribute4                 in  varchar2  default null
  ,p_egd_attribute5                 in  varchar2  default null
  ,p_egd_attribute6                 in  varchar2  default null
  ,p_egd_attribute7                 in  varchar2  default null
  ,p_egd_attribute8                 in  varchar2  default null
  ,p_egd_attribute9                 in  varchar2  default null
  ,p_egd_attribute10                in  varchar2  default null
  ,p_egd_attribute11                in  varchar2  default null
  ,p_egd_attribute12                in  varchar2  default null
  ,p_egd_attribute13                in  varchar2  default null
  ,p_egd_attribute14                in  varchar2  default null
  ,p_egd_attribute15                in  varchar2  default null
  ,p_egd_attribute16                in  varchar2  default null
  ,p_egd_attribute17                in  varchar2  default null
  ,p_egd_attribute18                in  varchar2  default null
  ,p_egd_attribute19                in  varchar2  default null
  ,p_egd_attribute20                in  varchar2  default null
  ,p_egd_attribute21                in  varchar2  default null
  ,p_egd_attribute22                in  varchar2  default null
  ,p_egd_attribute23                in  varchar2  default null
  ,p_egd_attribute24                in  varchar2  default null
  ,p_egd_attribute25                in  varchar2  default null
  ,p_egd_attribute26                in  varchar2  default null
  ,p_egd_attribute27                in  varchar2  default null
  ,p_egd_attribute28                in  varchar2  default null
  ,p_egd_attribute29                in  varchar2  default null
  ,p_egd_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 );
--
-- Performance cover
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_perf_ELIG_DPNT >------------------------|
-- ----------------------------------------------------------------------------
procedure create_perf_ELIG_DPNT
  (p_validate                       in boolean    default false
  ,p_elig_dpnt_id                   out nocopy number
  ,p_create_dt                      in  date      default null
  ,p_elig_strt_dt                   in  date      default null
  ,p_elig_thru_dt                   in  date      default null
  ,p_ovrdn_flag                     in  varchar2  default 'N'
  ,p_ovrdn_thru_dt                  in  date      default null
  ,p_inelg_rsn_cd                   in  varchar2  default null
  ,p_dpnt_inelig_flag               in  varchar2  default 'N'
  ,p_elig_per_elctbl_chc_id         in  number    default null
  ,p_per_in_ler_id                  in  number    default null
  ,p_elig_per_id                    in  number    default null
  ,p_elig_per_opt_id                in  number    default null
  ,p_elig_cvrd_dpnt_id              in  number    default null
  ,p_dpnt_person_id                 in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_egd_attribute_category         in  varchar2  default null
  ,p_egd_attribute1                 in  varchar2  default null
  ,p_egd_attribute2                 in  varchar2  default null
  ,p_egd_attribute3                 in  varchar2  default null
  ,p_egd_attribute4                 in  varchar2  default null
  ,p_egd_attribute5                 in  varchar2  default null
  ,p_egd_attribute6                 in  varchar2  default null
  ,p_egd_attribute7                 in  varchar2  default null
  ,p_egd_attribute8                 in  varchar2  default null
  ,p_egd_attribute9                 in  varchar2  default null
  ,p_egd_attribute10                in  varchar2  default null
  ,p_egd_attribute11                in  varchar2  default null
  ,p_egd_attribute12                in  varchar2  default null
  ,p_egd_attribute13                in  varchar2  default null
  ,p_egd_attribute14                in  varchar2  default null
  ,p_egd_attribute15                in  varchar2  default null
  ,p_egd_attribute16                in  varchar2  default null
  ,p_egd_attribute17                in  varchar2  default null
  ,p_egd_attribute18                in  varchar2  default null
  ,p_egd_attribute19                in  varchar2  default null
  ,p_egd_attribute20                in  varchar2  default null
  ,p_egd_attribute21                in  varchar2  default null
  ,p_egd_attribute22                in  varchar2  default null
  ,p_egd_attribute23                in  varchar2  default null
  ,p_egd_attribute24                in  varchar2  default null
  ,p_egd_attribute25                in  varchar2  default null
  ,p_egd_attribute26                in  varchar2  default null
  ,p_egd_attribute27                in  varchar2  default null
  ,p_egd_attribute28                in  varchar2  default null
  ,p_egd_attribute29                in  varchar2  default null
  ,p_egd_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_ELIG_DPNT >------------------------|
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
--   p_elig_dpnt_id                 Yes  number    PK of record
--   p_create_dt                    Yes  date
--   p_elig_strt_dt                 No   date
--   p_elig_thru_dt                 No   date
--   p_ovrdn_flag                   Yes  varchar2
--   p_ovrdn_thru_dt                No   date
--   p_inelg_rsn_cd                 No   varchar2
--   p_dpnt_inelig_flag             Yes  varchar2
--   p_elig_per_elctbl_chc_id       No   number
--   p_per_in_ler_id                No   number
--   p_elig_per_id                  No   number
--   p_elig_per_opt_id              No   number
--   p_elig_cvrd_dpnt_id            No   number
--   p_dpnt_person_id               Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_egd_attribute_category       No   varchar2  Descriptive Flexfield
--   p_egd_attribute1               No   varchar2  Descriptive Flexfield
--   p_egd_attribute2               No   varchar2  Descriptive Flexfield
--   p_egd_attribute3               No   varchar2  Descriptive Flexfield
--   p_egd_attribute4               No   varchar2  Descriptive Flexfield
--   p_egd_attribute5               No   varchar2  Descriptive Flexfield
--   p_egd_attribute6               No   varchar2  Descriptive Flexfield
--   p_egd_attribute7               No   varchar2  Descriptive Flexfield
--   p_egd_attribute8               No   varchar2  Descriptive Flexfield
--   p_egd_attribute9               No   varchar2  Descriptive Flexfield
--   p_egd_attribute10              No   varchar2  Descriptive Flexfield
--   p_egd_attribute11              No   varchar2  Descriptive Flexfield
--   p_egd_attribute12              No   varchar2  Descriptive Flexfield
--   p_egd_attribute13              No   varchar2  Descriptive Flexfield
--   p_egd_attribute14              No   varchar2  Descriptive Flexfield
--   p_egd_attribute15              No   varchar2  Descriptive Flexfield
--   p_egd_attribute16              No   varchar2  Descriptive Flexfield
--   p_egd_attribute17              No   varchar2  Descriptive Flexfield
--   p_egd_attribute18              No   varchar2  Descriptive Flexfield
--   p_egd_attribute19              No   varchar2  Descriptive Flexfield
--   p_egd_attribute20              No   varchar2  Descriptive Flexfield
--   p_egd_attribute21              No   varchar2  Descriptive Flexfield
--   p_egd_attribute22              No   varchar2  Descriptive Flexfield
--   p_egd_attribute23              No   varchar2  Descriptive Flexfield
--   p_egd_attribute24              No   varchar2  Descriptive Flexfield
--   p_egd_attribute25              No   varchar2  Descriptive Flexfield
--   p_egd_attribute26              No   varchar2  Descriptive Flexfield
--   p_egd_attribute27              No   varchar2  Descriptive Flexfield
--   p_egd_attribute28              No   varchar2  Descriptive Flexfield
--   p_egd_attribute29              No   varchar2  Descriptive Flexfield
--   p_egd_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_ELIG_DPNT
  (
   p_validate                       in boolean    default false
  ,p_elig_dpnt_id                   in  number
  ,p_create_dt                      in  date      default hr_api.g_date
  ,p_elig_strt_dt                   in  date      default hr_api.g_date
  ,p_elig_thru_dt                   in  date      default hr_api.g_date
  ,p_ovrdn_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_ovrdn_thru_dt                  in  date      default hr_api.g_date
  ,p_inelg_rsn_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_inelig_flag               in  varchar2  default hr_api.g_varchar2
  ,p_elig_per_elctbl_chc_id         in  number    default hr_api.g_number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_elig_per_id                    in  number    default hr_api.g_number
  ,p_elig_per_opt_id                in  number    default hr_api.g_number
  ,p_elig_cvrd_dpnt_id              in  number    default hr_api.g_number
  ,p_dpnt_person_id                 in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_egd_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- Performance cover
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_perf_ELIG_DPNT >------------------------|
-- ----------------------------------------------------------------------------
procedure update_perf_ELIG_DPNT
  (
   p_validate                       in boolean    default false
  ,p_elig_dpnt_id                   in  number
  ,p_create_dt                      in  date      default hr_api.g_date
  ,p_elig_strt_dt                   in  date      default hr_api.g_date
  ,p_elig_thru_dt                   in  date      default hr_api.g_date
  ,p_ovrdn_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_ovrdn_thru_dt                  in  date      default hr_api.g_date
  ,p_inelg_rsn_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_inelig_flag               in  varchar2  default hr_api.g_varchar2
  ,p_elig_per_elctbl_chc_id         in  number    default hr_api.g_number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_elig_per_id                    in  number    default hr_api.g_number
  ,p_elig_per_opt_id                in  number    default hr_api.g_number
  ,p_elig_cvrd_dpnt_id              in  number    default hr_api.g_number
  ,p_dpnt_person_id                 in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_egd_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ELIG_DPNT >------------------------|
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
--   p_elig_dpnt_id                 Yes  number    PK of record
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
procedure delete_ELIG_DPNT
  (
   p_validate                       in boolean        default false
  ,p_elig_dpnt_id                   in  number
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
--   p_elig_dpnt_id                 Yes  number   PK of record
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
    p_elig_dpnt_id                 in number
   ,p_object_version_number        in number
  );
-- ----------------------------------------------------------------------------
-- |---------------------< process_dependent >---------------------------------|
-- ----------------------------------------------------------------------------
procedure process_dependent(p_validate in boolean default false,
                            p_elig_dpnt_id    in number,
                            p_business_group_id in number,
                            p_effective_date    in date,
                            p_cvg_strt_dt       in date,
                            p_cvg_thru_dt       in date,
                            p_datetrack_mode    in varchar2,
                            p_pdp_attribute_category  in varchar2 default null,
                            p_pdp_attribute1          in varchar2 default null,
                            p_pdp_attribute2          in varchar2 default null,
                            p_pdp_attribute3          in varchar2 default null,
                            p_pdp_attribute4          in varchar2 default null,
                            p_pdp_attribute5          in varchar2 default null,
                            p_pdp_attribute6          in varchar2 default null,
                            p_pdp_attribute7          in varchar2 default null,
                            p_pdp_attribute8          in varchar2 default null,
                            p_pdp_attribute9          in varchar2 default null,
                            p_pdp_attribute10         in varchar2 default null,
                            p_pdp_attribute11         in varchar2 default null,
                            p_pdp_attribute12         in varchar2 default null,
                            p_pdp_attribute13         in varchar2 default null,
                            p_pdp_attribute14         in varchar2 default null,
                            p_pdp_attribute15         in varchar2 default null,
                            p_pdp_attribute16         in varchar2 default null,
                            p_pdp_attribute17         in varchar2 default null,
                            p_pdp_attribute18         in varchar2 default null,
                            p_pdp_attribute19         in varchar2 default null,
                            p_pdp_attribute20         in varchar2 default null,
                            p_pdp_attribute21         in varchar2 default null,
                            p_pdp_attribute22         in varchar2 default null,
                            p_pdp_attribute23         in varchar2 default null,
                            p_pdp_attribute24         in varchar2 default null,
                            p_pdp_attribute25         in varchar2 default null,
                            p_pdp_attribute26         in varchar2 default null,
                            p_pdp_attribute27         in varchar2 default null,
                            p_pdp_attribute28         in varchar2 default null,
                            p_pdp_attribute29         in varchar2 default null,
                            p_pdp_attribute30         in varchar2 default null,
                            p_elig_cvrd_dpnt_id       out nocopy number,
                            p_effective_start_date    out nocopy date,
                            p_effective_end_date      out nocopy date,
                            p_object_version_number   in  out nocopy number
                           ,p_multi_row_actn          in  BOOLEAN default FALSE);
-- ----------------------------------------------------------------------------
-- |---------------------< process_dependent_w >------------------------------|
-- ----------------------------------------------------------------------------
procedure process_dependent_w(p_validate                in varchar2,
                            p_elig_dpnt_id            in number,
                            p_business_group_id       in number,
                            p_effective_date          in date,
                            p_cvg_strt_dt             in date,
                            p_cvg_thru_dt             in date,
                            p_datetrack_mode          in varchar2,
                            p_elig_cvrd_dpnt_id       out nocopy number,
                            p_effective_start_date    out nocopy date,
                            p_effective_end_date      out nocopy date,
                            p_object_version_number   in  out nocopy number
                           ,p_multi_row_actn          in  varchar2);
-- ----------------------------------------------------------------------------
-- |---------------------< store_crt_ord_warnings_ss >------------------------------|
-- ----------------------------------------------------------------------------
procedure store_crt_ord_warning_ss(p_person_id             in number,
															      p_crt_ord_warning       in varchar2);
-- ----------------------------------------------------------------------------
-- |---------------------< store_crt_ord_warng_DDNA >------------------------------|
-- ----------------------------------------------------------------------------
procedure store_crt_ord_warng_DDNA(p_person_id             in number,
                                   p_per_in_ler_id         in number,
                                   p_pgm_id                in number,
                                   p_effective_date        in date,
                                   p_business_group_id     in number);
-- ----------------------------------------------------------------------------
-- |----------------------< get_crt_ordr_typ >------------------------------|
-- ----------------------------------------------------------------------------
procedure get_crt_ordr_typ(p_person_id in number,
			  p_pl_id in number,
			  p_pl_typ_id in number,
			  l_crt_ordr_meaning out nocopy varchar2);
-- ----------------------------------------------------------------------------
-- |---------------------< get_elig_dpnt_rec >---------------------------------|
-- ----------------------------------------------------------------------------
function get_elig_dpnt_rec(p_elig_dpnt_id  in number,
                           p_elig_dpnt_rec out nocopy ben_elig_dpnt%rowtype)
return boolean;

function get_elig_dpnt_rec(p_elig_cvrd_dpnt_id  in number,
                           p_effective_date     in date,
                           p_elig_dpnt_rec      out nocopy ben_elig_dpnt%rowtype)
return boolean;

function get_elig_dpnt_rec(p_dpnt_person_id  in number,
                           p_prtt_enrt_rslt_id     in number,
                           p_effective_date        in date,
                           p_elig_dpnt_rec      out nocopy ben_elig_dpnt%rowtype)
return boolean;

function get_elig_dpnt_rec
  (p_pgm_id          in     number default null
  ,p_pl_id           in     number default null
  ,p_oipl_id         in     number default null
  ,p_dpnt_person_id  in     number
  ,p_effective_date  in     date
  --
  ,p_per_in_ler_id   in     number default null
  ,p_elig_per_id     in     number default null
  ,p_elig_per_opt_id in     number default null
  ,p_opt_id          in     number default null
  --
  ,p_elig_dpnt_rec      out nocopy ben_elig_dpnt%rowtype
  )
return boolean;

-- ----------------------------------------------------------------------------
-- |------------------------< get_elig_per_id >------------------------|
-- ----------------------------------------------------------------------------
procedure get_elig_per_id(p_person_id in number,
                          p_pgm_id    in number default null,
                          p_pl_id     in number default null,
                          p_oipl_id   in number default null,
                          p_business_group_id in number,
                          p_effective_date    in date,
                          p_elig_per_id       out nocopy number,
                          p_elig_per_opt_id   out nocopy number);


/*Added the procedure for Bug 8414373  */
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_enrt_for_dpnt >-----------------|
-- ----------------------------------------------------------------------------
--
procedure chk_enrt_for_dpnt
  (
   p_dpnt_person_id                   in  number
  ,p_dpnt_rltp_id                in  number
  ,p_rltp_type                   in varchar2
  ,p_business_group_id              in number
  );
--
--
end ben_ELIG_DPNT_api;

/
