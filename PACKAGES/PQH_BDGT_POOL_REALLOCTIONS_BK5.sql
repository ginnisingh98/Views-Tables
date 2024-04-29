--------------------------------------------------------
--  DDL for Package PQH_BDGT_POOL_REALLOCTIONS_BK5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BDGT_POOL_REALLOCTIONS_BK5" AUTHID CURRENT_USER as
/* $Header: pqbreapi.pkh 120.1 2005/10/02 02:26:09 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_realloc_txn_period_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_realloc_txn_period_b
  (
   p_txn_detail_id            in  number
  ,p_transaction_type               in  varchar2
  ,p_entity_id                      in  number
  ,p_budget_period_id               in  number
  ,p_start_date                     in  date
  ,p_end_date                       in  date
  ,p_reallocation_amt               in  number
  ,p_reserved_amt                   in  number
  ,p_reallocation_period_id            in  number
  ,p_object_version_number          in  number
 );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_realloc_txn_period_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_realloc_txn_period_a
  (
   p_txn_detail_id            in  number
  ,p_transaction_type               in  varchar2
  ,p_entity_id                      in  number
  ,p_budget_period_id               in  number
  ,p_start_date                     in  date
  ,p_end_date                       in  date
  ,p_reallocation_amt               in  number
  ,p_reserved_amt                   in  number
  ,p_reallocation_period_id            in  number
  ,p_object_version_number          in  number
 );
--
end pqh_BDGT_POOL_REALLOCTIONS_bk5;

 

/
