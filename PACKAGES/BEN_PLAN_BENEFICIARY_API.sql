--------------------------------------------------------
--  DDL for Package BEN_PLAN_BENEFICIARY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_BENEFICIARY_API" AUTHID CURRENT_USER as
/* $Header: bepbnapi.pkh 120.2 2006/11/29 12:35:05 gsehgal noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_PLAN_BENEFICIARY >------------------------|
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
--   p_prtt_enrt_rslt_id            Yes  number
--   p_bnf_person_id                Yes  number
--   p_organization_id              No   number
--   p_ttee_person_id               No   number
--   p_prmry_cntngnt_cd             Yes  varchar2
--   p_pct_dsgd_num                 No   number
--   p_amt_dsgd_val                 No   number
--   p_amt_dsgd_uom                 No   varchar2
--   p_dsgn_strt_dt                 No   date
--   p_dsgn_thru_dt                 No   date
--   p_addl_instrn_txt              No   varchar2
--   p_pbn_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pbn_attribute1               No   varchar2  Descriptive Flexfield
--   p_pbn_attribute2               No   varchar2  Descriptive Flexfield
--   p_pbn_attribute3               No   varchar2  Descriptive Flexfield
--   p_pbn_attribute4               No   varchar2  Descriptive Flexfield
--   p_pbn_attribute5               No   varchar2  Descriptive Flexfield
--   p_pbn_attribute6               No   varchar2  Descriptive Flexfield
--   p_pbn_attribute7               No   varchar2  Descriptive Flexfield
--   p_pbn_attribute8               No   varchar2  Descriptive Flexfield
--   p_pbn_attribute9               No   varchar2  Descriptive Flexfield
--   p_pbn_attribute10              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute11              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute12              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute13              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute14              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute15              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute16              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute17              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute18              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute19              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute20              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute21              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute22              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute23              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute24              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute25              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute26              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute27              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute28              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute29              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date                Yes  date      Session Date.
--   p_per_in_ler_id                No   number
--   p_multi_row_actn
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_pl_bnf_id                    Yes  number    PK of record
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
procedure create_PLAN_BENEFICIARY
(
   p_validate                       in boolean    default false
  ,p_pl_bnf_id                      out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_prtt_enrt_rslt_id              in  number    default null
  ,p_bnf_person_id                  in  number    default null
  ,p_organization_id                in  number    default null
  ,p_ttee_person_id                 in  number    default null
  ,p_prmry_cntngnt_cd               in  varchar2  default null
  ,p_pct_dsgd_num                   in  number    default null
  ,p_amt_dsgd_val                   in  number    default null
  ,p_amt_dsgd_uom                   in  varchar2  default null
  ,p_dsgn_strt_dt                   in  date      default null
  ,p_dsgn_thru_dt                   in  date      default null
  ,p_addl_instrn_txt                in  varchar2  default null
  ,p_pbn_attribute_category         in  varchar2  default null
  ,p_pbn_attribute1                 in  varchar2  default null
  ,p_pbn_attribute2                 in  varchar2  default null
  ,p_pbn_attribute3                 in  varchar2  default null
  ,p_pbn_attribute4                 in  varchar2  default null
  ,p_pbn_attribute5                 in  varchar2  default null
  ,p_pbn_attribute6                 in  varchar2  default null
  ,p_pbn_attribute7                 in  varchar2  default null
  ,p_pbn_attribute8                 in  varchar2  default null
  ,p_pbn_attribute9                 in  varchar2  default null
  ,p_pbn_attribute10                in  varchar2  default null
  ,p_pbn_attribute11                in  varchar2  default null
  ,p_pbn_attribute12                in  varchar2  default null
  ,p_pbn_attribute13                in  varchar2  default null
  ,p_pbn_attribute14                in  varchar2  default null
  ,p_pbn_attribute15                in  varchar2  default null
  ,p_pbn_attribute16                in  varchar2  default null
  ,p_pbn_attribute17                in  varchar2  default null
  ,p_pbn_attribute18                in  varchar2  default null
  ,p_pbn_attribute19                in  varchar2  default null
  ,p_pbn_attribute20                in  varchar2  default null
  ,p_pbn_attribute21                in  varchar2  default null
  ,p_pbn_attribute22                in  varchar2  default null
  ,p_pbn_attribute23                in  varchar2  default null
  ,p_pbn_attribute24                in  varchar2  default null
  ,p_pbn_attribute25                in  varchar2  default null
  ,p_pbn_attribute26                in  varchar2  default null
  ,p_pbn_attribute27                in  varchar2  default null
  ,p_pbn_attribute28                in  varchar2  default null
  ,p_pbn_attribute29                in  varchar2  default null
  ,p_pbn_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_per_in_ler_id                  in  number    default null
  ,p_effective_date                 in  date
  ,p_multi_row_actn                 in  boolean   default TRUE
 );
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_PLAN_BENEFICIARY_W >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: Wrapper for self service development as currently cannot
--              pass booleans.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_business_group_id            Yes  number   Business Group of Record
--   p_prtt_enrt_rslt_id            Yes  number
--   p_bnf_person_id                No   number   either bnf_person or org is required
--   p_organization_id              No   number
--   p_prmry_cntngnt_cd             Yes  varchar2
--   p_pct_dsgd_num                 No   number
--   p_dsgn_strt_dt                 No   date
--   p_dsgn_thru_dt                 No   date
--   p_effective_date               Yes  date
--   p_per_in_ler_id                No   number
--   p_multi_row_actn
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_pl_bnf_id                    Yes  number    PK of record
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
procedure create_PLAN_BENEFICIARY_w
(
   p_validate                       in  varchar2
  ,p_pl_bnf_id                      out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number
  ,p_prtt_enrt_rslt_id              in  number
  ,p_bnf_person_id                  in  number  default null
  ,p_organization_id                in  number  default null
  ,p_prmry_cntngnt_cd               in  varchar2
  ,p_pct_dsgd_num                   in  number
  ,p_dsgn_strt_dt                   in  date
  ,p_dsgn_thru_dt                   in  date
  ,p_object_version_number          out nocopy number
  ,p_per_in_ler_id                  in  number
  ,p_effective_date                 in  date
  ,p_multi_row_actn                 in  varchar2
);
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_PLAN_BENEFICIARY >------------------------|
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
--   p_pl_bnf_id                    Yes  number    PK of record
--   p_business_group_id            Yes  number    Business Group of Record
--   p_prtt_enrt_rslt_id            Yes  number
--   p_bnf_person_id                Yes  number
--   p_organization_id              No   number
--   p_ttee_person_id               No   number
--   p_prmry_cntngnt_cd             Yes  varchar2
--   p_pct_dsgd_num                 No   number
--   p_amt_dsgd_val                 No   number
--   p_amt_dsgd_uom                 No   varchar2
--   p_dsgn_strt_dt                 No   date
--   p_dsgn_thru_dt                 No   date
--   p_addl_instrn_txt              No   varchar2
--   p_pbn_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pbn_attribute1               No   varchar2  Descriptive Flexfield
--   p_pbn_attribute2               No   varchar2  Descriptive Flexfield
--   p_pbn_attribute3               No   varchar2  Descriptive Flexfield
--   p_pbn_attribute4               No   varchar2  Descriptive Flexfield
--   p_pbn_attribute5               No   varchar2  Descriptive Flexfield
--   p_pbn_attribute6               No   varchar2  Descriptive Flexfield
--   p_pbn_attribute7               No   varchar2  Descriptive Flexfield
--   p_pbn_attribute8               No   varchar2  Descriptive Flexfield
--   p_pbn_attribute9               No   varchar2  Descriptive Flexfield
--   p_pbn_attribute10              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute11              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute12              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute13              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute14              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute15              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute16              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute17              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute18              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute19              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute20              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute21              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute22              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute23              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute24              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute25              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute26              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute27              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute28              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute29              No   varchar2  Descriptive Flexfield
--   p_pbn_attribute30              No   varchar2  Descriptive Flexfield
--   p_per_in_ler_id                No   number
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
procedure update_PLAN_BENEFICIARY
  (
   p_validate                       in boolean    default false
  ,p_pl_bnf_id                      in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_bnf_person_id                  in  number    default hr_api.g_number
  ,p_organization_id                in  number    default hr_api.g_number
  ,p_ttee_person_id                 in  number    default hr_api.g_number
  ,p_prmry_cntngnt_cd               in  varchar2  default hr_api.g_varchar2
  ,p_pct_dsgd_num                   in  number    default hr_api.g_number
  ,p_amt_dsgd_val                   in  number    default hr_api.g_number
  ,p_amt_dsgd_uom                   in  varchar2  default hr_api.g_varchar2
  ,p_dsgn_strt_dt                   in  date      default hr_api.g_date
  ,p_dsgn_thru_dt                   in  date      default hr_api.g_date
  ,p_addl_instrn_txt                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_multi_row_actn                 in  boolean   default TRUE
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_PLAN_BENEFICIARY_W >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: Wrapper for self service development as currently cannot
--              pass booleans.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  varchar2 Commit or Rollback.
--   p_pl_bnf_id                    Yes  number   PK of record
--   p_business_group_id            Yes  number   Business Group of Record
--   p_prtt_enrt_rslt_id            Yes  number
--   p_bnf_person_id                No   number
--   p_organization_id              No   number
--   p_prmry_cntngnt_cd             Yes  varchar2
--   p_pct_dsgd_num                 No   number
--   p_dsgn_strt_dt                 No   date
--   p_dsgn_thru_dt                 No   date
--   p_per_in_ler_id                No   number
--   p_effective_date               Yes  date
--   p_datetrack_mode               Yes  varchar2  Datetrack mode.
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
procedure update_PLAN_BENEFICIARY_w
  (
   p_validate                       in  varchar2
  ,p_pl_bnf_id                      in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number
  ,p_prtt_enrt_rslt_id              in  number
  ,p_bnf_person_id                  in  number    default hr_api.g_number
  ,p_organization_id                in  number    default hr_api.g_number
  ,p_prmry_cntngnt_cd               in  varchar2
  ,p_pct_dsgd_num                   in  number
  ,p_dsgn_strt_dt                   in  date
  ,p_dsgn_thru_dt                   in  date
  ,p_object_version_number      in  out nocopy number
  ,p_per_in_ler_id                  in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_multi_row_actn                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_PLAN_BENEFICIARY >------------------------|
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
--   p_pl_bnf_id                    Yes  number   PK of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--   p_business_group_id            Yes  number   Business Group
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
procedure delete_PLAN_BENEFICIARY
  (
   p_validate                       in boolean        default false
  ,p_pl_bnf_id                      in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_business_group_id              in number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  ,p_multi_row_actn                 in  boolean   default TRUE
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_PLAN_BENEFICIARY_w >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: Wrapper for self service development as currently cannot
--              pass booleans.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  varchar2 Commit or Rollback.
--   p_pl_bnf_id                    Yes  number   PK of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--   p_business_group_id            Yes  number   Business Group
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
procedure delete_PLAN_BENEFICIARY_w
  (
   p_validate                       in  varchar2
  ,p_pl_bnf_id                      in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in  out nocopy number
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_prtt_enrt_rslt_id              in number  --4879576
  ,p_multi_row_actn                 in  varchar2
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
--   p_pl_bnf_id                 Yes  number   PK of record
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
    p_pl_bnf_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< bnf_actn_items >-----------------|
-- ----------------------------------------------------------------------------
procedure bnf_actn_items
  (
   p_prtt_enrt_rslt_id              in     number
  ,p_pl_bnf_id                      in     number
  ,p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_validate                       in     boolean default false
  ,p_datetrack_mode                 in     varchar2
  ,p_delete_flag                    in     varchar2 default 'N'
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< add_usage >-----------------|
-- ----------------------------------------------------------------------------
procedure add_usage
  (
   p_validate                       in     boolean  default false
  ,p_pl_bnf_id                      in     number
  ,p_bnf_person_id                  in     number
  ,p_prtt_enrt_rslt_id              in     number
  ,p_business_group_id              in     number
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
  ,p_pl_bnf_id                      in     number
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_business_group_id              in     number
  -- bug 5668052
  ,p_dsgn_thru_dt                    in     date
  ) ;
--
end ben_PLAN_BENEFICIARY_api;
--

/
