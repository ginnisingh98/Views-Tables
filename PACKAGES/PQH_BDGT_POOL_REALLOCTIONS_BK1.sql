--------------------------------------------------------
--  DDL for Package PQH_BDGT_POOL_REALLOCTIONS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BDGT_POOL_REALLOCTIONS_BK1" AUTHID CURRENT_USER as
/* $Header: pqbreapi.pkh 120.1 2005/10/02 02:26:09 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_realloc_txn_dtl_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_realloc_txn_dtl_b
  (
   p_transaction_id  in number
  ,p_transaction_type in varchar2
  ,p_entity_id       in number
  ,p_budget_detail_id  in number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_realloc_txn__dtl_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_realloc_txn_dtl_a
  (
   p_txn_detail_id  in number
  ,p_transaction_id in number
  ,p_transaction_type in varchar2
  ,p_entity_id in number
  ,p_budget_detail_id in number
  ,p_object_version_number          in  number
  );
--
end pqh_BDGT_POOL_REALLOCTIONS_bk1;

 

/
