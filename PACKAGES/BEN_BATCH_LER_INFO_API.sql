--------------------------------------------------------
--  DDL for Package BEN_BATCH_LER_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BATCH_LER_INFO_API" AUTHID CURRENT_USER as
/* $Header: bebliapi.pkh 120.0 2005/05/28 00:41:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_batch_ler_info >-------------------------|
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
--   p_benefit_action_id            Yes  number
--   p_person_id                    Yes  number
--   p_ler_id                       Yes  number
--   p_lf_evt_ocrd_dt               Yes  date
--   p_replcd_flag                  Yes  varchar2
--   p_crtd_flag                    Yes  varchar2
--   p_tmprl_flag                   Yes  varchar2
--   p_dltd_flag                    Yes  varchar2
--   p_per_in_ler_id                Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_batch_ler_id                 Yes  number    PK of record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_batch_ler_info
  (p_validate                       in boolean    default false
  ,p_batch_ler_id                   out nocopy number
  ,p_benefit_action_id              in  number    default null
  ,p_person_id                      in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_lf_evt_ocrd_dt                 in  date      default null
  ,p_replcd_flag                    in  varchar2  default 'N'
  ,p_crtd_flag                      in  varchar2  default 'N'
  ,p_tmprl_flag                     in  varchar2  default 'N'
  ,p_dltd_flag                      in  varchar2  default 'N'
  ,p_open_and_clsd_flag             in  varchar2  default 'N'
  ,p_clsd_flag                      in  varchar2  default 'N'
  ,p_not_crtd_flag                  in  varchar2  default 'N'
  ,p_stl_actv_flag                  in  varchar2  default 'N'
  ,p_clpsd_flag                     in  varchar2  default 'N'
  ,p_clsn_flag                      in  varchar2  default 'N'
  ,p_no_effect_flag                 in  varchar2  default 'N'
  ,p_cvrge_rt_prem_flag             in  varchar2  default 'N'
  ,p_per_in_ler_id                  in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date);
-- ----------------------------------------------------------------------------
-- |------------------------< update_batch_ler_info >-------------------------|
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
--   p_batch_ler_id                 Yes  number    PK of record
--   p_benefit_action_id            Yes  number
--   p_person_id                    Yes  number
--   p_ler_id                       Yes  number
--   p_lf_evt_ocrd_dt               Yes  date
--   p_replcd_flag                  Yes  varchar2
--   p_crtd_flag                    Yes  varchar2
--   p_tmprl_flag                   Yes  varchar2
--   p_dltd_flag                    Yes  varchar2
--   p_per_in_ler_id                Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_effective_date          Yes  date       Session Date.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_batch_ler_info
  (p_validate                       in boolean    default false
  ,p_batch_ler_id                   in  number
  ,p_benefit_action_id              in  number    default hr_api.g_number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_lf_evt_ocrd_dt                 in  date      default hr_api.g_date
  ,p_replcd_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_crtd_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_tmprl_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_dltd_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_open_and_clsd_flag             in  varchar2  default hr_api.g_varchar2
  ,p_clsd_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_not_crtd_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_stl_actv_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_clpsd_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_clsn_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_no_effect_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_cvrge_rt_prem_flag             in  varchar2  default hr_api.g_varchar2
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date);
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_batch_ler_info >-------------------------|
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
--   p_batch_ler_id                 Yes  number    PK of record
--   p_effective_date          Yes  date     Session Date.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_batch_ler_info
  (p_validate                       in boolean        default false
  ,p_batch_ler_id                   in  number
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
--   p_batch_ler_id                 Yes  number   PK of record
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
  (p_batch_ler_id                 in number
  ,p_object_version_number        in number);
--
end ben_batch_ler_info_api;

 

/
