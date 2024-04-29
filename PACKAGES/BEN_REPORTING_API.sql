--------------------------------------------------------
--  DDL for Package BEN_REPORTING_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_REPORTING_API" AUTHID CURRENT_USER as
/* $Header: bebmnapi.pkh 115.5 2002/12/11 10:34:04 lakrish ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_reporting >------------------------------|
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
--   p_thread_id                    Yes  number
--   p_sequence                     Yes  number
--   p_text                         No   varchar2
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_reporting_id                 Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_reporting
  (p_validate                       in boolean    default false
  ,p_reporting_id                   out nocopy number
  ,p_benefit_action_id              in  number    default null
  ,p_thread_id                      in  number    default null
  ,p_sequence                       in  number    default null
  ,p_text                           in  varchar2  default null
  ,p_rep_typ_cd                     in  varchar2  default null
  ,p_error_message_code             in  varchar2  default null
  ,p_national_identifier            in  varchar2  default null
  ,p_related_person_ler_id          in  number    default null
  ,p_temporal_ler_id                in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_person_id                      in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_related_person_id              in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_pl_typ_id                      in  number    default null
  ,p_actl_prem_id                   in  number    default null
  ,p_val                            in  number    default null
  ,p_mo_num                         in  number    default null
  ,p_yr_num                         in  number    default null
  ,p_object_version_number          out nocopy number);
-- ----------------------------------------------------------------------------
-- |------------------------< update_reporting >------------------------------|
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
--   p_reporting_id                 Yes  number    PK of record
--   p_benefit_action_id            Yes  number
--   p_thread_id                    Yes  number
--   p_sequence                     Yes  number
--   p_text                         No   varchar2
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
procedure update_reporting
  (p_validate                       in boolean    default false
  ,p_reporting_id                   in  number
  ,p_benefit_action_id              in  number    default hr_api.g_number
  ,p_thread_id                      in  number    default hr_api.g_number
  ,p_sequence                       in  number    default hr_api.g_number
  ,p_text                           in  varchar2  default hr_api.g_varchar2
  ,p_rep_typ_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_error_message_code             in  varchar2  default hr_api.g_varchar2
  ,p_national_identifier            in  varchar2  default hr_api.g_varchar2
  ,p_related_person_ler_id          in  number    default hr_api.g_number
  ,p_temporal_ler_id                in  number    default hr_api.g_number
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_related_person_id              in  number    default hr_api.g_number
  ,p_oipl_id                        in  number    default hr_api.g_number
  ,p_pl_typ_id                      in  number    default hr_api.g_number
  ,p_actl_prem_id                   in  number    default hr_api.g_number
  ,p_val                            in  number    default hr_api.g_number
  ,p_mo_num                         in  number    default hr_api.g_number
  ,p_yr_num                         in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number);
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_reporting >------------------------------|
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
--   p_reporting_id                 Yes  number    PK of record
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
procedure delete_reporting
  (p_validate                       in boolean        default false
  ,p_reporting_id                   in  number
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
--   p_reporting_id                 Yes  number   PK of record
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
  (p_reporting_id                 in number
  ,p_object_version_number        in number);
--
end ben_reporting_api;

 

/
