--------------------------------------------------------
--  DDL for Package PQH_TRANSACTION_TEMPLATES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TRANSACTION_TEMPLATES_API" AUTHID CURRENT_USER as
/* $Header: pqttmapi.pkh 120.0 2005/05/29 02:51:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_transaction_template >------------------------|
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
--   p_enable_flag                  No   varchar2
--   p_template_id                  Yes  number
--   p_transaction_id               No   number
--   p_transaction_category_id      Yes  number
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_transaction_template_id      Yes  number    PK of record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_transaction_template
(
   p_validate                       in boolean    default false
  ,p_transaction_template_id        out nocopy number
  ,p_enable_flag                    in  varchar2  default null
  ,p_template_id                    in  number    default null
  ,p_transaction_id                 in  number    default null
  ,p_transaction_category_id        in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_transaction_template >------------------------|
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
--   p_transaction_template_id      Yes  number    PK of record
--   p_enable_flag                  No   varchar2
--   p_template_id                  Yes  number
--   p_transaction_id               No   number
--   p_transaction_category_id      Yes  number
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
procedure update_transaction_template
  (
   p_validate                       in boolean    default false
  ,p_transaction_template_id        in  number
  ,p_enable_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_template_id                    in  number    default hr_api.g_number
  ,p_transaction_id                 in  number    default hr_api.g_number
  ,p_transaction_category_id        in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_transaction_template >------------------------|
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
--   p_transaction_template_id      Yes  number    PK of record
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
procedure delete_transaction_template
  (
   p_validate                       in boolean        default false
  ,p_transaction_template_id        in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in date
  );
--
end pqh_transaction_templates_api;

 

/
