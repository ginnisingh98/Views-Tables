--------------------------------------------------------
--  DDL for Package PQH_BUDGET_SETS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGET_SETS_BK3" AUTHID CURRENT_USER as
/* $Header: pqbstapi.pkh 120.1 2005/10/02 02:26:16 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_budget_set_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_budget_set_b
  (
   p_budget_set_id                  in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_budget_set_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_budget_set_a
  (
   p_budget_set_id                  in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_budget_sets_bk3;

 

/
