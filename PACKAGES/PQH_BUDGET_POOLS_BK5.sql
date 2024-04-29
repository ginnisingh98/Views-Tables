--------------------------------------------------------
--  DDL for Package PQH_BUDGET_POOLS_BK5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGET_POOLS_BK5" AUTHID CURRENT_USER as
/* $Header: pqbplapi.pkh 120.1 2005/10/02 02:25:59 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_reallocation_txn_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_reallocation_txn_b
  (
   p_transaction_id                 in number
  ,p_name                           in varchar2
  ,p_parent_folder_id               in number
  ,p_effective_date                 in date
  ,p_object_version_number          in number
  ,p_business_group_id              in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_reallocation_txn_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_reallocation_txn_a
  (
   p_transaction_id                 in number
  ,p_name                           in varchar2
  ,p_parent_folder_id               in number
  ,p_effective_date                 in date
  ,p_object_version_number          in number
  ,p_business_group_id              in  number
  );
--

end pqh_budget_pools_bk5;

 

/
