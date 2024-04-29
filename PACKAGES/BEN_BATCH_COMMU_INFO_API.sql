--------------------------------------------------------
--  DDL for Package BEN_BATCH_COMMU_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BATCH_COMMU_INFO_API" AUTHID CURRENT_USER as
/* $Header: bebmiapi.pkh 120.0 2005/05/28 00:43:00 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_batch_commu_info >------------------------|
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
--   p_per_cm_id                    Yes  number
--   p_cm_typ_id                    Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_per_cm_prvdd_id              No   number
--   p_to_be_sent_dt                No   date
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_batch_commu_id               Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_batch_commu_info
(
   p_validate                       in boolean    default false
  ,p_batch_commu_id                 out nocopy number
  ,p_benefit_action_id              in  number    default null
  ,p_person_id                      in  number    default null
  ,p_per_cm_id                      in  number    default null
  ,p_cm_typ_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_per_cm_prvdd_id                in  number    default null
  ,p_to_be_sent_dt                  in  date      default null
  ,p_object_version_number          out nocopy number
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_batch_commu_info >------------------------|
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
--   p_batch_commu_id               Yes  number    PK of record
--   p_benefit_action_id            Yes  number
--   p_person_id                    Yes  number
--   p_per_cm_id                    Yes  number
--   p_cm_typ_id                    Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_per_cm_prvdd_id              No   number
--   p_to_be_sent_dt                No   date
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
procedure update_batch_commu_info
  (
   p_validate                       in boolean    default false
  ,p_batch_commu_id                 in  number
  ,p_benefit_action_id              in  number    default hr_api.g_number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_per_cm_id                      in  number    default hr_api.g_number
  ,p_cm_typ_id                      in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_per_cm_prvdd_id                in  number    default hr_api.g_number
  ,p_to_be_sent_dt                  in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_batch_commu_info >------------------------|
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
--   p_batch_commu_id               Yes  number    PK of record
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
procedure delete_batch_commu_info
  (
   p_validate                       in boolean        default false
  ,p_batch_commu_id                 in  number
  ,p_object_version_number          in out nocopy number
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
--   p_batch_commu_id                 Yes  number   PK of record
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
    p_batch_commu_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_batch_commu_info_api;

 

/
