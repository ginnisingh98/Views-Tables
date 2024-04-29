--------------------------------------------------------
--  DDL for Package PQH_TXN_CAT_DOCUMENTS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TXN_CAT_DOCUMENTS_BK3" AUTHID CURRENT_USER as
/* $Header: pqtcdapi.pkh 120.0 2005/05/29 02:46:11 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_txn_cat_document_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_txn_cat_document_b
  (p_document_id                   in     number
  ,p_transaction_category_id       in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_txn_cat_document_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_txn_cat_document_a
  (p_document_id                   in     number
  ,p_transaction_category_id       in     number
  ,p_object_version_number         in     number
  );
--
end pqh_txn_cat_documents_bk3;

 

/