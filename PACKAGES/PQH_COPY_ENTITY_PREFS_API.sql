--------------------------------------------------------
--  DDL for Package PQH_COPY_ENTITY_PREFS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_COPY_ENTITY_PREFS_API" AUTHID CURRENT_USER as
/* $Header: pqcepapi.pkh 120.0 2005/05/29 01:40:32 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_copy_entity_pref >------------------------|
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
--   p_table_route_id               Yes  number
--   p_copy_entity_txn_id           Yes  number
--   p_select_flag                  No   varchar2
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_copy_entity_pref_id          Yes  number    PK of record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_copy_entity_pref
(
   p_validate                       in boolean    default false
  ,p_copy_entity_pref_id            out nocopy number
  ,p_table_route_id                 in  number    default null
  ,p_copy_entity_txn_id             in  number    default null
  ,p_select_flag                    in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_copy_entity_pref >------------------------|
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
--   p_copy_entity_pref_id          Yes  number    PK of record
--   p_table_route_id               Yes  number
--   p_copy_entity_txn_id           Yes  number
--   p_select_flag                  No   varchar2
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
procedure update_copy_entity_pref
  (
   p_validate                       in boolean    default false
  ,p_copy_entity_pref_id            in  number
  ,p_table_route_id                 in  number    default hr_api.g_number
  ,p_copy_entity_txn_id             in  number    default hr_api.g_number
  ,p_select_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_copy_entity_pref >------------------------|
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
--   p_copy_entity_pref_id          Yes  number    PK of record
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
procedure delete_copy_entity_pref
  (
   p_validate                       in boolean        default false
  ,p_copy_entity_pref_id            in  number
  ,p_object_version_number          in  number
  ,p_effective_date            in date
  );
--
end pqh_copy_entity_prefs_api;

 

/
