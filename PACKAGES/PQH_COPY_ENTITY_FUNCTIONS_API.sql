--------------------------------------------------------
--  DDL for Package PQH_COPY_ENTITY_FUNCTIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_COPY_ENTITY_FUNCTIONS_API" AUTHID CURRENT_USER as
/* $Header: pqcefapi.pkh 120.0 2005/05/29 01:39:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_copy_entity_function >------------------------|
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
--   p_function_type_cd             No   varchar2
--   p_pre_copy_function_name       No   varchar2
--   p_copy_function_name           No   varchar2
--   p_post_copy_function_name      No   varchar2
--   p_context                      Yes  varchar2
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_copy_entity_function_id      Yes  number    PK of record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_copy_entity_function
(
   p_validate                       in boolean    default false
  ,p_copy_entity_function_id        out nocopy number
  ,p_table_route_id                 in  number    default null
  ,p_function_type_cd               in  varchar2  default null
  ,p_pre_copy_function_name         in  varchar2  default null
  ,p_copy_function_name             in  varchar2  default null
  ,p_post_copy_function_name        in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_context                        in  varchar2  default null
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_copy_entity_function >------------------------|
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
--   p_copy_entity_function_id      Yes  number    PK of record
--   p_table_route_id               Yes  number
--   p_function_type_cd             No   varchar2
--   p_pre_copy_function_name       No   varchar2
--   p_copy_function_name           No   varchar2
--   p_post_copy_function_name      No   varchar2
--   p_context                      Yes  varchar2
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
procedure update_copy_entity_function
  (
   p_validate                       in boolean    default false
  ,p_copy_entity_function_id        in  number
  ,p_table_route_id                 in  number    default hr_api.g_number
  ,p_function_type_cd               in  varchar2  default hr_api.g_varchar2
  ,p_pre_copy_function_name         in  varchar2  default hr_api.g_varchar2
  ,p_copy_function_name             in  varchar2  default hr_api.g_varchar2
  ,p_post_copy_function_name        in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_context                        in  varchar2  default hr_api.g_varchar2
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_copy_entity_function >------------------------|
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
--   p_copy_entity_function_id      Yes  number    PK of record
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
procedure delete_copy_entity_function
  (
   p_validate                       in boolean        default false
  ,p_copy_entity_function_id        in  number
  ,p_object_version_number          in number
  ,p_effective_date            in date
  );
--

--



end pqh_copy_entity_functions_api;

 

/
