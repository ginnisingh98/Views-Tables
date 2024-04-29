--------------------------------------------------------
--  DDL for Package BEN_BATCH_PROC_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BATCH_PROC_INFO_API" AUTHID CURRENT_USER as
/* $Header: bebpiapi.pkh 120.0 2005/05/28 00:46:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_batch_proc_info >------------------------|
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
--   p_strt_dt                      No   date
--   p_end_dt                       No   date
--   p_strt_tm                      No   varchar2
--   p_end_tm                       No   varchar2
--   p_elpsd_tm                     No   varchar2
--   p_per_slctd                    No   number
--   p_per_proc                     No   number
--   p_per_unproc                   No   number
--   p_per_proc_succ                No   number
--   p_per_err                      No   number
--   p_business_group_id            Yes  number    Business Group of Record
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_batch_proc_id                Yes  number    PK of record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_batch_proc_info
  (p_validate                       in boolean    default false
  ,p_batch_proc_id                  out nocopy number
  ,p_benefit_action_id              in  number    default null
  ,p_strt_dt                        in  date      default null
  ,p_end_dt                         in  date      default null
  ,p_strt_tm                        in  varchar2  default null
  ,p_end_tm                         in  varchar2  default null
  ,p_elpsd_tm                       in  varchar2  default null
  ,p_per_slctd                      in  number    default null
  ,p_per_proc                       in  number    default null
  ,p_per_unproc                     in  number    default null
  ,p_per_proc_succ                  in  number    default null
  ,p_per_err                        in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_object_version_number          out nocopy number);
-- ----------------------------------------------------------------------------
-- |------------------------< update_batch_proc_info >------------------------|
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
--   p_batch_proc_id                Yes  number    PK of record
--   p_benefit_action_id            Yes  number
--   p_strt_dt                      No   date
--   p_end_dt                       No   date
--   p_strt_tm                      No   varchar2
--   p_end_tm                       No   varchar2
--   p_elpsd_tm                     No   varchar2
--   p_per_slctd                    No   number
--   p_per_proc                     No   number
--   p_per_unproc                   No   number
--   p_per_proc_succ                No   number
--   p_per_err                      No   number
--   p_business_group_id            Yes  number    Business Group of Record
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
procedure update_batch_proc_info
  (p_validate                       in boolean    default false
  ,p_batch_proc_id                  in  number
  ,p_benefit_action_id              in  number    default hr_api.g_number
  ,p_strt_dt                        in  date      default hr_api.g_date
  ,p_end_dt                         in  date      default hr_api.g_date
  ,p_strt_tm                        in  varchar2  default hr_api.g_varchar2
  ,p_end_tm                         in  varchar2  default hr_api.g_varchar2
  ,p_elpsd_tm                       in  varchar2  default hr_api.g_varchar2
  ,p_per_slctd                      in  number    default hr_api.g_number
  ,p_per_proc                       in  number    default hr_api.g_number
  ,p_per_unproc                     in  number    default hr_api.g_number
  ,p_per_proc_succ                  in  number    default hr_api.g_number
  ,p_per_err                        in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number);
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_batch_proc_info >------------------------|
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
--   p_batch_proc_id                Yes  number    PK of record
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
procedure delete_batch_proc_info
  (p_validate                       in boolean        default false
  ,p_batch_proc_id                  in  number
  ,p_object_version_number          in out nocopy number);
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
--   p_batch_proc_id                 Yes  number   PK of record
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
  (p_batch_proc_id                in number
  ,p_object_version_number        in number);
--
end ben_batch_proc_info_api;

 

/
