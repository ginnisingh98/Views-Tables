--------------------------------------------------------
--  DDL for Package BEN_PTNL_LER_FOR_PER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PTNL_LER_FOR_PER_API" AUTHID CURRENT_USER as
/* $Header: bepplapi.pkh 120.0 2005/05/28 10:58:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_ptnl_ler_for_per >------------------------|
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
--   p_lf_evt_ocrd_dt               Yes  date
--   p_trgr_table_pk_id             No   number
--   p_csd_by_ptnl_ler_for_per_id   No   number
--   p_ptnl_ler_for_per_stat_cd     Yes  varchar2
--   p_ptnl_ler_for_per_src_cd      No   varchar2
--   p_mnl_dt                       No   date
--   p_enrt_perd_id                 Yes  number
--   p_ler_id                       Yes  number
--   p_person_id                    Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_dtctd_dt                     No   date
--   p_procd_dt                     No   date
--   p_unprocd_dt                   No   date
--   p_voidd_dt                     No   date
--   p_ntfn_dt                      No   date
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
--   p_ptnl_ler_for_per_id          Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_ptnl_ler_for_per
  (p_validate                       in boolean    default false
  ,p_ptnl_ler_for_per_id            out nocopy number
  ,p_csd_by_ptnl_ler_for_per_id     in  number    default null
  ,p_lf_evt_ocrd_dt                 in  date      default null
  ,p_trgr_table_pk_id               in  number    default null
  ,p_ptnl_ler_for_per_stat_cd       in  varchar2  default null
  ,p_ptnl_ler_for_per_src_cd        in  varchar2  default null
  ,p_mnl_dt                         in  date      default null
  ,p_enrt_perd_id                   in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_person_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_dtctd_dt                       in  date      default null
  ,p_procd_dt                       in  date      default null
  ,p_unprocd_dt                     in  date      default null
  ,p_voidd_dt                       in  date      default null
  ,p_mnlo_dt                        in  date      default null
  ,p_ntfn_dt                        in  date      default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date);
-- ----------------------------------------------------------------------------
-- |-----------------------< create_ptnl_ler_for_per_perf >-------------------|
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
--   p_csd_by_ptnl_ler_for_per_id   No   number
--   p_lf_evt_ocrd_dt               Yes  date
--   p_trgr_table_pk_id             No   number
--   p_ptnl_ler_for_per_stat_cd     Yes  varchar2
--   p_ptnl_ler_for_per_src_cd      No   varchar2
--   p_mnl_dt                       No   date
--   p_enrt_perd_id                 Yes  number
--   p_ler_id                       Yes  number
--   p_person_id                    Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_dtctd_dt                     No   date
--   p_procd_dt                     No   date
--   p_unprocd_dt                   No   date
--   p_voidd_dt                     No   date
--   p_ntfn_dt                      No   date
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
--   p_ptnl_ler_for_per_id          Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_ptnl_ler_for_per_perf
  (p_validate                       in boolean    default false
  ,p_ptnl_ler_for_per_id            out nocopy number
  ,p_csd_by_ptnl_ler_for_per_id     in  number    default null
  ,p_lf_evt_ocrd_dt                 in  date      default null
  ,p_trgr_table_pk_id               in  number    default null
  ,p_ptnl_ler_for_per_stat_cd       in  varchar2  default null
  ,p_ptnl_ler_for_per_src_cd        in  varchar2  default null
  ,p_mnl_dt                         in  date      default null
  ,p_enrt_perd_id                   in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_person_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_dtctd_dt                       in  date      default null
  ,p_procd_dt                       in  date      default null
  ,p_unprocd_dt                     in  date      default null
  ,p_voidd_dt                       in  date      default null
  ,p_mnlo_dt                        in  date      default null
  ,p_ntfn_dt                        in  date      default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date);
-- ----------------------------------------------------------------------------
-- |-----------------------< update_ptnl_ler_for_per >------------------------|
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
--   p_ptnl_ler_for_per_id          Yes  number    PK of record
--   p_csd_by_ptnl_ler_for_per_id   No   number
--   p_lf_evt_ocrd_dt               Yes  date
--   p_trgr_table_pk_id             No   number
--   p_ptnl_ler_for_per_stat_cd     Yes  varchar2
--   p_ptnl_ler_for_per_src_cd      No   varchar2
--   p_mnl_dt                       No   date
--   p_enrt_perd_id                 Yes  number
--   p_ler_id                       Yes  number
--   p_person_id                    Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_dtctd_dt                     No   date
--   p_procd_dt                     No   date
--   p_unprocd_dt                   No   date
--   p_voidd_dt                     No   date
--   p_ntfn_dt                      No   date
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
procedure update_ptnl_ler_for_per
  (p_validate                       in boolean    default false
  ,p_ptnl_ler_for_per_id            in  number
  ,p_csd_by_ptnl_ler_for_per_id     in  number     default hr_api.g_number
  ,p_lf_evt_ocrd_dt                 in  date      default hr_api.g_date
  ,p_trgr_table_pk_id               in  number    default hr_api.g_number
  ,p_ptnl_ler_for_per_stat_cd       in  varchar2  default hr_api.g_varchar2
  ,p_ptnl_ler_for_per_src_cd        in  varchar2  default hr_api.g_varchar2
  ,p_mnl_dt                         in  date      default hr_api.g_date
  ,p_enrt_perd_id                   in  number    default hr_api.g_number
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_dtctd_dt                       in  date      default hr_api.g_date
  ,p_procd_dt                       in  date      default hr_api.g_date
  ,p_unprocd_dt                     in  date      default hr_api.g_date
  ,p_voidd_dt                       in  date      default hr_api.g_date
  ,p_mnlo_dt                        in  date      default hr_api.g_date
  ,p_ntfn_dt                        in  date      default hr_api.g_date
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_ptnl_ler_for_per_perf >-------------------|
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
--   p_ptnl_ler_for_per_id          Yes  number    PK of record
--   p_csd_by_ptnl_ler_for_per_id   No   number
--   p_lf_evt_ocrd_dt               Yes  date
--   p_trgr_table_pk_id             No   number
--   p_ptnl_ler_for_per_stat_cd     Yes  varchar2
--   p_ptnl_ler_for_per_src_cd      No   varchar2
--   p_mnl_dt                       No   date
--   p_enrt_perd_id                 Yes  number
--   p_ler_id                       Yes  number
--   p_person_id                    Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_dtctd_dt                     No   date
--   p_procd_dt                     No   date
--   p_unprocd_dt                   No   date
--   p_voidd_dt                     No   date
--   p_ntfn_dt                      No   date
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
procedure update_ptnl_ler_for_per_perf
  (p_validate                       in boolean    default false
  ,p_ptnl_ler_for_per_id            in  number
  ,p_csd_by_ptnl_ler_for_per_id     in  number    default hr_api.g_number
  ,p_lf_evt_ocrd_dt                 in  date      default hr_api.g_date
  ,p_trgr_table_pk_id               in  number    default hr_api.g_number
  ,p_ptnl_ler_for_per_stat_cd       in  varchar2  default hr_api.g_varchar2
  ,p_ptnl_ler_for_per_src_cd        in  varchar2  default hr_api.g_varchar2
  ,p_mnl_dt                         in  date      default hr_api.g_date
  ,p_enrt_perd_id                   in  number    default hr_api.g_number
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_dtctd_dt                       in  date      default hr_api.g_date
  ,p_procd_dt                       in  date      default hr_api.g_date
  ,p_unprocd_dt                     in  date      default hr_api.g_date
  ,p_voidd_dt                       in  date      default hr_api.g_date
  ,p_mnlo_dt                        in  date      default hr_api.g_date
  ,p_ntfn_dt                        in  date      default hr_api.g_date
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_ptnl_ler_for_per >------------------------|
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
--   p_ptnl_ler_for_per_id          Yes  number    PK of record
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
procedure delete_ptnl_ler_for_per
  (p_validate                       in boolean        default false
  ,p_ptnl_ler_for_per_id            in number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date);
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
--   p_ptnl_ler_for_per_id                 Yes  number   PK of record
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
    p_ptnl_ler_for_per_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_ptnl_ler_for_per_api;

 

/
