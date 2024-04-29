--------------------------------------------------------
--  DDL for Package PQH_TXN_CAT_DOCUMENTS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TXN_CAT_DOCUMENTS_SWI" AUTHID CURRENT_USER As
/* $Header: pqtcdswi.pkh 115.0 2003/05/11 12:45:27 svorugan noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< create_txn_cat_document >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_txn_cat_documents_api.create_txn_cat_document
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
PROCEDURE create_txn_cat_document
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_document_id                  in     number
  ,p_transaction_category_id      in     number
  ,p_type_code                    in     varchar2
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< delete_txn_cat_document >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_txn_cat_documents_api.delete_txn_cat_document
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
PROCEDURE delete_txn_cat_document
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_document_id                  in     number
  ,p_transaction_category_id      in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );

PROCEDURE delete_group
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_transaction_category_id      in     number
  ,p_object_version_number        in     number
  ,p_effective_date               in     date      default sysdate
  ,p_return_status                   out nocopy varchar2
  );


-- ----------------------------------------------------------------------------
-- |------------------------< update_txn_cat_document >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_txn_cat_documents_api.update_txn_cat_document
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
PROCEDURE update_txn_cat_document
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_document_id                  in     number
  ,p_transaction_category_id      in     number
  ,p_type_code                    in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );

end pqh_txn_cat_documents_swi;

 

/
