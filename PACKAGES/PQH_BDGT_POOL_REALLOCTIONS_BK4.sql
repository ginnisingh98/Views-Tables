--------------------------------------------------------
--  DDL for Package PQH_BDGT_POOL_REALLOCTIONS_BK4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BDGT_POOL_REALLOCTIONS_BK4" AUTHID CURRENT_USER as
/* $Header: pqbreapi.pkh 120.1 2005/10/02 02:26:09 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_realloc_txn_period_b >----------|
-- ----------------------------------------------------------------------------
--
procedure create_realloc_txn_period_b
  (
   p_txn_detail_id            in  number
  ,p_transaction_type               in  varchar2
  ,p_entity_id                      in  number
  ,p_budget_period_id               in  number
  ,p_start_date                     in  date
  ,p_end_date                       in  date
  ,p_reallocation_amt               in  number
  ,p_reserved_amt                   in  number
 );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_realloc_txn_period_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_realloc_txn_period_a
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
end pqh_BDGT_POOL_REALLOCTIONS_bk4;

 

/
