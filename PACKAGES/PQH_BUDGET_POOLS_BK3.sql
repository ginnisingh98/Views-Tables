--------------------------------------------------------
--  DDL for Package PQH_BUDGET_POOLS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGET_POOLS_BK3" AUTHID CURRENT_USER as
/* $Header: pqbplapi.pkh 120.1 2005/10/02 02:25:59 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_reallocation_folder_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_reallocation_folder_b
  (
   p_folder_id                      in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_reallocation_folder_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_reallocation_folder_a
  (
   p_folder_id                      in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_budget_pools_bk3;

 

/
