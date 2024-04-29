--------------------------------------------------------
--  DDL for Package PQH_DFLT_BUDGET_ELEMENTS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DFLT_BUDGET_ELEMENTS_BK2" AUTHID CURRENT_USER as
/* $Header: pqdelapi.pkh 120.1 2005/10/02 02:26:38 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_dflt_budget_element_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_dflt_budget_element_b
  (
   p_dflt_budget_element_id         in  number
  ,p_dflt_budget_set_id             in  number
  ,p_element_type_id                in  number
  ,p_dflt_dist_percentage           in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_dflt_budget_element_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_dflt_budget_element_a
  (
   p_dflt_budget_element_id         in  number
  ,p_dflt_budget_set_id             in  number
  ,p_element_type_id                in  number
  ,p_dflt_dist_percentage           in  number
  ,p_object_version_number          in  number
  );
--
end pqh_dflt_budget_elements_bk2;

 

/
