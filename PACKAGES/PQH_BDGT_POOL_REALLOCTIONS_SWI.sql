--------------------------------------------------------
--  DDL for Package PQH_BDGT_POOL_REALLOCTIONS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BDGT_POOL_REALLOCTIONS_SWI" AUTHID CURRENT_USER As
/* $Header: pqbreswi.pkh 115.0 2003/02/06 15:20:03 kgowripe noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< create_realloc_txn_dtl >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_bdgt_pool_realloctions_api.create_realloc_txn_dtl
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
PROCEDURE create_realloc_txn_dtl
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_transaction_id               in     number
  ,p_transaction_type             in     varchar2
  ,p_entity_id                    in     number    default null
  ,p_budget_detail_id             in     number    default null
  ,p_txn_detail_id                   out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< create_realloc_txn_period >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_bdgt_pool_realloctions_api.create_realloc_txn_period
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
PROCEDURE create_realloc_txn_period
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_txn_detail_id                in     number
  ,p_transaction_type             in     varchar2
  ,p_entity_id                    in     number    default null
  ,p_budget_period_id             in     number    default null
  ,p_start_date                   in     date      default null
  ,p_end_date                     in     date      default null
  ,p_reallocation_amt             in     number
  ,p_reserved_amt                 in     number    default null
  ,p_reallocation_period_id          out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< delete_realloc_txn_dtl >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_bdgt_pool_realloctions_api.delete_realloc_txn_dtl
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
PROCEDURE delete_realloc_txn_dtl
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_txn_detail_id                in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_realloc_txn_period >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_bdgt_pool_realloctions_api.delete_realloc_txn_period
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
PROCEDURE delete_realloc_txn_period
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_reallocation_period_id       in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_realloc_txn_dtl >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_bdgt_pool_realloctions_api.update_realloc_txn_dtl
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
PROCEDURE update_realloc_txn_dtl
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_transaction_id               in     number    default hr_api.g_number
  ,p_transaction_type             in     varchar2  default hr_api.g_varchar2
  ,p_entity_id                    in     number    default hr_api.g_number
  ,p_budget_detail_id             in     number    default hr_api.g_number
  ,p_txn_detail_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< update_realloc_txn_period >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_bdgt_pool_realloctions_api.update_realloc_txn_period
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
PROCEDURE update_realloc_txn_period
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_txn_detail_id                in     number    default hr_api.g_number
  ,p_transaction_type             in     varchar2  default hr_api.g_varchar2
  ,p_entity_id                    in     number    default hr_api.g_number
  ,p_budget_period_id             in     number    default hr_api.g_number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_reallocation_amt             in     number    default hr_api.g_number
  ,p_reserved_amt                 in     number    default hr_api.g_number
  ,p_reallocation_period_id       in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
end pqh_bdgt_pool_realloctions_swi;

 

/
