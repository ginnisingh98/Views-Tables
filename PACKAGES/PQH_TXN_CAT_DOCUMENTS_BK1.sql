--------------------------------------------------------
--  DDL for Package PQH_TXN_CAT_DOCUMENTS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TXN_CAT_DOCUMENTS_BK1" AUTHID CURRENT_USER as
/* $Header: pqtcdapi.pkh 120.0 2005/05/29 02:46:11 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_txn_cat_document_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_txn_cat_document_b
  (p_effective_date                in     date
  ,p_document_id                   in     number
  ,p_transaction_category_id       in     number
  ,p_type_code                     in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_txn_cat_document_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_txn_cat_document_a
  (p_effective_date                in     date
  ,p_document_id                   in     number
  ,p_transaction_category_id       in     number
  ,p_type_code                     in     varchar2
  ,p_object_version_number         in     number
  );
--
end pqh_txn_cat_documents_bk1;

 

/
