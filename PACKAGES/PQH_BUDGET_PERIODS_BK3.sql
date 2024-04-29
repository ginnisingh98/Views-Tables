--------------------------------------------------------
--  DDL for Package PQH_BUDGET_PERIODS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGET_PERIODS_BK3" AUTHID CURRENT_USER as
/* $Header: pqbprapi.pkh 120.1 2005/10/02 02:26:04 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_budget_period_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_budget_period_b
  (
   p_budget_period_id               in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_budget_period_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_budget_period_a
  (
   p_budget_period_id               in  number
  ,p_object_version_number          in  number
  );
--
end pqh_budget_periods_bk3;

 

/
