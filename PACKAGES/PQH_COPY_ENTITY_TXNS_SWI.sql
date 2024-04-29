--------------------------------------------------------
--  DDL for Package PQH_COPY_ENTITY_TXNS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_COPY_ENTITY_TXNS_SWI" AUTHID CURRENT_USER As
/* $Header: pqcetswi.pkh 115.0 2003/07/29 22:54 rpasapul noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< create_copy_entity_txn >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_copy_entity_txns_api.create_copy_entity_txn
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE create_copy_entity_txn
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_copy_entity_txn_id              out nocopy number
  ,p_transaction_category_id      in     number    default null
  ,p_txn_category_attribute_id    in     number    default null
  ,p_context_business_group_id    in     number    default null
  ,p_datetrack_mode               in     varchar2  default null
  ,p_context                      in     varchar2  default null
  ,p_action_date                  in     date      default null
  ,p_src_effective_date           in     date      default null
  ,p_number_of_copies             in     number    default null
  ,p_display_name                 in     varchar2  default null
  ,p_replacement_type_cd          in     varchar2  default null
  ,p_start_with                   in     varchar2  default null
  ,p_increment_by                 in     number    default null
  ,p_status                       in     varchar2  default null
  ,p_object_version_number           out nocopy number
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< delete_copy_entity_txn >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_copy_entity_txns_api.delete_copy_entity_txn
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE delete_copy_entity_txn
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_copy_entity_txn_id           in     number
  ,p_object_version_number        in     number
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_copy_entity_txn >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_copy_entity_txns_api.update_copy_entity_txn
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE update_copy_entity_txn
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_copy_entity_txn_id           in     number
  ,p_transaction_category_id      in     number    default hr_api.g_number
  ,p_txn_category_attribute_id    in     number    default hr_api.g_number
  ,p_context_business_group_id    in     number    default hr_api.g_number
  ,p_datetrack_mode               in     varchar2  default hr_api.g_varchar2
  ,p_context                      in     varchar2  default hr_api.g_varchar2
  ,p_action_date                  in     date      default hr_api.g_date
  ,p_src_effective_date           in     date      default hr_api.g_date
  ,p_number_of_copies             in     number    default hr_api.g_number
  ,p_display_name                 in     varchar2  default hr_api.g_varchar2
  ,p_replacement_type_cd          in     varchar2  default hr_api.g_varchar2
  ,p_start_with                   in     varchar2  default hr_api.g_varchar2
  ,p_increment_by                 in     number    default hr_api.g_number
  ,p_status                       in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  );
end pqh_copy_entity_txns_swi;

 

/
