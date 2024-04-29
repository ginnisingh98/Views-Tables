--------------------------------------------------------
--  DDL for Package PQH_DFLT_BUDGET_ELEMENTS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DFLT_BUDGET_ELEMENTS_BK3" AUTHID CURRENT_USER as
/* $Header: pqdelapi.pkh 120.1 2005/10/02 02:26:38 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_dflt_budget_element_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_dflt_budget_element_b
  (
   p_dflt_budget_element_id         in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_dflt_budget_element_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_dflt_budget_element_a
  (
   p_dflt_budget_element_id         in  number
  ,p_object_version_number          in  number
  );
--
end pqh_dflt_budget_elements_bk3;

 

/
