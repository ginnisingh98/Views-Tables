--------------------------------------------------------
--  DDL for Package BEN_PERSON_ACTIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PERSON_ACTIONS_API" AUTHID CURRENT_USER as
/* $Header: beactapi.pkh 120.0 2005/05/28 00:20:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_person_actions >------------------------|
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
--   p_person_id                    Yes  number
--   p_ler_id                       No   number
--   p_benefit_action_id            Yes  number
--   p_action_status_cd             Yes  varchar2
--   p_chunk_number                 No   number
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_person_action_id             Yes  number    PK of record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_person_actions
(
   p_validate                       in boolean    default false
  ,p_person_action_id               out nocopy number
  ,p_person_id                      in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_benefit_action_id              in  number    default null
  ,p_action_status_cd               in  varchar2  default null
  ,p_chunk_number                   in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_person_actions >------------------------|
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
--   p_person_action_id             Yes  number    PK of record
--   p_person_id                    Yes  number
--   p_ler_id                       No   number
--   p_benefit_action_id            Yes  number
--   p_action_status_cd             Yes  varchar2
--   p_chunk_number                 No   number
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
procedure update_person_actions
  (
   p_validate                       in boolean    default false
  ,p_person_action_id               in  number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_benefit_action_id              in  number    default hr_api.g_number
  ,p_action_status_cd               in  varchar2  default hr_api.g_varchar2
  ,p_chunk_number                   in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_person_actions >------------------------|
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
--   p_person_action_id             Yes  number    PK of record
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
procedure delete_person_actions
  (
   p_validate                       in boolean        default false
  ,p_person_action_id               in  number
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
--   p_person_action_id                 Yes  number   PK of record
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
    p_person_action_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_person_actions_api;

 

/
