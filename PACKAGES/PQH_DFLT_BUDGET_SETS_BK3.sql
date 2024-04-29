--------------------------------------------------------
--  DDL for Package PQH_DFLT_BUDGET_SETS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DFLT_BUDGET_SETS_BK3" AUTHID CURRENT_USER as
/* $Header: pqdstapi.pkh 120.1 2005/10/02 02:26:48 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_dflt_budget_set_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_dflt_budget_set_b
  (
   p_dflt_budget_set_id             in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_dflt_budget_set_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_dflt_budget_set_a
  (
   p_dflt_budget_set_id             in  number
  ,p_object_version_number          in  number
  );
--
end pqh_dflt_budget_sets_bk3;

 

/
