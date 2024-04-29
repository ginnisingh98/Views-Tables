--------------------------------------------------------
--  DDL for Package PQH_BUDGET_ELEMENTS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGET_ELEMENTS_BK2" AUTHID CURRENT_USER as
/* $Header: pqbelapi.pkh 120.1 2005/10/02 02:25:41 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_budget_element_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_budget_element_b
  (
   p_budget_element_id              in  number
  ,p_budget_set_id                  in  number
  ,p_element_type_id                in  number
  ,p_distribution_percentage        in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_budget_element_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_budget_element_a
  (
   p_budget_element_id              in  number
  ,p_budget_set_id                  in  number
  ,p_element_type_id                in  number
  ,p_distribution_percentage        in  number
  ,p_object_version_number          in  number
  );
--
end pqh_budget_elements_bk2;

 

/
