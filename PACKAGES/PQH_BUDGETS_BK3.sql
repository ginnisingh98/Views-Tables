--------------------------------------------------------
--  DDL for Package PQH_BUDGETS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGETS_BK3" AUTHID CURRENT_USER as
/* $Header: pqbgtapi.pkh 120.2 2006/06/05 19:09:59 nsanghal noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_budget_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_budget_b
  (
   p_budget_id                      in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_budget_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_budget_a
  (
   p_budget_id                      in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_budgets_bk3;

 

/
