--------------------------------------------------------
--  DDL for Package PQH_TXN_CAT_DOCUMENTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TXN_CAT_DOCUMENTS_API" AUTHID CURRENT_USER as
/* $Header: pqtcdapi.pkh 120.0 2005/05/29 02:46:11 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_txn_cat_document >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_txn_cat_document
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_document_id                   in     number
  ,p_transaction_category_id       in     number
  ,p_type_code                     in     varchar2
  ,p_object_version_number            out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_txn_cat_document >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_txn_cat_document
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_document_id                   in     number
  ,p_transaction_category_id       in     number
  ,p_type_code                     in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_txn_cat_document >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_txn_cat_document
  (p_validate                      in     boolean  default false
  ,p_document_id                   in     number
  ,p_transaction_category_id       in     number
  ,p_object_version_number         in     number
  );
--
end pqh_txn_cat_documents_api ;

 

/
