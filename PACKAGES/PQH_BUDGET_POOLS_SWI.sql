--------------------------------------------------------
--  DDL for Package PQH_BUDGET_POOLS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGET_POOLS_SWI" AUTHID CURRENT_USER As
/* $Header: pqbplswi.pkh 115.1 2003/03/03 12:16:03 ggnanagu noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------< create_reallocation_folder >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_budget_pools_api.create_reallocation_folder
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
PROCEDURE create_reallocation_folder
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_folder_id                       out nocopy number
  ,p_name                         in     varchar2
  ,p_budget_version_id            in     number
  ,p_budget_unit_id               in     number
  ,p_entity_type                  in     varchar2
  ,p_approval_status              in     varchar2
  ,p_object_version_number           out nocopy number
  ,p_business_group_id            in     number
  ,p_wf_transaction_category_id    in number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< create_reallocation_txn >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_budget_pools_api.create_reallocation_txn
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
PROCEDURE create_reallocation_txn
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_transaction_id                  out nocopy number
  ,p_name                         in     varchar2
  ,p_parent_folder_id               in     number
  ,p_object_version_number           out nocopy number
  ,p_business_group_id            in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< delete_reallocation_folder >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_budget_pools_api.delete_reallocation_folder
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
PROCEDURE delete_reallocation_folder
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_folder_id                    in     number
  ,p_object_version_number        in     number
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< delete_reallocation_txn >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_budget_pools_api.delete_reallocation_txn
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
PROCEDURE delete_reallocation_txn
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_transaction_id               in     number
  ,p_object_version_number        in     number
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< update_reallocation_folder >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_budget_pools_api.update_reallocation_folder
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
PROCEDURE update_reallocation_folder
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_folder_id                    in     number
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_budget_version_id            in     number    default hr_api.g_number
  ,p_budget_unit_id               in     number    default hr_api.g_number
  ,p_entity_type                  in     varchar2  default hr_api.g_varchar2
  ,p_approval_status              in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number
  ,p_wf_transaction_category_id   in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_reallocation_txn >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_budget_pools_api.update_reallocation_txn
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
PROCEDURE update_reallocation_txn
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_transaction_id               in     number
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_parent_folder_id               in     number    default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< bgt_realloc_delete >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure deletes data for a given node_type and node_id
--
-- Pre-requisites
--
--
-- Post Success:
--
--
-- Post Failure:
--
--
-- Access Status:
--
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE bgt_realloc_delete(p_node_type  in varchar2, p_node_id in number);
end pqh_budget_pools_swi;

 

/
