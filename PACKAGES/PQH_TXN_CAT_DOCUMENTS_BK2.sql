--------------------------------------------------------
--  DDL for Package PQH_TXN_CAT_DOCUMENTS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TXN_CAT_DOCUMENTS_BK2" AUTHID CURRENT_USER as
/* $Header: pqtcdapi.pkh 120.0 2005/05/29 02:46:11 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_txn_cat_document_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_txn_cat_document_b
  (p_effective_date                in     date
  ,p_document_id                   in     number
  ,p_transaction_category_id       in     number
  ,p_type_code                     in     varchar2
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_txn_cat_document_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_txn_cat_document_a
  (p_effective_date                in     date
  ,p_document_id                   in     number
  ,p_transaction_category_id       in     number
  ,p_type_code                     in     varchar2
  ,p_object_version_number         in     number
  );
--
end pqh_txn_cat_documents_bk2;

 

/
