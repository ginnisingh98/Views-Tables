--------------------------------------------------------
--  DDL for Package PQH_BUDGET_POOLS_BK6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGET_POOLS_BK6" AUTHID CURRENT_USER as
/* $Header: pqbplapi.pkh 120.1 2005/10/02 02:25:59 aroussel $ */
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_reallocation_txn_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_reallocation_txn_b
  (
   p_transaction_id                 in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_reallocation_txn_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_reallocation_txn_a
  (
   p_transaction_id                      in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_budget_pools_bk6;

 

/
