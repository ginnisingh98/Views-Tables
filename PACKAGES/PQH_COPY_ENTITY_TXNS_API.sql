--------------------------------------------------------
--  DDL for Package PQH_COPY_ENTITY_TXNS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_COPY_ENTITY_TXNS_API" AUTHID CURRENT_USER as
/* $Header: pqcetapi.pkh 120.0 2005/05/29 01:41:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_COPY_ENTITY_TXN >------------------------|
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
--   p_transaction_category_id      Yes  number
--   p_txn_category_attribute_id    Yes  number    Descriptive Flexfield
--   p_context_business_group_id    No   number
--   p_datetrack_mode               No   varchar2
--   p_context                      No   varchar2
--   action_date                    No  date      default null
--   src_effective_date             No  date      default null
--   p_number_of_copies             No   number
--   p_display_name                 No   varchar2
--   p_replacement_type_cd          No   varchar2
--   p_start_with                   No   varchar2
--   p_increment_by                 No   number
--   p_status                       No   varchar2
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_copy_entity_txn_id           Yes  number    PK of record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_COPY_ENTITY_TXN
(
   p_validate                       in boolean    default false
  ,p_copy_entity_txn_id             out nocopy number
  ,p_transaction_category_id        in  number    default null
  ,p_txn_category_attribute_id      in  number    default null
  ,p_context_business_group_id      in  number    default null
  ,p_datetrack_mode                 in  varchar2    default null
  ,p_context                        in  varchar2  default null
  ,p_action_date                    in  date      default null
  ,p_src_effective_date             in  date      default null
  ,p_number_of_copies               in  number    default null
  ,p_display_name                   in  varchar2  default null
  ,p_replacement_type_cd            in  varchar2  default null
  ,p_start_with                     in  varchar2    default null
  ,p_increment_by                   in  number    default null
  ,p_status                         in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_COPY_ENTITY_TXN >------------------------|
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
--   p_copy_entity_txn_id           Yes  number    PK of record
--   p_transaction_category_id      Yes  number
--   p_txn_category_attribute_id    Yes  number    Descriptive Flexfield
--   p_context_business_group_id    No   number
--   p_datetrack_mode               No   varchar2
--   p_context                      Yes  varchar2
--   action_date                    in  date      default null
--   src_effective_date             in  date      default null
--   p_number_of_copies             No   number
--   p_display_name                 No   varchar2
--   p_replacement_type_cd          No   varchar2
--   p_start_with                   No   varchar2
--   p_increment_by                 No   number
--   p_status                       No   varchar2
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
procedure update_COPY_ENTITY_TXN
  (
   p_validate                       in boolean    default false
  ,p_copy_entity_txn_id             in  number
  ,p_transaction_category_id        in  number    default hr_api.g_number
  ,p_txn_category_attribute_id      in  number    default hr_api.g_number
  ,p_context_business_group_id      in  number    default hr_api.g_number
  ,p_datetrack_mode                 in  varchar2    default hr_api.g_varchar2
  ,p_context                        in  varchar2  default hr_api.g_varchar2
  ,p_action_date                    in  date      default hr_api.g_date
  ,p_src_effective_date             in  date      default hr_api.g_date
  ,p_number_of_copies               in  number    default hr_api.g_number
  ,p_display_name                   in  varchar2  default hr_api.g_varchar2
  ,p_replacement_type_cd            in  varchar2  default hr_api.g_varchar2
  ,p_start_with                     in  varchar2    default hr_api.g_varchar2
  ,p_increment_by                   in  number    default hr_api.g_number
  ,p_status                         in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_COPY_ENTITY_TXN >------------------------|
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
--   p_copy_entity_txn_id           Yes  number    PK of record
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
procedure delete_COPY_ENTITY_TXN
  (
   p_validate                       in boolean        default false
  ,p_copy_entity_txn_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date            in date
  );
--
end PQH_COPY_ENTITY_TXNS_api;

 

/
