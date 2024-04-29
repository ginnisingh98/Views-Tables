--------------------------------------------------------
--  DDL for Package PQH_COPY_ENTITY_CONTEXTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_COPY_ENTITY_CONTEXTS_API" AUTHID CURRENT_USER as
/* $Header: pqcecapi.pkh 120.0 2005/05/29 01:38:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_copy_entity_context >------------------------|
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
--   p_application_short_name       No   varchar2
--   p_legislation_code             No   varchar2
--   p_responsibility_key           No   varchar2
--   p_transaction_short_name       No   varchar2
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_context                      Yes  varchar2  PK of record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_copy_entity_context
(
   p_validate                       in boolean    default false
  ,p_context                        in  varchar2
  ,p_application_short_name         in  varchar2  default null
  ,p_legislation_code               in  varchar2  default null
  ,p_responsibility_key             in  varchar2  default null
  ,p_transaction_short_name         in  varchar2  default null
  ,p_object_version_number          out nocopy number
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_copy_entity_context >------------------------|
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
--   p_context                      Yes  varchar2  PK of record
--   p_application_short_name       No   varchar2
--   p_legislation_code             No   varchar2
--   p_responsibility_key           No   varchar2
--   p_transaction_short_name       No   varchar2
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
procedure update_copy_entity_context
  (
   p_validate                       in boolean    default false
  ,p_context                        in  varchar2
  ,p_application_short_name         in  varchar2  default hr_api.g_varchar2
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_responsibility_key             in  varchar2  default hr_api.g_varchar2
  ,p_transaction_short_name         in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_copy_entity_context >------------------------|
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
--   p_context                      Yes  varchar2  PK of record
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
procedure delete_copy_entity_context
  (
   p_validate                       in boolean        default false
  ,p_context                        in  varchar2
  ,p_object_version_number          in number
  );
--

--



end pqh_copy_entity_contexts_api;

 

/
