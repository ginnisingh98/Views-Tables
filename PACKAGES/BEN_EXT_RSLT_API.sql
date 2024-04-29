--------------------------------------------------------
--  DDL for Package BEN_EXT_RSLT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_RSLT_API" AUTHID CURRENT_USER as
/* $Header: bexrsapi.pkh 120.1 2005/06/08 14:27:02 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_EXT_RSLT >------------------------|
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
--   p_run_strt_dt                  No   date
--   p_run_end_dt                   No   date
--   p_ext_stat_cd                  No   varchar2
--   p_tot_rec_num                  No   number
--   p_tot_per_num                  No   number
--   p_tot_err_num                  No   number
--   p_eff_dt                       No   date
--   p_ext_strt_dt                  No   date
--   p_ext_end_dt                   No   date
--   p_output_name                  No   varchar2
--   p_drctry_name                  No   varchar2
--   p_ext_dfn_id                   Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_program_application_id       No   number
--   p_program_id                   No   number
--   p_program_update_date          No   date
--   p_request_id                   No   number
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_ext_rslt_id                  Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_EXT_RSLT
(
   p_validate                       in boolean    default false
  ,p_ext_rslt_id                    out nocopy number
  ,p_run_strt_dt                    in  date      default null
  ,p_run_end_dt                     in  date      default null
  ,p_ext_stat_cd                    in  varchar2  default null
  ,p_tot_rec_num                    in  number    default null
  ,p_tot_per_num                    in  number    default null
  ,p_tot_err_num                    in  number    default null
  ,p_eff_dt                         in  date      default null
  ,p_ext_strt_dt                    in  date      default null
  ,p_ext_end_dt                     in  date      default null
  ,p_output_name                    in  varchar2  default null
  ,p_drctry_name                    in  varchar2  default null
  ,p_ext_dfn_id                     in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_request_id                     in  number    default null
  ,p_output_type                    in  varchar2  default null
  ,p_xdo_template_id                in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_EXT_RSLT >------------------------|
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
--   p_ext_rslt_id                  Yes  number    PK of record
--   p_run_strt_dt                  No   date
--   p_run_end_dt                   No   date
--   p_ext_stat_cd                  No   varchar2
--   p_tot_rec_num                  No   number
--   p_tot_per_num                  No   number
--   p_tot_err_num                  No   number
--   p_eff_dt                       No   date
--   p_ext_strt_dt                  No   date
--   p_ext_end_dt                   No   date
--   p_output_name                  No   varchar2
--   p_drctry_name                  No   varchar2
--   p_ext_dfn_id                   Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_program_application_id       No   number
--   p_program_id                   No   number
--   p_program_update_date          No   date
--   p_request_id                   No   number
--  ,p_output_type                    in  varchar2  default null
--  ,p_xdo_template_id                in  number    default null
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
procedure update_EXT_RSLT
  (
   p_validate                       in boolean    default false
  ,p_ext_rslt_id                    in  number
  ,p_run_strt_dt                    in  date      default hr_api.g_date
  ,p_run_end_dt                     in  date      default hr_api.g_date
  ,p_ext_stat_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_tot_rec_num                    in  number    default hr_api.g_number
  ,p_tot_per_num                    in  number    default hr_api.g_number
  ,p_tot_err_num                    in  number    default hr_api.g_number
  ,p_eff_dt                         in  date      default hr_api.g_date
  ,p_ext_strt_dt                    in  date      default hr_api.g_date
  ,p_ext_end_dt                     in  date      default hr_api.g_date
  ,p_output_name                    in  varchar2  default hr_api.g_varchar2
  ,p_drctry_name                    in  varchar2  default hr_api.g_varchar2
  ,p_ext_dfn_id                     in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_output_type                    in  varchar2  default hr_api.g_varchar2
  ,p_xdo_template_id                in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_EXT_RSLT >------------------------|
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
--   p_ext_rslt_id                  Yes  number    PK of record
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
procedure delete_EXT_RSLT
  (
   p_validate                       in boolean        default false
  ,p_ext_rslt_id                    in  number
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
--   p_ext_rslt_id                 Yes  number   PK of record
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
    p_ext_rslt_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_EXT_RSLT_api;

 

/
