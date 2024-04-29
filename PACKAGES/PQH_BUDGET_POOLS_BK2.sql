--------------------------------------------------------
--  DDL for Package PQH_BUDGET_POOLS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGET_POOLS_BK2" AUTHID CURRENT_USER as
/* $Header: pqbplapi.pkh 120.1 2005/10/02 02:25:59 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_reallocation_folder_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_reallocation_folder_b
  (
   p_folder_id                      in  number
  ,p_name                           in  varchar2
  ,p_budget_version_id              in  number
  ,p_budget_unit_id                 in  number
  ,p_entity_type                    in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_business_group_id              in  number
  ,p_approval_status                in  varchar2
  ,p_wf_transaction_category_id     in number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_reallocation_folder_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_reallocation_folder_a
  (
   p_folder_id                      in  number
  ,p_name                           in  varchar2
  ,p_budget_version_id              in  number
  ,p_budget_unit_id                 in  number
  ,p_entity_type                    in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_business_group_id              in  number
  ,p_approval_status                in  varchar2
  ,p_wf_transaction_category_id     in number
  );

end pqh_budget_pools_bk2;

 

/
