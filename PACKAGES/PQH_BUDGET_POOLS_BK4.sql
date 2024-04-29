--------------------------------------------------------
--  DDL for Package PQH_BUDGET_POOLS_BK4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGET_POOLS_BK4" AUTHID CURRENT_USER as
/* $Header: pqbplapi.pkh 120.1 2005/10/02 02:25:59 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_reallocation_txn_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_reallocation_txn_b
  (
   p_name                           in varchar2
  ,p_parent_folder_id               in number
  ,p_effective_date                 in date
  ,p_business_group_id              in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_reallocation_txn_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_reallocation_txn_a
  (
   p_transaction_id                 in number
  ,p_name                           in varchar2
  ,p_parent_folder_id               in number
  ,p_effective_date                 in date
  ,p_object_version_number          in number
  ,p_business_group_id              in  number
  );
--
end pqh_budget_pools_bk4;

 

/
